# Apache httpd TLS hardening (TLS 1.3 + hardened TLS 1.2)

This is a baseline for modern Apache 2.4 deployments.

## Copy-paste config (starting point)

```apacheconf
# Enable TLS 1.2 and TLS 1.3 only
SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1

# TLS 1.2 cipher suites (TLS 1.3 ciphers are not configured here)
SSLCipherSuite          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
SSLHonorCipherOrder     off

# Session tickets (disable unless you have a strong reason to enable)
SSLSessionTickets       off

# OCSP stapling (optional but recommended)
SSLUseStapling          on
SSLStaplingCache        "shmcb:/var/run/ocsp(128000)"

# HSTS (only enable if you serve HTTPS exclusively)
Header always set Strict-Transport-Security "max-age=63072000"
```

## PQC hybrid TLS (advanced)

Only enable hybrid groups after verifying:
- OpenSSL (or your TLS provider) supports ML-KEM hybrid groups
- your client fleet interoperates

See:
- `reference/pqc/support-matrix.md`
- `/crypto:migrate-pqc`

## Verification

- Run SSL Labs / testssl.sh
- Confirm TLS 1.0/1.1 are rejected
