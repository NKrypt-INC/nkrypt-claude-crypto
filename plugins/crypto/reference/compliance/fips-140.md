# FIPS 140 compliance notes (engineering view)

This is not legal advice. Treat it as engineering guidance to support a real compliance program.

## Key idea

FIPS 140 compliance is about using a **validated cryptographic module** in an **approved mode**, inside a defined boundary, with supporting operational controls.

It is not “we used AES, therefore compliant”.

## Transition reality (140-2 → 140-3)

NIST’s CMVP has a published transition schedule. Two facts drive planning:

- FIPS 140-2 validations move to the CMVP Historical List on **September 21, 2026** (for new systems, procurement, and long-term planning, assume you need FIPS 140-3).  
  Sources:
  - CMVP program page: https://csrc.nist.gov/projects/cryptographic-module-validation-program
  - FIPS 140-3 transition effort: https://csrc.nist.gov/projects/fips-140-3-transition-effort

Current as of 2026-02-14. Monitor CMVP for any programmatic changes.

## What changes when you must be FIPS compliant

### 1) Library selection becomes a compliance decision
Pick modules that are validated for your target standard (140-3) and your operating environment.

Examples of “modules”:
- OpenSSL 3.x FIPS provider (in a validated configuration)
- OS crypto providers (Windows CNG, some distro-provided validated builds)
- vendor HSM/KMS modules

### 2) “Approved mode” becomes a runtime property
You must enable and enforce approved mode, not just link a library.

You also need evidence that it stayed enabled:
- startup self-tests ran
- non-approved algorithms did not execute (or you logged and blocked them)

### 3) Algorithm availability and policy constraints tighten
Approved mode may:
- disallow specific algorithms or parameter ranges
- restrict key sizes and padding modes
- change what is available for TLS, signing, and key generation

### 4) PQC adds an extra layer of nuance
Vendors may ship PQC implementations before validation paperwork catches up.

You can often *test* PQC features, but you should not assume “approved mode” covers them unless the validation explicitly includes them.

## Practical workflow (what to do)

### Step 1: Define scope
- Which services and environments require FIPS?
- Which crypto operations matter (TLS termination, signing, storage encryption, password hashing)?
- What is the evidence your auditors will expect?

### Step 2: Inventory providers and boundaries
Use `/crypto:audit` to identify:
- which libraries actually implement crypto in each service
- where TLS terminates (LB/proxy/service mesh/app server)
- where keys live (KMS/HSM vs app memory/config)

### Step 3: Verify validation status (do not guess)
- Look up the exact module and version in the CMVP validation lists.
- Keep the module’s Security Policy and certificate identifiers in your evidence set.

NIST CMVP links:
- CMVP overview: https://csrc.nist.gov/projects/cryptographic-module-validation-program
- Module validation lists: https://csrc.nist.gov/projects/cryptographic-module-validation-program/validated-modules

### Step 4: Enforce approved mode and detect drift
Concrete actions you can take:
- add a startup check that confirms approved mode (module-specific)
- log any attempt to use non-approved algorithms (module-specific “indicator” support exists in some providers)
- block deploys that fail the check

### Step 5: Align TLS and crypto policy with approved mode
Use `/crypto:tls` plus your provider docs to ensure:
- TLS versions and suites meet policy
- groups and signature algorithms align with approved constraints
- you do not accidentally enable non-approved fallbacks

### Step 6: Produce evidence, not vibes
Auditors want artifacts:
- module identifiers and versions
- configuration used to enable approved mode
- test outputs (self-tests, startup logs)
- key management and rotation procedures
- CI evidence (SCA scans, config linting, policy checks)

## Mapping to this plugin

- `/crypto:audit` inventories algorithms, providers, dependencies, and likely boundaries.
- `/crypto:tls` hardens TLS configs and helps you reason about termination layers.
- `reference/operations/key-rotation.md` provides rotation playbooks and evidence patterns.
- `reference/operations/incident-response.md` provides emergency rotation guidance.

## Common gotchas

- You enabled “FIPS” in one layer but TLS actually terminates elsewhere.
- You use a validated module, but your build/config does not match the validated operating environment.
- Your CI builds differ from prod builds (different OpenSSL, different providers).
- You assume PQC support implies FIPS approval without checking the validation boundary.

Sources for the 2026 transition date:
- https://csrc.nist.gov/projects/cryptographic-module-validation-program
- https://csrc.nist.gov/projects/fips-140-3-transition-effort
