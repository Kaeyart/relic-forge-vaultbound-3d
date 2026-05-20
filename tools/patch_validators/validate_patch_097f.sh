#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

AFFIX="$ROOT/scripts/data/AffixDB3D.gd"
ITEM="$ROOT/scripts/data/ItemDB3D.gd"
CRAFT="$ROOT/scripts/systems/CraftingSystem3D.gd"
UI="$ROOT/scripts/systems/UIFoundationSystem3D.gd"

[ -f "$AFFIX" ] || { echo "Missing AffixDB3D.gd"; exit 1; }
[ -f "$ITEM" ] || { echo "Missing ItemDB3D.gd"; exit 1; }
[ -f "$CRAFT" ] || { echo "Missing CraftingSystem3D.gd"; exit 1; }
[ -f "$UI" ] || { echo "Missing UIFoundationSystem3D.gd"; exit 1; }

grep -q 'class_name RVAffixDB3D' "$AFFIX" || { echo "AffixDB class_name missing"; exit 1; }
grep -q 'roll_specific_count' "$AFFIX" || { echo "AffixDB roll_specific_count missing"; exit 1; }
grep -q 'crafted_affix_for_item' "$AFFIX" || { echo "crafted affix helper missing"; exit 1; }
grep -q 'offhand_block' "$AFFIX" || { echo "offhand block affix missing"; exit 1; }
grep -q 'conversion_fire_lightning' "$AFFIX" || { echo "conversion hook affix missing"; exit 1; }

grep -q 'class_name RVItemDB3D' "$ITEM" || { echo "ItemDB class_name missing"; exit 1; }
grep -q 'normalize_item' "$ITEM" || { echo "normalize_item missing"; exit 1; }
grep -q 'upgrade_rarity' "$ITEM" || { echo "upgrade_rarity missing"; exit 1; }
grep -q 'remove_weakest_affix' "$ITEM" || { echo "remove_weakest_affix missing"; exit 1; }
grep -q 'compare_items_text' "$ITEM" || { echo "compare_items_text missing"; exit 1; }
grep -q 'Maximum Life' "$ITEM" || { echo "clean stat labels missing"; exit 1; }

grep -q 'class_name RVCraftingSystem3D' "$CRAFT" || { echo "CraftingSystem class_name missing"; exit 1; }
grep -q 'preview_selected' "$CRAFT" || { echo "craft preview missing"; exit 1; }
grep -q 'upgrade' "$CRAFT" || { echo "upgrade action missing"; exit 1; }
grep -q 'remove' "$CRAFT" || { echo "remove action missing"; exit 1; }
grep -q 'Forge Potential' "$CRAFT" || { echo "forge potential language missing"; exit 1; }

grep -q 'ItemDBScript.item_detail_text' "$UI" || { echo "UIFoundation not using ItemDB detail text"; exit 1; }
grep -q 'ItemDBScript.compare_items_text' "$UI" || { echo "UIFoundation not using ItemDB compare text"; exit 1; }

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "097F validation passed."
