# detect-secrets (optional): preventing secret commits

Regex scans catch some secrets. Dedicated scanners catch more. Prevention beats both.

`detect-secrets` (by Yelp) works well as a pre-commit and CI gate for many teams.

## Install

```bash
python -m pip install detect-secrets
```

## Baseline setup

1) Create or update the baseline file:

```bash
detect-secrets scan > .secrets.baseline
```

2) Add a pre-commit hook (if you use pre-commit):

```yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.5.0
    hooks:
      - id: detect-secrets
        args: ["--baseline", ".secrets.baseline"]
```

3) Run in CI:

```bash
detect-secrets-hook --baseline .secrets.baseline
```

## Notes

- Treat false positives as a tuning problem, not as an excuse to disable scanning.
- Combine with gitleaks or trufflehog for history scanning.
- Do not store real secrets in `.secrets.baseline`. Use allowlists carefully.
