# Auditing monorepos, multi-repo trees, and submodules

Large repos hide crypto problems in boring places: shared libs, generated bundles, vendored deps, and “temporary” scripts.

This doc gives practical tactics for `/crypto:audit` when the repo is not a single clean app.

## Recognize the layout

### 1) Git submodules

If the repo has `.gitmodules`, treat each submodule like its own mini-repo:
- inventory it separately
- run secrets scanning with history where possible
- scan its dependency manifests and lockfiles

Command:
```bash
git submodule status --recursive
```

### 2) Monorepo workspaces

Common patterns:
- Node: `package.json` with `workspaces`, `pnpm-workspace.yaml`, `lerna.json`
- Python: multiple `pyproject.toml` (Poetry/PEP 621) or multiple `requirements.txt`
- Go: multiple `go.mod` files (multi-module)
- Java: multi-module Maven (`pom.xml` with modules) or Gradle multi-project (`settings.gradle*`)
- .NET: `.sln` with multiple projects

## How to scan without drowning

### A) Start with a repo map

List:
- top-level apps and shared libs
- where auth lives
- where TLS terminates
- where secrets get loaded (env, files, KMS)

Then scan in chunks.

### B) Chunk scanning

Instead of “scan everything,” do:
- `apps/*` and `services/*`
- `libs/*` and `packages/*`
- `infra/*` (Terraform, Helm, K8s)
- `dist/` and `build/` only when you suspect embedded keys or crypto behavior

This makes false negatives more visible because you can state coverage per chunk.

### C) Aggregate results

For each module, produce:
- its top CRITICAL/HIGH findings
- its crypto-critical dependencies
- its TLS termination points
- its “needs deeper check” notes

Then aggregate into one remediation plan.

## Raising assurance in big repos

- Prefer AST tools (Semgrep) once you identify hotspots.
- Prefer dedicated scanners (gitleaks, SBOM/SCA) for scale.
- Add CI gates per module so fixes do not regress.

See:
- `reference/audit/methodology.md`
- `reference/operations/supply-chain.md`
- `reference/tooling/semgrep.md`
