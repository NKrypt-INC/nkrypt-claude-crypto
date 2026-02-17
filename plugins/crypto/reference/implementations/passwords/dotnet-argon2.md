# .NET Argon2id password hashing (Konscious)

**Package:** `Konscious.Security.Cryptography.Argon2` (NuGet)  
**Pinned example version:** `1.3.1`  
**Why this library:** Widely used Argon2 implementation that integrates with .NET crypto patterns.

## Install

```bash
dotnet add package Konscious.Security.Cryptography.Argon2 --version 1.3.1
```

## Hash + verify (copy-paste)

This stores hashes as a PHC-like string:

`$argon2id$v=19$m=65536,t=3,p=1$<salt_b64>$<hash_b64>`

```csharp
using System;
using System.Security.Cryptography;
using System.Text;
using Konscious.Security.Cryptography;

public static class Passwords
{
    // memory is in KiB (65536 KiB = 64 MiB)
    private const int Iterations = 3;
    private const int MemoryKiB = 65536;
    private const int Parallelism = 1;
    private const int SaltLength = 16;
    private const int KeyLength = 32;

    public static string HashPassword(string password)
    {
        byte[] salt = RandomNumberGenerator.GetBytes(SaltLength);

        byte[] hash = Derive(password, salt, Iterations, MemoryKiB, Parallelism, KeyLength);

        return $"$argon2id$v=19$m={MemoryKiB},t={Iterations},p={Parallelism}${ToB64(salt)}${ToB64(hash)}";
    }

    public static bool VerifyPassword(string password, string encoded)
    {
        if (!TryDecode(encoded, out var salt, out var expected, out var p))
            return false;

        byte[] actual = Derive(password, salt, p.iterations, p.memoryKiB, p.parallelism, expected.Length);

        return CryptographicOperations.FixedTimeEquals(actual, expected);
    }

    public static bool NeedsRehash(string encoded)
    {
        return !TryDecode(encoded, out _, out _, out var p)
               || p.iterations != Iterations
               || p.memoryKiB != MemoryKiB
               || p.parallelism != Parallelism;
    }

    private static byte[] Derive(string password, byte[] salt, int iterations, int memoryKiB, int parallelism, int length)
    {
        using var argon2 = new Argon2id(Encoding.UTF8.GetBytes(password))
        {
            Salt = salt,
            Iterations = iterations,
            MemorySize = memoryKiB,
            DegreeOfParallelism = parallelism,
        };
        return argon2.GetBytes(length);
    }

    private static string ToB64(byte[] bytes) =>
        Convert.ToBase64String(bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');

    private static byte[] FromB64(string b64)
    {
        string s = b64.Replace('-', '+').Replace('_', '/');
        switch (s.Length % 4)
        {
            case 2: s += "=="; break;
            case 3: s += "="; break;
        }
        return Convert.FromBase64String(s);
    }

    private static bool TryDecode(string encoded, out byte[] salt, out byte[] hash, out (int memoryKiB, int iterations, int parallelism) p)
    {
        salt = Array.Empty<byte>();
        hash = Array.Empty<byte>();
        p = default;

        // $argon2id$v=19$m=...,t=...,p=...$salt$hash
        var parts = encoded.Split('$', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length != 5) return false;
        if (parts[0] != "argon2id") return false;
        if (parts[1] != "v=19") return false;

        try
        {
            // parts[2] like: m=65536,t=3,p=1
            int m = 0, t = 0, par = 0;
            foreach (var kv in parts[2].Split(','))
            {
                var pair = kv.Split('=');
                if (pair.Length != 2) return false;
                if (pair[0] == "m") m = int.Parse(pair[1]);
                if (pair[0] == "t") t = int.Parse(pair[1]);
                if (pair[0] == "p") par = int.Parse(pair[1]);
            }

            salt = FromB64(parts[3]);
            hash = FromB64(parts[4]);
            p = (m, t, par);
            return salt.Length >= 16 && hash.Length >= 16 && m > 0 && t > 0 && par > 0;
        }
        catch
        {
            return false;
        }
    }
}
```

## Common mistakes

- Using `new Random()` for salts or tokens (must use `RandomNumberGenerator`).
- Forgetting constant-time compare (use `FixedTimeEquals`).
- Storing raw derived bytes without storing parameters and salt.

## Minimal xUnit tests (outline)

- Hash differs across calls
- Verify succeeds for correct password
- Verify fails for wrong password
- Tampering fails
- NeedsRehash detects parameter changes
