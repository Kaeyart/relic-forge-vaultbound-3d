#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/systems/StashSystem3D.gd scripts/ui/panels/StashPanel3D.gd scenes/ui/panels/StashPanel3D.tscn scripts/ui/UIPanelRoot3D.gd scenes/ui/UIPanelRoot3D.tscn scripts/ui/panels/InventoryPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "buy_tab" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "StashSystem missing buy_tab"; exit 1; }
grep -q "deposit_selected_inventory_item" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "StashSystem missing deposit"; exit 1; }
grep -q "withdraw_selected_stash_item" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "StashSystem missing withdraw"; exit 1; }
grep -q "AFFINITY_MAPS" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "StashSystem missing maps affinity"; exit 1; }
grep -q "stash_search_all" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "StashSystem missing global search"; exit 1; }
grep -q "TabStash" "$ROOT/scenes/ui/UIPanelRoot3D.tscn" || { echo "UIPanelRoot scene missing Stash tab"; exit 1; }
grep -q "StashPanel" "$ROOT/scenes/ui/UIPanelRoot3D.tscn" || { echo "UIPanelRoot scene missing StashPanel"; exit 1; }
grep -q "stash_panel" "$ROOT/scripts/ui/UIPanelRoot3D.gd" || { echo "UIPanelRoot script missing stash_panel"; exit 1; }
grep -q "StashSystemScript" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "InventoryPanel missing StashSystemScript"; exit 1; }
grep -q "StashSystemScript.deposit_selected_inventory_item" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory Deposit not wired"; exit 1; }

if grep -q "static func _get" "$ROOT/scripts/systems/StashSystem3D.gd"; then
  echo "Forbidden Object virtual helper name found: static func _get" >&2
  exit 1
fi

echo "090A validation passed."
