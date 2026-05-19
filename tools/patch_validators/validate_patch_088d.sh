#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/systems/InventoryItemRules3D.gd scripts/ui/widgets/UISlotButton3D.gd scripts/ui/panels/InventoryPanel3D.gd scenes/ui/panels/InventoryPanel3D.tscn; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "display_stat_line" "$ROOT/scripts/systems/InventoryItemRules3D.gd" || { echo "Missing stat display formatter"; exit 1; }
grep -q "is_stat_allowed_on_slot" "$ROOT/scripts/systems/InventoryItemRules3D.gd" || { echo "Missing slot affix legality rules"; exit 1; }
grep -q "sanitize_inventory_state" "$ROOT/scripts/systems/InventoryItemRules3D.gd" || { echo "Missing inventory sanitizer"; exit 1; }
grep -q "_sort_backpack" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Missing inventory sort function"; exit 1; }
grep -q "_fit_name" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Missing item name fit function"; exit 1; }
grep -q 'node name="SortButton"' "$ROOT/scenes/ui/panels/InventoryPanel3D.tscn" || { echo "Inventory scene missing sort button"; exit 1; }
grep -q "clip_text = true" "$ROOT/scripts/ui/widgets/UISlotButton3D.gd" || { echo "Slot button missing clipping"; exit 1; }

echo "088D validation passed."
