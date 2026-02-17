# Go TLS configuration (crypto/tls)

Go’s crypto/tls defaults are strong, but set explicit floors for safety.

## Server config (TLS 1.2+)

```go
import "crypto/tls"

tlsConfig := &tls.Config{
    MinVersion: tls.VersionTLS12,
    // TLS 1.3 is enabled by default when supported.
    CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
    // CipherSuites applies only to TLS 1.2 and below.
    CipherSuites: []uint16{
        tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
        tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
        tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
        tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
        tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,
        tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,
    },
}
```

## Client config

```go
tlsConfig := &tls.Config{
    MinVersion: tls.VersionTLS12,
    // InsecureSkipVerify: true // 🚫 never in prod
}
```

## PQC hybrid TLS

Go’s crypto/tls support depends on Go version and underlying support.
Verify support first; then test interoperability.
See `reference/pqc/support-matrix.md`.
