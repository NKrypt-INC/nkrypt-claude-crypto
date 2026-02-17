# .NET crypto footguns

Footguns:
- Using `System.Random` for secrets (use `RandomNumberGenerator`).
- Using AES-CBC without authentication.
- Using custom crypto formats without integrity.
- Disabling TLS validation (custom handlers that accept any cert).
- Comparing secrets with `==` or naive `SequenceEqual` in security-sensitive paths. Use `CryptographicOperations.FixedTimeEquals`.

Safer defaults:
- `RandomNumberGenerator.GetBytes` for secrets
- AES-GCM (`AesGcm`) for AEAD encryption
- `CryptographicOperations.FixedTimeEquals` for secret comparisons
- `HttpClient` with default TLS validation and hardened TLS policies

Constant-time compare snippet:

```csharp
using System.Security.Cryptography;

static bool TimingSafeEqual(byte[] a, byte[] b)
{
    if (a.Length != b.Length) return false;
    return CryptographicOperations.FixedTimeEquals(a, b);
}
```

