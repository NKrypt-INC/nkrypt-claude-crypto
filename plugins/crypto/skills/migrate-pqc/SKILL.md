---
name: migrate-pqc
description: Plan and execute a post-quantum cryptography transition (typically hybrid-first), with interop constraints, rollout metrics, and crypto-agility patterns.
disable-model-invocation: true
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - Bash
---

# /crypto:migrate-pqc

You are planning a post-quantum transition.

Do not treat this as an “algorithm swap”. Treat it as a system migration with interoperability risk.

## Prerequisites (do not skip)

1) Run `/crypto:audit`.
2) Fix CRITICAL classical issues first:
   - fast hashes for passwords
   - weak/non-crypto RNG used for tokens/keys
   - TLS cert validation disabled
   - legacy TLS versions and weak ciphers
3) Confirm you can test and roll back safely (staging, canaries, metrics).

## Threat model you are actually solving

- PQC work primarily targets **future decryption** of traffic captured today (“harvest now, decrypt later”).
- Shor-class quantum attacks threaten **public-key crypto** (RSA/ECDH/ECDSA) first.
- Symmetric and hash primitives do not collapse the same way, but long-lived confidentiality still pushes you toward higher security-strength choices (for conservatism: AES-256 and SHA-384 class choices).

See:
- `reference/pqc-reference.md`
- `reference/pqc/support-matrix.md`

## Decide the migration surface (in order)

### 1) TLS key agreement (often first)
Goal: protect confidentiality of sessions against future key recovery.

Typical approach:
- deploy **hybrid TLS 1.3 key agreement** groups (ECDHE + ML-KEM)
- keep classical groups available for compatibility
- measure failure rates and performance

Reference: IETF work on hybrid ECDHE-MLKEM for TLS 1.3.

### 2) Stored ciphertext with long data lifetime
Goal: ensure data you encrypt today stays confidential for its required lifetime.

Patterns:
- envelope encryption stays valid
- you may need re-wrap or re-encrypt flows
- key management and rotation dominate the work

### 3) Signatures and PKI (often hardest)
Goal: quantum-safe authentication and integrity over long horizons.

Constraints:
- certificates, CAs, tooling, key formats, and client support tend to lag
- plan for hybrid or parallel trust chains where feasible

## Hybrid vs pure PQ (be precise)

Hybrid:
- can reduce transition risk by keeping compatibility while adding PQ strength
- expands implementation surface, so treat it as a staged migration with monitoring

Pure PQ:
- may be required by policy in some environments
- can reduce complexity if your ecosystem fully supports it

Do not pick based on slogans. Pick based on constraints and policy.

## Migration workflow (operational)

### Phase 0: Inventory and readiness
- locate quantum-vulnerable public-key crypto (RSA, (EC)DH, ECDSA)
- classify data lifetimes:
  - short-lived (minutes to days)
  - medium (weeks to years)
  - long-lived (5–10+ years)
- identify all TLS termination points (LB, proxy, sidecar, app server)

### Phase 1: Prototype and interop testing
- choose target stacks and verify support (use `reference/pqc/support-matrix.md`)
- build an interop matrix:
  - client types (browsers, mobile, JVMs, embedded)
  - middleboxes (proxies, WAFs, TLS inspection)
- create automated handshake tests

### Phase 2: Canary rollout (metrics-driven)
Roll out hybrid support behind a feature flag where possible.

Minimum metrics:
- handshake failure rate (overall + by client cohort)
- negotiated protocol and group distribution
- handshake latency (p50/p95/p99)
- CPU and memory overhead at termination points

Guardrails (starting points, tune to your baseline and SLOs):
- measure your baseline handshake failure rate first (last 7–14 days)
- do not expand if canary failure rate exceeds **baseline + delta** (example deltas: +0.05% for critical services, +0.2% for less critical)
- treat sharp cohort-specific failures as blockers (often proxies, TLS inspection, or old clients)
- treat fragmentation and MTU-related issues as blockers (hybrid handshakes can get bigger)

### Phase 3: Prefer hybrid, keep escape hatches
- enable hybrid group preference while keeping classical fallback
- ramp traffic gradually (1% → 5% → 25% → 50% → 100%)
- maintain rollback: ability to revert preference within minutes

### Phase 4: Clean up and document
- update docs and runbooks
- bake checks into CI
- record evidence for compliance teams (configs, versions, test results)

## Tooling you can actually run (copy-paste starters)

This bundle includes helper templates under `tools/` that you can create in your repo (via `Edit`) and run (via `Bash`):

- `tools/tls-probe.sh` for quick protocol-floor checks
- `tools/pqc-handshake-matrix.sh` to attempt TLS 1.3 handshakes with specific groups via OpenSSL

Use them from:
- a normal client network
- a “hostile” network path (corporate proxy, WAF path, TLS inspection) when those exist

Record:
- success/failure by cohort
- negotiated group (when observable)
- error strings (alerts) without leaking secrets

## How to test hybrid TLS (examples)

- Verify supported groups with OpenSSL:
  - `openssl list -groups`
- Force a group in a client handshake:
  - `openssl s_client -connect HOST:443 -groups X25519MLKEM768:X25519`
- Use `testssl.sh` or `sslyze` for external endpoints.
- Capture and inspect handshakes with Wireshark where permitted.

## Output expectations

When asked to plan PQC migration:
- produce a phased plan with rollback and metrics
- identify the exact libraries and termination points involved
- provide a client interoperability test plan
- call out compliance constraints explicitly (FIPS/approved mode)
