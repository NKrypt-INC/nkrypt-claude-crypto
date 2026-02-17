# Java crypto footguns

Footguns:
- Using `MessageDigest` (SHA-256) directly for password storage (too fast).
- Using AES-CBC without authentication.
- Accepting weak TLS protocol versions or disabling validation.
- Using insecure RNGs (`java.util.Random`) for secrets.
- Comparing secrets with `Arrays.equals` and leaking timing. Use `MessageDigest.isEqual` (or a constant-time helper).

Safer defaults:
- Use a password hashing library (Argon2id preferred)
- Use AES-GCM (or a well-reviewed AEAD library)
- Use `SecureRandom` for secrets
- Use `MessageDigest.isEqual` for secret comparisons
- Use TLS defaults plus explicit hardening

Constant-time compare snippet:

```java
import java.security.MessageDigest;

boolean timingSafeEqual(byte[] a, byte[] b) {
  return MessageDigest.isEqual(a, b);
}
```

