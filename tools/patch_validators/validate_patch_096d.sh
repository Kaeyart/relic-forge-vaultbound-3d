#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

VFX="$ROOT/scripts/visual/SkillVFXLayer3D.gd"
GAME="$ROOT/scripts/core/GameRoot3D.gd"

[ -f "$VFX" ] || { echo "Missing scripts/visual/SkillVFXLayer3D.gd"; exit 1; }
[ -f "$GAME" ] || { echo "Missing scripts/core/GameRoot3D.gd"; exit 1; }

grep -q 'class_name RVSkillVFXLayer3D' "$VFX" || { echo "SkillVFXLayer class_name missing"; exit 1; }
grep -q 'func spawn_selected_skill_vfx' "$VFX" || { echo "spawn_selected_skill_vfx missing"; exit 1; }
grep -q 'func _spawn_fireball' "$VFX" || { echo "fireball VFX missing"; exit 1; }
grep -q 'func _spawn_storm_lance' "$VFX" || { echo "storm lance VFX missing"; exit 1; }
grep -q 'func _spawn_arc_slash' "$VFX" || { echo "arc slash VFX missing"; exit 1; }
grep -q 'func _spawn_void_rift' "$VFX" || { echo "void rift VFX missing"; exit 1; }
grep -q 'func _spawn_ember_mine' "$VFX" || { echo "ember mine VFX missing"; exit 1; }
grep -q 'func _selected_skill_id' "$VFX" || { echo "selected skill lookup missing"; exit 1; }

grep -q 'SkillVFXLayerScript' "$GAME" || { echo "GameRoot missing SkillVFXLayer preload"; exit 1; }
grep -q '_rf_096d_ensure_skill_vfx_layer' "$GAME" || { echo "GameRoot missing skill VFX ensure function"; exit 1; }
grep -q 'SkillVFXLayer096D' "$GAME" || { echo "GameRoot missing skill VFX node name"; exit 1; }

echo "096D validation passed."
