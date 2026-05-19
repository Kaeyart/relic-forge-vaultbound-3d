#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/systems/GemInventoryBridge3D.gd scripts/ui/panels/InventoryPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "install_gem_from_backpack" "$ROOT/scripts/systems/GemInventoryBridge3D.gd" || { echo "GemInventoryBridge missing install function"; exit 1; }
grep -q "gem_type" "$ROOT/scripts/systems/GemInventoryBridge3D.gd" || { echo "GemInventoryBridge missing gem type detection"; exit 1; }
grep -q "GemInventoryBridgeScript" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing GemInventoryBridge preload"; exit 1; }
grep -q "_rf_089b_try_install_selected_gem" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing gem install hook"; exit 1; }
grep -q "_rf_089b_gem_inventory_text" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing gem inventory text hook"; exit 1; }

echo "089B validation passed."
