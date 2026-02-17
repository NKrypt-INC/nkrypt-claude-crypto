# Node.js HKDF (built-in crypto)

HKDF (RFC 5869) derives one or more subkeys from a root key.

Use HKDF to derive separate keys for:
- encryption
- authentication
- key wrapping
…instead of reusing one key everywhere.

```js
import crypto from "crypto";

export function hkdfSha256({ ikm, salt, info, length }) {
  // ikm, salt, info are Buffers
  return crypto.hkdfSync("sha256", ikm, salt, info, length);
}

// Example:
const master = crypto.randomBytes(32);
const salt = crypto.randomBytes(16);
const encKey = hkdfSha256({ ikm: master, salt, info: Buffer.from("enc"), length: 32 });
const authKey = hkdfSha256({ ikm: master, salt, info: Buffer.from("auth"), length: 32 });
```

Common mistakes:
- using SHA-256(master || "label") as a DIY KDF
- reusing one key for multiple purposes
