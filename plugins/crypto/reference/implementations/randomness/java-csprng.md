# Java secure randomness (CSPRNG)

Use `java.security.SecureRandom`.

```java
import java.security.SecureRandom;

SecureRandom rng = new SecureRandom();
byte[] key = new byte[32];
rng.nextBytes(key);
```

Common mistakes:
- using `java.util.Random` for keys/tokens
- reusing a single nonce by accident
