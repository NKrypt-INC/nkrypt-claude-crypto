#!/usr/bin/env bash
# crypto-audit-escalate.sh
#
# Purpose:
#   Run "Level 2/3" audit helpers when they are available, and record what ran vs what skipped.
#   This script does NOT install tools. It prints install one-liners instead.
#
# Safety:
#   - Expect scanners to surface sensitive file paths and redacted secret snippets.
#   - Do not upload the output directory to public places.
#
# Usage:
#   ./crypto-audit-escalate.sh
#   CRYPTO_AUDIT_OUT=.crypto-audit ./crypto-audit-escalate.sh

set -u
set -o pipefail

OUT_DIR="${CRYPTO_AUDIT_OUT:-.crypto-audit}"
mkdir -p "$OUT_DIR"

timestamp="$(date -u +"%Y%m%dT%H%M%SZ" 2>/dev/null || true)"
if [ -z "${timestamp}" ]; then
  timestamp="unknown-time"
fi

SUMMARY="$OUT_DIR/summary.txt"
: > "$SUMMARY"

log() {
  printf "%s\n" "$*" | tee -a "$SUMMARY"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

run_cmd() {
  local name="$1"
  shift
  log ""
  log "== ${name} =="
  log "cmd: $*"
  # Never fail the whole script on scanner findings.
  set +e
  "$@" > "$OUT_DIR/${name}.out" 2> "$OUT_DIR/${name}.err"
  local rc=$?
  log "exit: ${rc}"
  if [ -s "$OUT_DIR/${name}.err" ]; then
    log "stderr: $OUT_DIR/${name}.err"
  fi
  log "stdout: $OUT_DIR/${name}.out"
  return 0
}

skip() {
  local name="$1"
  local why="$2"
  local install="$3"
  log ""
  log "== SKIP ${name} =="
  log "why: ${why}"
  if [ -n "${install}" ]; then
    log "install: ${install}"
  fi
}

log "crypto-audit-escalate.sh"
log "out_dir: ${OUT_DIR}"
log "time_utc: ${timestamp}"
log "cwd: $(pwd)"

# Git context (optional)
if have git && git rev-parse --git-dir >/dev/null 2>&1; then
  run_cmd "git-status" git status --porcelain=v1
  # Submodules matter for monorepos and multi-repo layouts.
  run_cmd "git-submodule" git submodule status --recursive
else
  skip "git-status" "not a git repo or git missing" "install git"
fi

# Secrets scanning (prefer gitleaks)
if have gitleaks; then
  # --redact reduces accidental exposure in outputs.
  run_cmd "gitleaks" gitleaks detect --source . --redact --no-banner --report-format json --report-path "$OUT_DIR/gitleaks.json"
elif have trufflehog; then
  run_cmd "trufflehog" trufflehog filesystem . --json
else
  skip "gitleaks" "gitleaks not found" "brew install gitleaks   # or see https://github.com/gitleaks/gitleaks"
  skip "trufflehog" "trufflehog not found" "pipx install trufflehog   # or see https://github.com/trufflesecurity/trufflehog"
fi

# Node (npm/pnpm/yarn)
if [ -f package-lock.json ] || [ -f pnpm-lock.yaml ] || [ -f yarn.lock ] || [ -f package.json ]; then
  if have npm; then
    run_cmd "npm-ls" npm ls --all
    run_cmd "npm-audit" npm audit --json
  else
    skip "npm-audit" "npm not found" "install node/npm (or use your org tooling)"
  fi
fi

# Python
if [ -f requirements.txt ] || [ -f pyproject.toml ] || [ -f poetry.lock ] || [ -f Pipfile.lock ]; then
  if have python; then
    run_cmd "pip-freeze" python -m pip freeze
  fi
  if have pip-audit; then
    run_cmd "pip-audit" pip-audit
  else
    skip "pip-audit" "pip-audit not found" "python -m pip install pip-audit"
  fi
fi

# Go
if [ -f go.mod ]; then
  if have go; then
    run_cmd "go-mod" go list -m all
    run_cmd "go-mod-verify" go mod verify
  fi
  if have govulncheck; then
    run_cmd "govulncheck" govulncheck ./...
  else
    skip "govulncheck" "govulncheck not found" "go install golang.org/x/vuln/cmd/govulncheck@latest"
  fi
fi

# Rust
if [ -f Cargo.toml ] || [ -f Cargo.lock ]; then
  if have cargo; then
    run_cmd "cargo-tree" cargo tree
  fi
  if have cargo-audit; then
    run_cmd "cargo-audit" cargo audit
  else
    skip "cargo-audit" "cargo-audit not found" "cargo install cargo-audit"
  fi
fi

# .NET
if find . -maxdepth 6 \( -name "*.sln" -o -name "*.csproj" -o -name "*.fsproj" \) 2>/dev/null | head -n 1 | grep -q .; then
  if have dotnet; then
    run_cmd "dotnet-list" dotnet list package
    # Available on newer SDKs; still useful when it works.
    run_cmd "dotnet-vuln" dotnet list package --vulnerable
  else
    skip "dotnet-vuln" "dotnet not found" "install .NET SDK"
  fi
fi

# Java (Maven/Gradle)
if [ -f pom.xml ]; then
  if have mvn; then
    run_cmd "maven-deps" mvn -q -DskipTests dependency:tree
  else
    skip "maven-deps" "mvn not found" "install Maven (mvn)"
  fi
fi

if [ -f build.gradle ] || [ -f build.gradle.kts ] || [ -f settings.gradle ] || [ -f settings.gradle.kts ]; then
  if [ -x ./gradlew ]; then
    run_cmd "gradle-deps" ./gradlew -q dependencies
  elif have gradle; then
    run_cmd "gradle-deps" gradle -q dependencies
  else
    skip "gradle-deps" "gradle/gradlew not found" "install Gradle or add ./gradlew wrapper"
  fi
fi

# OSV scanner (lockfile scanning)
if have osv-scanner; then
  run_cmd "osv-scanner" osv-scanner --recursive .
else
  skip "osv-scanner" "osv-scanner not found" "see https://github.com/google/osv-scanner"
fi

# SBOM + image scanning (optional)
if have syft; then
  run_cmd "syft-dir" syft dir:. -o json
else
  skip "syft-dir" "syft not found" "brew install syft   # or see https://github.com/anchore/syft"
fi

if have grype; then
  # If syft ran, scanning the produced SBOM is often cleaner, but grype can also scan dir directly.
  if [ -f "$OUT_DIR/syft-dir.out" ] && [ -s "$OUT_DIR/syft-dir.out" ]; then
    run_cmd "grype-dir" grype dir:.
  else
    run_cmd "grype-dir" grype dir:.
  fi
else
  skip "grype-dir" "grype not found" "brew install grype  # or see https://github.com/anchore/grype"
fi

log ""
log "done"
log "Review outputs under: ${OUT_DIR}"
