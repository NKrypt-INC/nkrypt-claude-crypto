# Supply chain and dependency integrity (crypto-specific focus)

Crypto breaks in boring ways: a dependency update, a typosquat, an unmaintained fork.

This doc focuses on practical controls you can add without turning your build into a ritual.

## Baseline controls

### 1) Always use lockfiles

- Node: commit `package-lock.json` / `pnpm-lock.yaml` / `yarn.lock`
- Python: lock with Poetry/Pipenv, or use `pip-tools` compiled requirements
- Go: commit `go.sum`
- Rust: commit `Cargo.lock` (even for libs when used in apps)
- .NET: commit `packages.lock.json` where possible

### 2) Prefer reproducible installs in CI

- Node: `npm ci` (not `npm install`)
- Python: pin versions, then install from a lock; consider `--require-hashes` for high assurance
- Go: `go mod download` + `go mod verify`
- Rust: `cargo fetch` + `cargo vendor` (optional) + `cargo build --locked`
- .NET: lock mode + restore locked

### 3) Scan dependencies for known vulns

Use ecosystem-native scanners plus an OSV-based scanner when practical:
- OSV scanner against lockfiles
- `npm audit`, `pip-audit`, `govulncheck`, `cargo audit`, `dotnet list package --vulnerable`

Do not treat “no findings” as “secure”. Treat it as “no known CVEs in this view”.

## Higher assurance controls (pick what fits)

- generate an SBOM (syft or your platform’s tooling), then scan it (grype, osv-scanner)
- restrict registries and require provenance where your platform supports it
- use dependency allowlists for crypto primitives (known-good libs, disallow abandoned forks)
- watch for “single maintainer” critical packages and set a policy for updates

## Crypto library extra caution

Apply extra scrutiny to:
- TLS libraries and providers
- crypto wrappers and “helpers”
- JWT libraries (auth bypass history is long)

Prefer:
- widely used, actively maintained libraries
- libraries with published security reviews
- standard APIs over “clever” wrappers

## What /crypto:audit should flag

- unmaintained crypto dependencies
- wrappers that hide algorithm choice (hard to audit)
- build scripts that download prebuilt binaries without verification
