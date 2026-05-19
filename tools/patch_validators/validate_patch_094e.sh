#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FORGE="$ROOT/scripts/ui/panels/ForgePanel3D.gd"

[ -f "$FORGE" ] || { echo "Missing scripts/ui/panels/ForgePanel3D.gd"; exit 1; }

grep -q 'ForgeRoot094E' "$FORGE" || { echo "Forge 094E root missing"; exit 1; }
grep -q 'ForgeCurrentItemCard094E' "$FORGE" || { echo "Forge current item card missing"; exit 1; }
grep -q 'ForgePreviewCard094E' "$FORGE" || { echo "Forge preview card missing"; exit 1; }
grep -q 'func _apply_selected_craft' "$FORGE" || { echo "Apply craft missing"; exit 1; }
grep -q 'func _preview_item' "$FORGE" || { echo "Preview item missing"; exit 1; }
grep -q 'func _operation_cost' "$FORGE" || { echo "Operation cost missing"; exit 1; }
grep -q 'func _forge_potential' "$FORGE" || { echo "Forge potential missing"; exit 1; }
grep -q 'OP_REFINE' "$FORGE" || { echo "Refine operation missing"; exit 1; }
grep -q 'OP_ADD_AFFIX' "$FORGE" || { echo "Add affix operation missing"; exit 1; }
grep -q 'OP_UPGRADE_RARITY' "$FORGE" || { echo "Upgrade rarity operation missing"; exit 1; }
grep -q 'OP_ADD_QUALITY' "$FORGE" || { echo "Add quality operation missing"; exit 1; }
grep -q 'OP_RESTORE_POTENTIAL' "$FORGE" || { echo "Restore potential operation missing"; exit 1; }
grep -q 'UIFoundationSystemScript.item_card_text' "$FORGE" || { echo "Shared item card not used"; exit 1; }

echo "094E validation passed."
