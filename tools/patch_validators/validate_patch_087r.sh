#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for p in scripts/ui/GameHUD3D.gd scripts/ui/UIPanelRoot3D.gd scripts/ui/widgets/UISlotButton3D.gd scripts/ui/panels/InventoryPanel3D.gd scripts/ui/panels/ForgePanel3D.gd scripts/ui/panels/SkillGemPanel3D.gd scripts/ui/panels/MapDevicePanel3D.gd scripts/ui/panels/CharacterPanel3D.gd scenes/ui/GameHUD3D.tscn scenes/ui/UIPanelRoot3D.tscn scenes/ui/panels/InventoryPanel3D.tscn scenes/ui/panels/ForgePanel3D.tscn scenes/ui/panels/SkillGemPanel3D.tscn scenes/ui/panels/MapDevicePanel3D.tscn scenes/ui/panels/CharacterPanel3D.tscn; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done
grep -q "FinalGameHUDScene" "$ROOT/scripts/core/GameRoot3D.gd" || { echo "GameRoot3D missing HUD hook"; exit 1; }
grep -q "_rf_087r_update_final_ui" "$ROOT/scripts/core/GameRoot3D.gd" || { echo "GameRoot3D missing UI update hook"; exit 1; }
echo "087R validation passed."
