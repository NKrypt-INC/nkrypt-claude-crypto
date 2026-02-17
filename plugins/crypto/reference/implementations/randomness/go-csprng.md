# Go secure randomness (CSPRNG)

Use `crypto/rand`.

```go
import "crypto/rand"

b := make([]byte, 32)
if _, err := rand.Read(b); err != nil {
    // handle error
}
```

Common mistakes:
- using `math/rand` for salts, keys, tokens
