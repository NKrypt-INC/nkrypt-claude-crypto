# Python Argon2id password hashing (argon2-cffi)

**Package:** `argon2-cffi` (PyPI)  
**Pinned example version:** `25.1.0` (verify in your lockfile)  
**Why this library:** Maintained Argon2 implementation with safe PHC string handling and “rehash needed” support.

## Install

```bash
python -m pip install "argon2-cffi==25.1.0"
```

## Hash + verify (copy-paste)

```python
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

# memory_cost is in KiB (65536 KiB = 64 MiB)
ph = PasswordHasher(
    time_cost=3,
    memory_cost=65536,
    parallelism=1,
    hash_len=32,
    salt_len=16,
)

def hash_password(password: str) -> str:
    # Returns a PHC-format string embedding parameters and salt.
    return ph.hash(password)

def verify_password(stored_hash: str, password: str) -> bool:
    try:
        return ph.verify(stored_hash, password)
    except VerifyMismatchError:
        return False
    except Exception:
        # Treat parsing / internal errors as failure.
        return False

def verify_and_maybe_rehash(stored_hash: str, password: str, update_hash_fn) -> bool:
    try:
        ph.verify(stored_hash, password)
        if ph.check_needs_rehash(stored_hash):
            update_hash_fn(ph.hash(password))
        return True
    except VerifyMismatchError:
        return False
```

## Common mistakes

- **Using hashlib.sha256 for passwords**: too fast, easy to crack.
- **Setting memory_cost in bytes**: it is KiB.
- **Catching all exceptions and returning “ok”**: treat errors as failure.

## Minimal pytest tests

```python
from yourmodule.passwords import hash_password, verify_password

def test_hash_is_salted():
    h1 = hash_password("pw")
    h2 = hash_password("pw")
    assert h1 != h2

def test_verify_ok_and_fail():
    h = hash_password("pw")
    assert verify_password(h, "pw") is True
    assert verify_password(h, "wrong") is False

def test_tamper_fails():
    h = hash_password("pw")
    tampered = h[:-1] + ("x" if h[-1] != "x" else "y")
    assert verify_password(tampered, "pw") is False
```

## Operational notes

- Tune parameters on production hardware (latency target).
- Rate-limit login and reset endpoints.
- Add MFA for high-value accounts.
