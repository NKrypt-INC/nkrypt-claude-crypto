# Tools (optional helpers)

This directory contains small scripts you can copy into a repo to raise assurance beyond grep.

They are intentionally conservative:
- they do **not** auto-install tooling
- they record what ran vs what skipped
- they try to avoid printing full secrets (but treat output as sensitive anyway)

## Quick start

1. Make scripts runnable and see optional tool hints:

```bash
./bootstrap.sh
```

2. Run the helpers you need.

## Included

- `bootstrap.sh`  
  Makes scripts runnable and prints optional install hints.

- `crypto-audit-escalate.sh`  
  Runs optional Level 2/3 scanners when present and writes outputs to `.crypto-audit/`.

- `secrets-quickscan.sh`  
  Fast secrets scan wrapper (gitleaks → trufflehog → grep + entropy heuristic).

- `tls-probe.sh`  
  Quick TLS protocol-floor probe via OpenSSL.

- `pqc-handshake-matrix.sh`  
  Attempts TLS 1.3 handshakes with specific groups via OpenSSL to validate hybrid negotiation.

## How to use with Claude Code skills

The skills reference these scripts as templates. When you run a skill, it can:
1) create these scripts in your repo via `Edit`
2) run them via `Bash`
3) summarize results with coverage + confidence

## Output handling

Outputs under `.crypto-audit/` can include:
- dependency lists
- vulnerability reports
- redacted secret findings

Treat `.crypto-audit/` as sensitive and exclude it from commits.
