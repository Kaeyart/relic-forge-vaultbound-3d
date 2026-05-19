#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$ROOT/scripts/ui/UIPanelRoot3D.gd"

[ -f "$FILE" ] || { echo "Missing scripts/ui/UIPanelRoot3D.gd"; exit 1; }

FIRST_NONEMPTY="$(grep -n -m 1 '[^[:space:]]' "$FILE" | cut -d: -f2-)"
if [ "$FIRST_NONEMPTY" = "@tool" ]; then
  SECOND_NONEMPTY="$(grep -n '[^[:space:]]' "$FILE" | sed -n '2p' | cut -d: -f2-)"
  if [[ "$SECOND_NONEMPTY" != extends* ]]; then
    echo "UIPanelRoot3D.gd does not have extends immediately after @tool" >&2
    exit 1
  fi
else
  if [[ "$FIRST_NONEMPTY" != extends* ]]; then
    echo "UIPanelRoot3D.gd first non-empty line is not extends" >&2
    echo "Found: $FIRST_NONEMPTY" >&2
    exit 1
  fi
fi

COUNT="$(grep -c '^const StationAccessSystemScript := preload("res://scripts/systems/StationAccessSystem3D.gd")$' "$FILE" || true)"
if [ "$COUNT" -ne 1 ]; then
  echo "Expected exactly one StationAccessSystemScript preload; found $COUNT" >&2
  exit 1
fi

grep -q "_rf_091a_block_station_panel" "$FILE" || { echo "UIPanelRoot missing 091A station lock helper"; exit 1; }

echo "091B validation passed."
