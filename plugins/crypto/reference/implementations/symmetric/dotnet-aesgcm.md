# .NET AES-GCM (System.Security.Cryptography)

**Library:** .NET built-in `System.Security.Cryptography`

## Encrypt + decrypt (copy-paste)

```csharp
using System;
using System.Security.Cryptography;

public static class AesGcmCrypto
{
    public sealed record Payload(byte[] Nonce, byte[] Ciphertext, byte[] Tag);

    public static Payload Encrypt(byte[] key32, byte[] plaintext, byte[]? aad = null)
    {
        if (key32.Length != 32) throw new ArgumentException("key must be 32 bytes (AES-256)");

        byte[] nonce = RandomNumberGenerator.GetBytes(12);
        byte[] ciphertext = new byte[plaintext.Length];
        byte[] tag = new byte[16];

        using var aesgcm = new AesGcm(key32);
        aesgcm.Encrypt(nonce, plaintext, ciphertext, tag, aad);

        return new Payload(nonce, ciphertext, tag);
    }

    public static byte[] Decrypt(byte[] key32, Payload p, byte[]? aad = null)
    {
        byte[] plaintext = new byte[p.Ciphertext.Length];
        using var aesgcm = new AesGcm(key32);
        aesgcm.Decrypt(p.Nonce, p.Ciphertext, p.Tag, plaintext, aad);
        return plaintext; // throws CryptographicException on tamper/wrong key/AAD
    }
}
```

## Common mistakes

- Reusing a nonce (catastrophic).
- Losing the tag (decryption will fail).
- Using `Random` for nonce generation (use `RandomNumberGenerator`).

## Minimal tests

- Roundtrip ok
- Wrong key fails
- Wrong AAD fails
- Tamper fails


## Side-channel note (when it matters)

Most application teams can use platform primitives safely.

If you operate under strong local attacker models (co-tenancy, shared hardware, or hostile runtime), treat side-channels as a first-class requirement and review:
- `reference/controls/side-channels.md`
