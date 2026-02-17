# Node.js AES-256-GCM (built-in crypto)

**Library:** Node.js built-in `crypto`  
**Why this pattern:** AES-GCM gives confidentiality + integrity in one construction (AEAD).

## Encrypt + decrypt (copy-paste)

This returns a portable payload you can store as JSON:
- `iv` (nonce): 12 random bytes
- `ct`: ciphertext
- `tag`: authentication tag (16 bytes)

```js
import crypto from "crypto";

export function encryptAesGcm(key32, plaintextBytes, aadBytes = null) {
  if (key32.length !== 32) throw new Error("key must be 32 bytes");
  const iv = crypto.randomBytes(12);

  const cipher = crypto.createCipheriv("aes-256-gcm", key32, iv);
  if (aadBytes) cipher.setAAD(aadBytes);

  const ct = Buffer.concat([cipher.update(plaintextBytes), cipher.final()]);
  const tag = cipher.getAuthTag();

  return {
    iv: iv.toString("base64url"),
    ct: ct.toString("base64url"),
    tag: tag.toString("base64url"),
  };
}

export function decryptAesGcm(key32, payload, aadBytes = null) {
  const iv = Buffer.from(payload.iv, "base64url");
  const ct = Buffer.from(payload.ct, "base64url");
  const tag = Buffer.from(payload.tag, "base64url");

  const decipher = crypto.createDecipheriv("aes-256-gcm", key32, iv);
  if (aadBytes) decipher.setAAD(aadBytes);
  decipher.setAuthTag(tag);

  return Buffer.concat([decipher.update(ct), decipher.final()]);
}
```

## Common mistakes

- **Nonce reuse with the same key**: catastrophic in GCM.
  - Use a fresh random 96-bit IV per message (shown above) or a counter scheme.
- **Forgetting to store the auth tag**: decryption will fail or, worse, you might skip verification.
- **Using CBC without authentication**: use AEAD instead.
- **Using string encodings incorrectly**: encrypt bytes; decide encoding at the edges.

## Minimal tests

- Roundtrip works
- Wrong key fails
- Wrong AAD fails
- Tampered ciphertext fails
- Tampered tag fails
