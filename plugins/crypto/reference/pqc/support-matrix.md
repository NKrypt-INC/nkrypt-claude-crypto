# PQC library and platform support matrix (last reviewed 2026-02-14)

PQC support changes quickly. Treat this as a **starting point**, then verify against your exact:
- runtime and library versions
- distro backports
- client fleet and middleboxes

## Canonical hybrid TLS groups

The IETF TLS working group draft defines hybrid TLS 1.3 named groups that combine ECDHE + ML-KEM, including:

- `X25519MLKEM768`
- `SecP256r1MLKEM768`
- `SecP384r1MLKEM1024`

Reference:
- IETF datatracker: `draft-ietf-tls-ecdhe-mlkem`  
  https://datatracker.ietf.org/doc/draft-ietf-tls-ecdhe-mlkem/

## Support matrix (high-level)

| Stack / library | ML-KEM | ML-DSA | SLH-DSA | Hybrid TLS 1.3 groups | Notes |
|---|---:|---:|---:|---:|---|
| OpenSSL 3.5 (default provider) | ✅ | ✅ | ✅ | ✅ | OpenSSL 3.5 adds PQC algorithms (ML-KEM/ML-DSA/SLH-DSA) and hybrid TLS 1.3 groups. See OpenSSL 3.5 release announcement and docs: https://openssl-library.org/post/2025-04-08-openssl-35-final-release/ and https://docs.openssl.org/3.5/man3/SSL_CONF_cmd/ |
| OpenSSL 3.5 (FIPS provider) | ⚠️ (varies) | ⚠️ (varies) | ⚠️ (varies) | ⚠️ (varies) | PQC support in FIPS mode varies by vendor and validated build. In some distros, PQC algorithms are present in the default provider but not available in the FIPS provider; only hybrid groups that use FIPS-approved curves may function in FIPS mode. Example: RHEL 10.1 notes this explicitly (updated 2025-11-11): https://access.redhat.com/articles/7119430 |
| OpenSSL + OQS Provider (`oqs-provider`) | ✅ | ✅ | ✅ | ✅ (many hybrids) | Useful for prototyping and early adoption. Expect churn around identifiers and policy defaults. Prefer standard names when available. |
| BoringSSL (TLS-focused) | ✅ (TLS KEM) | (TLS-specific) | (TLS-specific) | ✅ (`X25519MLKEM768`) | BoringSSL implemented `X25519MLKEM768` for TLS. See the upstream commit: https://boringssl.googlesource.com/boringssl/+/7fb4d3da5082225c7180267e9daad291887ce982 and Cloudflare client example: https://developers.cloudflare.com/ssl/post-quantum-cryptography/pqc-to-origin/ |
| Go `crypto/tls` (Go 1.24+) | ✅ (TLS KEM) | (N/A in stdlib) | (N/A in stdlib) | ✅ (`X25519MLKEM768`) | The Go `crypto/tls` docs note that the default includes `X25519MLKEM768` starting in Go 1.24 when `CurvePreferences` is empty. See: https://pkg.go.dev/crypto/tls |
| NSS / GnuTLS (distro-dependent) | ✅ (varies) | ✅ (varies) | ⚠️ | ⚠️ | Distro backports vary. For one concrete distro view, see RHEL 10’s PQC interop notes: https://www.redhat.com/en/blog/post-quantum-cryptography-red-hat-enterprise-linux-10 |
| rustls | ⚠️ (provider-dependent) | ⚠️ | ⚠️ | ⚠️ | rustls support depends on the crypto provider (ring vs aws-lc, etc). Track rustls + provider release notes and test interop in your environment. |
| Java (OpenJDK) TLS stacks | ⚠️ (version-dependent) | ⚠️ | ⚠️ | ⚠️ | Track OpenJDK work (example issue): https://bugs.openjdk.org/browse/JDK-8369848 and test with your JVM vendor builds. |

Legend:
- ✅ supported in some form in mainstream releases
- ⚠️ depends heavily on provider, distro, or build flags

## How to verify quickly (copy-paste checks)

### OpenSSL

```bash
openssl version -a
openssl list -groups | rg -n "MLKEM|KYBER|X25519MLKEM|SecP256r1MLKEM|SecP384r1MLKEM" || true
```

Probe a specific group (if listed):
```bash
openssl s_client -connect example.com:443 -servername example.com -tls1_3 -groups X25519MLKEM768 -brief </dev/null
```

### Go

```bash
go env GOVERSION
go doc crypto/tls.Config | sed -n '1,120p'
```

If your code sets `CurvePreferences`, you may disable defaults unintentionally.

## What this matrix does not do

- It does not guarantee your distribution shipped the feature.
- It does not guarantee interop with your client fleet or middleboxes.
- It does not replace testing in staging with real traffic patterns.

For rollouts, use:
- `/crypto:migrate-pqc`
- `reference/testing/pqc.md`
