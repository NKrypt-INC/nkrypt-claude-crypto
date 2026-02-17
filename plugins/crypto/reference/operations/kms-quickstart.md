# KMS and secret manager quickstart (practical patterns)

This is not a cloud guide. It is a set of “do the boring safe thing” patterns that map to `/crypto:secure` and `/crypto:audit`.

## Core pattern: envelope encryption

- Use a KMS/HSM to protect a **KEK** (key encryption key).
- Generate per-object or per-record **DEKs** (data encryption keys).
- Encrypt data with a DEK using AEAD (AES-GCM or ChaCha20-Poly1305).
- Wrap (encrypt) the DEK with the KEK and store the wrapped DEK next to the ciphertext.

This keeps bulk crypto fast and keeps KEKs out of application memory as much as practical.

## Quick table: common ops by provider

This table is intentionally high-level. Providers differ in names and APIs, but the pattern stays the same.

| Provider | Generate a DEK (data key) | Rotate the KEK | Store and fetch app secrets |
| --- | --- | --- | --- |
| AWS | KMS `GenerateDataKey` returns `{plaintext DEK, ciphertext DEK}` | Enable automatic rotation for symmetric keys when available. For manual rotation, create a new key and repoint an alias. | AWS Secrets Manager (preferred) or SSM Parameter Store |
| GCP | Generate DEK client-side and wrap with Cloud KMS `Encrypt` (or use libraries that do envelope encryption for you) | Cloud KMS rotates by creating new key versions (rotation schedule supported) | GCP Secret Manager |
| Azure | Generate DEK client-side and wrap with Key Vault `wrapKey/unwrapKey` | Key Vault uses key versions and rotation policies | Azure Key Vault Secrets |
| Vault | Use Transit `datakey` or wrap DEKs with Transit encrypt/decrypt | Transit keys support versioning and rotation | Vault KV v2 (or another secret store) |

## Provider quick notes

### AWS KMS
- Use **aliases** to keep identifiers stable across rotations.
- Use **EncryptionContext** to bind ciphertext to purpose (helps prevent key misuse).
- Turn on CloudTrail logging for KMS key usage when you need an audit trail.

### Google Cloud KMS
- Use IAM + audit logs to control and record unwrap operations.
- Prefer key versioning with a clear rotation policy.

### Azure Key Vault
- Prefer managed identity for apps where possible.
- Track key versions and enforce least privilege on unwrap.

### HashiCorp Vault (Transit)
- Transit supports versioned keys and rotation.
- Use Vault audit devices to record unwrap/decrypt operations.

## What /crypto:audit should flag

- long-lived application secrets in config files or env defaults
- DEKs stored in the clear
- KMS usage without key versioning or without a stable key identifier strategy (alias, version field, `kid`)
- missing audit trails for unwrap operations when compliance requires it

## Operational guardrails

- Separate duties: developers should not hold production KEK material.
- Log unwrap/decrypt operations (or enable provider audit logging).
- Design rollback: keep previous key versions usable for decrypt/verify during grace windows.
- Test failure modes: KMS throttling, permission errors, region outages.

See:
- `reference/operations/key-rotation.md`
- `reference/operations/incident-response.md`

