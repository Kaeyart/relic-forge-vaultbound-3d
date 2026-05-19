#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/ui/widgets/UISlotButton3D.gd scripts/ui/UIPanelRoot3D.gd scripts/ui/panels/InventoryPanel3D.gd scripts/ui/panels/ForgePanel3D.gd scripts/ui/panels/MapDevicePanel3D.gd scripts/ui/panels/SkillGemPanel3D.gd scripts/ui/panels/CharacterPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "func _unhandled_input" "$ROOT/scripts/ui/UIPanelRoot3D.gd" || { echo "UIPanelRoot3D missing Escape close handler"; exit 1; }
grep -q "_compare_text" "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "InventoryPanel3D missing comparison logic"; exit 1; }
grep -q "_refresh_action_buttons" "$ROOT/scripts/ui/panels/ForgePanel3D.gd" || { echo "ForgePanel3D missing action highlighting"; exit 1; }
grep -q "set_disabled_reason" "$ROOT/scripts/ui/widgets/UISlotButton3D.gd" || { echo "UISlotButton3D missing disabled reason support"; exit 1; }

if grep -R '@onready var .*%[A-Za-z]' "$ROOT/scripts/ui" >/tmp/087y_bad_unique.txt 2>/dev/null; then
  cat /tmp/087y_bad_unique.txt
  echo "Found fragile %UniqueName binding in UI scripts." >&2
  exit 1
fi

echo "087Y validation passed."
