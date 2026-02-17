---
name: secrets
description: Scan for hardcoded secrets, API keys, passwords, and private keys (including git history guidance) and produce a containment + rotation plan.
disable-model-invocation: true
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - Bash
---

# /crypto:secrets

You are scanning for exposed secrets (in code, config, and history).

A secret leak beats “perfect crypto” every time.

## Safety rules

- Never print full secrets. Redact aggressively.
- Prefer file + line numbers and small surrounding context with masking.
- If you find a private key, stop and treat it as a live incident until proven otherwise.

## Method (layered, not just grep)

Tip: this bundle includes a runnable helper template: `tools/secrets-quickscan.sh`.
Create it in-repo (via `Edit`) if you want a repeatable scan command.


### Layer 1: High-signal patterns (always run)

Use `Grep` to search for:
- private keys: `BEGIN .* PRIVATE KEY`
- common secret variable names: `API_KEY`, `SECRET`, `TOKEN`, `PASSWORD`, `PRIVATE_KEY`, `CLIENT_SECRET`
- cloud credential patterns (AWS, GCP, GitHub, Slack, Stripe, etc.)
- connection strings with embedded passwords
- JWTs and bearer tokens in config files

Also scan non-code:
- `.env*`, `*.pem`, `*.p12`, `*.pfx`, `*.key`, `id_rsa`, `id_ed25519`
- CI configs (GitHub Actions, GitLab CI, CircleCI)
- Kubernetes manifests and Helm charts

### Layer 2: Dedicated secret scanners (higher confidence)

If you are in a git repo, prefer scanners that traverse history by default.


If available, prefer a dedicated scanner because attackers do not store secrets in nice regex-friendly ways.

Try:
- `gitleaks detect --source .` (includes git history by default)
- `trufflehog git file://$(pwd)` (history scanning)
- `detect-secrets` for pre-commit/CI prevention (see `reference/tooling/detect-secrets.md`)

If tools are missing, do not auto-install without asking. Provide the exact install command and ask for permission.

### Layer 3: High-entropy string hunting (optional, noisy)

Scale tip:
- For very large repos, run entropy scans on a subset first (hot directories, recent diffs), or cap files scanned. Prefer gitleaks/trufflehog when possible.


Grep patterns miss:
- split secrets
- unusual key formats
- short-lived tokens embedded in JSON blobs

If Python is available, you can run a simple entropy heuristic as a signal:

```bash
python - <<'PY'
import os, re, math

def shannon(s: str) -> float:
    if not s: return 0.0
    from collections import Counter
    c = Counter(s)
    n = len(s)
    return -sum((v/n) * math.log2(v/n) for v in c.values())

# Heuristic: strings that look like base64/base64url/hex and are long-ish.
pat = re.compile(r'([A-Za-z0-9_\-]{24,}|[A-Fa-f0-9]{32,})')
ext_skip = {".png",".jpg",".jpeg",".gif",".pdf",".zip",".gz",".tgz",".jar",".class",".so",".dll",".dylib"}
for root, dirs, files in os.walk("."):
    # skip common vendor/build dirs
    dirs[:] = [d for d in dirs if d not in {"node_modules",".git","dist","build","target","vendor"}]
    for fn in files:
        path = os.path.join(root, fn)
        _, ext = os.path.splitext(fn)
        if ext.lower() in ext_skip: 
            continue
        try:
            data = open(path, "rb").read()
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
                print(f"{path}:{text.count('\n', 0, m.start())+1}: entropy={e:.2f} len={len(s)} sample={s[:4]}…{s[-4:]}")
PY
```

Treat this as a lead generator, not proof.

## Output format

### A) Findings (redacted)
For each suspected secret:
- type guess (API key, private key, password, token, connection string)
- location (file:line)
- redacted evidence (prefix + suffix only)
- confidence (HIGH/MEDIUM/LOW)

### B) Immediate containment plan
- revoke/rotate secrets (do not wait for “confirmation”)
- invalidate sessions/tokens as needed
- remove hardcoded fallback secrets (the “default-secret” trap)
- add detection to CI (gitleaks/trufflehog)

### C) Remediation plan
- move secrets to a secret manager (KMS, Vault, platform secret store)
- enforce least privilege and short TTL where possible
- add pre-commit hooks and CI gates

### D) History considerations
If the secret lived in git history:
- assume compromise
- rotate anyway
- consider history rewrite only as a hygiene step (it does not guarantee eradication from forks/caches)
- if you rewrite history, use a dedicated tool (git-filter-repo) and plan for force-push fallout: https://github.com/newren/git-filter-repo
