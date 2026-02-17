# Rust AES-GCM (aes-gcm crate)

**Crate:** `aes-gcm`  
**Pinned example version:** `0.10.3`

## Cargo.toml

```toml
[dependencies]
aes-gcm = "0.10.3"
rand_core = "0.10.0"
base64 = "0.22.1"
```

## Encrypt + decrypt (copy-paste)

```rust
use aes_gcm::{Aes256Gcm, KeyInit, aead::{Aead, Payload}};
use rand_core::{OsRng, RngCore};

pub fn encrypt(key32: &[u8; 32], plaintext: &[u8], aad: &[u8]) -> (Vec<u8>, Vec<u8>) {
    let cipher = Aes256Gcm::new(key32.into());

    let mut nonce = [0u8; 12];
    OsRng.fill_bytes(&mut nonce);

    let ct = cipher.encrypt(&nonce.into(), Payload { msg: plaintext, aad }).expect("encrypt");
    (nonce.to_vec(), ct)
}

pub fn decrypt(key32: &[u8; 32], nonce: &[u8], ct: &[u8], aad: &[u8]) -> Result<Vec<u8>, aes_gcm::Error> {
    let cipher = Aes256Gcm::new(key32.into());
    cipher.decrypt(nonce.into(), Payload { msg: ct, aad })
}
```

## Common mistakes

- Nonce reuse (catastrophic).
- Using non-crypto RNG for nonces (use `OsRng`).
- Discarding decrypt errors (they indicate tampering/wrong key/AAD).
