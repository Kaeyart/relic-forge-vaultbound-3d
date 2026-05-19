#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for p in \
scripts/systems/SkillGemUXSystem3D.gd \
scripts/systems/ForgeUXSystem3D.gd \
scripts/systems/UIItemFormatSystem3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "selected_skill_detail" "$ROOT/scripts/systems/SkillGemUXSystem3D.gd" || { echo "SkillGemUX missing selected detail"; exit 1; }
grep -q "support_id" "$ROOT/scripts/systems/SkillGemUXSystem3D.gd" || { echo "SkillGemUX missing support id helper"; exit 1; }
grep -q "spirit_overview" "$ROOT/scripts/systems/SkillGemUXSystem3D.gd" || { echo "SkillGemUX missing spirit overview"; exit 1; }
grep -q "forge_detail_text" "$ROOT/scripts/systems/ForgeUXSystem3D.gd" || { echo "ForgeUX missing detail text"; exit 1; }
grep -q "selected_item" "$ROOT/scripts/systems/ForgeUXSystem3D.gd" || { echo "ForgeUX missing selected item resolver"; exit 1; }

if [ -f "$ROOT/scripts/ui/panels/SkillGemPanel3D.gd" ]; then
  grep -q "SkillGemUXSystemScript" "$ROOT/scripts/ui/panels/SkillGemPanel3D.gd" || { echo "SkillGemPanel missing SkillGemUX preload"; exit 1; }
  grep -q "SkillGemDetail092C" "$ROOT/scripts/ui/panels/SkillGemPanel3D.gd" || { echo "SkillGemPanel missing detail UI"; exit 1; }
fi
if [ -f "$ROOT/scripts/ui/panels/ForgePanel3D.gd" ]; then
  grep -q "ForgeUXSystemScript" "$ROOT/scripts/ui/panels/ForgePanel3D.gd" || { echo "ForgePanel missing ForgeUX preload"; exit 1; }
  grep -q "ForgeDetail092C" "$ROOT/scripts/ui/panels/ForgePanel3D.gd" || { echo "ForgePanel missing detail UI"; exit 1; }
fi

echo "092C validation passed."
