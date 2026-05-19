#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for p in scripts/ui/SimpleHUD3D.gd scripts/ui/SkillLoadoutPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done
if grep -R 'ensure_loadout_defaults\|active_gem_for_slot\|gem_detail\|can_support\|build_cast_data\|set_active_for_slot\|toggle_support_for_slot\|toggle_spirit_gem\|item_detail_text\|skill_summary_text' "$ROOT/scripts/ui/SimpleHUD3D.gd" "$ROOT/scripts/ui/SkillLoadoutPanel3D.gd" >/tmp/087z_bad_legacy_api.txt 2>/dev/null; then
  cat /tmp/087z_bad_legacy_api.txt
  echo "Found old removed API call in legacy UI scripts." >&2
  exit 1
fi
grep -q "SkillGemSystemScript.ensure_defaults" "$ROOT/scripts/ui/SkillLoadoutPanel3D.gd" || { echo "SkillLoadoutPanel3D missing current ensure_defaults call"; exit 1; }
grep -q "SkillGemSystemScript.selected_cast_data" "$ROOT/scripts/ui/SimpleHUD3D.gd" || { echo "SimpleHUD3D missing current selected_cast_data call"; exit 1; }
echo "087Z validation passed."
