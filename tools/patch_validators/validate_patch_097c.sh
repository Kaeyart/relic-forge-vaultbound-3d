#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

REWARD="$ROOT/scripts/systems/RewardLoopSystem3D.gd"
COMBAT="$ROOT/scripts/combat/CombatArena3D.gd"
LOOT_ACTOR="$ROOT/scripts/loot/LootActor3D.gd"
LOOT_SYSTEM="$ROOT/scripts/systems/LootSystem3D.gd"

[ -f "$REWARD" ] || { echo "Missing scripts/systems/RewardLoopSystem3D.gd"; exit 1; }
[ -f "$COMBAT" ] || { echo "Missing scripts/combat/CombatArena3D.gd"; exit 1; }
[ -f "$LOOT_ACTOR" ] || { echo "Missing scripts/loot/LootActor3D.gd"; exit 1; }
[ -f "$LOOT_SYSTEM" ] || { echo "Missing scripts/systems/LootSystem3D.gd"; exit 1; }

grep -q 'class_name RVRewardLoopSystem3D' "$REWARD" || { echo "RewardLoop class_name missing"; exit 1; }
grep -q 'static func enemy_reward_bundle' "$REWARD" || { echo "enemy_reward_bundle missing"; exit 1; }
grep -q 'static func clear_reward_bundle' "$REWARD" || { echo "clear_reward_bundle missing"; exit 1; }
grep -q 'static func normalize_drop' "$REWARD" || { echo "normalize_drop missing"; exit 1; }
grep -q 'static func presentation_data_for_drop' "$REWARD" || { echo "presentation_data_for_drop missing"; exit 1; }
grep -q 'static func apply_drop_to_state' "$REWARD" || { echo "reward apply helper missing"; exit 1; }

grep -q 'RewardLoopSystemScript' "$COMBAT" || { echo "CombatArena missing RewardLoop preload"; exit 1; }
grep -q 'enemy_reward_bundle' "$COMBAT" || { echo "CombatArena enemy death not using reward loop"; exit 1; }
grep -q 'clear_reward_bundle' "$COMBAT" || { echo "CombatArena clear reward not using reward loop"; exit 1; }
grep -q '_spawn_reward_burst_visual' "$COMBAT" || { echo "CombatArena reward burst helper missing"; exit 1; }

grep -q 'RewardLoopSystemScript' "$LOOT_ACTOR" || { echo "LootActor missing RewardLoop preload"; exit 1; }
grep -q 'presentation_data_for_drop' "$LOOT_ACTOR" || { echo "LootActor missing presentation metadata"; exit 1; }
grep -q 'add_to_group("loot")' "$LOOT_ACTOR" || { echo "LootActor not added to loot group"; exit 1; }

grep -q 'apply_drop_to_state_097c_safe' "$LOOT_SYSTEM" || { echo "LootSystem safe wrapper missing"; exit 1; }
grep -q 'RewardLoopSystemScript.normalize_drop' "$LOOT_SYSTEM" || { echo "LootSystem does not normalize reward drops"; exit 1; }

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "097C validation passed."
