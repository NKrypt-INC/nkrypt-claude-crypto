# Python crypto footguns

Footguns:
- Using `hashlib.sha256(password)` for password storage (too fast).
- Using `random` module for secrets (use `secrets`).
- Disabling TLS validation (`CERT_NONE`, `check_hostname = False`).
- Building custom AES-CBC schemes without authentication.
- Serializing secrets with `pickle` (not crypto, but it breaks security).
- Logging exceptions that include sensitive values.
- Comparing secrets with `==` and leaking timing. Use `hmac.compare_digest` or `secrets.compare_digest`.

Safer defaults:
- `argon2-cffi` for password hashing
- `cryptography` AEAD primitives
- `ssl.create_default_context()` for clients
- `hmac.compare_digest` for secret comparisons

Constant-time compare snippet:

```python
import hmac

def timing_safe_equal(a: bytes, b: bytes) -> bool:
    return hmac.compare_digest(a, b)
```

