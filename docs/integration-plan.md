# Integration Plan (Base)

- **Stage 0:** Ensure Git ≥2.42, Git LFS ≥3.x, PowerShell 7+.
- **Stage 1:** Run `scripts/inventory.ps1 -DryRun` then `-Execute` to emit ledger files.
- **Stage 2:** Run `scripts/cluster-export.ps1 -DryRun` then `-Execute` to emit cluster docs.
- **Stage 3:** Draft ADRs for major choices; start with ADR-0001 (policy).
- **Stage 4:** Add CI + pre-commit; run `scripts/verify-repo.ps1`.

> This file is base-only. Generated artifacts are described in `docs/ledger/README.md` and are not included.
