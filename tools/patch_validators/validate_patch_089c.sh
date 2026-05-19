#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BRIDGE="$ROOT/scripts/systems/GemInventoryBridge3D.gd"
INV="$ROOT/scripts/ui/panels/InventoryPanel3D.gd"

[ -f "$BRIDGE" ] || { echo "Missing scripts/systems/GemInventoryBridge3D.gd"; exit 1; }
[ -f "$INV" ] || { echo "Missing scripts/ui/panels/InventoryPanel3D.gd"; exit 1; }

grep -q "static func _state_get" "$BRIDGE" || { echo "GemInventoryBridge missing _state_get helper"; exit 1; }
if grep -q "static func _get" "$BRIDGE"; then
  echo "Forbidden helper name remains: static func _get" >&2
  exit 1
fi
if grep -q "Array(_get(state" "$BRIDGE"; then
  echo "Old _get(state...) calls remain." >&2
  exit 1
fi

grep -q "install_gem_from_backpack" "$BRIDGE" || { echo "GemInventoryBridge missing install_gem_from_backpack"; exit 1; }
grep -q "GemInventoryBridgeScript" "$INV" || { echo "InventoryPanel missing GemInventoryBridgeScript preload"; exit 1; }
grep -q "_rf_089b_try_install_selected_gem" "$INV" || { echo "InventoryPanel missing 089B install hook"; exit 1; }

echo "089C validation passed."
