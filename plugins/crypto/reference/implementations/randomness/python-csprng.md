# Python secure randomness (CSPRNG)

Use the `secrets` module for tokens and `os.urandom` for raw bytes.

```python
import secrets

token = secrets.token_urlsafe(32)     # good for reset tokens
key = secrets.token_bytes(32)         # AES-256 key material
nonce = secrets.token_bytes(12)       # AES-GCM nonce
```

Common mistakes:
- using `random.random()` or `random.Random()` for secrets
- using UUIDv1 for tokens (time+MAC derived)
