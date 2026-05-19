#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/ui/widgets/UISlotButton3D.gd scripts/ui/panels/InventoryPanel3D.gd scenes/ui/panels/InventoryPanel3D.tscn; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "LEFT_EQUIPMENT_SLOTS" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing left equipment slots"; exit 1; }
grep -q "RIGHT_EQUIPMENT_SLOTS" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing right equipment slots"; exit 1; }
grep -q "_compare_text" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing compare text"; exit 1; }
grep -q "_salvage_selected_item" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing salvage action"; exit 1; }
grep -q 'node name="CloseButton"' "$ROOT/scenes/ui/panels/InventoryPanel3D.tscn" || { echo "Inventory scene missing close button"; exit 1; }
grep -q 'columns = 10' "$ROOT/scenes/ui/panels/InventoryPanel3D.tscn" || { echo "Inventory scene missing 10-column grid"; exit 1; }

if grep -R '@onready var .*%[A-Za-z]' "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" >/tmp/088a_bad_unique.txt 2>/dev/null; then
  cat /tmp/088a_bad_unique.txt
  echo "Found fragile %UniqueName binding in InventoryPanel3D." >&2
  exit 1
fi

echo "088A validation passed."
