# Python JWT signing and verification (PyJWT)

**Package:** `PyJWT` (PyPI)  
**Pinned example version:** `2.11.0` (verify in your lockfile)  
**Why this library:** widely used JWT implementation with JWKS client support.

## Install

```bash
python -m pip install "PyJWT==2.11.0"
```

For ES256/ECDSA, you typically also need `cryptography`:

```bash
python -m pip install "cryptography"
```

## Verify with a JWKS endpoint (recommended)

PyJWT includes a JWKS client helper.

```python
import jwt
from jwt import PyJWKClient

ISSUER = "https://auth.example.com"
AUDIENCE = "my-api"

jwks_client = PyJWKClient("https://auth.example.com/.well-known/jwks.json")

def verify_access_token(token: str) -> dict:
    signing_key = jwks_client.get_signing_key_from_jwt(token)
    payload = jwt.decode(
        token,
        signing_key.key,
        algorithms=["ES256"],   # pin allowed algorithms
        audience=AUDIENCE,
        issuer=ISSUER,
        options={
            "require": ["exp", "iat", "iss", "aud"],
        },
    )
    return payload
```

## Sign (ES256) with `kid` (outline)

In production, load the private key from KMS/HSM or secure storage.

```python
import jwt
import time

def mint_access_token(private_key_pem: str, kid: str, sub: str) -> str:
    now = int(time.time())
    payload = {
        "sub": sub,
        "iss": "https://auth.example.com",
        "aud": "my-api",
        "iat": now,
        "exp": now + 15 * 60,
    }
    headers = {"kid": kid, "typ": "JWT"}
    return jwt.encode(payload, private_key_pem, algorithm="ES256", headers=headers)
```



## Safe `kid` handling (avoid path traversal)

If you use `kid` locally (not JWKS), validate it as an identifier.

```python
import re

_KID_RE = re.compile(r"^[A-Za-z0-9._-]{1,64}$")

def validate_kid(kid: str) -> str:
    if not isinstance(kid, str) or not _KID_RE.match(kid):
        raise ValueError("invalid kid")
    if ".." in kid or "/" in kid or "\\" in kid:
        raise ValueError("invalid kid")
    return kid
```

Do not use `kid` as a file path or URL selector.

## Common mistakes

- Not pinning algorithms (algorithm confusion attacks).
- Not validating `iss` and `aud`.
- Using long-lived tokens without rotation or revocation strategy.
- Logging tokens. Tokens are credentials.

## Testing

See:
- `reference/testing/jwt-signing.md`
- `reference/operations/key-rotation.md`
