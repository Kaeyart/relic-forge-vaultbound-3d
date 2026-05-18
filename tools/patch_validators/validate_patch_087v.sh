#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

grep -q "func _rf_087v_float" "$ROOT/scripts/ui/GameHUD3D.gd" || { echo "GameHUD missing safe float helper"; exit 1; }
grep -q "func _rf_087v_int" "$ROOT/scripts/ui/GameHUD3D.gd" || { echo "GameHUD missing safe int helper"; exit 1; }

if grep -R 'float(_state_get' "$ROOT/scripts/ui" >/tmp/087v_bad_ui_float.txt 2>/dev/null; then
  cat /tmp/087v_bad_ui_float.txt
  echo "Found unsafe float(_state_get(...)) in UI scripts." >&2
  exit 1
fi

if grep -R 'int(_state_get' "$ROOT/scripts/ui" >/tmp/087v_bad_ui_int.txt 2>/dev/null; then
  cat /tmp/087v_bad_ui_int.txt
  echo "Found unsafe int(_state_get(...)) in UI scripts." >&2
  exit 1
fi

echo "087V validation passed."
