#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/ui/panels/InventoryPanel3D.gd scenes/ui/panels/InventoryPanel3D.tscn; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "_cell_size" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory script missing responsive cell sizing"; exit 1; }
grep -q "BACKPACK_MIN_SIZE" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory script missing backpack min size"; exit 1; }
grep -q "custom_minimum_size = Vector2(520, 340)" "$ROOT/scenes/ui/panels/InventoryPanel3D.tscn" || { echo "Inventory scene still has wrong BackpackArea minimum"; exit 1; }
grep -q "custom_minimum_size = Vector2(0, 168)" "$ROOT/scenes/ui/panels/InventoryPanel3D.tscn" || { echo "Inventory bottom panel not compacted"; exit 1; }

if grep -q "Vector2(794, 554)" "$ROOT/scenes/ui/panels/InventoryPanel3D.tscn" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd"; then
  echo "Old oversized backpack dimensions still present." >&2
  exit 1
fi

echo "088C validation passed."
