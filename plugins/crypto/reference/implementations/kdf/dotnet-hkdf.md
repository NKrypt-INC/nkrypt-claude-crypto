# .NET HKDF-SHA256 (RFC 5869) without extra dependencies

.NET does not always expose HKDF as a single built-in API across all target frameworks, so this implements RFC 5869 using `HMACSHA256`.

```csharp
using System;
using System.Security.Cryptography;

public static class HkdfSha256
{
    public static byte[] DeriveKey(byte[] ikm, byte[] salt, byte[] info, int length)
    {
        if (length <= 0) throw new ArgumentOutOfRangeException(nameof(length));

        // Extract
        byte[] prk = Extract(ikm, salt);

        // Expand
        return Expand(prk, info, length);
    }

    private static byte[] Extract(byte[] ikm, byte[] salt)
    {
        byte[] actualSalt = (salt == null || salt.Length == 0) ? new byte[32] : salt;
        using var hmac = new HMACSHA256(actualSalt);
        return hmac.ComputeHash(ikm);
    }

    private static byte[] Expand(byte[] prk, byte[] info, int length)
    {
        using var hmac = new HMACSHA256(prk);

        int hashLen = 32;
        int n = (int)Math.Ceiling((double)length / hashLen);
        if (n > 255) throw new ArgumentOutOfRangeException(nameof(length), "length too large");

        byte[] okm = new byte[length];
        byte[] t = Array.Empty<byte>();
        int offset = 0;

        for (byte i = 1; i <= n; i++)
        {
            // T(i) = HMAC(PRK, T(i-1) | info | i)
            byte[] input = new byte[t.Length + (info?.Length ?? 0) + 1];
            Buffer.BlockCopy(t, 0, input, 0, t.Length);
            if (info != null) Buffer.BlockCopy(info, 0, input, t.Length, info.Length);
            input[input.Length - 1] = i;

            t = hmac.ComputeHash(input);

            int toCopy = Math.Min(hashLen, length - offset);
            Buffer.BlockCopy(t, 0, okm, offset, toCopy);
            offset += toCopy;
        }

        return okm;
    }
}
```

Common mistakes:
- using raw SHA-256 as a KDF
- reusing one key for multiple purposes instead of deriving subkeys
