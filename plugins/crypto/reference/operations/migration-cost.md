# Migration cost estimation (starter)

Crypto migrations are mostly about:
- surface area (how many services/clients)
- interop constraints
- data re-encryption volume
- key rotation logistics

## Example questions

### “How long to migrate 10M password hashes from bcrypt to Argon2id?”
- If you do **rehash-on-login**, time depends on login rate distribution:
  - active users migrate quickly
  - inactive users never migrate until they return (or you force reset)
- If you do **forced reset**, it’s an ops + support cost, not CPU cost.

### “How long to enable hybrid PQ TLS?”
- Depends on:
  - TLS termination architecture (LB vs app servers)
  - client diversity
  - ability to canary + rollback
  - vendor support and patch cadence

## Recommendation

Estimate in phases:
1) Inventory (audit)
2) Prototype in staging (interop + performance)
3) Canary to small % of traffic
4) Expand rollout with monitoring
