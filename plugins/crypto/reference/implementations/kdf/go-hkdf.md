# Go HKDF (x/crypto/hkdf)

```go
import (
  "crypto/sha256"
  "golang.org/x/crypto/hkdf"
  "io"
)

func HKDFSHA256(ikm, salt, info []byte, length int) ([]byte, error) {
  r := hkdf.New(sha256.New, ikm, salt, info)
  out := make([]byte, length)
  if _, err := io.ReadFull(r, out); err != nil {
    return nil, err
  }
  return out, nil
}
```

Common mistakes:
- using `sha256.Sum256(ikm || info)` as a DIY KDF
