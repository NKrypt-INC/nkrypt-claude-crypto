# Testing Argon2id password hashing

Password hashing is probabilistic (random salt), so tests should check **properties**, not fixed outputs.

## Positive tests

- Hash output is non-empty and parses (if applicable)
- Hash differs across calls for the same password (random salt)
- Verify succeeds with correct password

## Negative tests

- Verify fails with wrong password
- Verify fails with tampered hash (edit one char)
- Verify fails with corrupted/invalid hash format

## Upgrade tests

- `needs_rehash` triggers when parameters change
- Rehash-on-login updates stored hash after successful verification

## Example: Node.js + Jest

```js
import { hashPassword, verifyPassword } from "../passwords.js";

test("argon2 hashes are salted", async () => {
  const h1 = await hashPassword("pw");
  const h2 = await hashPassword("pw");
  expect(h1).not.toEqual(h2);
});

test("verify ok + fail", async () => {
  const h = await hashPassword("pw");
  expect(await verifyPassword(h, "pw")).toBe(true);
  expect(await verifyPassword(h, "wrong")).toBe(false);
});

test("tamper fails", async () => {
  const h = await hashPassword("pw");
  const tampered = h.replace(/.$/, "x");
  expect(await verifyPassword(tampered, "pw")).toBe(false);
});
```

## Performance/DoS guardrails

- Measure hash verification latency in CI (rough bound).
- Avoid extremely heavy parameters that allow trivial DoS on login endpoints.
- Add request rate limits independent of hashing cost.

## Calibration: measure latency on your hardware

Treat recommended parameters as a starting point. Calibrate on your real hardware and concurrency.

### Node.js quick benchmark (outline)

```js
import { hashPassword, verifyPassword } from "./passwords.js";

const N = 50;

const run = async () => {
  const hash = await hashPassword("benchmark-password");
  const t0 = Date.now();
  for (let i = 0; i < N; i++) {
    const ok = await verifyPassword(hash, "benchmark-password");
    if (!ok) throw new Error("verify failed");
  }
  const dt = Date.now() - t0;
  console.log(`verify avg: ${(dt / N).toFixed(1)} ms over ${N} runs`);
};

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
```

### Python quick benchmark (outline)

```python
import time
from passwords import hash_password, verify_password

N = 50
h = hash_password("benchmark-password")
t0 = time.time()
for _ in range(N):
    assert verify_password(h, "benchmark-password") is True
dt = (time.time() - t0) * 1000.0
print(f"verify avg: {dt/N:.1f} ms over {N} runs")
```

Set your target based on your SLOs and DoS posture, not based on vibes.
