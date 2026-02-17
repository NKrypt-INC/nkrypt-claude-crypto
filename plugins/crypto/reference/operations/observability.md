# Observability for crypto and security controls

Crypto failures often hide until they become outages or breaches. Track the boring metrics.

## TLS metrics

- handshake failure rate (by reason if possible)
- negotiated protocol versions (TLS 1.2 vs 1.3)
- negotiated cipher suites (TLS 1.2)
- negotiated key share groups (TLS 1.3), especially during hybrid PQ rollouts
- certificate expiry lead time alerts
- OCSP stapling success rate (if enabled)
- mTLS client verification failure rate (if used)

## Auth and password metrics

- login failure rate and rate-limit triggers
- password hash verification latency (p50/p95/p99)
- reset token issuance rate and failure reasons
- account takeover signals (unusual IPs, device changes)

## Encryption metrics

- AEAD decrypt failures (tag failures)
- key id distribution (how many requests use old key vs new key)
- envelope unwrap failures (KMS errors, key disabled)

## Key rotation metrics

- rotation job success rate
- % of data re-wrapped or re-encrypted
- verify/decrypt failures by key id
- time-to-disable for compromised keys (measured in minutes, not “soon”)

## Logging cautions

- Never log plaintext secrets, tokens, passwords, or raw keys.
- Avoid logging full ciphertexts if it leaks sensitive structure.
- Avoid logging raw key material in stack traces (sanitize exceptions).
