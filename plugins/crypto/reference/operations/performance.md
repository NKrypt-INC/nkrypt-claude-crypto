# Performance impact guidance (starter)

## Password hashing (Argon2id vs bcrypt)

- Argon2id often increases memory usage per verification (by design).
- Calibrate parameters to hit your latency budget on your real hardware and concurrency.
- Protect endpoints with rate limiting to prevent DoS.

Rule: measure on production-like hardware. Track p50/p95, not just averages.

## AEAD encryption

- AES-GCM is fast on CPUs with AES-NI.
- ChaCha20-Poly1305 is often faster on mobile/without AES acceleration.
- The bottleneck is usually I/O, not AES.

## PQC / hybrid TLS

Hybrid key exchange increases:
- handshake message sizes (more bytes on the wire)
- CPU cost (usually modest, but measurable)
- risk of middlebox breakage (interop!)

Treat hybrid TLS rollout as a measured production change with monitoring and rollback.

See `reference/testing/pqc.md`.
