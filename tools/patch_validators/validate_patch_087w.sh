#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if grep -R '_rf_087[uv]__rf_087[uv]_' "$ROOT/scripts/core" "$ROOT/scripts/ui" "$ROOT/scripts/systems" >/tmp/087w_bad_double_prefix.txt 2>/dev/null; then
  cat /tmp/087w_bad_double_prefix.txt
  echo "Found remaining double-prefixed helper calls." >&2
  exit 1
fi

if ! grep -q "func _rf_087v_float" "$ROOT/scripts/core/GameRoot3D.gd"; then
  echo "GameRoot3D.gd missing _rf_087v_float helper." >&2
  exit 1
fi

if ! grep -q "func _rf_087v_int" "$ROOT/scripts/core/GameRoot3D.gd"; then
  echo "GameRoot3D.gd missing _rf_087v_int helper." >&2
  exit 1
fi

echo "087W validation passed."
