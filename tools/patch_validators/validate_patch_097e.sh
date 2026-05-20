#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

MAPDIFF="$ROOT/scripts/systems/MapDifficultySystem3D.gd"
MAPDB="$ROOT/scripts/data/MapDB3D.gd"
MAPLOOP="$ROOT/scripts/systems/MapLoopSystem3D.gd"
COMBAT="$ROOT/scripts/combat/CombatArena3D.gd"
LOOT="$ROOT/scripts/systems/LootSystem3D.gd"
THREAT="$ROOT/scripts/systems/MapThreatSystem3D.gd"

[ -f "$MAPDIFF" ] || { echo "Missing MapDifficultySystem3D.gd"; exit 1; }
[ -f "$MAPDB" ] || { echo "Missing MapDB3D.gd"; exit 1; }
[ -f "$MAPLOOP" ] || { echo "Missing MapLoopSystem3D.gd"; exit 1; }
[ -f "$COMBAT" ] || { echo "Missing CombatArena3D.gd"; exit 1; }
[ -f "$LOOT" ] || { echo "Missing LootSystem3D.gd"; exit 1; }
[ -f "$THREAT" ] || { echo "Missing MapThreatSystem3D.gd"; exit 1; }

grep -q 'class_name RVMapDifficultySystem3D' "$MAPDIFF" || { echo "MapDifficulty class_name missing"; exit 1; }
grep -q 'static func normalize_map_item' "$MAPDIFF" || { echo "normalize_map_item missing"; exit 1; }
grep -q 'static func threat_profile' "$MAPDIFF" || { echo "threat_profile missing"; exit 1; }
grep -q 'static func apply_reward_modifiers' "$MAPDIFF" || { echo "apply_reward_modifiers missing"; exit 1; }
grep -q 'static func complete_current_map_state' "$MAPDIFF" || { echo "complete_current_map_state missing"; exit 1; }

grep -q 'MapDifficultySystemScript' "$MAPDB" || { echo "MapDB missing MapDifficulty preload"; exit 1; }
grep -q 'make_magic_map_item' "$MAPDB" || { echo "MapDB missing magic map generator"; exit 1; }
grep -q 'make_rare_map_item' "$MAPDB" || { echo "MapDB missing rare map generator"; exit 1; }

grep -q 'MapDifficultySystemScript' "$MAPLOOP" || { echo "MapLoop missing MapDifficulty preload"; exit 1; }
grep -q 'active_map_item' "$MAPLOOP" || { echo "MapLoop not setting active map item"; exit 1; }
grep -q 'bonus_completed_maps' "$MAPLOOP" || { echo "MapLoop not showing bonus completion"; exit 1; }

grep -q 'MapDifficultySystemScript' "$COMBAT" || { echo "CombatArena missing MapDifficulty preload"; exit 1; }
grep -q 'extra_pack_count' "$COMBAT" || { echo "CombatArena missing extra map packs"; exit 1; }

grep -q 'MapDifficultySystemScript' "$LOOT" || { echo "LootSystem missing MapDifficulty preload"; exit 1; }
grep -q 'apply_reward_modifiers' "$LOOT" || { echo "LootSystem not applying map reward modifiers"; exit 1; }

grep -q 'profile_for_state' "$THREAT" || { echo "MapThreat missing profile_for_state"; exit 1; }

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "097E validation passed."
