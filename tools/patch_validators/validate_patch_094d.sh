#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$ROOT/scripts/ui/panels/SkillGemPanel3D.gd"

[ -f "$SKILL" ] || { echo "Missing scripts/ui/panels/SkillGemPanel3D.gd"; exit 1; }

grep -q 'SkillGemRoot094D' "$SKILL" || { echo "SkillGem 094D root missing"; exit 1; }
grep -q 'SelectedActiveGemDetail094D' "$SKILL" || { echo "Selected active detail missing"; exit 1; }
grep -q 'SupportSocketGrid094D' "$SKILL" || { echo "Socket grid missing"; exit 1; }
grep -q 'func _install_selected_inventory_gem' "$SKILL" || { echo "Install gem action missing"; exit 1; }
grep -q 'func _socket_selected_support_to_spirit' "$SKILL" || { echo "Support-to-spirit action missing"; exit 1; }
grep -q 'func _remove_selected_support' "$SKILL" || { echo "Remove support action missing"; exit 1; }
grep -q 'func _toggle_selected_spirit' "$SKILL" || { echo "Toggle spirit action missing"; exit 1; }
grep -q 'GemCoreSystemScript.install_active_from_inventory' "$SKILL" || { echo "Active install not wired to GemCore"; exit 1; }
grep -q 'GemCoreSystemScript.install_support_from_inventory_to_active' "$SKILL" || { echo "Support active install not wired to GemCore"; exit 1; }
grep -q 'GemCoreSystemScript.install_spirit_from_inventory' "$SKILL" || { echo "Spirit install not wired to GemCore"; exit 1; }
grep -q 'GemCoreSystemScript.recompute_spirit_reservation' "$SKILL" || { echo "Spirit reservation not recomputed"; exit 1; }

echo "094D validation passed."
