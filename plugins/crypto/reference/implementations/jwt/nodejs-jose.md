# Node.js JWT signing and verification (jose)

**Package:** `jose` (npm)  
**Pinned example version:** `6.1.3` (verify in your lockfile)  
**Why this library:** widely used JOSE implementation with good defaults and active maintenance.

## Install

```bash
npm i jose@6.1.3
```

## Sign (ES256) with `kid`

```js
import { generateKeyPair, exportJWK, SignJWT } from "jose";

const ISSUER = "https://auth.example.com";
const AUDIENCE = "my-api";

// Example only: generate keys at runtime.
// In production, load keys from KMS/HSM or secure storage.
const { publicKey, privateKey } = await generateKeyPair("ES256");
const kid = "key-2026-02-14";

// Publish this in your JWKS endpoint (public only)
const jwk = await exportJWK(publicKey);
jwk.kid = kid;
jwk.use = "sig";
jwk.alg = "ES256";

export async function mintAccessToken(sub) {
  return await new SignJWT({ sub })
    .setProtectedHeader({ alg: "ES256", kid, typ: "JWT" })
    .setIssuer(ISSUER)
    .setAudience(AUDIENCE)
    .setIssuedAt()
    .setExpirationTime("15m")
    .sign(privateKey);
}
```

## Verify with a JWKS (rotation-friendly)

If you host a JWKS endpoint, jose can verify using it directly.

```js
import { createRemoteJWKSet, jwtVerify } from "jose";

const JWKS = createRemoteJWKSet(new URL("https://auth.example.com/.well-known/jwks.json"));

export async function verifyAccessToken(token) {
  const { payload, protectedHeader } = await jwtVerify(token, JWKS, {
    issuer: "https://auth.example.com",
    audience: "my-api",
    algorithms: ["ES256"], // pin allowed algorithms
  });
  return { payload, protectedHeader };
}
```



## Safe `kid` handling (avoid path traversal)

Do not treat `kid` as a file path or URL. Validate it as a small identifier and look up keys from a map or JWKS.

```js
const KID_RE = /^[A-Za-z0-9._-]{1,64}$/;

export function validateKid(kid) {
  if (typeof kid !== "string" || !KID_RE.test(kid)) {
    throw new Error("invalid kid");
  }
  // extra paranoia against path-like values
  if (kid.includes("..") || kid.includes("/") || kid.includes("\\")) {
    throw new Error("invalid kid");
  }
  return kid;
}
```

If you do local key lookup:

```js
const keyByKid = new Map(); // kid -> KeyLike

export function keyForKid(kid) {
  const k = keyByKid.get(validateKid(kid));
  if (!k) throw new Error("unknown kid");
  return k;
}
```

## Common mistakes

- Accepting `alg=none` or not pinning algorithms.
- Trusting `kid` to select arbitrary files or URLs. Treat it as an identifier, not a path.
- Skipping issuer/audience validation.
- Using long-lived access tokens instead of short TTL + refresh flow.
- Using HS256 with shared secrets across many services without strong key management.

## Testing

See:
- `reference/testing/jwt-signing.md`
- `reference/operations/key-rotation.md`
