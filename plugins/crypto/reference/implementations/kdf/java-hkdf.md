# Java HKDF-SHA256 (RFC 5869) using JCA Mac

This implements HKDF using `HmacSHA256` with no third-party dependencies.

```java
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.util.Arrays;

public final class HkdfSha256 {

  public static byte[] deriveKey(byte[] ikm, byte[] salt, byte[] info, int length) throws Exception {
    byte[] prk = extract(ikm, salt);
    return expand(prk, info, length);
  }

  private static byte[] extract(byte[] ikm, byte[] salt) throws Exception {
    byte[] actualSalt = (salt == null || salt.length == 0) ? new byte[32] : salt;
    Mac mac = Mac.getInstance("HmacSHA256");
    mac.init(new SecretKeySpec(actualSalt, "HmacSHA256"));
    return mac.doFinal(ikm);
  }

  private static byte[] expand(byte[] prk, byte[] info, int length) throws Exception {
    Mac mac = Mac.getInstance("HmacSHA256");
    mac.init(new SecretKeySpec(prk, "HmacSHA256"));

    final int hashLen = 32;
    int n = (int)Math.ceil((double)length / hashLen);
    if (n > 255) throw new IllegalArgumentException("length too large");

    byte[] okm = new byte[length];
    byte[] t = new byte[0];
    int offset = 0;

    for (int i = 1; i <= n; i++) {
      mac.reset();
      mac.update(t);
      if (info != null) mac.update(info);
      mac.update((byte)i);
      t = mac.doFinal();

      int toCopy = Math.min(hashLen, length - offset);
      System.arraycopy(t, 0, okm, offset, toCopy);
      offset += toCopy;
    }
    return okm;
  }
}
```

Common mistakes:
- DIY KDFs like SHA-256(ikm || label)
- reusing keys across contexts instead of deriving subkeys
