#!/usr/bin/env bash
# Upload everything under repo/ to the R2 bucket, keyed by path relative to repo/.
# Usage: ./upload.sh [path-under-repo ...]   (default: everything)
set -euo pipefail

BUCKET=rapidcow-ftp-lib-java

cd "$(dirname "$0")/repo"

if [ $# -eq 0 ]; then
  set -- .
fi

find "$@" -type f | sed 's|^\./||' | sort | while read -r f; do
  echo "put $f"
  # --remote: wrangler defaults to a local simulated bucket otherwise
  npx wrangler r2 object put "$BUCKET/$f" --file "$f" --remote
done
