#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

SYS="$ROOT/scripts/systems/LootPresentationSystem3D.gd"
VIS="$ROOT/scripts/visual/LootPresentationLayer3D.gd"
GAME="$ROOT/scripts/core/GameRoot3D.gd"

[ -f "$SYS" ] || { echo "Missing scripts/systems/LootPresentationSystem3D.gd"; exit 1; }
[ -f "$VIS" ] || { echo "Missing scripts/visual/LootPresentationLayer3D.gd"; exit 1; }
[ -f "$GAME" ] || { echo "Missing scripts/core/GameRoot3D.gd"; exit 1; }

grep -q 'class_name RVLootPresentationSystem3D' "$SYS" || { echo "LootPresentationSystem class_name missing"; exit 1; }
grep -q 'static func item_name_from_source' "$SYS" || { echo "item name helper missing"; exit 1; }
grep -q 'static func rarity_from_source' "$SYS" || { echo "rarity helper missing"; exit 1; }
grep -q 'static func kind_from_source' "$SYS" || { echo "kind helper missing"; exit 1; }
grep -q 'static func pickup_text' "$SYS" || { echo "pickup text helper missing"; exit 1; }

grep -q 'class_name RVLootPresentationLayer3D' "$VIS" || { echo "LootPresentationLayer class_name missing"; exit 1; }
grep -q 'func spawn_loot_beam_at' "$VIS" || { echo "spawn_loot_beam_at missing"; exit 1; }
grep -q 'func spawn_reward_burst' "$VIS" || { echo "spawn_reward_burst missing"; exit 1; }
grep -q 'func _scan_loot_nodes' "$VIS" || { echo "loot scanner missing"; exit 1; }
grep -q 'func _decorate_loot' "$VIS" || { echo "loot decorator missing"; exit 1; }
grep -q 'LootPresentationDecorator096F' "$VIS" || { echo "loot decorator node name missing"; exit 1; }

grep -q 'LootPresentationLayerScript' "$GAME" || { echo "GameRoot missing LootPresentationLayer preload"; exit 1; }
grep -q '_rf_096f_ensure_loot_presentation_layer' "$GAME" || { echo "GameRoot missing loot presentation ensure function"; exit 1; }
grep -q 'LootPresentationLayer096F' "$GAME" || { echo "GameRoot missing loot presentation node name"; exit 1; }

echo "096F validation passed."
