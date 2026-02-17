# Testing AEAD encryption (AES-GCM / ChaCha20-Poly1305)

AEAD tests should verify confidentiality and integrity behaviors.

## Positive tests

- encrypt → decrypt roundtrip returns original plaintext
- different nonces produce different ciphertexts (for same key + plaintext)

## Negative tests (integrity)

- wrong key fails decryption
- wrong nonce fails decryption
- wrong AAD fails decryption (if you use AAD)
- tampered ciphertext fails decryption
- tampered tag fails decryption (if tag is separate)

## Example: Node.js + Jest (AES-GCM style)

```js
import { randomBytes } from "crypto";
import { encrypt, decrypt } from "../crypto/aesgcm.js";

test("roundtrip works", () => {
  const key = randomBytes(32);
  const nonce = randomBytes(12);
  const aad = Buffer.from("header");
  const pt = Buffer.from("hello");

  const ct = encrypt(key, nonce, pt, aad);
  const out = decrypt(key, nonce, ct, aad);
  expect(out.toString("utf8")).toBe("hello");
});

test("tamper fails", () => {
  const key = randomBytes(32);
  const nonce = randomBytes(12);
  const aad = Buffer.from("header");
  const pt = Buffer.from("hello");

  const ct = encrypt(key, nonce, pt, aad);
  ct[0] ^= 1;
  expect(() => decrypt(key, nonce, ct, aad)).toThrow();
});
```

## Example: Python + pytest (property-style)

```python
import os
import pytest
from yourpkg.crypto import encrypt, decrypt

def test_roundtrip():
    key = os.urandom(32)
    nonce = os.urandom(12)
    aad = b"header"
    pt = b"hello"
    ct = encrypt(key, nonce, pt, aad)
    assert decrypt(key, nonce, ct, aad) == pt

def test_tamper_fails():
    key = os.urandom(32)
    nonce = os.urandom(12)
    aad = b"header"
    pt = b"hello"
    ct = bytearray(encrypt(key, nonce, pt, aad))
    ct[0] ^= 1
    with pytest.raises(Exception):
        decrypt(key, nonce, bytes(ct), aad)
```

## Fuzzing and property-based testing (recommended when you build formats)

See `reference/testing/fuzzing.md` for runnable starters.


- Go: use built-in fuzzing (`go test -fuzz=Fuzz`).
- Python: use Hypothesis for randomized payload sizes and AAD variations.
- Node: use fast-check for randomized inputs.

Core properties:
- `decrypt(encrypt(k, p, aad), k, aad) == p`
- if you flip 1 bit in ciphertext or tag, decrypt must fail

## Notes

- Never ignore decrypt errors and continue.
- If you build a payload format, test encoding/decoding too (base64url/hex correctness).
- Test nonce uniqueness rules. Treat nonce reuse as a blocker for GCM.
