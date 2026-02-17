#!/usr/bin/env bash
# bootstrap.sh
#
# Purpose:
#   Make the helper scripts in this directory runnable and show optional install hints.
#
# This script does NOT install anything. It prints suggested commands only.

set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "bootstrap.sh"
echo "tools_dir: ${SCRIPT_DIR}"
echo ""

# Make all helper scripts executable.
chmod +x "${SCRIPT_DIR}"/*.sh 2>/dev/null || true

have() { command -v "$1" >/dev/null 2>&1; }

check() {
  local bin="$1"
  local hint="$2"
  if have "${bin}"; then
    printf "OK   %s\n" "${bin}"
  else
    printf "MISS %s\n" "${bin}"
    if [ -n "${hint}" ]; then
      printf "     hint: %s\n" "${hint}"
    fi
  fi
}

echo "Optional tools (the helpers will run whatever is available):"
echo ""

check git "install git"
check rg "brew install ripgrep  |  apt-get install ripgrep"
check openssl "install OpenSSL (needed for pqc-handshake-matrix.sh)"
check python "install Python 3 (for entropy scan and some tooling)"

echo ""
echo "Secrets scanners:"
check gitleaks "brew install gitleaks  |  go install github.com/gitleaks/gitleaks/v8@latest"
check trufflehog "pipx install trufflehog  |  python -m pip install trufflehog"
check detect-secrets "python -m pip install detect-secrets"

echo ""
echo "Static analysis:"
check semgrep "pipx install semgrep  |  python -m pip install semgrep"
check osv-scanner "see https://github.com/google/osv-scanner"

echo ""
echo "SBOM + vuln scanning:"
check syft "brew install syft  |  see https://github.com/anchore/syft"
check grype "brew install grype |  see https://github.com/anchore/grype"

echo ""
echo "TLS probing:"
check sslyze "pipx install sslyze  |  python -m pip install sslyze"
check testssl.sh "git clone https://github.com/drwetter/testssl.sh (then add to PATH)"

echo ""
echo "Language-specific vuln tools (optional):"
check npm "install Node.js/npm"
check pip-audit "python -m pip install pip-audit"
check govulncheck "go install golang.org/x/vuln/cmd/govulncheck@latest"
check cargo-audit "cargo install cargo-audit"
check dotnet "install .NET SDK"
check mvn "install Maven"
check gradle "install Gradle or add ./gradlew"

echo ""
echo "Next steps:"
echo "  1) Run: ${SCRIPT_DIR}/crypto-audit-escalate.sh"
echo "  2) Run: ${SCRIPT_DIR}/secrets-quickscan.sh"
echo "  3) Run: ${SCRIPT_DIR}/tls-probe.sh https://your-endpoint"
echo ""
echo "Outputs default to .crypto-audit/ (gitignore it). Treat outputs as sensitive."
