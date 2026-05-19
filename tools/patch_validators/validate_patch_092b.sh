#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for p in \
scripts/systems/UIItemFormatSystem3D.gd \
scripts/ui/UIPanelRoot3D.gd \
scripts/ui/panels/StashPanel3D.gd \
scripts/ui/panels/InventoryPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done
grep -q "item_detail_text" "$ROOT/scripts/systems/UIItemFormatSystem3D.gd" || { echo "UIItemFormat missing item detail formatter"; exit 1; }
grep -q "action_hint_for_panel" "$ROOT/scripts/systems/UIItemFormatSystem3D.gd" || { echo "UIItemFormat missing panel hints"; exit 1; }
grep -q "UXHintBar092B" "$ROOT/scripts/ui/UIPanelRoot3D.gd" || { echo "UIPanelRoot missing hint bar"; exit 1; }
grep -q "SelectedItemDetail092B" "$ROOT/scripts/ui/panels/StashPanel3D.gd" || { echo "StashPanel missing selected detail panel"; exit 1; }
grep -q "Stand near the physical Stash to deposit items" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory deposit does not require physical stash"; exit 1; }
grep -q "InventoryHelp092B" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing friendly help strip"; exit 1; }
echo "092B validation passed."
