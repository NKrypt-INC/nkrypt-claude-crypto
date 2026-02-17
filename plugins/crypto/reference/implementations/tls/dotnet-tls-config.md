# .NET TLS configuration (Kestrel / SslProtocols)

.NET defaults are generally strong. Set protocol floors explicitly.

## Example: ASP.NET Core Kestrel

```csharp
using System.Security.Authentication;

builder.WebHost.ConfigureKestrel(options =>
{
    options.ConfigureHttpsDefaults(httpsOptions =>
    {
        httpsOptions.SslProtocols = SslProtocols.Tls12 | SslProtocols.Tls13;
        // Configure certificate loading here (store, file, etc.)
    });
});
```

## Client footgun

- `HttpClientHandler.ServerCertificateCustomValidationCallback = (_,_,_,_) => true;`
  This disables validation. Avoid it outside of tightly scoped dev scenarios.

## PQC hybrid TLS

Hybrid support depends on the underlying TLS provider and OS crypto stack.
Start with `reference/pqc/support-matrix.md` and test interoperability.
