# nkrypt-claude-crypto

Cryptography skills for Claude Code (and other AI coding agents). Audit your repo's crypto, fix what's broken, and plan post-quantum transitions -- with copy-paste code in 6 languages.

> **Status: beta** (v0.5.0). This produces triage and engineering playbooks, not a security audit. It does not replace a pen test or compliance review.

## Quick start

```bash
npx skills add NKrypt-INC/nkrypt-claude-crypto
```

Then open Claude Code in your project and type a slash command:

```text
/crypto:audit
```

That's it. Claude scans your repo for crypto issues and produces a risk-ranked report.

## What you get

Six skills that cover the most common crypto problems in production codebases:

| Skill | What it does | When to use it |
|---|---|---|
| `/crypto:audit` | Risk-ranked crypto audit with dependency and secrets checks | "Is the crypto in this repo okay?" |
| `/crypto:secure` | Safe implementation patterns (AEAD, HKDF, CSPRNG, key management) | "Help me encrypt this correctly" |
| `/crypto:passwords` | Argon2id/bcrypt/scrypt with migration and reset-token flows | "We're storing passwords, what do we use?" |
| `/crypto:tls` | TLS hardening configs + hybrid post-quantum key exchange | "Harden our TLS" or "Set up PQ TLS" |
| `/crypto:secrets` | Hardcoded secrets scanning + containment and rotation plans | "Are there leaked keys in this repo?" |
| `/crypto:migrate-pqc` | Post-quantum transition planning (hybrid-first) | "How do we prepare for quantum?" |

Each skill produces actionable output: findings with evidence, code you can paste, tests you should write, and rollout steps.

## Supported languages

Every skill includes reference implementations and language-specific footgun guides for:

**Node.js** -- **Python** -- **Go** -- **Java** -- **.NET** -- **Rust**

## How it works

You ask Claude to do something crypto-related. The skills give it structured guidance, reference docs, and code examples so it produces safe, tested, standards-backed output instead of guessing.

Behind each skill:
- **90+ reference docs** covering implementations, testing patterns, operations, compliance, and PQC
- **28+ code snippets** (passwords, AEAD, KDF, CSPRNG, JWT, TLS configs)
- **Helper scripts** for chaining vulnerability scanners and probing TLS endpoints
- **Risk scoring** methodology with confidence levels (HIGH/MEDIUM/LOW)

The philosophy: fix broken classical crypto first (MD5 passwords, `Math.random()` for tokens, disabled cert validation), then plan PQC where it matters.

## Install options

### Via skills.sh (recommended)

```bash
npx skills add NKrypt-INC/nkrypt-claude-crypto
```

Pick which skills and agents to install for (Claude Code, Cursor, Windsurf, etc.).

### Manual install (Claude Code)

```bash
# Project-level (just this repo)
git clone https://github.com/NKrypt-INC/nkrypt-claude-crypto.git /tmp/nkrypt-crypto
cp -r /tmp/nkrypt-crypto/skills/* .claude/skills/

# Global (all your projects)
cp -r /tmp/nkrypt-crypto/skills/* ~/.claude/skills/
```

### As a Claude Code marketplace plugin

This repo also works as a marketplace bundle. See the [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code) for marketplace plugin setup.

## Example workflows

### Audit this repo's crypto

```text
/crypto:audit
```

Produces: repo map, crypto inventory, secrets scan, dependency CVE check, risk-ranked findings table, and a 30/60/90-day remediation plan.

### Hash passwords in a Go service

```text
/crypto:passwords
```

Produces: Argon2id implementation with exact library, working code, parameter guidance calibrated to your hardware, migration plan from old hashes, and test checklist.

### Harden an nginx TLS config

```text
/crypto:tls
```

Produces: copy-paste nginx config with TLS 1.3 preference, AEAD-only TLS 1.2, HSTS, and verification commands. Optionally includes hybrid PQ TLS rollout steps.

### Scan for leaked secrets

```text
/crypto:secrets
```

Produces: layered scan (grep patterns, then dedicated scanners, then entropy analysis), redacted findings, containment plan, and CI gate recommendations.

## What this is not

- **Not a security audit.** It's triage. It tells you where to look and what to fix first.
- **Not exhaustive.** Static scanning misses obfuscated code, generated bundles, native binaries, and runtime-only config. It tells you what it scanned and what it didn't.
- **Not a compliance program.** It includes engineering notes for FIPS, PCI DSS, HIPAA, and GDPR conversations, but those are starting points, not legal advice.

## Project layout

```text
skills/                          # skills.sh-compatible (root-level)
  audit/SKILL.md
  secure/SKILL.md
  passwords/SKILL.md
  tls/SKILL.md
  secrets/SKILL.md
  migrate-pqc/SKILL.md

plugins/crypto/                  # Full plugin with reference material
  skills/                        # Claude Code marketplace skill definitions
  reference/
    implementations/             # Code: passwords, AEAD, KDF, CSPRNG, JWT, TLS
    testing/                     # Test patterns for each crypto area
    operations/                  # Key rotation, incident response, CI/CD, observability
    compliance/                  # FIPS, PCI DSS, HIPAA, GDPR notes
    pqc/                         # Post-quantum support matrix and interop templates
    language-footguns/           # Per-language crypto pitfalls
    controls/                    # Nonce management, side-channel basics
    tooling/                     # detect-secrets, semgrep, toolkit guides
  tools/                         # Helper shell scripts (scanners, TLS probes)
```

# Remember, this is your crypto co-pilot, not the pilot. Use it to accelerate secure development, then validate with experts.

## Standards referenced

Skills link to primary sources throughout, including:
- NIST SP 800-57 (key management), NIST SP 800-63B (password guidance)
- OWASP Password Storage and Forgot Password cheat sheets
- RFC 9325 (TLS deployment), RFC 5869 (HKDF)
- IETF hybrid ML-KEM drafts for TLS 1.3

## Contributing

Contributions and real-world war stories welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
