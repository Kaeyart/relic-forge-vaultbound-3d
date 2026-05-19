#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/systems/StashSystem3D.gd scripts/ui/panels/StashPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "custom_rules_match" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "Missing custom affinity rule matcher"; exit 1; }
grep -q "map_bonus_requirement_text" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "Missing map bonus requirement text"; exit 1; }
grep -q "map_bonus_requirements_met" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "Missing map bonus requirement checker"; exit 1; }
grep -q "complete_map_item" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "Missing map completion function"; exit 1; }
grep -q "AFFINITY_CUSTOM_ITEMS" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "Missing custom item affinity"; exit 1; }
grep -q "_try_stack_item_into" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "Missing stack merge logic"; exit 1; }
grep -q "_sorted_items_for_affinity" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "Missing specialized sort logic"; exit 1; }

grep -q "CustomizeTabPopup" "$ROOT/scripts/ui/panels/StashPanel3D.gd" || { echo "Missing right-click customize popup"; exit 1; }
grep -q "_open_customize_for_tab" "$ROOT/scripts/ui/panels/StashPanel3D.gd" || { echo "Missing right-click customize handler"; exit 1; }
grep -q "popup_rarity_option" "$ROOT/scripts/ui/panels/StashPanel3D.gd" || { echo "Missing rarity rule UI"; exit 1; }
grep -q "popup_slot_option" "$ROOT/scripts/ui/panels/StashPanel3D.gd" || { echo "Missing slot rule UI"; exit 1; }

if grep -q "static func _get" "$ROOT/scripts/systems/StashSystem3D.gd"; then
  echo "Forbidden Object virtual helper name found: static func _get" >&2
  exit 1
fi

echo "090BCD validation passed."
