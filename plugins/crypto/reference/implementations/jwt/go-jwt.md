# Go JWT signing and verification (golang-jwt/jwt v5)

**Package:** `github.com/golang-jwt/jwt/v5`  
**Why this library:** actively maintained fork with better validation ergonomics.

## Install

```bash
go get github.com/golang-jwt/jwt/v5
```

## Verify with algorithm pinning + `kid` selection

You can implement a `Keyfunc` that selects the right public key based on `kid`.

```go
package auth

import (
  "errors"
  "github.com/golang-jwt/jwt/v5"
)

var keyByKID map[string]any // map kid -> public key (ecdsa.PublicKey or rsa.PublicKey)

func Verify(tokenString string) (jwt.MapClaims, error) {
  token, err := jwt.Parse(tokenString, func(t *jwt.Token) (any, error) {
    // Pin allowed algorithms (defense against alg confusion)
    if t.Method.Alg() != jwt.SigningMethodES256.Alg() {
      return nil, errors.New("unexpected alg")
    }
    kidRaw, _ := t.Header["kid"].(string)
    if kidRaw == "" {
      return nil, errors.New("missing kid")
    }
    kid, err := ValidateKID(kidRaw)
    if err != nil {
      return nil, err
    }
    k, ok := keyByKID[kid]
    if !ok {
      return nil, errors.New("unknown kid")
    }
    return k, nil
  })
  if err != nil {
    return nil, err
  }
  if !token.Valid {
    return nil, errors.New("invalid token")
  }
  claims, ok := token.Claims.(jwt.MapClaims)
  if !ok {
    return nil, errors.New("unexpected claims")
  }
  return claims, nil
}
```



## Safe `kid` handling (avoid path traversal)

Do not treat `kid` as a file path or URL. Validate it and look up keys from a map.

```go
package auth

import (
  "errors"
  "regexp"
  "strings"
)

var kidRe = regexp.MustCompile(`^[A-Za-z0-9._-]{1,64}$`)

func ValidateKID(kid string) (string, error) {
  if !kidRe.MatchString(kid) {
    return "", errors.New("invalid kid")
  }
  if strings.Contains(kid, "..") || strings.Contains(kid, "/") || strings.Contains(kid, "\\") {
    return "", errors.New("invalid kid")
  }
  return kid, nil
}
```

## Rotation pattern

- publish a set of public keys (JWK set or equivalent) containing current + previous keys
- sign new tokens with newest key (`kid=new`)
- verify with both during the grace period (max token TTL)
- remove old key from the verify set after grace period

See `reference/operations/key-rotation.md`.

## Common mistakes

- accepting `alg=none` or not pinning algorithms
- trusting `kid` as a file path or URL
- skipping issuer/audience/expiry validation
- using HS256 everywhere with a shared secret and no strong key controls

## Testing

See:
- `reference/testing/jwt-signing.md`
- `reference/operations/key-rotation.md`
