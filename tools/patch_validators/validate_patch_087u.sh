#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$ROOT/scripts/core/GameRoot3D.gd"

[ -f "$FILE" ] || { echo "Missing GameRoot3D.gd"; exit 1; }

grep -q "func _rf_087u_float" "$FILE" || { echo "Missing _rf_087u_float helper"; exit 1; }
grep -q "func _rf_087u_int" "$FILE" || { echo "Missing _rf_087u_int helper"; exit 1; }

if grep -nE '(^|[^A-Za-z0-9_])(float|int)\(' "$FILE" | grep -v '_rf_087u_' >/tmp/087u_bad_casts.txt 2>/dev/null; then
  cat /tmp/087u_bad_casts.txt
  echo "Found direct float()/int() constructor calls in GameRoot3D.gd." >&2
  exit 1
fi

echo "087U validation passed."
