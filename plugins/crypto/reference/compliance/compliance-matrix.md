# Compliance mapping matrix (starter)

This matrix helps you map plugin activities to common compliance evidence needs.

| Control area | What auditors often want | Use this plugin |
|---|---|---|
| Crypto inventory | List of algorithms, libraries, key usage | `/crypto:audit` |
| Password storage | Password hashing design + parameters | `/crypto:passwords` + implementations |
| Encryption at rest | Construction choice + key management | `/crypto:secure` + symmetric implementations |
| TLS hardening | Protocol floors + ciphers + verification | `/crypto:tls` + TLS implementations |
| Key lifecycle | Rotation schedule + runbooks + rollback | `reference/operations/key-rotation.md` |
| Secret hygiene | Proof secrets aren’t in repos | `/crypto:secrets` |
| Vulnerability mgmt | Dependency scanning evidence | `/crypto:audit` dependency section + CI examples |
| Incident response | Runbooks and rotation procedures | `reference/operations/incident-response.md` |

Treat this as a starter, then tailor to your specific standard and scope.
