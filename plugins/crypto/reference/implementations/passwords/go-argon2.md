# Go Argon2id password hashing (x/crypto/argon2)

**Package:** `golang.org/x/crypto/argon2`  
**Pinned example version:** `v0.48.0` (verify in your `go.mod`)  
**Why this approach:** Uses Go's maintained Argon2 implementation and stores hashes in standard PHC string format.

## Hash + verify (copy-paste)

This implementation stores hashes as:

`$argon2id$v=19$m=65536,t=3,p=1$<salt_b64>$<hash_b64>`

```go
package passwords

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"

	"golang.org/x/crypto/argon2"
)

type Argon2Params struct {
	Memory      uint32 // KiB
	Iterations  uint32
	Parallelism uint8
	SaltLength  uint32
	KeyLength   uint32
}

var DefaultParams = Argon2Params{
	Memory:      64 * 1024, // 64 MiB
	Iterations:  3,
	Parallelism: 1,
	SaltLength:  16,
	KeyLength:   32,
}

func HashPassword(password string, p Argon2Params) (string, error) {
	salt := make([]byte, p.SaltLength)
	if _, err := rand.Read(salt); err != nil {
		return "", err
	}

	hash := argon2.IDKey([]byte(password), salt, p.Iterations, p.Memory, p.Parallelism, p.KeyLength)

	b64Salt := base64.RawStdEncoding.EncodeToString(salt)
	b64Hash := base64.RawStdEncoding.EncodeToString(hash)

	encoded := fmt.Sprintf("$argon2id$v=19$m=%d,t=%d,p=%d$%s$%s",
		p.Memory, p.Iterations, p.Parallelism, b64Salt, b64Hash)

	return encoded, nil
}

func VerifyPassword(password, encodedHash string) (bool, error) {
	p, salt, expectedHash, err := decodePHC(encodedHash)
	if err != nil {
		return false, err
	}

	hash := argon2.IDKey([]byte(password), salt, p.Iterations, p.Memory, p.Parallelism, uint32(len(expectedHash)))

	if subtle.ConstantTimeCompare(hash, expectedHash) == 1 {
		return true, nil
	}
	return false, nil
}

func NeedsRehash(encodedHash string, desired Argon2Params) bool {
	p, _, _, err := decodePHC(encodedHash)
	if err != nil {
		return true
	}
	return p.Memory != desired.Memory ||
		p.Iterations != desired.Iterations ||
		p.Parallelism != desired.Parallelism ||
		p.SaltLength != desired.SaltLength ||
		p.KeyLength != desired.KeyLength
}

func decodePHC(encoded string) (Argon2Params, []byte, []byte, error) {
	// Expected: $argon2id$v=19$m=...,t=...,p=...$salt$hash
	parts := strings.Split(encoded, "$")
	if len(parts) != 6 || parts[1] != "argon2id" {
		return Argon2Params{}, nil, nil, errors.New("invalid argon2id hash format")
	}
	if parts[2] != "v=19" {
		return Argon2Params{}, nil, nil, errors.New("unsupported argon2 version")
	}

	var p Argon2Params
	if _, err := fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &p.Memory, &p.Iterations, &p.Parallelism); err != nil {
		return Argon2Params{}, nil, nil, errors.New("invalid argon2 params")
	}

	salt, err := base64.RawStdEncoding.DecodeString(parts[4])
	if err != nil {
		return Argon2Params{}, nil, nil, errors.New("invalid salt encoding")
	}
	hash, err := base64.RawStdEncoding.DecodeString(parts[5])
	if err != nil {
		return Argon2Params{}, nil, nil, errors.New("invalid hash encoding")
	}

	p.SaltLength = uint32(len(salt))
	p.KeyLength = uint32(len(hash))
	return p, salt, hash, nil
}
```

## Common mistakes

- Using `math/rand` for salts (must use `crypto/rand`).
- Forgetting to store Argon2 parameters (rehash detection becomes guessy).
- Using `argon2.Key()` instead of `argon2.IDKey()` for password hashing.

## Minimal Go tests

```go
func TestHashAndVerify(t *testing.T) {
    h1, _ := HashPassword("pw", DefaultParams)
    h2, _ := HashPassword("pw", DefaultParams)
    if h1 == h2 { t.Fatal("expected different hashes due to random salt") }

    ok, err := VerifyPassword("pw", h1)
    if err != nil || !ok { t.Fatal("expected verify ok") }

    ok, _ = VerifyPassword("wrong", h1)
    if ok { t.Fatal("expected verify fail") }

    // Tamper
    tampered := h1[:len(h1)-1] + "x"
    ok, _ = VerifyPassword("pw", tampered)
    if ok { t.Fatal("expected tamper fail") }
}
```

## Operational notes

Tune Argon2 parameters to your production hardware and threat model (latency target, memory budget, DoS risk).
