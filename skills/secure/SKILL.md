---
name: secure
description: Implement cryptography safely (passwords, symmetric encryption, randomness, key management, TLS) with language-specific references and tests. Use when building or fixing crypto code.
license: MIT
allowed-tools: Read Edit Glob Grep Bash
metadata:
  author: nkrypt
  version: "0.5.0"
---

# /crypto:secure

You are here to **replace insecure crypto with safe, boring crypto**.

## Rules of engagement

- Prefer **standard libraries** or widely used, audited third-party libraries.
- Use **authenticated encryption** (AEAD) by default.
- Use **OS-provided CSPRNG** for all secret material.
- Treat key management as a first-class feature, not an afterthought.
- Add tests and interop checks. Crypto that isn't tested becomes "Schrodinger's security".


## Side-channel sanity checks (cheap wins)

- Use constant-time comparisons for secret-derived bytes (MAC tags, token hashes) when your code compares them.
- Prefer high-level verify APIs (they usually handle timing behavior and parsing pitfalls).

See `../../plugins/crypto/reference/controls/side-channels.md`.

See `../../plugins/crypto/reference/controls/nonce-management.md` for AEAD nonce strategies.

## Decision tree (fast)

1) **Passwords?** Use `/crypto:passwords` (Argon2id, reset tokens, migration, tests).
2) **Data at rest / payload encryption?** Use AEAD:
   - AES-256-GCM (default) or ChaCha20-Poly1305
3) **Key derivation?**
   - Password-based: Argon2id / scrypt / PBKDF2 (only for legacy or compliance constraints)
   - Key-based: HKDF
4) **Transport security?** Use `/crypto:tls` (TLS 1.3 preferred; harden 1.2).
5) **PQC planning?** Use `/crypto:migrate-pqc` (hybrid-first).

## Implementation guidance (multi-language)

Use the reference implementations (copy-pasteable, with pitfalls + tests):

- Password hashing:
  - `../../plugins/crypto/reference/implementations/passwords/*`
- Symmetric AEAD:
  - `../../plugins/crypto/reference/implementations/symmetric/*`
- HKDF and derivation:
  - `../../plugins/crypto/reference/implementations/kdf/*`
- Secure randomness:
  - `../../plugins/crypto/reference/implementations/randomness/*`
- TLS:
  - `../../plugins/crypto/reference/implementations/tls/*`
- JWT signing and rotation:
  - `../../plugins/crypto/reference/implementations/jwt/nodejs-jose.md`
  - `../../plugins/crypto/reference/implementations/jwt/python-pyjwt.md`
  - `../../plugins/crypto/reference/implementations/jwt/go-jwt.md`

## Footgun catalog (language-specific)

Before coding, read the relevant pitfalls list:

- `../../plugins/crypto/reference/language-footguns/nodejs.md`
- `../../plugins/crypto/reference/language-footguns/python.md`
- `../../plugins/crypto/reference/language-footguns/go.md`
- `../../plugins/crypto/reference/language-footguns/java.md`
- `../../plugins/crypto/reference/language-footguns/dotnet.md`
- `../../plugins/crypto/reference/language-footguns/rust.md`

## Testing requirements (ship-ready)

Ship crypto changes with tests whenever you can.

If you cannot test (no harness, no staging, no safe way to validate), treat that as a risk and escalate to a deeper review.

Minimum:

- Unit tests for invariants (encrypt/decrypt roundtrip, verify fails on tamper)
- Negative tests (wrong key, wrong nonce, modified ciphertext)
- Interop tests (client/server TLS, JWT consumers, cross-language decrypt if needed)

See:
- `../../plugins/crypto/reference/testing/passwords-argon2.md`
- `../../plugins/crypto/reference/testing/symmetric-aead.md`
- `../../plugins/crypto/reference/testing/jwt-signing.md`
- `../../plugins/crypto/reference/testing/tls.md`

## Key management baseline

- Separate **DEKs** (data encryption keys) from **KEKs** (key encryption keys).
- Store KEKs in KMS/HSM when possible.
- Rotate keys with versioning (`kid` or explicit key version fields).
- Keep rollback paths (dual-key verify/decrypt windows).

See:
- `../../plugins/crypto/reference/operations/kms-quickstart.md`
- `../../plugins/crypto/reference/operations/key-rotation.md`
- `../../plugins/crypto/reference/operations/incident-response.md`

## Output expectations

When asked to secure something:
1) Identify what is being protected (passwords, data at rest, data in transit, tokens).
2) Provide a concrete implementation plan + code changes (language specific).
3) Provide tests.
4) Provide rollout steps (feature flags, canary, monitoring).
