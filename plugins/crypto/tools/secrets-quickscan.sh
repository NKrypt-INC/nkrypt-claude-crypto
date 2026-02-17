#!/usr/bin/env bash
# secrets-quickscan.sh
#
# A fast secrets scan wrapper:
#   1) gitleaks (preferred)
#   2) trufflehog
#   3) fallback: grep + optional entropy heuristic
#
# It avoids printing full secrets, but scanners can still reveal sensitive context.
# Treat output as sensitive.

set -u
set -o pipefail

OUT_DIR="${CRYPTO_AUDIT_OUT:-.crypto-audit}"
mkdir -p "$OUT_DIR"

have() { command -v "$1" >/dev/null 2>&1; }

echo "secrets-quickscan.sh"
echo "out_dir: ${OUT_DIR}"
echo "cwd: $(pwd)"
echo ""

if have git && git rev-parse --git-dir >/dev/null 2>&1; then
  echo "git: yes"
else
  echo "git: no (history scanning may be limited)"
fi

if have gitleaks; then
  echo ""
  echo "== gitleaks (with --redact) =="
  gitleaks detect --source . --redact --no-banner --report-format json --report-path "$OUT_DIR/gitleaks.json" || true
  echo "report: $OUT_DIR/gitleaks.json"
  exit 0
fi

if have trufflehog; then
  echo ""
  echo "== trufflehog filesystem (json) =="
  trufflehog filesystem . --json > "$OUT_DIR/trufflehog.json" || true
  echo "report: $OUT_DIR/trufflehog.json"
  exit 0
fi

echo ""
echo "== fallback: grep patterns =="
# High signal: private keys and obvious secret names
if have rg; then
  rg -n --no-heading -S "BEGIN .* PRIVATE KEY" . 2>/dev/null | head -n 200 > "$OUT_DIR/keys_grep.txt" || true
  rg -n --no-heading -S "(API_KEY|SECRET|TOKEN|PASSWORD|PRIVATE_KEY|CLIENT_SECRET)\s*[:=]" . 2>/dev/null | head -n 400 > "$OUT_DIR/names_grep.txt" || true
else
  # grep fallback (less accurate)
  grep -RIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=build --exclude-dir=target --exclude-dir=vendor -E "BEGIN .* PRIVATE KEY" . 2>/dev/null | head -n 200 > "$OUT_DIR/keys_grep.txt" || true
  grep -RIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=build --exclude-dir=target --exclude-dir=vendor -E "(API_KEY|SECRET|TOKEN|PASSWORD|PRIVATE_KEY|CLIENT_SECRET)[[:space:]]*[:=]" . 2>/dev/null | head -n 400 > "$OUT_DIR/names_grep.txt" || true
fi

echo "wrote:"
echo "  $OUT_DIR/keys_grep.txt"
echo "  $OUT_DIR/names_grep.txt"

if ! have python; then
  echo ""
  echo "python not found; skipping entropy scan"
  exit 0
fi

echo ""
echo "== optional: entropy scan (noisy) =="

python - <<'PY' > "$OUT_DIR/entropy_hits.txt" 2>/dev/null || true
import os, re, math
from collections import Counter

def shannon(s: str) -> float:
    if not s: return 0.0
    c = Counter(s)
    n = len(s)
    return -sum((v/n) * math.log2(v/n) for v in c.values())

# base64/base64url-ish or hex-ish candidates
pat = re.compile(r'([A-Za-z0-9_\-]{24,}|[A-Fa-f0-9]{32,})')

# Skip noisy dirs
SKIP_DIRS = {
  "node_modules",".git","dist","build","target","vendor",
  ".venv","venv",".tox",".mypy_cache",".pytest_cache",
  ".next",".nuxt","out",".parcel-cache",".turbo",
  "bin","obj",".gradle",".idea",".vscode","coverage"
}

# Skip large/binary-ish extensions
SKIP_EXT = {".png",".jpg",".jpeg",".gif",".pdf",".zip",".gz",".tgz",".jar",".class",".so",".dll",".dylib",".exe",".pdb",".wasm"}

MAX_FILES = int(os.environ.get("CRYPTO_ENTROPY_MAX_FILES", "2000"))
MAX_BYTES = int(os.environ.get("CRYPTO_ENTROPY_MAX_BYTES", "2000000"))
scanned = 0

for root, dirs, files in os.walk("."):
    dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
    for fn in files:
        path = os.path.join(root, fn)
        _, ext = os.path.splitext(fn)
        if ext.lower() in SKIP_EXT:
            continue
        if scanned >= MAX_FILES:
            break
        try:
            data = open(path, "rb").read(MAX_BYTES + 1)
            scanned += 1
            if len(data) > MAX_BYTES:
                continue
            if b"\x00" in data:
                continue
            text = data.decode("utf-8", errors="ignore")
        except Exception:
            continue
        for m in pat.finditer(text):
            s = m.group(1)
            if len(s) < 24:
                continue
            e = shannon(s)
            if e >= 4.0:
                # print location without revealing the full string
                line = text.count("\n", 0, m.start()) + 1
                print(f"{path}:{line}: entropy={e:.2f} len={len(s)} sample={s[:4]}…{s[-4:]}")
PY

echo "wrote: $OUT_DIR/entropy_hits.txt"
echo "entropy limits: CRYPTO_ENTROPY_MAX_FILES=${CRYPTO_ENTROPY_MAX_FILES:-2000} CRYPTO_ENTROPY_MAX_BYTES=${CRYPTO_ENTROPY_MAX_BYTES:-2000000}"
echo ""
echo "next steps:"
echo "  - install gitleaks for higher confidence"
echo "  - add CI gates and rotate any confirmed secrets"