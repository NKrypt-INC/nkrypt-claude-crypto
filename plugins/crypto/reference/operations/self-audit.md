# Self-audit checklist (for maintainers)

This bundle ships as a **beta**. Run this checklist before tagging a release.

## 1) Make sure nothing is “stubbed”

- Search for `TODO`, `TBD`, `stub`, `FIXME`.
- Confirm every reference link points to an existing file.

Suggested commands:

```bash
rg -n "TODO|TBD|FIXME|stub" .
```

## 2) Run the helper scripts on a known test repo

On a small polyglot repo (or fixtures), run:

```bash
./plugins/crypto/tools/bootstrap.sh
CRYPTO_AUDIT_OUT=.crypto-audit ./plugins/crypto/tools/crypto-audit-escalate.sh
CRYPTO_AUDIT_OUT=.crypto-audit ./plugins/crypto/tools/secrets-quickscan.sh
```

Verify:
- the scripts do not auto-install tooling
- outputs land under `.crypto-audit/`
- outputs avoid printing full secrets

## 3) Validate TLS probing docs

If you have an endpoint:
- run `tools/tls-probe.sh`
- run sslyze or testssl.sh when available
- confirm docs match real output

## 4) Validate PQC probing docs

If your OpenSSL build exposes hybrid groups:
- run `tools/pqc-handshake-matrix.sh` against a known hybrid-capable endpoint
- confirm the sample output still resembles reality

## 5) Confirm “humble claims” standards

Audit for absolute language:
- “always”, “never” (when not literally true)
- “proves”, “guarantees”, “secure”

Replace with:
- “prefer”, “treat as”, “verify”, “measure”

## 6) Red team your examples

- Check JWT examples for `alg` pinning and safe `kid` handling.
- Check AEAD examples for nonce handling and tag verification.
- Check password reset examples for hash-at-rest, expiry, and single-use.

## 7) Update “current as of” dates

Any support matrix or compliance timeline should include:
- a “current as of YYYY-MM-DD” line
- a link to the upstream source

