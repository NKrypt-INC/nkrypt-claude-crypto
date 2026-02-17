# Fuzzing and property-based testing starters (crypto-adjacent)

Most teams do not fuzz cryptographic primitives. Teams do fuzz:
- message formats (serialization, encoding, framing)
- crypto “glue” code (nonce handling, key selection, envelope formats)
- parsing paths (JWT headers, key IDs, certificate parsing wrappers)

This doc gives runnable starters to catch crashes, panics, and “accepts garbage” bugs.

## Go: built-in fuzzing (AEAD roundtrip property)

```go
package cryptotest

import (
  "crypto/rand"
  "testing"
)

func FuzzEncryptDecrypt(f *testing.F) {
  f.Add([]byte("hello"), []byte("header"))
  f.Fuzz(func(t *testing.T, pt []byte, aad []byte) {
    key := make([]byte, 32)
    nonce := make([]byte, 12)
    _, _ = rand.Read(key)
    _, _ = rand.Read(nonce)

    ct := Encrypt(key, nonce, pt, aad)
    out, err := Decrypt(key, nonce, ct, aad)
    if err != nil {
      t.Fatalf("decrypt failed: %v", err)
    }
    if string(out) != string(pt) {
      t.Fatalf("mismatch")
    }

    // Flip a bit and require failure.
    if len(ct) > 0 {
      ct2 := make([]byte, len(ct))
      copy(ct2, ct)
      ct2[0] ^= 1
      if _, err := Decrypt(key, nonce, ct2, aad); err == nil {
        t.Fatalf("expected tamper to fail")
      }
    }
  })
}
```

Run:
```bash
go test -fuzz=Fuzz -fuzztime=30s ./...
```

## Python: Hypothesis property tests (AEAD style)

```python
import os
import pytest
from hypothesis import given, strategies as st

@given(
    pt=st.binary(min_size=0, max_size=2048),
    aad=st.binary(min_size=0, max_size=256),
)
def test_encrypt_decrypt_property(pt, aad):
    key = os.urandom(32)
    nonce = os.urandom(12)
    ct = encrypt(key, nonce, pt, aad)
    assert decrypt(key, nonce, ct, aad) == pt
```

## Node.js: fast-check starter

```js
import fc from "fast-check";
import { randomBytes } from "crypto";

test("AEAD property", () => {
  fc.assert(
    fc.property(fc.uint8Array(), fc.uint8Array(), (ptArr, aadArr) => {
      const key = randomBytes(32);
      const nonce = randomBytes(12);
      const pt = Buffer.from(ptArr);
      const aad = Buffer.from(aadArr);
      const ct = encrypt(key, nonce, pt, aad);
      const out = decrypt(key, nonce, ct, aad);
      return out.equals(pt);
    }),
    { numRuns: 200 }
  );
});
```

## Rust: cargo-fuzz starter (format parsing or glue code)

Crypto primitives should come from vetted libraries. Fuzz the glue code.

Harness outline (`fuzz/fuzz_targets/parse_format.rs`):

```rust
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = try_parse_and_decrypt(data);
});
```

Run:
```bash
cargo install cargo-fuzz
cargo fuzz run parse_format -- -max_total_time=30
```

## Notes

- Fuzzing finds panics and weird acceptance. It does not prove crypto security.
- Keep fuzz targets deterministic and side-effect-free.
- Save crashing inputs as regression tests.
