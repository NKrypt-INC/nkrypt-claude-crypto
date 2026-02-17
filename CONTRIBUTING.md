# Contributing

Thanks for improving this crypto plugin bundle.

This repo optimizes for:
- practical guidance
- explicit limitations and confidence
- copy-pasteable examples with tests
- safe handling of secrets in output and docs

## How to contribute

1) Open an issue (bug, feature, or question).
2) Propose the smallest change that improves safety or clarity.
3) Include sources for standards-level claims (NIST, RFCs, OWASP, upstream docs).

## Style rules

- Keep claims humble. Prefer “often”, “usually”, “verify in your environment”.
- Avoid cargo-cult defaults. When you recommend parameters, include a measurement step.
- Never include real secrets. Use obvious placeholders.

## Adding a new language example

- Add code under `plugins/crypto/reference/implementations/`
- Add a matching test note under `plugins/crypto/reference/testing/` (or extend an existing one)
- Update the relevant skill to point to it

