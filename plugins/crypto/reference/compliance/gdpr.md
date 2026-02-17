# GDPR crypto and data protection (engineering view)

This is not legal advice.

GDPR expects appropriate technical and organizational measures.
Encryption and pseudonymization are frequently referenced as examples of such measures.

## Practical checklist

- Encrypt data in transit (TLS 1.2+)
- Encrypt sensitive data at rest where feasible
- Keep keys separate from encrypted data
- Rotate keys and revoke on compromise
- Minimize data retention (crypto can’t justify keeping data forever)

## Engineering outputs that help

- A crypto inventory (/crypto:audit report)
- Documented key management and rotation procedures
- Secret scanning + CI gates
- Incident response procedures for key/secret compromise
