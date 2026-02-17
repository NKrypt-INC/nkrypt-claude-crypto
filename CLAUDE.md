# CLAUDE.md

This is the nkrypt-claude-crypto plugin -- a Claude Code marketplace bundle for practical cryptography guidance.

## What this project is

A Claude Code plugin with 6 skills for cryptography triage, hardening, and post-quantum planning. It ships reference docs, multi-language implementation examples, and helper scripts. It is not a security product -- it produces triage and engineering playbooks.

## Philosophy

Fix broken classical crypto first, then plan PQC transitions with interoperability and operational reality in mind.

## Available skills

- `/crypto:audit` -- Risk-ranked crypto audit with coverage and confidence limits
- `/crypto:secure` -- Safe crypto implementation patterns (AEAD, HKDF, CSPRNG)
- `/crypto:passwords` -- Argon2id/bcrypt/scrypt with migration and reset-token patterns
- `/crypto:tls` -- TLS hardening configs plus hybrid PQ TLS rollout
- `/crypto:secrets` -- Hardcoded secrets scanning and containment plans
- `/crypto:migrate-pqc` -- Post-quantum transition planning (hybrid-first)

## Safety constraints

- Never print full secrets or private keys. Always redact.
- Never auto-install tools. Print the install command and ask.
- Separate evidence from assumptions in all outputs.
- Label confidence levels (HIGH/MEDIUM/LOW) on findings.
- Always report what was scanned and what was NOT scanned.
- This plugin does not replace a security review, pen test, or compliance audit.

## Project layout

- `plugins/crypto/skills/` -- Skill definitions (SKILL.md files)
- `plugins/crypto/reference/` -- Reference docs, implementation examples, testing guides
- `plugins/crypto/tools/` -- Helper shell scripts (bootstrap, scanners, probes)
- `.claude-plugin/marketplace.json` -- Marketplace bundle metadata

## Key references

- Threat model: `plugins/crypto/reference/threat-model.md`
- Risk scoring: `plugins/crypto/reference/risk-scoring.md`
- Audit methodology: `plugins/crypto/reference/audit/methodology.md`
- Language footguns: `plugins/crypto/reference/language-footguns/`
- Compliance notes: `plugins/crypto/reference/compliance/` (not legal advice)

## Style

- Keep claims humble. Prefer "often", "usually", "verify in your environment."
- Include sources for standards-level claims (NIST, RFCs, OWASP).
- Never include real secrets in examples. Use obvious placeholders.
