#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

echo "== Patch 087E validation =="

required=(
  project.godot
  scenes/main/GameRoot3D.tscn
  scenes/hub/VaultHub3D.tscn
  scenes/combat/CombatArena3D.tscn
  scenes/prefabs/player/Player3D.tscn
  scenes/prefabs/enemies/Enemy3D.tscn
  scenes/prefabs/projectiles/Projectile3D.tscn
  scenes/ui/GameHUD3D.tscn
  scripts/core/GameRoot3D.gd
  scripts/core/GameState3D.gd
  scripts/data/ItemDB3D.gd
  scripts/data/SkillDB3D.gd
  scripts/data/MapDB3D.gd
  scripts/systems/LootSystem3D.gd
  scripts/systems/MapLoopSystem3D.gd
  scripts/systems/ProgressionSystem3D.gd
  scripts/systems/SaveSystem3D.gd
  scripts/player/PlayerActor3D.gd
  scripts/hub/VaultHub3D.gd
  scripts/combat/CombatArena3D.gd
  scripts/combat/EnemyActor3D.gd
  scripts/combat/ProjectileActor3D.gd
)

for f in "${required[@]}"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: missing $f"
    exit 1
  fi
  echo "OK: $f"
done

if ! grep -q 'run/main_scene="res://scenes/main/GameRoot3D.tscn"' project.godot; then
  echo "ERROR: project.godot does not point to GameRoot3D.tscn"
  exit 1
fi

for bad in 'func _get(' 'func _set(' 'RVClassIdentitySystem' 'RVPassiveTreeSystem'; do
  if grep -R "$bad" -n scripts scenes --include='*.gd' --include='*.tscn' >/tmp/rv087e_bad.txt; then
    echo "ERROR: found forbidden old/fragile symbol: $bad"
    cat /tmp/rv087e_bad.txt
    exit 1
  fi
done

if grep -R '_ported_from_2d_raw.*\.gd' -n . >/dev/null 2>&1; then
  echo "ERROR: inert 2D snapshot should not contain active .gd files"
  exit 1
fi

echo "Patch 087E validation passed."
