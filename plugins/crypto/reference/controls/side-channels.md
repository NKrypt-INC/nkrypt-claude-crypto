# Side-channel and timing considerations (practical notes)

Most application teams do not need constant-time proofs. Some teams absolutely do.

This doc gives “good defaults” and escalation triggers.

## What side-channels look like in practice

- timing differences (branching on secret data)
- cache effects (co-resident attacker on same machine)
- error messages that leak secret-dependent state
- padding oracle style failures (crypto + different error paths)

## Safer defaults you can actually apply

### Use constant-time comparison helpers

When you compare secret-derived bytes, use constant-time comparisons.

Common safe helpers:
- Node.js: `crypto.timingSafeEqual(a, b)`
- Python: `hmac.compare_digest(a, b)`
- Go: `subtle.ConstantTimeCompare(a, b) == 1`
- .NET: `CryptographicOperations.FixedTimeEquals(a, b)`
- Java: `MessageDigest.isEqual(a, b)` (preferred over `Arrays.equals`)

Use them for:
- MAC/tag comparisons (if you ever handle them manually)
- password hash comparisons (if your library does not handle verification)
- token comparisons (reset tokens, API tokens) if you store hashed forms

### Fail closed without leaking details

Return “invalid” instead of:
- “wrong password” vs “unknown user”
- “token expired” vs “token invalid” in attacker-visible contexts

Log detailed reasons internally, not to clients.

### Prefer high-level, vetted APIs

High-level APIs usually handle:
- tag verification
- padding details
- constant-time comparisons (where applicable)

Avoid hand-rolled verify paths.

## When to escalate

Escalate to a deeper review (and likely dedicated libraries, isolation, or HSMs) when:

- you run untrusted code on the same host as secrets (multi-tenant, plugin ecosystems)
- you operate in adversarial co-location environments (public cloud shared tenancy with strong threat model)
- you handle high-value signing keys (code signing, financial signing, long-lived root keys)
- your requirements explicitly call for side-channel resistance

In these scenarios:
- isolate keys in HSM/KMS where possible
- prefer libraries with documented side-channel defenses and audits
- measure and test with side-channel tooling appropriate for your environment
