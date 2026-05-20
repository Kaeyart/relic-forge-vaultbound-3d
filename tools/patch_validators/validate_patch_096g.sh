#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

VIS="$ROOT/scripts/visual/CombatFeedbackLayer3D.gd"
GAME="$ROOT/scripts/core/GameRoot3D.gd"

[ -f "$VIS" ] || { echo "Missing scripts/visual/CombatFeedbackLayer3D.gd"; exit 1; }
[ -f "$GAME" ] || { echo "Missing scripts/core/GameRoot3D.gd"; exit 1; }

grep -q 'class_name RVCombatFeedbackLayer3D' "$VIS" || { echo "CombatFeedbackLayer class_name missing"; exit 1; }
grep -q 'func _scan_enemies' "$VIS" || { echo "enemy scanner missing"; exit 1; }
grep -q 'func _ensure_decorator' "$VIS" || { echo "decorator builder missing"; exit 1; }
grep -q 'func _spawn_damage_number' "$VIS" || { echo "damage number helper missing"; exit 1; }
grep -q 'func _spawn_death_burst' "$VIS" || { echo "death burst helper missing"; exit 1; }
grep -q 'HPBarFill' "$VIS" || { echo "health bar fill missing"; exit 1; }
grep -q 'HitFlash' "$VIS" || { echo "hit flash missing"; exit 1; }

grep -q 'CombatFeedbackLayerScript' "$GAME" || { echo "GameRoot missing CombatFeedbackLayer preload"; exit 1; }
grep -q '_rf_096g_ensure_combat_feedback_layer' "$GAME" || { echo "GameRoot missing combat feedback ensure function"; exit 1; }
grep -q 'CombatFeedbackLayer096G' "$GAME" || { echo "GameRoot missing combat feedback node name"; exit 1; }

echo "096G validation passed."
