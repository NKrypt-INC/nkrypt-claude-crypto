# PCI DSS cryptography checklist (engineering view)

This is not legal advice. Use it to drive conversations with your PCI/compliance owners.

## High-level expectations

PCI generally expects:
- strong cryptography for cardholder data in transit and at rest (when applicable)
- robust key management (generation, storage, rotation, access control)
- segmentation and least privilege around sensitive systems
- vulnerability management and logging

## Practical engineering checklist

### Transport (in transit)
- TLS 1.2+ (prefer 1.3)
- No insecure renegotiation, no weak ciphers
- Certificate validation enforced everywhere (no “trust all”)

See: `skills/tls/SKILL.md`

### Storage (at rest)
- Use AEAD (AES-GCM / ChaCha20-Poly1305) for sensitive payloads
- Use envelope encryption with KMS/HSM where possible
- Separate duties for key admins vs app operators

See: `skills/secure/SKILL.md`, `reference/operations/key-rotation.md`

### Keys
- Document key ownership and rotation schedules
- Implement dual-control where required
- Rotate on compromise and at defined intervals

### Logging and secrets
- Never log PANs or secrets
- Scan for secrets committed to repos
- Gate CI on secret scanning failures

See: `/crypto:secrets`

## Evidence-building tips

- Keep config as code (TLS configs, cipher policies)
- Add CI checks for protocol floors and crypto dependency CVEs
- Keep rotation runbooks and incident response runbooks updated
