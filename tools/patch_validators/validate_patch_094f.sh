#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MAP="$ROOT/scripts/ui/panels/MapDevicePanel3D.gd"

[ -f "$MAP" ] || { echo "Missing scripts/ui/panels/MapDevicePanel3D.gd"; exit 1; }

grep -q 'MapDeviceRoot094F' "$MAP" || { echo "Map device 094F root missing"; exit 1; }
grep -q 'SelectedMapCard094F' "$MAP" || { echo "Selected map card missing"; exit 1; }
grep -q 'MapObjectiveCard094F' "$MAP" || { echo "Objective card missing"; exit 1; }
grep -q 'AtlasProgressCard094F' "$MAP" || { echo "Atlas card missing"; exit 1; }
grep -q 'func _open_selected_map' "$MAP" || { echo "Open selected map missing"; exit 1; }
grep -q 'func _consume_selected_map_item' "$MAP" || { echo "Map consumption missing"; exit 1; }
grep -q 'func _bonus_requirement_text' "$MAP" || { echo "Bonus requirement text missing"; exit 1; }
grep -q 'func _map_meets_bonus_requirement' "$MAP" || { echo "Bonus requirement checker missing"; exit 1; }
grep -q 'active_map_item' "$MAP" || { echo "active_map_item state write missing"; exit 1; }
grep -q '_start_map' "$MAP" || { echo "GameRoot map start call missing"; exit 1; }
grep -q 'UIFoundationSystemScript.item_card_text' "$MAP" || { echo "Shared item card not used"; exit 1; }

echo "094F validation passed."
