---
name: audit
description: Produce a risk-ranked cryptography audit across a repo (classical + PQC readiness), including secrets exposure checks, dependency posture, and explicit coverage/confidence limits. Use when asked to audit, review, or assess cryptography in a codebase.
license: MIT
allowed-tools: Read Grep Glob Bash Edit
metadata:
  author: nkrypt
  version: "0.5.0"
---

# /crypto:audit

You are auditing a codebase for cryptography risk.

Treat this as **triage plus a plan to raise assurance**, not as a magical proof of security.

Before you start, read:
- `../../plugins/crypto/reference/audit/methodology.md`
- `../../plugins/crypto/reference/audit/monorepos.md` (if the repo is large or polyglot)
- `../../plugins/crypto/reference/risk-scoring.md`

## Safety rules

- Never print full secrets or private keys. Always redact.
- Prefer file + line numbers and small redacted snippets.
- Separate "evidence" from "assumptions".

## Audit levels (pick the deepest you can support)

If you stop at Level 1, label the result as **TRIAGE** and include a concrete plan to raise assurance.

### Level 1: Quick triage (always doable)
- grep-based scanning for high-signal hazards
- basic crypto inventory
- basic dependency inventory

### Level 2: Standard (default)
Do Level 1 plus:
- (optional) run `../../plugins/crypto/tools/bootstrap.sh` to make the helper scripts runnable and to see tool hints
- (optional) run the bundled helper script template to chain scanners (see `../../plugins/crypto/reference/audit/methodology.md`): `../../plugins/crypto/tools/crypto-audit-escalate.sh`
- run ecosystem vulnerability tooling where available (`npm audit`, `pip-audit`, `govulncheck`, `cargo audit`, etc.)
- run a dedicated secret scanner if available (gitleaks/trufflehog)
- scan built artifacts directories (dist/, build/, vendor/, etc.) for embedded crypto and secrets

### Level 3: Deep (higher confidence)
Do Level 2 plus:
- SBOM + SCA scan (syft + grype, or OSV scanner against lockfiles)
- binary/native dependency inspection where relevant
- dynamic TLS verification for known endpoints or staging (testssl.sh/sslyze/openssl)
- targeted runtime verification if the repo includes tests or a runnable stack

If tools are missing, do not auto-install without asking. Provide the exact install command and ask for permission.

## Step 0: Map the repo (what exists)

Use `Glob` to detect:
- Git submodules (`.gitmodules`) and nested repos
- monorepo workspaces (pnpm/yarn/npm workspaces, Gradle multi-project, Maven modules)

- languages and frameworks (Node, Python, Go, Java, .NET, Rust)
- dependency manifests and lockfiles
- TLS configs (nginx, Apache, Envoy, Ingress, service mesh)
- crypto-related configs (KMS, JWT, OpenSSL, keystores)
- binary artifacts (`*.so`, `*.dll`, `*.dylib`, `*.jar`, `*.a`, `*.p12`, `*.pfx`)

Report a short "repo map" section. This becomes your coverage statement.

## Step 1: Crypto inventory (classical + PQC-relevant)

### 1A) Public-key and key agreement usage (PQC-relevant)
Search for:
- RSA / DSA / ECDSA / Ed25519 / DH / ECDH / X25519 / X448
- certificate handling and key generation
- hard-coded curves/groups or TLS group config

### 1B) Password handling
Find:
- password hashing functions and parameters
- PBKDF usage (PBKDF2, scrypt)
- any fast hashes used near passwords (MD5/SHA-1/SHA-256)

### 1C) Symmetric encryption and integrity
Find:
- AES-GCM / ChaCha20-Poly1305 (good)
- AES-CBC without MAC, raw AES-CTR without MAC (high risk)
- homegrown "encrypt then base64" patterns
- nonce/IV handling (reuse is catastrophic for GCM; see `../../plugins/crypto/reference/controls/nonce-management.md`)

