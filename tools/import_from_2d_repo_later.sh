#!/usr/bin/env bash
set -euo pipefail
SRC="${1:-/home/kaey/Desktop/Game}"
DEST="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -d "$SRC" ]; then
  echo "Source 2D repo not found: $SRC"
  exit 1
fi

mkdir -p "$DEST/_ported_from_2d"
for path in scripts/data scripts/systems; do
  if [ -d "$SRC/$path" ]; then
    mkdir -p "$DEST/_ported_from_2d/$(dirname "$path")"
    cp -a "$SRC/$path" "$DEST/_ported_from_2d/$path"
    echo "Copied $path into _ported_from_2d for manual review."
  fi
done

echo "Nothing was activated automatically. Review _ported_from_2d before merging into live scripts."
