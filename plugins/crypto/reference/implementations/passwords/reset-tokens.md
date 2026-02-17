# Password reset tokens (secure pattern)

This pattern avoids storing raw reset tokens and makes tokens single-use.

## Recommendations

- Token lifetime: keep it short. Many teams start with 15–60 minutes (use 5–15 minutes for higher-risk accounts).
- OWASP guidance: enforce a lifetime restriction, use a CSPRNG, invalidate after use, and store reset identifiers securely.
  Reference: https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html
- Token size: 32+ random bytes (256+ bits).
- Format: base64url (no `+` or `/`) or hex.
- Storage: store **only a hash** of the token, not the token itself.
- Single use: invalidate after successful reset.
- Rate limit: cap reset requests per account and per IP.

## Node.js example (hash-at-rest)

```js
import { randomBytes, createHash, timingSafeEqual } from "crypto";

function base64url(buf) {
  return buf.toString("base64").replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

export function mintResetToken() {
  const tokenBytes = randomBytes(32);
  const token = base64url(tokenBytes);
  const tokenHash = createHash("sha256").update(token).digest(); // Buffer
  return { token, tokenHash };
}

export function verifyResetToken(providedToken, storedTokenHash) {
  const providedHash = createHash("sha256").update(providedToken).digest();
  if (providedHash.length !== storedTokenHash.length) return false;
  return timingSafeEqual(providedHash, storedTokenHash);
}
```

Store:
- `tokenHash` (binary or base64)
- `expiresAt`
- `usedAt` (null until used)

Verify flow:
1) look up reset record by user (or token id)
2) check `expiresAt` and `usedAt`
3) constant-time verify
4) mark used (transactionally), then rotate password hash

## Python example (hash-at-rest)

```python
import base64, os, hashlib, hmac

def base64url(b: bytes) -> str:
    return base64.urlsafe_b64encode(b).decode("ascii").rstrip("=")

def mint_reset_token():
    token_bytes = os.urandom(32)
    token = base64url(token_bytes)
    token_hash = hashlib.sha256(token.encode("utf-8")).digest()
    return token, token_hash

def verify_reset_token(provided_token: str, stored_token_hash: bytes) -> bool:
    provided_hash = hashlib.sha256(provided_token.encode("utf-8")).digest()
    return hmac.compare_digest(provided_hash, stored_token_hash)
```

## Common mistakes

- Storing raw tokens in the DB.
- Long-lived tokens (days).
- Allowing token reuse.
- Not rate-limiting reset requests.
- Logging tokens (treat as credentials).
