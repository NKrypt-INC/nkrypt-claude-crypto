# Nonce management for AEAD (AES-GCM, ChaCha20-Poly1305)

Nonce reuse with the same key is the most common catastrophic AEAD failure.
This doc covers strategies for avoiding it.

## Why nonce reuse is catastrophic

For AES-GCM, reusing a nonce with the same key causes two failures at once:
1. **Keystream reuse** -- XOR of two ciphertexts reveals XOR of plaintexts, enabling plaintext recovery.
2. **Auth key leak** -- the GHASH authentication key can be recovered, enabling forgery of arbitrary messages.

This is not a theoretical weakness. It is a complete, practical break of both confidentiality and integrity.

Risk score: **CRITICAL** (Likelihood 5, Impact 5). See `reference/risk-scoring.md`.

## Strategy 1: Random nonces (recommended default)

Generate 12 random bytes (96 bits) from the OS CSPRNG for each encryption operation.

This is what all the reference implementations in this plugin use:
- Node.js: `crypto.randomBytes(12)`
- Python: `os.urandom(12)`
- Go: `crypto/rand.Read(nonce)`
- Java: `SecureRandom().nextBytes(nonce)`
- .NET: `RandomNumberGenerator.GetBytes(nonce)`
- Rust: `OsRng.fill_bytes(&mut nonce)`

**Birthday bound:** with 96-bit random nonces, the probability of collision reaches ~50% at 2^48 encryptions per key, but the commonly cited safety margin is approximately **2^32 messages per key** (keeping collision probability negligible). If you approach this volume, rotate the key.

**When to use:** most applications. Unless you encrypt billions of messages with a single key, random nonces are the simplest and safest default.

## Strategy 2: Counter-based nonces

Use a monotonically increasing counter as the nonce. The counter must never repeat for the same key.

**Advantages:**
- No birthday bound -- safe for up to 2^96 messages per key (96-bit nonce space).
- Deterministic -- useful for deduplication or idempotent encryption.

**Risks:**
- Counter must be **durable** -- a crash or restart must not reset the counter.
- Counter must be **unique per key** -- two processes sharing a key must not share a counter range without coordination.
- Counter wrap-around is a nonce reuse. Detect and rotate key before wrap.

**When to use:** high-volume encryption where you approach the random nonce birthday bound AND you can guarantee counter durability and uniqueness across all writers.

## Strategy 3: Key-per-message via HKDF

Derive a unique key per message using HKDF with a random salt:
1. Generate a random salt (e.g., 16 bytes from CSPRNG).
2. Derive a per-message key: `HKDF(master_key, salt, info="encrypt")`.
3. Encrypt with a fixed nonce (e.g., all zeros) since the key is unique.
4. Store/transmit the salt alongside the ciphertext.

**Advantages:**
- Eliminates the nonce management problem entirely.
- Safe in distributed systems without shared state.

**Disadvantages:**
- Higher computational cost (one HKDF per message).
- More complex key material handling.

**When to use:** when nonce management is hard (distributed systems without shared counters, multi-writer stores) and the performance overhead is acceptable.

See `reference/implementations/kdf/*` for HKDF examples.

## Multi-instance and distributed systems

The hardest nonce management problems arise when multiple instances encrypt with the same key:

- **Random nonces:** the birthday bound applies across all instances combined, not per instance. Two servers each encrypting 2^31 messages share the same collision risk as one server encrypting 2^32.
- **Counter partitioning:** assign each instance a unique counter prefix or range. Requires coordination and is error-prone during scaling events.
- **Key-per-instance:** derive a unique DEK per instance from a shared KEK using HKDF with instance-specific info. Each instance manages its own nonces independently.

The key-per-instance pattern is often the simplest safe choice for distributed systems. See `reference/operations/kms-quickstart.md` for envelope encryption patterns.

## Audit checklist

When reviewing code for nonce safety, verify:

- [ ] Nonce is generated from CSPRNG (not `Math.random`, `Random()`, `math/rand`, or hardcoded)
- [ ] Nonce is 12 bytes (96 bits) for AES-GCM and ChaCha20-Poly1305
- [ ] A fresh nonce is generated for every encryption call (no reuse across messages)
- [ ] The key is rotated before the birthday bound is approached (~2^32 messages for random nonces)
- [ ] In multi-instance deployments, nonce uniqueness is guaranteed (key-per-instance, partitioned counters, or shared-nothing design)

## References

- Language implementations: `reference/implementations/symmetric/*`
- Testing AEAD: `reference/testing/symmetric-aead.md`
- Side-channel considerations: `reference/controls/side-channels.md`
- NIST SP 800-38D (Recommendation for Block Cipher Modes -- GCM)
