#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

DETECT="$ROOT/scripts/systems/RuntimeDetectionSystem3D.gd"
SMOKE="$ROOT/scripts/systems/VerticalSliceSmokeTestSystem3D.gd"
OVERLAY="$ROOT/scripts/visual/VerticalSliceDebugOverlay3D.gd"
LOOT="$ROOT/scripts/visual/LootPresentationLayer3D.gd"
ENEMY="$ROOT/scripts/visual/EnemyReadabilityLayer3D.gd"
MANAGER="$ROOT/scripts/core/RuntimeLayerManager3D.gd"

[ -f "$DETECT" ] || { echo "Missing RuntimeDetectionSystem3D.gd"; exit 1; }
[ -f "$SMOKE" ] || { echo "Missing VerticalSliceSmokeTestSystem3D.gd"; exit 1; }
[ -f "$OVERLAY" ] || { echo "Missing VerticalSliceDebugOverlay3D.gd"; exit 1; }
[ -f "$LOOT" ] || { echo "Missing LootPresentationLayer3D.gd"; exit 1; }
[ -f "$ENEMY" ] || { echo "Missing EnemyReadabilityLayer3D.gd"; exit 1; }

grep -q 'class_name RVRuntimeDetectionSystem3D' "$DETECT" || { echo "RuntimeDetection class_name missing"; exit 1; }
grep -q 'static func mark_generated_visual' "$DETECT" || { echo "mark_generated_visual missing"; exit 1; }
grep -q 'static func is_real_enemy' "$DETECT" || { echo "is_real_enemy missing"; exit 1; }
grep -q 'static func is_real_loot' "$DETECT" || { echo "is_real_loot missing"; exit 1; }
grep -q 'static func collect_enemy_candidates' "$DETECT" || { echo "collect_enemy_candidates missing"; exit 1; }
grep -q 'static func collect_loot_candidates' "$DETECT" || { echo "collect_loot_candidates missing"; exit 1; }

grep -q 'class_name RVVerticalSliceSmokeTestSystem3D' "$SMOKE" || { echo "Smoke test class_name missing"; exit 1; }
grep -q 'class_name RVVerticalSliceDebugOverlay3D' "$OVERLAY" || { echo "Debug overlay class_name missing"; exit 1; }
grep -q 'KEY_F3' "$OVERLAY" || { echo "Debug overlay F3 toggle missing"; exit 1; }

grep -q 'RuntimeDetectionSystemScript.collect_loot_candidates' "$LOOT" || { echo "Loot layer not using central loot detection"; exit 1; }
grep -q 'RuntimeDetectionSystemScript.is_real_loot' "$LOOT" || { echo "Loot layer not using central loot predicate"; exit 1; }
grep -q 'mark_generated_visual(root, "loot_presentation")' "$LOOT" || { echo "Loot decorator is not marked generated"; exit 1; }

grep -q 'RuntimeDetectionSystemScript.collect_enemy_candidates' "$ENEMY" || { echo "Enemy readability not using central enemy detection"; exit 1; }
grep -q 'RuntimeDetectionSystemScript.is_real_enemy' "$ENEMY" || { echo "Enemy readability not using central enemy predicate"; exit 1; }

if [ -f "$MANAGER" ]; then
  grep -q 'VerticalSliceDebugOverlay098A' "$MANAGER" || { echo "RuntimeLayerManager missing debug overlay registration"; exit 1; }
fi

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "098A validation passed."
