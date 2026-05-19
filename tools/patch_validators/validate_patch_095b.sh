#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

UI="$ROOT/scripts/systems/UIFoundationSystem3D.gd"
STASH="$ROOT/scripts/systems/StashSystem3D.gd"
REPO_SCRIPT="$ROOT/tools/create_new_github_repo_095b.sh"

[ -f "$UI" ] || { echo "Missing scripts/systems/UIFoundationSystem3D.gd"; exit 1; }
[ -f "$STASH" ] || { echo "Missing scripts/systems/StashSystem3D.gd"; exit 1; }
[ -x "$REPO_SCRIPT" ] || { echo "Missing or non-executable repo script"; exit 1; }

grep -q 'static func rarity_color' "$UI" || { echo "UIFoundationSystem3D missing rarity_color"; exit 1; }

for fn in ensure_defaults find_tab tabs_in_category select_category select_tab tab_summary_line visible_items_for_current_view buy_tab create_category customize_tab quick_deposit_inventory withdraw_selected_stash_item deposit_selected_inventory_item; do
  grep -q "static func $fn" "$STASH" || { echo "StashSystem3D missing $fn"; exit 1; }
done

grep -q 'gh repo create' "$REPO_SCRIPT" || { echo "GitHub repo create command missing"; exit 1; }
grep -q 'Initial 3D ARPG foundation checkpoint' "$REPO_SCRIPT" || { echo "Checkpoint commit message missing"; exit 1; }

echo "095B validation passed."
