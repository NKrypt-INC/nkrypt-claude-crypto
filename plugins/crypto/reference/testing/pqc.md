# Testing PQC and hybrid deployments

PQC failures often look like “random handshake breakage” because interoperability is the hard part.

Treat testing as a first-class deliverable, not a footnote.

## What to test

### 1) Interoperability matrix (clients + middleboxes)

Test across:
- OS versions (Windows/macOS/Linux)
- runtime versions (JDK, Node, Go, OpenSSL)
- browsers (if applicable)
- mobile SDKs and embedded clients
- load balancers, WAFs, TLS inspection, proxies, service meshes

Record results in a table and keep it in-repo.

### 2) Negotiation behavior

Verify:
- server offers classical + hybrid groups
- clients negotiate hybrid when supported
- clients fall back to classical when needed
- rollback works (hybrid disabled) without outages

### 3) Performance and size

Measure:
- handshake latency (p50/p95/p99)
- CPU cost at termination points
- handshake sizes (watch for MTU fragmentation and middlebox limits)

### 4) Failure modes

Collect error distributions:
- handshake alert types
- client cohorts that fail
- correlation with middleboxes and TLS inspection

## Practical tooling (copy-paste starters)

### OpenSSL (when available)

Helper template: `tools/pqc-handshake-matrix.sh`.


List supported groups:
```bash
openssl list -groups
```

Force a group in a handshake:
```bash
openssl s_client -connect HOST:443 -groups X25519MLKEM768:X25519
```

Tip: capture `-msg` output for debugging when safe:
```bash
openssl s_client -connect HOST:443 -groups X25519MLKEM768:X25519 -msg
```

### testssl.sh / sslyze

Use these for black-box endpoint testing:
- protocol floors
- cipher suite posture
- general TLS hygiene

They may not fully surface hybrid group negotiation, so combine with OpenSSL/Wireshark.

### Wireshark

Use Wireshark to confirm:
- key share group sent
- HelloRetryRequest behavior (if used)
- negotiated group

Only do this in environments where key logging and packet capture are permitted.

## Automation hooks (CI/staging)

- run handshake probes from a small client zoo (Node, Java, Go, OpenSSL)
- fail a build when handshake failure rate crosses a threshold in staging
- store negotiation results (protocol, group, alert) as artifacts

## Example success criteria (tune to your SLOs)

- handshake failure rate stays within **baseline + delta** (set delta based on your error budget)
- p95 handshake latency increase stays within your error budget
- no single client cohort experiences > 1% failure without an explicit exception/plan

## Notes

- Always test behind the real termination stack (LB/proxy/mesh), not just localhost.
- Prefer reversible rollouts. Treat “we cannot roll back” as a blocker.


## Fault and side-channel notes (when it matters)

Most application teams use vetted libraries and do not implement PQ primitives directly.

Escalate to deeper review if:
- you run on hostile hardware (physical access threat)
- you implement primitives yourself
- you rely on custom accelerators or HSM integrations

In those cases, add:
- fault injection considerations (glitching, induced errors)
- side-channel review for your environment (timing, cache, power)
