#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STASH="$ROOT/scripts/ui/panels/StashPanel3D.gd"

[ -f "$STASH" ] || { echo "Missing scripts/ui/panels/StashPanel3D.gd"; exit 1; }

grep -q 'StashRoot094C' "$STASH" || { echo "Stash 094C root missing"; exit 1; }
grep -q 'StashItemCard094C' "$STASH" || { echo "Stash 094C item card missing"; exit 1; }
grep -q 'StashCustomizePopup094C' "$STASH" || { echo "Stash customize popup missing"; exit 1; }
grep -q 'func _quick_deposit_all' "$STASH" || { echo "Quick deposit missing"; exit 1; }
grep -q 'func _withdraw_selected' "$STASH" || { echo "Withdraw missing"; exit 1; }
grep -q 'func _buy_item_tab' "$STASH" || { echo "Buy item tab missing"; exit 1; }
grep -q 'func _add_gem_sections' "$STASH" || { echo "Gem sections missing"; exit 1; }
grep -q 'Currency' "$STASH" || { echo "Currency specialized label missing"; exit 1; }
grep -q 'Maps by Tier' "$STASH" || { echo "Map specialized label missing"; exit 1; }
grep -q 'Unique Collection' "$STASH" || { echo "Unique specialized label missing"; exit 1; }
grep -q 'UIFoundationSystemScript.item_card_text' "$STASH" || { echo "Shared item card not used"; exit 1; }

echo "094C validation passed."
