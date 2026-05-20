#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

SYS="$ROOT/scripts/systems/EnemyModifierSystem3D.gd"
VIS="$ROOT/scripts/visual/EnemyReadabilityLayer3D.gd"
GAME="$ROOT/scripts/core/GameRoot3D.gd"

[ -f "$SYS" ] || { echo "Missing scripts/systems/EnemyModifierSystem3D.gd"; exit 1; }
[ -f "$VIS" ] || { echo "Missing scripts/visual/EnemyReadabilityLayer3D.gd"; exit 1; }
[ -f "$GAME" ] || { echo "Missing scripts/core/GameRoot3D.gd"; exit 1; }

grep -q 'class_name RVEnemyModifierSystem3D' "$SYS" || { echo "EnemyModifierSystem class_name missing"; exit 1; }
grep -q 'static func rarity_for_roll' "$SYS" || { echo "rarity_for_roll missing"; exit 1; }
grep -q 'static func modifier_count_for_rarity' "$SYS" || { echo "modifier_count_for_rarity missing"; exit 1; }
grep -q 'static func pick_modifier_ids' "$SYS" || { echo "pick_modifier_ids missing"; exit 1; }
grep -q 'static func apply_roll_to_enemy' "$SYS" || { echo "apply_roll_to_enemy missing"; exit 1; }
grep -q 'crit_immune' "$SYS" || { echo "crit immune modifier missing"; exit 1; }
grep -q 'slow_immune' "$SYS" || { echo "slow immune modifier missing"; exit 1; }
grep -q 'empowers_nearby' "$SYS" || { echo "empowers nearby modifier missing"; exit 1; }
grep -q 'explodes_on_death' "$SYS" || { echo "explodes on death modifier missing"; exit 1; }

grep -q 'class_name RVEnemyReadabilityLayer3D' "$VIS" || { echo "EnemyReadabilityLayer class_name missing"; exit 1; }
grep -q 'func _scan_enemies' "$VIS" || { echo "enemy scanner missing"; exit 1; }
grep -q 'func _decorate_enemy' "$VIS" || { echo "enemy decoration missing"; exit 1; }
grep -q 'func _add_modifier_badges' "$VIS" || { echo "modifier badges missing"; exit 1; }

grep -q 'EnemyReadabilityLayerScript' "$GAME" || { echo "GameRoot missing EnemyReadabilityLayer preload"; exit 1; }
grep -q '_rf_096e_ensure_enemy_readability_layer' "$GAME" || { echo "GameRoot missing enemy readability ensure function"; exit 1; }
grep -q 'EnemyReadabilityLayer096E' "$GAME" || { echo "GameRoot missing enemy readability node name"; exit 1; }

echo "096E validation passed."
