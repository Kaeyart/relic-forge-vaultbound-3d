#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D
required=(
  scripts/core/GameRoot3D.gd
  scripts/core/GameState3D.gd
  scripts/data/ItemDB3D.gd
  scripts/data/AffixDB3D.gd
  scripts/data/GemDB3D.gd
  scripts/data/MapDB3D.gd
  scripts/systems/SkillGemSystem3D.gd
  scripts/systems/LootSystem3D.gd
  scripts/systems/LootPickupSystem3D.gd
  scripts/systems/CraftingSystem3D.gd
  scripts/systems/MapLoopSystem3D.gd
  scripts/loot/LootActor3D.gd
  scripts/pets/PickupPet3D.gd
  scenes/main/GameRoot3D.tscn
  scenes/prefabs/loot/LootActor3D.tscn
  scenes/prefabs/pets/PickupPet3D.tscn
)
for f in "${required[@]}"; do
  test -f "$f" || { echo "MISSING: $f"; exit 1; }
done
if grep -R "var class_name" -n scripts; then
  echo "ERROR: reserved class_name variable present" >&2
  exit 1
fi
if grep -R "func _get\|func _set" -n scripts; then
  echo "ERROR: forbidden _get/_set helper signature present" >&2
  exit 1
fi
echo "087J validator OK"
