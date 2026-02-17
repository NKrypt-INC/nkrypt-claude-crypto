# Go AES-GCM (standard library)

**Packages:** `crypto/aes`, `crypto/cipher`, `crypto/rand`

## Encrypt + decrypt (copy-paste)

```go
package aead

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"errors"
	"io"
)

type Payload struct {
	Nonce []byte
	Ct    []byte // ciphertext + tag (Go appends tag internally)
}

func EncryptAESGCM(key []byte, plaintext []byte, aad []byte) (Payload, error) {
	if len(key) != 32 {
		return Payload{}, errors.New("key must be 32 bytes (AES-256)")
	}
	block, err := aes.NewCipher(key)
	if err != nil {
		return Payload{}, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return Payload{}, err
	}
	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return Payload{}, err
	}

	ct := gcm.Seal(nil, nonce, plaintext, aad)
	return Payload{Nonce: nonce, Ct: ct}, nil
}

func DecryptAESGCM(key []byte, p Payload, aad []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	return gcm.Open(nil, p.Nonce, p.Ct, aad)
}
```

## Common mistakes

- Nonce reuse with the same key (catastrophic).
- Using `math/rand` for nonces (must use `crypto/rand`).
- Ignoring errors from `Open()` (it fails on tamper/wrong key/AAD).

## Minimal tests

- Roundtrip ok
- Wrong key fails
- Wrong AAD fails
- Tamper fails
