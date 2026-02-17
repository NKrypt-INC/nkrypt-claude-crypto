# Testing TLS configuration

TLS tests should cover:
- protocol version floors
- cipher negotiation (TLS 1.2)
- certificate validation
- interop with real clients

## Quick checks (manual / CI)

- External: SSL Labs (public endpoints)
- CLI: `testssl.sh` (great for CI if you can run it)

## Protocol floor tests

- TLS 1.0 and 1.1 should fail
- TLS 1.2 and 1.3 should succeed

## Certificate validation tests

Client tests must fail if:
- cert is expired
- hostname mismatch
- unknown CA (unless you intentionally pin/private CA)

## PQC hybrid TLS tests (if enabled)

- Confirm negotiated group includes a hybrid ML-KEM group.
- Measure handshake size and latency impact.

See `reference/pqc/support-matrix.md` for which stacks can do this today.

## Scripted probe (fast)

This bundle includes `tools/tls-probe.sh` as a quick protocol-floor probe via OpenSSL.

Example:
```bash
./tls-probe.sh example.com 443
```

Run it from multiple network paths when relevant:
- normal client network
- corporate proxy / TLS inspection path
- WAF path

## Middlebox and cohort testing (practical)

Hybrid TLS and stricter configs often fail because of middleboxes.

Collect:
- which client cohorts fail (OS/runtime versions)
- which network paths fail (proxy, inspection, VPN)
- which alerts appear (handshake_failure, illegal_parameter, etc.)

Store sanitized results as artifacts in CI or staging.

## Black-box scanners

- `testssl.sh` gives excellent coverage for protocol/cipher posture.
- `sslyze --regular` provides a structured report.

## PQC hybrid probes (when supported)

If your OpenSSL supports hybrid groups, you can attempt group-forced handshakes:

```bash
./pqc-handshake-matrix.sh example.com 443
```

Treat results as “works from this machine and path”, not as global truth.
