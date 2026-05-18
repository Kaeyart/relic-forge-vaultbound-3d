#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Relic Forge 3D foundation validation =="
required=(
  project.godot
  scenes/main/GameRoot3D.tscn
  scripts/core/GameRoot3D.gd
  scripts/core/GameState3D.gd
  scripts/core/SaveSystem3D.gd
  scenes/hub/VaultHub3D.tscn
  scripts/hub/VaultHub3D.gd
  scenes/combat/CombatArena3D.tscn
  scripts/combat/CombatArena3D.gd
  scenes/prefabs/player/Player3D.tscn
  scripts/player/PlayerActor3D.gd
  scenes/prefabs/enemies/Enemy3D.tscn
  scripts/combat/EnemyActor3D.gd
  scenes/prefabs/projectiles/Projectile3D.tscn
  scripts/combat/ProjectileActor3D.gd
  scenes/ui/HUD3D.tscn
  scripts/ui/HUD3D.gd
)
for path in "${required[@]}"; do
  test -f "$path" || { echo "MISSING: $path"; exit 1; }
  echo "OK: $path"
done

grep -q 'run/main_scene="res://scenes/main/GameRoot3D.tscn"' project.godot || { echo "ERROR: project.godot does not point to GameRoot3D"; exit 1; }
grep -q 'func _process' scripts/core/GameRoot3D.gd || { echo "ERROR: GameRoot3D missing _process"; exit 1; }
grep -q 'func _update_player' scripts/core/GameRoot3D.gd || { echo "ERROR: GameRoot3D missing _update_player"; exit 1; }

echo "Validation complete. Open this folder in Godot and press Play."
