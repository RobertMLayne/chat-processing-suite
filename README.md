# chat-history-integration-ledger

Base scaffolding for unifying parallel implementations that analyze OpenAI ChatGPT data exports. Windows-first (PowerShell 7+). This repo includes only **base** materials. Run scripts to generate artifacts when ready.

## Layout

- `docs/adr`: decision records.
- `docs/ledger`: generated ledgers (indexes, hashes) will land here.
- `scripts`: PowerShell utilities to inventory, parse, and verify.
- `.github/workflows`: CI guards for LFS and verification.

## Quick start (Windows)

```powershell
# From repository root
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\lfs-track.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify-repo.ps1
# Generate inventory and clustering when ready (produces files under docs/ledger/)
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\inventory.ps1 -DryRun
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\cluster-export.ps1 -DryRun
