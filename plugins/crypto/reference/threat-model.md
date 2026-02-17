# Threat model and prioritization

This plugin uses a deliberately boring rule:

**Broken classical crypto beats quantum risk almost every time.**

Quantum threats matter, but most incidents still happen because someone:
- stored passwords with MD5
- reused nonces in AES-GCM
- disabled TLS certificate validation
- committed secrets to GitHub
- used `Math.random()` to generate keys

## Threat categories

### 1) Immediate, high-probability threats (today)
- Credential stuffing and password database cracking
- Secrets leaks (repo, logs, CI artifacts, backups)
- MITM due to TLS misconfiguration or cert validation disabled
- Key theft via poor key storage (keys in env vars, configs, or code)
- Dependency compromise (vulnerable or malicious crypto libraries)

### 2) Medium-term threats (months to years)
- “Harvest now, decrypt later” (HN-DL) against long-lived confidentiality:
  attackers capture encrypted traffic or stored ciphertext now, hoping to decrypt later

### 3) Long-term threats (years+)
- Large-scale quantum computers running Shor’s algorithm to break RSA/ECDH/ECDSA

## Severity rubric used by /crypto:audit

- **CRITICAL (fix immediately)**  
  Clear, practical compromise paths today.
  Examples: MD5/SHA-1 password hashes, hardcoded secrets, TLS < 1.2, cert validation disabled, weak RNG for keys, AES-ECB, unauthenticated encryption.

- **HIGH (fix soon)**  
  Weak or brittle crypto that often leads to compromise with some effort.
  Examples: SHA-1 signatures, RSA-1024, static IVs, poor key handling, missing rotation, outdated crypto dependencies with known CVEs.

- **MEDIUM (plan)**  
  Quantum-vulnerable public-key crypto *combined with long data lifetime*.
  Examples: RSA-2048/ECDSA used to protect data that must remain confidential 10+ years.

- **LOW (monitor)**  
  Quantum-vulnerable public-key crypto where data is short-lived and keys rotate aggressively.

## Practical prioritization examples

- System uses SHA-1 for signatures and RSA-2048 for TLS key exchange  
  → Fix SHA-1 first.

- System uses bcrypt(10) and RSA-2048 for TLS, but has `rejectUnauthorized: false` in prod  
  → Fix TLS validation first.

- System uses AES-GCM but reuses nonces  
  → Fix nonce generation immediately. This is catastrophic.

## “Quantum ready” does not mean “secure”

PQC migration is a **layer**, not a substitute for:
- safe password storage
- safe AEAD usage
- safe TLS configs
- safe key management
- secure randomness
- secrets hygiene
