# CI/CD integration examples (starter)

Goal: fail builds on CRITICAL crypto findings and prevent secret leaks.

Treat CI gates as a seatbelt, not as an airbag. You still need review.

## Baseline gates (recommended)

1) secret scanning (including history where feasible), plus prevention (detect-secrets/pre-commit)
2) dependency vulnerability scanning (SCA)
3) crypto-focused static analysis (Semgrep or your org’s SAST)
4) TLS scanning for public endpoints (optional but valuable)

## GitHub Actions example (starter)

This example uses:
- OSV-Scanner Action (dependency CVEs)
- Gitleaks Action (secrets)
- Semgrep via CLI (because older wrapper actions have been deprecated)

```yaml
name: security-gates
on:
  pull_request:

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # allow history scanning for secrets

      # Dependency scanning (lockfile-aware)
      - name: OSV-Scanner
        uses: google/osv-scanner-action@v2
        with:
          # See OSV docs for ecosystem-specific options
          scan-args: |-
            --recursive
            .

      # Secret scanning
      - name: Gitleaks
        uses: gitleaks/gitleaks-action@v2


      # Optional: detect-secrets prevention (baseline file)
      - name: detect-secrets (optional)
        run: |
          python -m pip install detect-secrets
          detect-secrets scan > .secrets.baseline
          detect-secrets-hook --baseline .secrets.baseline

      # Crypto-focused static analysis (example: Semgrep CLI)
      - name: Semgrep (optional)
        run: |
          python -m pip install --upgrade pip
          python -m pip install semgrep
          # Replace with your chosen ruleset or a local rules file.
          semgrep --config p/crypto --config p/secrets .
```

Notes:
- Pin action versions to specific tags/SHAs in regulated environments.
- Semgrep registry configs require network access. If you need offline CI, vendor a rules file.

## Build breaker rule of thumb

Fail the build if you detect:
- hardcoded secrets (or suspected secrets with high confidence)
- fast hashes used for password storage
- TLS certificate validation disabled in prod code paths
- unauthenticated encryption for sensitive data
- critical crypto/auth CVEs in dependencies when a fix exists

## Where this plugin fits

Use `/crypto:audit` during engineering review to produce a risk-ranked remediation plan.

Use CI tooling to enforce “never again” rules.
