#!/usr/bin/env bash
# pqc-handshake-matrix.sh
#
# Attempt TLS 1.3 handshakes with specific groups via OpenSSL.
# This helps validate hybrid group negotiation when your OpenSSL build supports it.
#
# Usage:
#   ./pqc-handshake-matrix.sh example.com 443
#   ./pqc-handshake-matrix.sh example.com 443 X25519MLKEM768 P256MLKEM768 X25519
#
# If no groups provided, the script tries to auto-select groups containing "MLKEM"
# from `openssl list -groups`.

set -u
set -o pipefail

HOST="${1:-}"
PORT="${2:-}"
shift 2 || true

if [ -z "${HOST}" ] || [ -z "${PORT}" ]; then
  echo "usage: $0 host port [groups...]"
  exit 2
fi

have() { command -v "$1" >/dev/null 2>&1; }

if ! have openssl; then
  echo "openssl not found"
  exit 2
fi

SNI="${HOST}"
OUT_DIR="${CRYPTO_AUDIT_OUT:-.crypto-audit}"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/pqc-handshake-matrix.txt"
: > "$OUT"

groups=("$@")
if [ "${#groups[@]}" -eq 0 ]; then
  # auto select
  mapfile -t groups < <(openssl list -groups 2>/dev/null | awk '{print $1}' | grep -E "MLKEM|KYBER" || true)
fi

if [ "${#groups[@]}" -eq 0 ]; then
  echo "No MLKEM-like groups found in this OpenSSL build."
  echo "Try: openssl list -groups"
  exit 1
fi

echo "pqc-handshake-matrix.sh" | tee -a "$OUT"
echo "target: ${HOST}:${PORT}" | tee -a "$OUT"
echo "sni: ${SNI}" | tee -a "$OUT"
echo "" | tee -a "$OUT"

for g in "${groups[@]}"; do
  echo "== group: ${g} ==" | tee -a "$OUT"
  set +e
  out="$(openssl s_client -connect "${HOST}:${PORT}" -servername "${SNI}" -tls1_3 -groups "${g}" -brief </dev/null 2>&1)"
  rc=$?
  if echo "$out" | grep -q "Protocol  : TLSv1.3"; then
    proto="$(echo "$out" | awk -F': ' '/Protocol  :/ {print $2; exit}')"
    cipher="$(echo "$out" | awk -F': ' '/Ciphersuite: / {print $2; exit}')"
    echo "result: OK (${proto}, ${cipher})" | tee -a "$OUT"
  else
    echo "result: FAIL (exit ${rc})" | tee -a "$OUT"
  fi
  echo "$out" | sed -n '1,12p' | tee -a "$OUT"
  echo "" | tee -a "$OUT"
done

echo "wrote: ${OUT}"
echo "Interpretation tips:"
echo "  - run from networks with real middleboxes (corp proxy, WAF path)"
echo "  - compare failure rate vs baseline TLS handshakes"


# Example run (mocked)
#
#   $ ./pqc-handshake-matrix.sh example.com 443 X25519 X25519MLKEM768
#   pqc-handshake-matrix.sh
#   target: example.com:443
#
#   == group: X25519 ==
#   result: OK (TLSv1.3, TLS_AES_256_GCM_SHA384)
#
#   == group: X25519MLKEM768 ==
#   result: FAIL (exit 1)
#
# Interpretation
#   - If a classical baseline group works but a hybrid group fails, your server or client stack likely does not support hybrid groups yet.
#   - Group names vary by OpenSSL build. Check what your client supports with: openssl list -groups
