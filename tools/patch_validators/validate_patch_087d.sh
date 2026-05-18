#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== validate 087D clean 3D design foundation =="

required=(
  "docs/RELIC_FORGE_3D_CLEAN_DESIGN_FOUNDATION.md"
  "docs/PORTING_RULES_2D_TO_3D.md"
  "docs/PATCH_087D_CLEAN_DESIGN_FOUNDATION.md"
  "scripts/core/GameState3D.gd"
  "scripts/data/ItemDB3D.gd"
  "scripts/data/AffixDB3D.gd"
  "scripts/data/SkillDB3D.gd"
  "scripts/data/MapDB3D.gd"
  "scripts/systems/CharacterClassSystem3D.gd"
  "scripts/systems/LootSystem3D.gd"
  "scripts/systems/CraftingSystem3D.gd"
  "scripts/systems/MapLoopSystem3D.gd"
  "scripts/systems/ProgressionSystem3D.gd"
  "scripts/systems/SaveSystem3D.gd"
)

for path in "${required[@]}"; do
  if [ ! -f "$path" ]; then
    echo "ERROR: missing $path" >&2
    exit 1
  fi
  echo "OK: $path"
done

if grep -R "class_name RVGameState$\|class_name RVCombatArena\|class_name RVPassiveAtlasPanel" scripts 2>/dev/null; then
  echo "ERROR: old 2D class names detected in active scripts" >&2
  exit 1
fi

if grep -R "func _get(\|func _set(" scripts 2>/dev/null; then
  echo "ERROR: reserved _get/_set helper signature detected" >&2
  exit 1
fi

if grep -R "GeneratedTreeScroll\|GeneratedSummaryLabel\|GeneratedDetailText" scripts scenes 2>/dev/null; then
  echo "ERROR: generated fallback UI markers detected" >&2
  exit 1
fi

if [ -d _ported_from_2d_raw ]; then
  if find _ported_from_2d_raw -name '*.gd' -o -name '*.tscn' | grep -q .; then
    echo "ERROR: raw 2D snapshot contains active .gd/.tscn files; it must remain inert" >&2
    exit 1
  fi
fi

echo "087D validation passed."
