# Contributing

1. Fork and branch from `main`. Use conventional commits.
2. Install and enable `pre-commit` locally to catch trivial issues before review. :contentReference[oaicite:3]{index=3}
3. Keep generated artifacts out of commits; regenerate via scripts when needed.
4. For large files, add patterns via `scripts/lfs-track.ps1` before committing. GitHub blocks files ≥100 MiB. :contentReference[oaicite:4]{index=4}
