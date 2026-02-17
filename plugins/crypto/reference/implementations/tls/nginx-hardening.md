# nginx TLS hardening (TLS 1.3 + hardened TLS 1.2)

This is a **baseline** configuration for public HTTPS services.

- Prefer TLS 1.3
- Keep TLS 1.2 enabled for compatibility
- Use AEAD ciphers only for TLS 1.2
- Disable session tickets unless you have a strong operational reason to keep them

## Copy-paste config (starting point)

```nginx
# TLS
ssl_protocols TLSv1.2 TLSv1.3;

# TLS 1.2 ciphers (TLS 1.3 ciphers are not configured here)
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;

# Sessions
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;

# OCSP stapling (optional but recommended when supported)
ssl_stapling on;
ssl_stapling_verify on;

# DNS resolver for OCSP (adjust for your environment)
resolver 1.1.1.1 8.8.8.8 valid=300s;
resolver_timeout 5s;

# HSTS (only enable if you serve HTTPS exclusively)
add_header Strict-Transport-Security "max-age=63072000" always;

# Security headers (consider adding)
# add_header X-Content-Type-Options "nosniff" always;
# add_header X-Frame-Options "DENY" always;
```

## PQC hybrid TLS (advanced, verify support first)

Only do this if your nginx links against OpenSSL 3.5+ (or an equivalent PQ-capable stack) and you have tested client compatibility.

In OpenSSL-backed stacks, hybrid groups are typically configured via OpenSSL “Groups” / supported groups settings.
Consult:
- `reference/pqc/support-matrix.md`
- `/crypto:migrate-pqc`

## Verification

- Use SSL Labs or `testssl.sh` on the endpoint.
- Confirm protocol floors:
  - TLS 1.0/1.1 should fail
  - TLS 1.2 and 1.3 should succeed
