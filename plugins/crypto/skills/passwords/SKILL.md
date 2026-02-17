---
name: passwords
description: Implement password storage, verification, and reset flows safely (Argon2id/bcrypt/scrypt), with migration + testing patterns and multi-language code references.
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - Bash
---

# /crypto:passwords

You are implementing password security. This is where breaches turn into headlines.

## Baseline requirements

- Never store plaintext passwords.
- Never use fast hashes (MD5, SHA-1, SHA-256) for passwords.
- Use a **password hashing function**: **Argon2id preferred**, else scrypt/bcrypt.
- Use a unique random salt per password (most libraries handle this).
- Add a **pepper** only if you can store it safely (KMS/HSM/secret manager), and you understand rotation.

## Recommended choices

### Default: Argon2id
Use Argon2id unless your platform can’t support it.

Parameter guidance (starting point):

Reference: OWASP Password Storage Cheat Sheet (Argon2id guidance): https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html

OWASP floor (treat as a minimum, not a ceiling):
- memory: 19 MiB
- iterations: 2
- parallelism: 1
- Target ~100–500ms verification time on your production hardware.
- Prefer memory-hardness (tune memory up before iterations).
- Keep parallelism modest (avoid DoS by over-parallelizing).

### Calibrate on your real hardware

- Calibrate on the slowest production class you expect (or your worst-case login node).
- Measure verification latency under realistic concurrency.
- Keep an eye on DoS: heavier params increase attacker cost and your own CPU bill.

Practical method:
- write a small benchmark that calls verify N times and reports p50/p95
- tune memory first, then iterations

See `reference/testing/passwords-argon2.md`.

## Language-specific implementation (copy-paste)

Use these references:

- Node.js: `reference/implementations/passwords/nodejs-argon2.md`
- Python: `reference/implementations/passwords/python-argon2.md`
- Go: `reference/implementations/passwords/go-argon2.md`
- Java: `reference/implementations/passwords/java-argon2.md`
- .NET: `reference/implementations/passwords/dotnet-argon2.md`
- Rust: `reference/implementations/passwords/rust-argon2.md`

Each includes:
- exact library/package name
- working hash + verify code
- common pitfalls
- testing snippets

## Migration patterns

### A) Rehash-on-login (recommended)
1) Keep verifying old hashes.
2) On successful login, rehash with new algorithm/params and replace stored hash.
3) Track `needs_rehash` or infer from hash prefix.

### B) Forced reset (only when necessary)
Use when old hashes are dangerously weak (MD5/SHA-1) or breached.

## Password reset tokens (complete pattern)

Reset tokens are credentials. Treat them like passwords.

### Token format
- Generate **32+ random bytes** from a CSPRNG.
- Encode as **base64url** (no `+` or `/`) for URLs.

### Lifetime
- **15–60 minutes** is a common starting range.
- Use **5–15 minutes** for higher-risk accounts or when you can tolerate tighter UX.
- Single-use only.

OWASP guidance: enforce a lifetime restriction, use a CSPRNG, invalidate after use, and store reset identifiers securely.
Reference: https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html

### Storage
- Store only a **hash** of the token (like a password), never the raw token.
- Store: `user_id`, `token_hash`, `expires_at`, `used_at` (nullable), `issued_ip/user_agent` (optional).

### Verification rules
- Match user + token hash + not expired + not used.
- Use constant-time compare helpers when you compare secret-derived bytes (see `reference/controls/side-channels.md`).
- Rate-limit reset requests per account and per IP.

### Invalidation
- On successful reset: mark token used and invalidate other outstanding tokens for that user.
- Optional: invalidate active sessions.

## Testing checklist

See `reference/testing/passwords-argon2.md`.

Minimum tests:
- Hash differs across calls for same password (random salt)
- Verify succeeds for correct password
- Verify fails for incorrect password
- Tampering with hash fails
- “Rehash needed” triggers on old params
- Reset token: wrong/expired/used token fails, valid token works once

## Output expectations

When asked for password help:
- Provide exact implementation in the project’s language
- Provide tests
- Provide migration plan
- Provide operational notes (DoS risk, rate-limits, monitoring)
