# Node.js Argon2id password hashing (argon2)

**Package:** `argon2` (npm)  
**Pinned example version:** `0.44.0` (verify in your lockfile)  
**Why this library:** Produces standard PHC-format hashes and handles salt generation safely.

## Install

```bash
npm i argon2@0.44.0
# or
pnpm add argon2@0.44.0
# or
yarn add argon2@0.44.0
```

## Hash + verify (copy-paste)

```js
import argon2 from "argon2";

/**
 * Tune these on production hardware.
 * memoryCost is in KiB (65536 KiB = 64 MiB).
 */
const ARGON2_OPTIONS = {
  type: argon2.argon2id,
  timeCost: 3,
  memoryCost: 65536,
  parallelism: 1,
  hashLength: 32,
};

export async function hashPassword(password) {
  // argon2 generates a unique random salt and embeds params in the PHC string.
  return argon2.hash(password, ARGON2_OPTIONS);
}

export async function verifyPassword(storedHash, password) {
  try {
    return await argon2.verify(storedHash, password);
  } catch {
    // Treat parse errors as failure (hash may be corrupted or attacker-controlled input).
    return false;
  }
}
```

### Rehash-on-login pattern

When you change parameters, rehash after a successful login:

```js
export async function verifyAndMaybeRehash(storedHash, password, updateHashFn) {
  const ok = await verifyPassword(storedHash, password);
  if (!ok) return false;

  // If your argon2 library supports needsRehash(), use it.
  // Otherwise, track params in metadata or parse the PHC string prefix.
  // Example (pseudo):
  // if (argon2.needsRehash(storedHash, ARGON2_OPTIONS)) { ... }

  const newHash = await hashPassword(password);
  await updateHashFn(newHash);
  return true;
}
```

## Common mistakes

- **Using SHA-256/MD5 for passwords**: fast hashes make cracking cheap.
- **Setting memoryCost too low**: Argon2's value is in KiB, not bytes.
- **Logging the password or hash**: treat both as sensitive.
- **Treating verify errors as “user not found”**: return a generic auth failure response.

## Minimal Jest tests

```js
import { hashPassword, verifyPassword } from "./passwords.js";

test("hash differs for same password (random salt)", async () => {
  const h1 = await hashPassword("correct horse battery staple");
  const h2 = await hashPassword("correct horse battery staple");
  expect(h1).not.toEqual(h2);
});

test("verify succeeds for correct password and fails for wrong password", async () => {
  const hash = await hashPassword("p@ssw0rd");
  expect(await verifyPassword(hash, "p@ssw0rd")).toBe(true);
  expect(await verifyPassword(hash, "wrong")).toBe(false);
});

test("tampering fails verification", async () => {
  const hash = await hashPassword("p@ssw0rd");
  const tampered = hash.replace(/.$/, "x");
  expect(await verifyPassword(tampered, "p@ssw0rd")).toBe(false);
});
```

## Operational notes

- Calibrate parameters so login verification costs ~100–500ms on production hardware.
- Add rate limiting and account lockout rules to mitigate online guessing.
- Prefer MFA; password hashing cannot stop phishing.
