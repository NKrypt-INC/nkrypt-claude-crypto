# Node.js TLS configuration (https/tls)

Node uses OpenSSL under the hood. Good news: modern Node defaults are usually sane, but it’s easy to shoot yourself in the foot with “temporary” flags.

## Server: enforce TLS 1.2+ (prefer 1.3)

```js
import https from "https";
import fs from "fs";

const tlsOptions = {
  key: fs.readFileSync("./tls/key.pem"),
  cert: fs.readFileSync("./tls/cert.pem"),

  minVersion: "TLSv1.2",
  maxVersion: "TLSv1.3",

  // TLS 1.2 only. TLS 1.3 cipher suites aren't controlled here.
  ciphers:
    "ECDHE-ECDSA-AES128-GCM-SHA256:" +
    "ECDHE-RSA-AES128-GCM-SHA256:" +
    "ECDHE-ECDSA-AES256-GCM-SHA384:" +
    "ECDHE-RSA-AES256-GCM-SHA384:" +
    "ECDHE-ECDSA-CHACHA20-POLY1305:" +
    "ECDHE-RSA-CHACHA20-POLY1305",

  honorCipherOrder: true,
};

https.createServer(tlsOptions, (req, res) => {
  res.writeHead(200);
  res.end("ok");
}).listen(443);
```

## Client: never disable cert validation

Bad:
```js
// rejectUnauthorized: false  // 🚫 don't do this in prod
```

Good (defaults + pinned CA when needed):
```js
import https from "https";
import fs from "fs";

const agent = new https.Agent({
  minVersion: "TLSv1.2",
  ca: fs.readFileSync("./tls/internal-ca.pem"), // only if you use private PKI
});

https.get("https://internal.service", { agent }, res => { /* ... */ });
```

## PQC hybrid TLS

Hybrid groups require your OpenSSL build to support them and your clients to interoperate.
See:
- `reference/pqc/support-matrix.md`
- `/crypto:migrate-pqc`

## Quick checks

- `NODE_DEBUG=tls` can help debug handshakes (be careful with logs).
- Use SSL Labs / testssl.sh for public endpoints.
