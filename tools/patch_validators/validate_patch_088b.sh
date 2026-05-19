#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/ui/widgets/UISlotButton3D.gd scripts/ui/panels/InventoryPanel3D.gd scenes/ui/panels/InventoryPanel3D.tscn; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "BackpackArea" "$ROOT/scenes/ui/panels/InventoryPanel3D.tscn" || { echo "Inventory scene missing BackpackArea"; exit 1; }
if grep -q "ScrollContainer" "$ROOT/scenes/ui/panels/InventoryPanel3D.tscn"; then
  echo "Inventory scene still contains ScrollContainer." >&2
  exit 1
fi
grep -q "_normalize_backpack_tetris_layout" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing tetris layout normalization"; exit 1; }
grep -q "_move_item_to_grid" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing grid move logic"; exit 1; }
grep -q "_rarity_color" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing rarity colors"; exit 1; }
grep -q "base_color" "$ROOT/scripts/ui/widgets/UISlotButton3D.gd" || { echo "Slot button missing base color support"; exit 1; }

echo "088B validation passed."
