# Rust secure randomness (CSPRNG)

Use `rand_core::OsRng` or `getrandom`.

```rust
use rand_core::{OsRng, RngCore};

let mut key = [0u8; 32];
OsRng.fill_bytes(&mut key);
```

Common mistakes:
- using deterministic PRNGs for tokens/keys
