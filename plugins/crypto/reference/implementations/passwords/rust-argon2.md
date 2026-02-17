# Rust Argon2id password hashing (argon2)

**Crate:** `argon2`  
**Pinned example version:** `0.5.3`  
**Why this crate:** Implements PHC string output and integrates with `password-hash` traits.

## Cargo.toml

```toml
[dependencies]
argon2 = "0.5.3"
password-hash = "0.5.0"
rand_core = "0.10.0"
```

## Hash + verify (copy-paste)

```rust
use argon2::{Algorithm, Argon2, Params, PasswordHasher, PasswordVerifier, Version};
use password_hash::{PasswordHash, SaltString};
use rand_core::OsRng;

pub fn hash_password(password: &str) -> Result<String, password_hash::Error> {
    // memory is in KiB (65536 KiB = 64 MiB)
    let params = Params::new(65536, 3, 1, Some(32))?;
    let argon2 = Argon2::new(Algorithm::Argon2id, Version::V0x13, params);

    let salt = SaltString::generate(&mut OsRng);
    let hash = argon2.hash_password(password.as_bytes(), &salt)?.to_string();
    Ok(hash)
}

pub fn verify_password(encoded: &str, password: &str) -> Result<bool, password_hash::Error> {
    let parsed = PasswordHash::new(encoded)?;
    let argon2 = Argon2::default();
    Ok(argon2.verify_password(password.as_bytes(), &parsed).is_ok())
}
```

## Common mistakes

- Using `rand`'s non-crypto RNGs for salts (use `OsRng`).
- Confusing KiB with bytes.
- Logging hashes or passwords.

## Minimal tests (outline)

- Hash differs across calls
- Verify ok for correct password; fail for wrong
- Tamper fails
