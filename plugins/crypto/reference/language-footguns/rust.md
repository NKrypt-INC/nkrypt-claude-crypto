# Rust crypto footguns

Footguns:
- Using homegrown crypto instead of vetted crates.
- Reusing nonces with nonce-misuse-intolerant AEADs.
- Using `rand` for secrets instead of OS RNGs (`rand::rngs::OsRng` or `getrandom`).
- Comparing secrets with `==` and leaking timing. Use constant-time equality (`subtle` or `ring`).

Safer defaults:
- Prefer high-level, well-reviewed crates (for example, `ring`, `rustls`, `argon2`, `aes-gcm`, `chacha20poly1305`)
- Use `subtle::ConstantTimeEq` for secret comparisons
- Use `getrandom` / `OsRng` for randomness

Constant-time compare snippet (with `subtle`):

```rust
use subtle::ConstantTimeEq;

fn timing_safe_equal(a: &[u8], b: &[u8]) -> bool {
    if a.len() != b.len() { return false; }
    a.ct_eq(b).into()
}
```

