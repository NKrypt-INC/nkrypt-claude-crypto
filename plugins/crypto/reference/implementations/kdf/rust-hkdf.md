# Rust HKDF (hkdf crate)

**Crate:** `hkdf` (example pinned to `0.12.4`)

```toml
[dependencies]
hkdf = "0.12.4"
sha2 = "0.10.8"
```

```rust
use hkdf::Hkdf;
use sha2::Sha256;

pub fn hkdf_sha256(ikm: &[u8], salt: &[u8], info: &[u8], length: usize) -> Vec<u8> {
    let hk = Hkdf::<Sha256>::new(Some(salt), ikm);
    let mut okm = vec![0u8; length];
    hk.expand(info, &mut okm).expect("hkdf expand");
    okm
}
```

Common mistakes:
- using raw hashes as KDFs
- reusing keys instead of deriving subkeys
