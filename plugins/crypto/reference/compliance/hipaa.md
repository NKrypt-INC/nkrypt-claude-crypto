# HIPAA security rule and encryption (engineering view)

This is not legal advice.

HIPAA does not mandate a single algorithm, but expects reasonable safeguards.
Encryption is a common and powerful safeguard for ePHI.

## Practical checklist

### In transit
- TLS 1.2+ (prefer 1.3)
- Strong certificate validation
- No insecure fallbacks

See: `/crypto:tls`

### At rest
- Encrypt backups, snapshots, and stored sensitive data where appropriate
- Use envelope encryption with KMS/HSM when possible
- Control access and audit key usage

See: `/crypto:secure`, `reference/operations/observability.md`

### Auth and access
- Strong password storage (Argon2id/bcrypt/scrypt)
- MFA for privileged accounts
- Session management and rotation

See: `/crypto:passwords`

### Incident response
- Key compromise playbooks
- Evidence preservation
- User notification workflows (handled by your org’s policy/legal teams)

See: `reference/operations/incident-response.md`
