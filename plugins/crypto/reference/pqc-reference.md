# Post-quantum cryptography (PQC) reference

PQC aims to protect against attackers with large-scale quantum computers.

Two quantum algorithms matter most in practice:

- **Shor** threatens widely deployed **public-key crypto** (RSA, (EC)DH, ECDSA, Ed25519).
- **Grover** gives a generic square-root speedup for brute-force style searches, which affects symmetric key search and hash preimage search.

## NIST-standardized algorithms (high-level)

- **ML-KEM** (FIPS 203): key encapsulation mechanism (KEM) for key agreement (including hybrid TLS)
- **ML-DSA** (FIPS 204): digital signatures (lattice-based)
- **SLH-DSA** (FIPS 205): stateless hash-based signatures

## Quantum impact beyond public-key crypto (don’t hand-wave this)

Grover changes “how much security you get per bit” for brute-force style attacks. A common conservative rule of thumb is:

- To keep ~**128-bit** brute-force security against a Grover-style attacker, you plan for ~**256-bit** symmetric keys.

AES key sizes top out at 256 bits, so “the nudge” is:
- **AES-128 → AES-256** (when you want long-lived confidentiality margins).

For hashes, the equivalent conservative move is often:
- **SHA-256 → SHA-384** (or another construction with higher classical strength), when your threat model demands it.

Do not treat this as a mandate to upgrade everything blindly. Follow NIST guidance and your protocol constraints, and measure performance impact.

Primary references:
- NIST PQC FAQ: https://csrc.nist.gov/projects/post-quantum-cryptography/faqs
- NIST SP 800-57 (key management and security strength): https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final
- NIST paper on practical Grover costs for AES: https://csrc.nist.gov/csrc/media/Events/2024/fifth-pqc-standardization-conference/documents/papers/on-practical-cost-of-grover.pdf

## Practical migration order

1) **TLS key exchange (often hybrid)**  
   Mitigates “harvest now, decrypt later” for network traffic captured today.

2) **Long-lived stored ciphertext**  
   Re-encrypt or re-wrap keys with quantum-resistant mechanisms when feasible.

3) **Signatures and PKI**  
   Usually the hardest area due to tooling, certificates, and ecosystem constraints.

## Hybrid as a transition tool (not a religion)

Hybrid constructions combine classical + PQ algorithms so the connection can remain secure if at least one component remains secure (assuming the composition is sound).

Hybrid often helps during transitions, but it also expands implementation surface. Pure PQ may be required in some environments. Treat this as a threat-model and policy decision.

## Reality check: library support matters more than theory

Start with:
- `reference/pqc/support-matrix.md`

Then validate:
- which TLS groups your stack negotiates
- certificate tooling support (CSR, CA issuance, validation)
- handshake size and latency impact
- failure modes with your real client fleet and middleboxes

## Common pitfalls

- Treating PQC as an “algorithm swap”  
  PQC changes message sizes, key formats, certificate tooling, and operational rollouts.

- Shipping PQ-only endpoints without interop planning  
  This can break clients and cause outages.

- Ignoring compliance modes  
  Approved-mode constraints often differ from default provider behavior.

## When NOT to prioritize PQC

- you have CRITICAL classical crypto issues
- your confidentiality needs are short-lived and you rotate keys aggressively
- you cannot deploy a transition safely yet (interop unknown)

Use `/crypto:audit` to prioritize properly.

