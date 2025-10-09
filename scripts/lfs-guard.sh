#!/usr/bin/env bash
set -euo pipefail
limit=$((50*1024*1024))  # warn threshold
fail=$((100*1024*1024))  # GitHub blocks ≥100 MiB  # source: GitHub docs
bad=0

while IFS= read -r -d '' f; do
  size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")
  if [ "$size" -ge "$limit" ]; then
    if ! git lfs ls-files --name-only -- "$f" >/dev/null 2>&1; then
      echo "ERROR: $f is ${size} bytes and not tracked by LFS."
      bad=1
    fi
  fi
  if [ "$size" -ge "$fail" ]; then
    echo "ERROR: $f is ${size} bytes (≥100 MiB). GitHub will block pushes."
    bad=1
  fi
done < <(git ls-files -z)

exit $bad
# GitHub blocks files ≥100 MiB; use Git LFS. :contentReference[oaicite:9]{index=9}
