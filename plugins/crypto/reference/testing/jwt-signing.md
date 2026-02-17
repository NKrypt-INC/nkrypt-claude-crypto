# Testing JWT signing and verification

JWT failures become auth bypasses fast. Test both correctness and refusal behavior.

## Positive tests

- Token signed by current key verifies
- Claims validation works (issuer, audience, expiration, not-before)
- `kid` resolves to the correct key (if using JWK sets)

## Negative tests

- Token with wrong signature fails
- Token with modified payload fails
- Token with expired `exp` fails
- Token with `alg=none` is rejected
- Token with malformed `kid` is rejected (path traversal / URL-like values)
- Token signed with retired key is rejected after grace period

## Rotation tests (operational)

- During rotation window: both old and new keys verify (dual-verify)
- After retirement: old key fails
- New tokens use new `kid`

## Recommendation

Prefer JWK sets + `kid` versioning for smooth rotation.
See `reference/operations/key-rotation.md`.
