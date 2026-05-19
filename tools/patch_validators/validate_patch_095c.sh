#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHAR="$ROOT/scripts/ui/panels/CharacterPanel3D.gd"

[ -f "$CHAR" ] || { echo "Missing scripts/ui/panels/CharacterPanel3D.gd"; exit 1; }

if grep -q 'var class_name:' "$CHAR"; then
  echo "Forbidden reserved local variable remains: var class_name" >&2
  exit 1
fi

if grep -q '+ class_name +' "$CHAR"; then
  echo "Forbidden reserved identifier remains in concatenation: class_name" >&2
  exit 1
fi

grep -q 'var class_display: String' "$CHAR" || { echo "Missing class_display replacement"; exit 1; }
grep -q 'lines.append("\[b\]" + class_display + "\[/b\]")' "$CHAR" || { echo "Missing class_display title line"; exit 1; }

echo "095C validation passed."
