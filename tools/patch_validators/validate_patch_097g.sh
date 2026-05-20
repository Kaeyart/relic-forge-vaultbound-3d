#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

UX="$ROOT/scripts/systems/UIUXSystem3D.gd"
SUMMARY="$ROOT/scripts/systems/UIStateSummarySystem3D.gd"
ROOTUI="$ROOT/scripts/ui/UIPanelRoot3D.gd"

[ -f "$UX" ] || { echo "Missing UIUXSystem3D.gd"; exit 1; }
[ -f "$SUMMARY" ] || { echo "Missing UIStateSummarySystem3D.gd"; exit 1; }
[ -f "$ROOTUI" ] || { echo "Missing UIPanelRoot3D.gd"; exit 1; }

grep -q 'class_name RVUIUXSystem3D' "$UX" || { echo "UIUX class_name missing"; exit 1; }
grep -q 'mode_for_keycode' "$UX" || { echo "key routing helper missing"; exit 1; }
grep -q 'next_mode' "$UX" || { echo "panel cycling helper missing"; exit 1; }
grep -q 'action_bar_text' "$UX" || { echo "action bar text helper missing"; exit 1; }
grep -q 'nav_strip_text' "$UX" || { echo "nav strip helper missing"; exit 1; }

grep -q 'class_name RVUIStateSummarySystem3D' "$SUMMARY" || { echo "summary class_name missing"; exit 1; }
grep -q 'inventory_summary' "$SUMMARY" || { echo "inventory summary missing"; exit 1; }
grep -q 'stash_summary' "$SUMMARY" || { echo "stash summary missing"; exit 1; }
grep -q 'forge_summary' "$SUMMARY" || { echo "forge summary missing"; exit 1; }
grep -q 'maps_summary' "$SUMMARY" || { echo "maps summary missing"; exit 1; }

grep -q 'UIUXSystemScript' "$ROOTUI" || { echo "UIPanelRoot missing UIUX preload"; exit 1; }
grep -q 'UXActionBar097G' "$ROOTUI" || { echo "UIPanelRoot missing action bar node"; exit 1; }
grep -q '_rf_097g_handle_key' "$ROOTUI" || { echo "UIPanelRoot missing shortcut handler"; exit 1; }
grep -q '_rf_097g_update_action_bar' "$ROOTUI" || { echo "UIPanelRoot missing action bar updater"; exit 1; }

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "097G validation passed."
