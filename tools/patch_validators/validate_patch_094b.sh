#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
INV="$ROOT/scripts/ui/panels/InventoryPanel3D.gd"

[ -f "$INV" ] || { echo "Missing scripts/ui/panels/InventoryPanel3D.gd"; exit 1; }

grep -q 'InventoryRoot094B' "$INV" || { echo "Inventory 094B root missing"; exit 1; }
grep -q 'BackpackGrid094B' "$INV" || { echo "Inventory 094B backpack grid missing"; exit 1; }
grep -q 'InventoryItemCard094B' "$INV" || { echo "Inventory 094B item card missing"; exit 1; }
grep -q 'func _primary_action' "$INV" || { echo "Inventory primary action missing"; exit 1; }
grep -q 'func _deposit_selected_item' "$INV" || { echo "Inventory deposit action missing"; exit 1; }
grep -q 'Stand near the physical Stash to deposit items' "$INV" || { echo "Inventory deposit station restriction missing"; exit 1; }
grep -q 'func _sort_inventory' "$INV" || { echo "Inventory sort missing"; exit 1; }
grep -q 'func _equip_selected_item' "$INV" || { echo "Inventory equip missing"; exit 1; }
grep -q 'GemCoreSystemScript.is_gem_item' "$INV" || { echo "Inventory gem item handling missing"; exit 1; }

echo "094B validation passed."
