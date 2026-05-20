#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

FILES=(
scripts/systems/MapThreatSystem3D.gd
scripts/systems/EnemySpawnContractSystem3D.gd
scripts/systems/EnemyModifierRuntimeSystem3D.gd
scripts/systems/LootDropContractSystem3D.gd
scripts/visual/CombatDirectorLayer3D.gd
)

for rel in "${FILES[@]}"; do
  [ -f "$ROOT/$rel" ] || { echo "Missing $rel"; exit 1; }
done

grep -q 'class_name RVMapThreatSystem3D' "$ROOT/scripts/systems/MapThreatSystem3D.gd" || { echo "MapThreat class missing"; exit 1; }
grep -q 'class_name RVEnemySpawnContractSystem3D' "$ROOT/scripts/systems/EnemySpawnContractSystem3D.gd" || { echo "EnemySpawnContract class missing"; exit 1; }
grep -q 'class_name RVEnemyModifierRuntimeSystem3D' "$ROOT/scripts/systems/EnemyModifierRuntimeSystem3D.gd" || { echo "EnemyModifierRuntime class missing"; exit 1; }
grep -q 'class_name RVLootDropContractSystem3D' "$ROOT/scripts/systems/LootDropContractSystem3D.gd" || { echo "LootDropContract class missing"; exit 1; }
grep -q 'class_name RVCombatDirectorLayer3D' "$ROOT/scripts/visual/CombatDirectorLayer3D.gd" || { echo "CombatDirector class missing"; exit 1; }

grep -q 'apply_to_existing_enemies' "$ROOT/scripts/systems/EnemySpawnContractSystem3D.gd" || { echo "enemy assignment function missing"; exit 1; }
grep -q 'magic_pack' "$ROOT/scripts/systems/EnemySpawnContractSystem3D.gd" || { echo "magic pack contract missing"; exit 1; }
grep -q 'rare_standalone' "$ROOT/scripts/systems/EnemySpawnContractSystem3D.gd" || { echo "rare standalone contract missing"; exit 1; }
grep -q 'regenerating' "$ROOT/scripts/systems/EnemyModifierRuntimeSystem3D.gd" || { echo "regeneration runtime missing"; exit 1; }
grep -q 'empowers_nearby' "$ROOT/scripts/systems/EnemyModifierRuntimeSystem3D.gd" || { echo "empower runtime missing"; exit 1; }
grep -q 'roll_drops_for_enemy' "$ROOT/scripts/systems/LootDropContractSystem3D.gd" || { echo "loot drop contract missing"; exit 1; }

GAME="$ROOT/scripts/core/GameRoot3D.gd"
grep -q 'CombatDirectorLayerScript' "$GAME" || { echo "GameRoot missing CombatDirector preload"; exit 1; }
grep -q '_rf_097a_ensure_combat_director_layer' "$GAME" || { echo "GameRoot missing CombatDirector ensure function"; exit 1; }
grep -q 'CombatDirectorLayer097A' "$GAME" || { echo "GameRoot missing CombatDirector node name"; exit 1; }

echo "097A validation passed."
