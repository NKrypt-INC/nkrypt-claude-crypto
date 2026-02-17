# Python TLS configuration (ssl.SSLContext)

Python’s `ssl` module wraps OpenSSL. Use `SSLContext` and set protocol floors explicitly.

## Server context (TLS 1.2+)

```python
import ssl

ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.minimum_version = ssl.TLSVersion.TLSv1_2

# TLS 1.2 cipher suites (TLS 1.3 ciphers are not controlled here)
ctx.set_ciphers(
    "ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:!aNULL:!eNULL:!MD5:!DSS"
)

ctx.options |= ssl.OP_NO_COMPRESSION

ctx.load_cert_chain(certfile="cert.pem", keyfile="key.pem")
```

## Client context (verify certificates)

```python
import ssl

ctx = ssl.create_default_context()
ctx.minimum_version = ssl.TLSVersion.TLSv1_2
ctx.check_hostname = True
ctx.verify_mode = ssl.CERT_REQUIRED

# If using private PKI:
# ctx.load_verify_locations(cafile="internal-ca.pem")
```

## Footguns

- `CERT_NONE` or `check_hostname = False` disables validation.
- Catching TLS errors and retrying with insecure settings.

## PQC hybrid TLS

Requires PQ-capable OpenSSL and client interoperability.
See `reference/pqc/support-matrix.md`.
