#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

COMBAT="$ROOT/scripts/visual/CombatArenaGreyboxPass3D.gd"
GAME="$ROOT/scripts/core/GameRoot3D.gd"

[ -f "$COMBAT" ] || { echo "Missing scripts/visual/CombatArenaGreyboxPass3D.gd"; exit 1; }
[ -f "$GAME" ] || { echo "Missing scripts/core/GameRoot3D.gd"; exit 1; }

grep -q 'class_name RVCombatArenaGreyboxPass3D' "$COMBAT" || { echo "CombatArenaGreyboxPass class_name missing"; exit 1; }
grep -q 'func _build_floor' "$COMBAT" || { echo "Combat floor builder missing"; exit 1; }
grep -q 'func _build_boundaries' "$COMBAT" || { echo "Combat boundary builder missing"; exit 1; }
grep -q 'func _build_lanes' "$COMBAT" || { echo "Combat lanes builder missing"; exit 1; }
grep -q 'func _build_blockers' "$COMBAT" || { echo "Combat blockers builder missing"; exit 1; }
grep -q 'func _build_spawn_and_exit' "$COMBAT" || { echo "Combat spawn/exit builder missing"; exit 1; }
grep -q 'func _build_reward_dais' "$COMBAT" || { echo "Combat reward dais builder missing"; exit 1; }
grep -q 'func _build_telegraph_samples' "$COMBAT" || { echo "Combat telegraph samples missing"; exit 1; }

grep -q 'CombatArenaGreyboxPassScript' "$GAME" || { echo "GameRoot missing CombatArenaGreyboxPass preload"; exit 1; }
grep -q '_rf_096c_ensure_combat_greybox' "$GAME" || { echo "GameRoot missing combat greybox ensure function"; exit 1; }
grep -q 'CombatArenaGreyboxPass096C' "$GAME" || { echo "GameRoot missing combat greybox node name"; exit 1; }

echo "096C validation passed."
