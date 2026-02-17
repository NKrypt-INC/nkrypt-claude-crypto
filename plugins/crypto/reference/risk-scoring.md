# Risk scoring and severity rubric (starting point)

Severity labels are only useful if they encode a repeatable method.

This plugin uses a simple two-axis model:

- **Likelihood (0–5):** how easily an attacker can exploit this in your environment
- **Impact (0–5):** what happens if they succeed (blast radius + data sensitivity + time horizon)

Then compute:

`risk_score = likelihood + impact`  (0–10)

Map to labels:

- **CRITICAL:** 9–10
- **HIGH:** 7–8
- **MEDIUM:** 4–6
- **LOW:** 0–3

## Likelihood (0–5)

Score based on the easiest realistic attacker path.

- **5:** trivially exploitable remotely, widely known exploit pattern  
  Example: TLS certificate validation disabled in a client that touches real endpoints.

- **4:** exploitable with modest effort or common tooling  
  Example: fast password hashes (MD5/SHA-1/SHA-256) for user passwords.

- **3:** exploitable with access to logs, backups, or a narrower position  
  Example: encryption without integrity where attacker can tamper with ciphertext.

- **2:** exploitable only with strong positioning or partial compromise  
  Example: weak key management where keys live in configs but not in repo.

- **1:** theoretical or requires rare conditions  
  Example: niche algorithm weakness with limited exposure.

- **0:** not exploitable as described (or already mitigated)

## Impact (0–5)

- **5:** full compromise of auth, private keys, or bulk sensitive data  
  Example: JWT signing key leaked, production DB password leaked, private TLS key leaked.

- **4:** account takeover risk or data exposure for many users  
  Example: password hash database with weak hashing and no rate limiting.

- **3:** meaningful data exposure or integrity break for a subset  
  Example: a single service uses unauthenticated encryption for sensitive payloads.

- **2:** limited exposure, contained system, short-lived secrets  
  Example: non-prod secret leak with no prod access, but still embarrassing.

- **1:** low practical impact or quickly rotating keys  
  Example: a quantum-vulnerable key exchange where sessions have no long-lived confidentiality need.

- **0:** no impact

## Examples (sanity checks)

- MD5 for user passwords in production database  
  Likelihood 4–5, Impact 4–5 → **CRITICAL**

- `Math.random()` used to generate password reset tokens  
  Likelihood 5, Impact 4 → **CRITICAL**

- RSA-2048 for TLS key agreement, data lifetime > 10 years, high-value target  
  Likelihood 2–3 (today), Impact 4–5 (future confidentiality) → **MEDIUM/HIGH** depending on context

- RSA-2048 for short-lived sessions, keys rotate frequently, no long-lived confidentiality  
  Likelihood 2, Impact 1–2 → **LOW/MEDIUM**

## What this model does not do

- It does not replace CVSS scoring for specific CVEs.
- It does not compute probabilities. It forces a consistent argument.
- It will change per environment. Write down assumptions.
