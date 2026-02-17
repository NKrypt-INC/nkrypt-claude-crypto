# Go crypto footguns

Footguns:
- Using `math/rand` for keys, tokens, or salts (use `crypto/rand`).
- Reusing nonces in AES-GCM or ChaCha20-Poly1305.
- Using `InsecureSkipVerify` in TLS clients.
- Rolling your own crypto formats instead of using well-reviewed libs.
- Comparing secrets with regular equality and leaking timing (use `crypto/subtle`).

Safer defaults:
- `crypto/rand` for secrets
- `crypto/subtle.ConstantTimeCompare` for secret comparisons
- `crypto/hmac` for MACs (do not invent your own)
- `crypto/tls` with hardened config and TLS 1.2+ / 1.3

Constant-time compare snippet:

```go
import "crypto/subtle"

func TimingSafeEqual(a, b []byte) bool {
  if len(a) != len(b) {
    return false
  }
  return subtle.ConstantTimeCompare(a, b) == 1
}
```

