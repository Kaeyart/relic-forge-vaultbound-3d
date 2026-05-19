#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GEM="$ROOT/scripts/systems/GemCoreSystem3D.gd"

[ -f "$GEM" ] || { echo "Missing scripts/systems/GemCoreSystem3D.gd"; exit 1; }

grep -q 'var xp: int' "$GEM" || { echo "GemCore missing explicit xp int"; exit 1; }
grep -q 'var reservation: float' "$GEM" || { echo "GemCore missing explicit reservation float"; exit 1; }
grep -q 'var level: int' "$GEM" || { echo "GemCore missing explicit level int"; exit 1; }
grep -q 'var data: Dictionary' "$GEM" || { echo "GemCore missing explicit data Dictionary"; exit 1; }
grep -q 'install_active_from_inventory' "$GEM" || { echo "GemCore missing active install"; exit 1; }
grep -q 'install_support_from_inventory_to_active' "$GEM" || { echo "GemCore missing active support install"; exit 1; }
grep -q 'install_support_from_inventory_to_spirit' "$GEM" || { echo "GemCore missing spirit support install"; exit 1; }
grep -q 'install_spirit_from_inventory' "$GEM" || { echo "GemCore missing spirit install"; exit 1; }
grep -q 'active_quality_extra_projectiles' "$GEM" || { echo "GemCore missing quality projectile helper"; exit 1; }

if grep -q 'var xp :=' "$GEM"; then
  echo "Found forbidden inferred xp variable" >&2
  exit 1
fi
if grep -q 'var res :=' "$GEM"; then
  echo "Found forbidden inferred res variable" >&2
  exit 1
fi
if grep -q 'var level :=' "$GEM"; then
  echo "Found forbidden inferred level variable" >&2
  exit 1
fi

echo "093B validation passed."
