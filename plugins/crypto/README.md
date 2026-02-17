# Crypto Plugin for Claude Code

Status: **beta** (v0.4.1-beta). Battle-tested in simulation and in limited repos, not production-hardened.


Practical cryptography guidance for production codebases: classical hardening first, then measured post-quantum readiness.

This plugin helps you:
- find obvious crypto hazards quickly (MD5 for passwords, non-crypto RNG, TLS validation disabled)
- connect findings to concrete fixes in common languages (Node.js, Python, Go, Java, .NET, Rust)
- plan ops work (rotation, incident response, CI gates, observability)
- plan PQC transitions where they actually fit (typically hybrid TLS key exchange first)

## What this plugin is not

- It does not replace a security review, pen test, or compliance audit.
- It will not find every issue. Static scanning misses obfuscation, generated code, native binaries, and weird runtime behavior.
- It cannot “prove” constant-time behavior or side-channel safety. Treat that as a separate threat-model-driven effort.

Use it as **triage + engineering playbooks**, then raise assurance with deeper tools (Semgrep, SCA/SBOM, gitleaks, testssl/sslyze, and targeted runtime verification).

## Skills

- `/crypto:audit`  
  Inventory crypto usage across languages, scan for common crypto footguns, include dependency/CVE posture, and generate a risk-ranked remediation plan with explicit coverage and confidence.

- `/crypto:secure`  
  Implement safe cryptography patterns with pointers to copy-pasteable, language-specific references and tests.

- `/crypto:passwords`  
  Argon2id/bcrypt/scrypt guidance with migration and reset-token patterns, plus code references and test checklists.

- `/crypto:tls`  
  Concrete TLS hardening configs (nginx/Apache/Node/Python/Go/Java/.NET) plus hybrid PQ TLS rollout guidance where supported.

- `/crypto:migrate-pqc`  
  PQC transition planning with interoperability constraints, rollout metrics, and “do not skip classical hygiene” gates.

- `/crypto:secrets`  
  Scan for hardcoded secrets and produce a containment + rotation plan, including git history scanning guidance.

## Reference content

- `reference/implementations/`  
  Working code snippets for Node, Python, Go, Java, .NET, and Rust.

- `reference/testing/`  
  How to test crypto changes (positive, negative, interop, plus fuzzing/property-test starters).

- `reference/operations/`  
  Key rotation runbooks, incident response, CI/CD gates, observability, performance and rollout metrics.

- `reference/compliance/`  
  Engineering notes and evidence checklists for common compliance conversations (FIPS, PCI DSS, HIPAA, GDPR). These do not replace a compliance program.

- `reference/pqc/`  
  PQC support matrix, rollout notes, and pointers to current standards and drafts.

## Design stance (plain, not macho)

1) Fix broken classical crypto first (fast hashes for passwords, weak RNG, cert validation off, legacy TLS).
2) Treat PQC as a transition problem, not an algorithm swap. Hybrid often makes sense, pure PQ sometimes does.
3) Prove changes with tests, metrics, and rollback plans.

## Sources (starting points)

This plugin links out to primary references inside the docs, including:
- NIST SP 800-57 (key management and security strength)
- OWASP Password Storage Cheat Sheet
- RFC 9325 (TLS deployment best practices)
- RFC 5869 (HKDF) and other IETF RFCs
- IETF TLS hybrid ML-KEM drafts (for group names and negotiation behavior)


## Maintainer notes

- Self-audit checklist: `reference/operations/self-audit.md`