### 1D) Randomness
Find:
- non-crypto RNGs used in security contexts (`Math.random`, `Random()`, `rand()`, `math/rand`)
- token generation (reset tokens, API keys, session IDs)

### 1E) TLS and certificate validation footguns
Find:
- TLS versions forced low (SSLv3/TLS1.0/1.1)
- certificate validation disabled (`rejectUnauthorized: false`, `InsecureSkipVerify`, custom verifiers that always return true)

## Step 2: Secrets exposure scan (do this even if you think you're "just auditing crypto")

Run `/crypto:secrets` as part of the audit.

Classical crypto that is "correct" becomes irrelevant when the keys live in the repo.

## Step 3: Dependency and CVE posture (SCA)

Inventory dependencies and then scan for known issues.

Minimum:
- Node: `npm ls --all`, `npm audit` (or your org tooling)
- Python: `python -m pip freeze`, `pip-audit` if available
- Go: `go list -m all`, `govulncheck` if available
- Rust: `cargo tree`, `cargo audit` if available
- Java (Maven): `mvn -q -DskipTests dependency:tree` (or your org SCA)
- Java (Gradle): `./gradlew -q dependencies` (or your org SCA)
- .NET: `dotnet list package`, `dotnet list package --vulnerable` where supported

Stronger:
- run OSV scanning against lockfiles
- generate an SBOM and scan it (see `../../plugins/crypto/reference/operations/supply-chain.md`)

Report:
- crypto-critical dependencies (TLS/crypto libs, JWT libs, KMS clients)
- version pinning status (lockfiles present? reproducible installs?)
- any known CVEs that affect crypto or auth paths

## Step 4: TLS posture (static + dynamic where possible)

Static checks:
- review nginx/Apache/app server TLS settings
- confirm TLS 1.3 preference and TLS 1.2 AEAD-only stance
- confirm HSTS where appropriate

Dynamic checks (if you have an endpoint or staging):
- use the script template `../../plugins/crypto/tools/tls-probe.sh` for a quick protocol-floor check
- if the repo ships a `docker-compose.yml`, consider spinning up a local stack for probing (`docker compose up`) so you test what actually runs
- test from a network that resembles real clients (including proxies/middleboxes)

- run `testssl.sh` or `sslyze`
- confirm negotiated TLS versions and groups
- if hybrid PQ TLS is enabled, confirm group negotiation and failure rate

## Step 5: Score and rank findings

Use `../../plugins/crypto/reference/risk-scoring.md`:
- assign Likelihood (0-5) and Impact (0-5)
- compute risk_score (0-10)
- assign Severity (CRITICAL/HIGH/MEDIUM/LOW)
- assign Confidence (HIGH/MEDIUM/LOW)

Confidence examples:
- HIGH: direct code evidence in a clear call path
- MEDIUM: strong indicator but behind wrappers/framework magic
- LOW: inferred from config or partial evidence

## Output format (strict)

### A) Coverage and limits
- Assurance level achieved: TRIAGE (L1) / STANDARD (L2) / DEEP (L3)

- languages and artifact types scanned
- tools used (and not used)
- top blind spots (generated bundles, native binaries, runtime-only config)

### B) Findings table (risk-ranked)
For each finding include:
- ID
- Risk score + Severity
- Confidence
- Category (passwords, symmetric, RNG, TLS, secrets, PQC readiness, dependencies)
- Location (file:line)
- Evidence (redacted)
- Why it matters (1-2 lines)
- Fix guidance (link to relevant reference implementation/testing doc)

### C) 30/60/90-day remediation plan
- 0-7 days: fix CRITICAL
- 7-30 days: fix HIGH
- 30-90 days: plan MEDIUM (including PQC roadmap items where relevant)

### D) PQC readiness snapshot (only after classical fires are out)
- where quantum-vulnerable public-key crypto exists
- data lifetime notes ("harvest now, decrypt later" relevance)
- whether hybrid TLS rollout is feasible for your stack
- top interop risks and how to measure them
