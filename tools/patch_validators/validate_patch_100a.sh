#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

SCHEMA="$ROOT/scripts/systems/FinalUISchema3D.gd"
ACTIONS="$ROOT/scripts/systems/FinalUIActions3D.gd"
UI="$ROOT/scripts/ui/FinalUIPanelRoot3D.gd"
MANAGER="$ROOT/scripts/core/RuntimeLayerManager3D.gd"
DOC="$ROOT/docs/PATCH_100A_FULL_UI_REDESIGN.md"

[ -f "$SCHEMA" ] || { echo "Missing FinalUISchema3D.gd"; exit 1; }
[ -f "$ACTIONS" ] || { echo "Missing FinalUIActions3D.gd"; exit 1; }
[ -f "$UI" ] || { echo "Missing FinalUIPanelRoot3D.gd"; exit 1; }
[ -f "$MANAGER" ] || { echo "Missing RuntimeLayerManager3D.gd"; exit 1; }
[ -f "$DOC" ] || { echo "Missing patch doc"; exit 1; }

grep -q 'class_name RVFinalUISchema3D' "$SCHEMA" || { echo "Schema class_name missing"; exit 1; }
grep -q 'active_skill_choices' "$SCHEMA" || { echo "active skill choices missing"; exit 1; }
grep -q 'support_choices' "$SCHEMA" || { echo "support choices missing"; exit 1; }
grep -q 'spirit_choices' "$SCHEMA" || { echo "spirit choices missing"; exit 1; }

grep -q 'class_name RVFinalUIActions3D' "$ACTIONS" || { echo "Actions class_name missing"; exit 1; }
grep -q 'cut_selected_uncut_gem' "$ACTIONS" || { echo "uncut gem cut action missing"; exit 1; }
grep -q 'toggle_selected_spirit' "$ACTIONS" || { echo "spirit toggle action missing"; exit 1; }
grep -q 'quick_deposit_all' "$ACTIONS" || { echo "stash deposit action missing"; exit 1; }
grep -q 'open_selected_map' "$ACTIONS" || { echo "open map action missing"; exit 1; }

grep -q 'class_name RVFinalUIPanelRoot3D' "$UI" || { echo "Final UI class_name missing"; exit 1; }
grep -q '_build_skills' "$UI" || { echo "Skill panel builder missing"; exit 1; }
grep -q '_build_inventory' "$UI" || { echo "Inventory panel builder missing"; exit 1; }
grep -q '_build_forge' "$UI" || { echo "Forge panel builder missing"; exit 1; }
grep -q '_build_stash' "$UI" || { echo "Stash panel builder missing"; exit 1; }
grep -q '_build_maps' "$UI" || { echo "Map panel builder missing"; exit 1; }
grep -q '_build_character' "$UI" || { echo "Character panel builder missing"; exit 1; }
grep -q '_build_rewards' "$UI" || { echo "Reward panel builder missing"; exit 1; }

grep -q 'FinalUIPanelRoot100A' "$MANAGER" || { echo "RuntimeLayerManager missing FinalUIPanelRoot100A"; exit 1; }

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "100A validation passed."
