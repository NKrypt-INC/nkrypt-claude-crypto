# Python HKDF (cryptography)

```python
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes
import os

def hkdf_sha256(ikm: bytes, salt: bytes, info: bytes, length: int) -> bytes:
    hkdf = HKDF(
        algorithm=hashes.SHA256(),
        length=length,
        salt=salt,
        info=info,
    )
    return hkdf.derive(ikm)

master = os.urandom(32)
salt = os.urandom(16)
enc_key = hkdf_sha256(master, salt, b"enc", 32)
auth_key = hkdf_sha256(master, salt, b"auth", 32)
```

Common mistakes:
- reusing keys across contexts without derivation
- using raw hashes as KDFs
