#!/usr/bin/env bash
# Upload files under repo/ to the R2 bucket, keyed by path relative to repo/.
# Usage: ./upload.sh [path ...]   (default: everything under repo/)
# Paths are relative to the current directory, like any other command.
set -euo pipefail

BUCKET=rapidcow-ftp-lib-java

root=$(realpath "$(dirname "$0")/repo")

# resolve args before we cd anywhere
if [ $# -eq 0 ]; then
  set -- "$root"
fi
paths=()
for p in "$@"; do
  abs=$(realpath -- "$p")
  case $abs/ in
    "$root"/*) paths+=("$abs") ;;
    *) echo "error: $p is not inside $root" >&2; exit 1 ;;
  esac
done

find "${paths[@]}" -type f | sort | while read -r abs; do
  key=${abs#"$root"/}
  echo "put $key"
  # --remote: wrangler defaults to a local simulated bucket otherwise
  npx wrangler r2 object put "$BUCKET/$key" --file "$abs" --remote
done
