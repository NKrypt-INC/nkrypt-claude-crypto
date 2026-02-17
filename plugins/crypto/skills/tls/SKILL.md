---
name: tls
description: Harden TLS configurations (TLS 1.3 + safe TLS 1.2), including hybrid post-quantum key exchange rollout patterns where supported.
disable-model-invocation: true
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - Bash
---

# /crypto:tls

You are configuring TLS for real clients on real networks.

Aim for: secure-by-default, compatible-enough, measurable, and reversible.

## Baseline requirements

- Prefer **TLS 1.3**. Keep **TLS 1.2** for compatibility unless you control all clients.
- Disable SSLv3, TLS 1.0, TLS 1.1 unless an explicit legacy requirement exists (and document it).
- For TLS 1.2, enable only **AEAD** ciphers (GCM / ChaCha20-Poly1305).
- Enforce certificate validation (never `rejectUnauthorized: false` in prod).
- Enable HSTS on HTTPS endpoints that should never downgrade to HTTP.
- Track certificate expiry and OCSP stapling behavior if you rely on it.

## Concrete configs (copy-paste)

Use the reference implementations:

- nginx: `reference/implementations/tls/nginx-hardening.md`
- Apache httpd: `reference/implementations/tls/apache-hardening.md`
- Node.js: `reference/implementations/tls/nodejs-tls-config.md`
- Python: `reference/implementations/tls/python-ssl-config.md`
- Go: `reference/implementations/tls/go-tls-config.md`
- Java: `reference/implementations/tls/java-tls-config.md`
- .NET: `reference/implementations/tls/dotnet-tls-config.md`

Each includes:
- protocol floors
- cipher suite strings/settings
- certificate chain notes
- common misconfigurations
- quick verification commands

## Post-quantum TLS (hybrid as a transition)

Only after baseline TLS is solid:

1) Prefer hybrid key agreement groups (classical + ML-KEM) where your stack supports them.
2) Roll out cautiously:
   - server offers hybrid + classical
   - measure handshake failures and latency
   - gradually prefer hybrid for clients that succeed
3) Keep escape hatches for older clients and weird middleboxes.

See:
- `reference/pqc/support-matrix.md`
- `tools/pqc-handshake-matrix.sh` (helper template for OpenSSL group probing)
- `skills/migrate-pqc/SKILL.md`

## Validation

Static:
- review TLS settings in configs and code

Dynamic:
- (quick) run the helper template `tools/tls-probe.sh` (create it in-repo via `Edit`)
- run `testssl.sh` or `sslyze` for endpoints you can reach
- use `openssl s_client` to confirm protocol and group negotiation
- add automated integration tests (see `reference/testing/tls.md`)

Metrics:
- handshake failure rate (overall + by client cohort)
- negotiated protocol and cipher/group distributions
- handshake latency (p95/p99)

## Output expectations

When asked to harden TLS:
1) identify the termination stack (nginx/Apache/LB/service mesh/app server/library)
2) provide exact config snippets
3) provide rollout steps and validation commands
4) if hybrid PQ TLS is requested, verify library support first and call out client risks
