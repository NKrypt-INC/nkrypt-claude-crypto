# Classical cryptography baseline

This is the minimum bar for “we are not obviously on fire.”

If you are below this bar, **do not spend engineering time on PQC yet**. Fix the baseline.

## Passwords

- Use **Argon2id** (preferred) or scrypt/bcrypt.
- Never use MD5/SHA-1/SHA-256 for password storage.
- Use per-password salts (library-managed).
- Add rate-limits and MFA. Crypto can’t save weak auth flows.

See:
- `skills/passwords/SKILL.md`
- `reference/implementations/passwords/*`

## Symmetric encryption

Use **AEAD**:
- AES-256-GCM (default)
- ChaCha20-Poly1305 (great on mobile/without AES acceleration)

Requirements:
- For AES-GCM and ChaCha20-Poly1305, treat nonce uniqueness as a hard requirement. Never reuse a nonce with the same key.
- Prefer a random 96-bit nonce for AES-GCM (or a counter you can prove never repeats).
- Store/transmit nonce + ciphertext + auth tag.
- Use Associated Data (AAD) for headers you need integrity-protected.
- If you cannot guarantee uniqueness (distributed writers, counters that can reset), prefer a misuse-resistant AEAD like AES-GCM-SIV or XChaCha20-Poly1305 where supported.

Never:
- AES-ECB
- “AES-CBC without authentication”
- “encrypt-then-hash DIY”

See:
- `reference/implementations/symmetric/*`
- `reference/testing/symmetric-aead.md`

## Key derivation

- Use **HKDF** for deriving multiple keys from a root key (key-based).
- Use **Argon2id/scrypt/PBKDF2** for password-based derivation.
- Do not roll your own KDF by hashing strings.

See:
- `reference/implementations/kdf/*`

## Randomness

- Use OS CSPRNG:
  - Node: `crypto.randomBytes`
  - Python: `secrets.token_bytes`
  - Go: `crypto/rand`
  - Java: `SecureRandom`
  - .NET: `RandomNumberGenerator`

Never use:
- `Math.random()`, `random.Random()`, `java.util.Random`, `math/rand`, `rand()`

See:
- `reference/implementations/randomness/*`

## Constant-time comparisons

- Use constant-time comparison helpers when comparing secret-derived values (MAC tags, tokens, password reset token hashes).
- Avoid `==` / string equality for secrets in hot paths.

See:
- `reference/controls/side-channels.md`
- `reference/language-footguns/*`

## TLS

- TLS 1.3 preferred, TLS 1.2 allowed for compatibility.
- Disable SSLv3/TLS1.0/TLS1.1 unless you have a written exception.
- Use modern cipher suites and enforce cert validation.

See:
- `skills/tls/SKILL.md`
- `reference/implementations/tls/*`

## Key management

- Separate KEK (wrap keys) from DEK (encrypt data).
- Prefer KMS/HSM for KEKs.
- Implement rotation with versioning (`kid` or key version field) and safe rollback.

See:
- `reference/operations/key-rotation.md`

## Secrets hygiene

- Never commit secrets.
- Scan regularly and gate CI.

See:
- `skills/secrets/SKILL.md`
