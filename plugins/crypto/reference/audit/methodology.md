# Audit methodology and coverage (read this before trusting results)

This plugin can speed up crypto hygiene work, but it cannot magically turn grep into a formal audit.

Use the audit output as **triage** plus a plan to raise assurance.

## Three-layer audit model

### Layer 1: Triage scans (fast, high false negatives)

Examples:
- grep/ripgrep for obvious hazards (`MD5`, `Math.random`, `rejectUnauthorized: false`)
- search for deprecated APIs (`crypto.createCipher`, `InsecureSkipVerify`)

Strength:
- catches the most common failures quickly

Limits:
- misses obfuscation, wrapper libraries, dynamic imports, generated code
- struggles with minified bundles and native binaries

### Layer 2: Structured static analysis (AST-based)

Prefer an AST tool when possible:
- Semgrep (rule-based, language-aware)
- language linters and security analyzers (where your org already uses them)
- SCA tooling for dependencies (OSV, npm audit, pip-audit, etc.)

Strength:
- reduces false negatives compared to plain text search
- finds patterns across refactors and wrappers

Limits:
- still cannot see runtime behavior
- can miss framework-provided crypto that happens behind abstractions

### Layer 3: Dynamic verification (runtime and protocol behavior)

Dynamic checks matter most for:
- TLS negotiation (protocol floor, cipher choice, key share groups, client compatibility)
- secrets exposure in runtime configs (env vars, mounted files)
- “what actually ships” (container images, built artifacts, deployed configs)

Examples:
- test your TLS endpoint with testssl.sh or sslyze
- confirm negotiated groups/ciphers with OpenSSL or Wireshark
- generate an SBOM from the built image and scan it (syft + grype, osv-scanner)
- for C/C++/Rust glue: run tests under ASan/UBSan or Valgrind to catch misuse and parsing crashes
- for JS/Python services: use profilers (clinic.js, py-spy) to measure crypto hot paths and regressions under load

Strength:
- catches “works on paper” failures
- finds config drift between repo and prod

Limits:
- requires access to a running environment
- cannot prove security, only increase confidence

## What /crypto:audit should always report

- what it scanned (paths, languages, artifact types)
- what it did not scan (and why)
- for each finding: severity, confidence, and a suggested next step to increase confidence

## When you need more than this plugin

Escalate to a dedicated security review when:
- you handle regulated data and need evidence for audits
- you need constant-time guarantees or side-channel hardening
- you ship cryptographic libraries, protocol implementations, or embedded devices
- you suspect supply-chain compromise or targeted adversaries
## Monorepos and submodules

Large repos often contain multiple apps and shared libraries. Treat them as separate scan units and aggregate.

Read:
- `reference/audit/monorepos.md`

## How to avoid “Layer 1 = audited” failures

If you only run Layer 1 scans:
- label the result as **TRIAGE**
- call out major blind spots explicitly (bundles, native deps, runtime config)
- include a concrete “raise assurance” next-step plan (AST rules, secret scanner, SCA, TLS probing)

## Optional helper scripts

This bundle includes small scripts under `tools/` that you can copy into a repo to automate Level 2/3 checks.

Tip: run `tools/bootstrap.sh` to make scripts runnable and to see tool hints.
- `tools/bootstrap.sh`
- `tools/crypto-audit-escalate.sh`
- `tools/secrets-quickscan.sh`
- `tools/tls-probe.sh`
- `tools/pqc-handshake-matrix.sh`

Treat outputs as sensitive and do not commit them.
