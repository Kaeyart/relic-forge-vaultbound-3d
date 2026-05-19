#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/systems/UIFoundationSystem3D.gd scripts/ui/components/UIFoundationItemCard3D.gd scripts/ui/components/UIFoundationActionBar3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q 'panel_actions' "$ROOT/scripts/systems/UIFoundationSystem3D.gd" || { echo "UIFoundation missing panel actions"; exit 1; }
grep -q 'item_card_text' "$ROOT/scripts/systems/UIFoundationSystem3D.gd" || { echo "UIFoundation missing item card formatter"; exit 1; }
grep -q 'compare_text' "$ROOT/scripts/systems/UIFoundationSystem3D.gd" || { echo "UIFoundation missing compare formatter"; exit 1; }

COUNT=0
for p in scripts/ui/panels/InventoryPanel3D.gd scripts/ui/panels/StashPanel3D.gd scripts/ui/panels/SkillGemPanel3D.gd scripts/ui/panels/ForgePanel3D.gd scripts/ui/panels/MapDevicePanel3D.gd scripts/ui/panels/CharacterPanel3D.gd; do
  if [ -f "$ROOT/$p" ] && grep -q '_rf_094a_ensure_panel_foundation' "$ROOT/$p"; then
    COUNT=$((COUNT+1))
  fi
done

if [ "$COUNT" -lt 2 ]; then
  echo "Expected at least two panels patched with UI foundation; found $COUNT" >&2
  exit 1
fi

if [ -f "$ROOT/scripts/ui/UIPanelRoot3D.gd" ]; then
  grep -q 'UIContractHint094A' "$ROOT/scripts/ui/UIPanelRoot3D.gd" || { echo "UIPanelRoot missing 094A contract hint"; exit 1; }
fi

echo "094A validation passed."
