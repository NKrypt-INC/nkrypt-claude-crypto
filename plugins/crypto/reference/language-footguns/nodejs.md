# Node.js crypto footguns

Footguns:
- `crypto.createCipher()` / `createDecipher()` (deprecated, implicit IV and weak defaults). Use `createCipheriv` with AEAD.
- AES-CBC without authentication (must use AEAD or add a MAC correctly).
- Forgetting GCM auth tags or reusing nonces.
- `Math.random()` for tokens or keys.
- `rejectUnauthorized: false` or custom agents that skip TLS validation.
- JWT libraries that allow `alg=none` or accept attacker-controlled `kid` paths (key confusion).
- Comparing secrets (MACs, tokens, hashes) with `===` or string equality. Use `crypto.timingSafeEqual` on bytes.

Safer defaults:
- AES-256-GCM with random 96-bit IV
- `crypto.randomBytes` for secrets
- `crypto.timingSafeEqual` for secret comparisons (after a length check)
- jose-like libraries that validate `alg` and claims strictly

Constant-time compare snippet:

```js
import { timingSafeEqual } from "crypto";

export function timingSafeEqualBytes(a, b) {
  const ab = Buffer.isBuffer(a) ? a : Buffer.from(a);
  const bb = Buffer.isBuffer(b) ? b : Buffer.from(b);
  if (ab.length !== bb.length) return false;
  return timingSafeEqual(ab, bb);
}
```

