# Python AES-GCM (cryptography)

**Package:** `cryptography`  
**Pinned example version:** `46.0.5`  
**Why this library:** Maintained primitives with high-level AEAD APIs.

## Install

```bash
python -m pip install "cryptography==46.0.5"
```

## Encrypt + decrypt (copy-paste)

```python
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

def encrypt_aes_gcm(key32: bytes, plaintext: bytes, aad: bytes | None = None) -> dict:
    if len(key32) != 32:
        raise ValueError("key must be 32 bytes (AES-256)")
    aesgcm = AESGCM(key32)
    nonce = os.urandom(12)  # 96-bit nonce recommended for GCM
    ct = aesgcm.encrypt(nonce, plaintext, aad)  # ct includes auth tag at the end
    return {
        "nonce": nonce.hex(),
        "ct": ct.hex(),
    }

def decrypt_aes_gcm(key32: bytes, payload: dict, aad: bytes | None = None) -> bytes:
    aesgcm = AESGCM(key32)
    nonce = bytes.fromhex(payload["nonce"])
    ct = bytes.fromhex(payload["ct"])
    return aesgcm.decrypt(nonce, ct, aad)  # raises InvalidTag on tamper/wrong key/aad
```

## Common mistakes

- Reusing a nonce with the same key (catastrophic).
- Treating encryption errors as “return plaintext anyway”.
- Using AES-CBC without authentication.

## Minimal tests

- Roundtrip ok
- Wrong key fails (InvalidTag)
- Wrong AAD fails
- Tamper fails
