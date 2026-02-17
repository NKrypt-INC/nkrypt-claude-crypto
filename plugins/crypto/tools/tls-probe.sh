#!/usr/bin/env bash
# tls-probe.sh
#
# Quick TLS probing for an endpoint.
# This is a convenience helper, not a full scanner.
#
# Usage:
#   ./tls-probe.sh example.com 443
#   ./tls-probe.sh 10.0.0.5 8443 example.com   # host port sni
#
# Notes:
# - Use testssl.sh or sslyze for deeper checks when possible.
# - Run probes from networks that resemble real clients (including proxies/middleboxes).

set -u
set -o pipefail

HOST="${1:-}"
PORT="${2:-}"
SNI="${3:-}"

if [ -z "${HOST}" ] || [ -z "${PORT}" ]; then
  echo "usage: $0 host port [sni]"
  exit 2
fi

if [ -z "${SNI}" ]; then
  SNI="${HOST}"
fi

have() { command -v "$1" >/dev/null 2>&1; }

echo "tls-probe.sh"
echo "target: ${HOST}:${PORT}"
echo "sni: ${SNI}"
echo ""

if ! have openssl; then
  echo "openssl not found"
  exit 2
fi

probe_one() {
  local label="$1"
  local flag="$2"
  echo "== ${label} =="
  # -brief keeps output short on newer OpenSSL.
  set +e
  out="$(openssl s_client -connect "${HOST}:${PORT}" -servername "${SNI}" ${flag} -brief </dev/null 2>&1)"
  rc=$?
  echo "${out}" | sed -n '1,25p'
  echo "exit: ${rc}"
  echo ""
}

probe_one "TLS 1.3" "-tls1_3"
probe_one "TLS 1.2" "-tls1_2"
probe_one "TLS 1.1 (should fail)" "-tls1_1"
probe_one "TLS 1.0 (should fail)" "-tls1"

echo "optional:"
echo "  - run testssl.sh: testssl.sh ${HOST}:${PORT}"
echo "  - run sslyze: sslyze --regular ${HOST}:${PORT}"
