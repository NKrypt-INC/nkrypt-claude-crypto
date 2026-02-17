# Java AES-GCM (JCA)

**Libraries:** Java Cryptography Architecture (built-in)

## Encrypt + decrypt (copy-paste)

```java
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.security.SecureRandom;

public final class AesGcm {
  private static final SecureRandom RNG = new SecureRandom();
  private static final int NONCE_LEN = 12;     // 96-bit
  private static final int TAG_BITS = 128;     // 16 bytes

  public static record Payload(byte[] nonce, byte[] ct) {}

  public static Payload encrypt(byte[] key32, byte[] plaintext, byte[] aad) throws Exception {
    if (key32.length != 32) throw new IllegalArgumentException("key must be 32 bytes");
    byte[] nonce = new byte[NONCE_LEN];
    RNG.nextBytes(nonce);

    SecretKey key = new SecretKeySpec(key32, "AES");
    Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
    cipher.init(Cipher.ENCRYPT_MODE, key, new GCMParameterSpec(TAG_BITS, nonce));
    if (aad != null) cipher.updateAAD(aad);

    byte[] ct = cipher.doFinal(plaintext); // includes tag
    return new Payload(nonce, ct);
  }

  public static byte[] decrypt(byte[] key32, Payload p, byte[] aad) throws Exception {
    SecretKey key = new SecretKeySpec(key32, "AES");
    Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
    cipher.init(Cipher.DECRYPT_MODE, key, new GCMParameterSpec(TAG_BITS, p.nonce()));
    if (aad != null) cipher.updateAAD(aad);

    return cipher.doFinal(p.ct()); // throws AEADBadTagException on tamper/wrong key/AAD
  }
}
```

## Common mistakes

- Nonce reuse with the same key (catastrophic).
- Using CBC without MAC (use AEAD instead).
- Catching `AEADBadTagException` and returning plaintext anyway (no).

## Minimal tests

- Roundtrip ok
- Wrong key fails
- Wrong AAD fails
- Tamper fails
