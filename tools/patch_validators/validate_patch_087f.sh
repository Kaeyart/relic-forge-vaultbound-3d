#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

echo "== Patch 087F validation =="

required=(
  scripts/core/GameState3D.gd
  scripts/data/AffixDB3D.gd
  scripts/data/ItemDB3D.gd
  scripts/data/SkillDB3D.gd
  scripts/systems/LootSystem3D.gd
  scripts/ui/GameHUD3D.gd
  docs/PATCH_087F_3D_ITEMIZATION_EQUIPMENT.md
)

for f in "${required[@]}"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: missing $f"
    exit 1
  fi
  echo "OK: $f"
done

for symbol in 'prefixes' 'suffixes' 'total_stats' 'forge_potential' 'item_level' 'compare_text'; do
  if ! grep -R "$symbol" -n scripts/data/ItemDB3D.gd scripts/ui/GameHUD3D.gd >/dev/null; then
    echo "ERROR: expected symbol not found: $symbol"
    exit 1
  fi
  echo "OK: symbol $symbol"
done

if ! grep -q 'class_name RVAffixDB3D' scripts/data/AffixDB3D.gd; then
  echo "ERROR: AffixDB3D class missing"
  exit 1
fi

if grep -R 'func _get(' -n scripts --include='*.gd' >/tmp/rv087f_bad.txt; then
  echo "ERROR: forbidden fragile _get helper found"
  cat /tmp/rv087f_bad.txt
  exit 1
fi
if grep -R 'func _set(' -n scripts --include='*.gd' >/tmp/rv087f_bad.txt; then
  echo "ERROR: forbidden fragile _set helper found"
  cat /tmp/rv087f_bad.txt
  exit 1
fi

if ! grep -q 'build_stats' scripts/core/GameState3D.gd; then
  echo "ERROR: GameState3D does not expose build_stats"
  exit 1
fi

if ! grep -q 'strict slot/tag affix rules' scripts/ui/GameHUD3D.gd; then
  echo "ERROR: HUD does not appear to be updated for 087F item detail"
  exit 1
fi

echo "Patch 087F validation passed."
