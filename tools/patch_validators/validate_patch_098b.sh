#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FEEL="$ROOT/scripts/systems/CombatFeelSystem3D.gd"
LAYER="$ROOT/scripts/visual/CombatFeelLayer3D.gd"
MANAGER="$ROOT/scripts/core/RuntimeLayerManager3D.gd"
[ -f "$FEEL" ] || { echo "Missing CombatFeelSystem3D.gd"; exit 1; }
[ -f "$LAYER" ] || { echo "Missing CombatFeelLayer3D.gd"; exit 1; }
[ -f "$MANAGER" ] || { echo "Missing RuntimeLayerManager3D.gd"; exit 1; }
grep -q 'class_name RVCombatFeelSystem3D' "$FEEL" || { echo "CombatFeelSystem class_name missing"; exit 1; }
grep -q 'static func enemy_hp' "$FEEL" || { echo "enemy_hp helper missing"; exit 1; }
grep -q 'static func threat_ring_radius' "$FEEL" || { echo "threat_ring_radius helper missing"; exit 1; }
grep -q 'class_name RVCombatFeelLayer3D' "$LAYER" || { echo "CombatFeelLayer class_name missing"; exit 1; }
grep -q 'RuntimeDetectionSystemScript.collect_enemy_candidates' "$LAYER" || { echo "CombatFeelLayer not using central enemy detection"; exit 1; }
grep -q 'mark_generated_visual' "$LAYER" || { echo "CombatFeelLayer not marking generated visuals"; exit 1; }
grep -q 'CombatFeelThreatRing098B' "$LAYER" || { echo "Threat ring missing"; exit 1; }
grep -q 'CombatFeelHitPulse098B' "$LAYER" || { echo "Hit pulse missing"; exit 1; }
grep -q 'CombatFeelPlayerFocusRing098B' "$LAYER" || { echo "Player focus ring missing"; exit 1; }
grep -q 'CombatFeelLayer098B' "$MANAGER" || { echo "RuntimeLayerManager missing CombatFeelLayer098B"; exit 1; }
if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi
echo "098B validation passed."
