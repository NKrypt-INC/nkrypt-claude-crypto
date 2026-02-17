# Java TLS configuration (JDK + common servers)

Java TLS configuration depends on the server framework (Jetty, Tomcat, Netty, etc.).
The core idea: set protocol floors and avoid insecure “trust all” managers.

## Minimum baseline (conceptual)

- Enable TLS 1.3 and TLS 1.2
- Disable TLS 1.0/1.1
- Use default trust store or pin a private CA appropriately
- Never ship a TrustManager that accepts all certs

## Example: Spring Boot / Tomcat (application.properties)

```properties
server.ssl.enabled-protocols=TLSv1.3,TLSv1.2
# Optionally restrict ciphers for TLS 1.2:
# server.ssl.ciphers=...
```

## Example: programmatic SSLParameters

```java
import javax.net.ssl.SSLParameters;

SSLParameters p = new SSLParameters();
p.setProtocols(new String[] { "TLSv1.3", "TLSv1.2" });
```

## PQC hybrid TLS

Support varies by JDK and provider.
If you rely on OpenSSL (via native) vs JSSE, the capabilities differ.
Start with `reference/pqc/support-matrix.md`.
