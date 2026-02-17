# PQC / hybrid TLS interop matrix template

Use this template during `/crypto:migrate-pqc`.

The goal: avoid “works on my laptop” surprises by testing real cohorts.

## Axes

### Server-side
- TLS termination product (nginx, Envoy, HAProxy, cloud LB)
- TLS library and version (OpenSSL, BoringSSL, NSS, GnuTLS)
- PQC enablement flags/config (groups, keyshares, provider modules)
- FIPS / compliance mode (if applicable)

### Client-side cohorts
List cohorts that reflect reality:
- browsers by engine + version
- mobile OS versions
- JVM versions
- Go versions
- corporate proxy / TLS inspection products
- IoT / embedded clients

### Network paths
- direct
- via CDN
- via corporate proxy
- via VPN
- via WAF

## What to record

For each cell:
- handshake success/failure
- negotiated protocol (TLS 1.2 / 1.3)
- negotiated group (when observable)
- latency (p50/p95) for handshake
- error codes / alerts (sanitized)

## Suggested workflow

1) Establish baseline (classical) with the same test harness.
2) Enable hybrid on a canary and repeat the exact same matrix.
3) Compare failure deltas and chase cohort-specific failures first.

## Starter probe commands

- `tools/tls-probe.sh`
- `tools/pqc-handshake-matrix.sh`
- `testssl.sh`, `sslyze`

See also:
- `reference/testing/tls.md`
- `reference/testing/pqc.md`
