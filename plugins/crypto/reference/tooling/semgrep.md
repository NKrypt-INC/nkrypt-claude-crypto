# Semgrep: raising audit confidence with AST rules

Grep catches obvious problems. AST rules catch wrappers, refactors, and “same bug, different formatting”.

Semgrep is a practical middle ground between grep and full-blown static analyzers.

## Quick start (Semgrep registry)

If your CI environment can reach the Semgrep registry:

```bash
semgrep --config p/crypto --config p/secrets .
```

This typically finds:
- insecure crypto API usage
- obvious secret patterns
- common TLS verification bypass patterns

## Offline starter rules (small and opinionated)

If you need offline runs, create a local rules file such as `.semgrep/crypto-basics.yml`:

```yaml
rules:
  - id: js-math-random-for-security
    message: "Do not use Math.random() for tokens/keys. Use crypto.randomBytes / WebCrypto."
    severity: ERROR
    languages: [javascript, typescript]
    pattern: Math.random(...)

  - id: go-math-rand-for-security
    message: "Do not use math/rand for tokens/keys. Use crypto/rand."
    severity: ERROR
    languages: [go]
    pattern: rand.$FUNC(...)

  - id: python-insecure-random
    message: "Do not use random.* for secrets. Use secrets or os.urandom."
    severity: ERROR
    languages: [python]
    pattern-either:
      - pattern: random.random(...)
      - pattern: random.randint(...)
      - pattern: random.choice(...)

  - id: node-tls-reject-unauthorized-false
    message: "TLS validation disabled. This enables MITM. Remove rejectUnauthorized:false in prod."
    severity: ERROR
    languages: [javascript, typescript]
    pattern: rejectUnauthorized: false
```

This file will not catch everything. It gives you a repeatable “never again” gate for high-impact footguns.

Run it:

```bash
semgrep --config .semgrep/crypto-basics.yml .
```

## How to integrate with this plugin

- Use `/crypto:audit` to produce a risk-ranked plan.
- Use Semgrep (and secret/SCA scanners) in CI to prevent regressions.

### Guardrail: secret comparisons should be constant-time (noisy starter)

This rule is intentionally noisy. Tune it to your codebase.

```yaml
  - id: js-secret-compare-not-constant-time
    message: "Potential secret comparison with ==/===. Consider crypto.timingSafeEqual for secret-derived bytes."
    severity: WARNING
    languages: [javascript, typescript]
    patterns:
      - pattern-either:
          - pattern: $A == $B
          - pattern: $A === $B
      - metavariable-regex:
          metavariable: $A
          regex: (?i)(secret|token|password|api[_-]?key)
```

Python equivalent (often noisy, use with care):

```yaml
  - id: python-secret-compare
    message: "Potential secret comparison. Consider hmac.compare_digest for secret-derived bytes."
    severity: WARNING
    languages: [python]
    patterns:
      - pattern: $A == $B
      - metavariable-regex:
          metavariable: $A
          regex: (?i)(secret|token|password|api[_-]?key)
```

Treat this as a “review trigger,” not as a proof of vulnerability.
