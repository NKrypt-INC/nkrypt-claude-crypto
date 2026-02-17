# Node.js secure randomness (CSPRNG)

Use Node's built-in `crypto` module.

## Generate random bytes

```js
import crypto from "crypto";

const key = crypto.randomBytes(32);   // AES-256 key
const nonce = crypto.randomBytes(12); // AES-GCM nonce
const token = crypto.randomBytes(32).toString("base64url"); // URL-safe token
```

## Common mistakes

- Using `Math.random()` for anything security related.
- Generating tokens with predictable seeds or timestamps.
