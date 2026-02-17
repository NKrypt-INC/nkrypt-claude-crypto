# .NET secure randomness (CSPRNG)

Use `RandomNumberGenerator`.

```csharp
using System.Security.Cryptography;

byte[] key = RandomNumberGenerator.GetBytes(32);
byte[] nonce = RandomNumberGenerator.GetBytes(12);
```

Common mistakes:
- using `new Random()` for tokens/keys
