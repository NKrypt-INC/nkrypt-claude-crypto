# Java Argon2id password hashing (argon2-jvm)

**Package:** `de.mkammerer:argon2-jvm`  
**Pinned example version:** `2.12`  
**Why this library:** High-level Argon2 wrapper with encoded hashes (includes salt + params).

## Gradle (Kotlin DSL)

```kotlin
dependencies {
  implementation("de.mkammerer:argon2-jvm:2.12")
}
```

## Maven

```xml
<dependency>
  <groupId>de.mkammerer</groupId>
  <artifactId>argon2-jvm</artifactId>
  <version>2.12</version>
</dependency>
```

## Hash + verify (copy-paste)

```java
import de.mkammerer.argon2.Argon2;
import de.mkammerer.argon2.Argon2Factory;

public final class Passwords {
  // memory is in KiB (65536 KiB = 64 MiB)
  private static final int ITERATIONS = 3;
  private static final int MEMORY_KIB = 65536;
  private static final int PARALLELISM = 1;

  public static String hash(char[] password) {
    Argon2 argon2 = Argon2Factory.create(Argon2Factory.Argon2Types.ARGON2id);
    try {
      return argon2.hash(ITERATIONS, MEMORY_KIB, PARALLELISM, password);
    } finally {
      argon2.wipeArray(password);
    }
  }

  public static boolean verify(String encodedHash, char[] password) {
    Argon2 argon2 = Argon2Factory.create(Argon2Factory.Argon2Types.ARGON2id);
    try {
      return argon2.verify(encodedHash, password);
    } finally {
      argon2.wipeArray(password);
    }
  }
}
```

## Common mistakes

- Using `MessageDigest` (SHA-256/MD5) for passwords.
- Confusing KiB vs bytes for memory.
- Forgetting to wipe password char arrays (risk: heap dumps, logs, crash reports).

## Minimal JUnit tests (outline)

- Hash differs across calls for same password
- Verify succeeds for correct password
- Verify fails for wrong password
- Tampering with hash fails verification

## Operational notes

- Calibrate parameters on production hardware.
- Rate-limit login and reset flows.
