# Key rotation playbooks (practical)

Rotation is not an abstract “best practice”. It is how you survive leaks.

## Principles

- Version keys. Everything should have an identifier (`kid`, key version number, alias version).
- Support a **dual-key window**:
  - sign/encrypt with the newest key
  - verify/decrypt with both new and previous keys
- Keep rollback safe:
  - ability to re-enable previous verify/decrypt
  - but never resurrect compromised keys

## 1) JWT signing key rotation (without breaking sessions)

### Pattern: `kid` + JWK set

**Goal:** existing tokens keep verifying while new tokens switch to new key.

Steps:
1) Generate a new signing key (Key B).
2) Publish JWK set containing **Key A + Key B**.
3) Start signing new tokens with **Key B** and set `kid=B`.
4) Keep accepting tokens signed by Key A during the grace period (max token TTL).
5) After grace period, remove Key A from verification set.
6) Optional: force-refresh tokens for high-risk users.

Rollbacks:
- If Key B breaks clients, continue verifying both and temporarily sign with Key A again.
- If Key A is compromised, skip rollback and revoke/rotate immediately.

### Notes
- Prefer asymmetric signing (EdDSA/ES256) when feasible.
- If using HMAC (HS256), treat the secret like a password and rotate aggressively.

## 2) DEK rotation (data encryption keys)

DEKs encrypt data. KEKs wrap DEKs.

### Pattern: envelope encryption
- Data encrypted under a per-record or per-tenant DEK
- DEK wrapped by KEK in KMS/HSM

Rotation options:

A) **Re-wrap only (cheap)**
- Generate new KEK (or new KEK version)
- Re-encrypt (wrap) existing DEKs under new KEK
- Data ciphertext does not change

B) **Re-encrypt data (expensive but sometimes required)**
- Generate new DEKs and re-encrypt ciphertext
- Used when DEKs may be compromised or construction changed

## 3) KEK rotation (KMS/HSM key)

1) Create new KEK version (or new key) in KMS.
2) Update application to use new KEK for wrapping new DEKs.
3) Re-wrap existing DEKs under new KEK (background job).
4) Maintain ability to unwrap with old KEK until re-wrap completes.
5) Disable old KEK usage for new wraps; eventually disable decrypt/unwrapping after completion.

## 4) Rotation testing checklist

- Can decrypt/verify data created under old key after deploy?
- Can decrypt/verify after rollback?
- Are metrics in place for failures and key id distribution?
- Can you disable the new key quickly (feature flag / config)?

See also:
- `reference/operations/incident-response.md`
- `reference/testing/jwt-signing.md`


## 5) KMS/HSM operational controls (often required in real orgs)

Rotation fails when humans cannot execute it safely.

Add these controls where possible:

- **Separation of duties:** the person who deploys code should not also have blanket key-admin permissions.
- **Quorum / dual control:** require multiple approvers for key creation, policy changes, or key deletion where your platform supports it.
- **Audit trails:** enable and retain key usage logs (unwrap/decrypt/sign events) and admin actions (policy changes, disables).
- **Least privilege:** give services only the operations they need (decrypt, not admin).
- **Break-glass process:** predefine how you rotate during an incident when normal approvals are too slow.

If you use cloud KMS/HSM:
- treat key policy and IAM changes as code-reviewed artifacts
- test rotation in a staging environment that mirrors prod policies
