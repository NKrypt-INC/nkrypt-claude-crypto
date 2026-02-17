# Crypto incident response playbooks (engineering)

This is not legal advice. It’s an engineering runbook outline.

## Core flow

1) Detection
2) Assessment
3) Containment
4) Remediation
5) Recovery
6) Post-mortem + prevention

## Scenario A: “A secret leaked on GitHub 3 months ago”

### Assessment
- Identify secret type (API token, DB password, signing key, cloud credential).
- Determine blast radius (what access did it grant?).

### Containment (fast)
- Revoke/rotate the secret immediately.
- Invalidate sessions/tokens if the secret signs/authorizes sessions.
- Add monitoring for use of the leaked credential (if provider supports it).

### Remediation
- Remove secret from repo + git history if needed.
- Add `/crypto:secrets` scan + CI gate.
- Rotate related keys (defense in depth).

## Scenario B: “TLS private key compromise”

- Revoke cert (CRL/OCSP) and reissue with a new key pair.
- Rotate any mTLS client certs if relevant.
- Investigate whether MITM could have occurred.
- Consider forced session invalidation depending on app risk.

## Scenario C: “We found MD5 password hashes in production backups”

- Treat as CRITICAL.
- Confirm whether the database has been exfiltrated or could have been accessed.
- Force password reset for affected users if there’s credible exposure.
- Implement Argon2id/bcrypt/scrypt immediately with rehash-on-login.
- Consider user notification (handled by policy/legal).

See `/crypto:passwords`.

## Scenario D: “Critical crypto CVE in a dependency”

- Identify affected versions and where deployed.
- Patch/upgrade quickly.
- Rotate keys if the vulnerability could expose keys or plaintext.
- Add dependency scanning to CI (see `reference/operations/cicd.md`).

## Evidence preservation

- Preserve logs, commit history, build artifacts, and access logs.
- Avoid destroying evidence during cleanup.

## Preventive controls

- Secret scanning in CI and pre-commit.
- Key rotation runbooks tested in staging.
- Short TTL tokens where possible.
- Dependency scanning gates.
