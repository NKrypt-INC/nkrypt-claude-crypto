# Toolkit appendix: practical commands and checks

This appendix collects “runnable” starters that pair well with the skills.

The goal is not to be fancy. The goal is to be repeatable.

## Quick start for the helper scripts

Make the scripts runnable and see tool hints:

```bash
./bootstrap.sh
```

## One command to raise assurance

If you want a repeatable local command, copy the helper templates from `tools/` into your repo and run:

```bash
./crypto-audit-escalate.sh
```

It will:
- run what is installed
- record what ran vs what skipped
- write outputs under `.crypto-audit/`

Treat `.crypto-audit/` as sensitive and do not commit it.

## TLS quick probes

Fast protocol-floor probe:
```bash
./tls-probe.sh example.com 443
```

Deeper scanners:
```bash
testssl.sh example.com:443
sslyze --regular example.com:443
```

## PQC hybrid sanity probes

If your OpenSSL supports hybrid groups:
```bash
openssl list -groups | grep -E "MLKEM|X25519MLKEM|SecP256r1MLKEM|SecP384r1MLKEM" || true
./pqc-handshake-matrix.sh example.com 443
```

## Dependency and SBOM checks

OSV Scanner:
```bash
osv-scanner --recursive .
```

Syft + Grype:
```bash
syft dir:. -o json > sbom.json
grype sbom:sbom.json
```

## Secrets scanning

History scanning (recommended):
```bash
gitleaks detect --source . --redact --no-banner
```

Prevention (optional):
- `detect-secrets` baseline + pre-commit hooks  
  See `reference/tooling/detect-secrets.md`

## Static analysis beyond grep

Semgrep:
```bash
semgrep --config p/crypto .
```

Tune rules for your stack:
- `reference/tooling/semgrep.md`
