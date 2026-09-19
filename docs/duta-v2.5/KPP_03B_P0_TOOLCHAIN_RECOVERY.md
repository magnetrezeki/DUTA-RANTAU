# KPP-03B-P0 Toolchain Recovery

- Package manager: npm; lockfile: `package-lock.json` v3, preserved.
- Node actual: v24.14.1. NPM actual: 11.11.0. The repository specifies no Node/NPM version or engines field.
- Initial `npm` shim was broken. The host installation at `C:\Program Files\nodejs\npm.cmd` was used instead.
- `npm ci --ignore-scripts` restored packages but omitted executable shims. A subsequent deterministic `npm ci` encountered Windows `ENOTEMPTY` under `node_modules/next`; direct locked package binaries remain callable (`eslint/bin/eslint.js`, `typescript/bin/tsc`, `vitest/vitest.mjs`, `next/dist/bin/next`).
- Lint and typecheck direct invocations returned without reported errors. Vitest and build did not return a complete summary in the current command environment, so they are **UNVERIFIED**, not PASS.
- No package manifest or lockfile was modified.
