#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

FLAGS="$ROOT/scripts/systems/RuntimeFeatureFlags3D.gd"
FLOW="$ROOT/scripts/systems/GameFlowDirector3D.gd"
CHECK="$ROOT/scripts/systems/SliceChecklistSystem3D.gd"
MANAGER="$ROOT/scripts/core/RuntimeLayerManager3D.gd"
DOC="$ROOT/docs/MILESTONE_0_1_PLAYABLE_SLICE_CHECKLIST.md"

[ -f "$FLAGS" ] || { echo "Missing RuntimeFeatureFlags3D.gd"; exit 1; }
[ -f "$FLOW" ] || { echo "Missing GameFlowDirector3D.gd"; exit 1; }
[ -f "$CHECK" ] || { echo "Missing SliceChecklistSystem3D.gd"; exit 1; }
[ -f "$MANAGER" ] || { echo "Missing RuntimeLayerManager3D.gd"; exit 1; }
[ -f "$DOC" ] || { echo "Missing milestone checklist doc"; exit 1; }

grep -q 'class_name RVRuntimeFeatureFlags3D' "$FLAGS" || { echo "RuntimeFeatureFlags class_name missing"; exit 1; }
grep -q 'DEFAULT_FLAGS' "$FLAGS" || { echo "DEFAULT_FLAGS missing"; exit 1; }
grep -q 'hub_station_layer' "$FLAGS" || { echo "hub station flag missing"; exit 1; }
grep -q 'combat_feel_layer' "$FLAGS" || { echo "combat feel flag missing"; exit 1; }
grep -q 'game_flow_director' "$FLAGS" || { echo "game flow flag missing"; exit 1; }

grep -q 'class_name RVGameFlowDirector3D' "$FLOW" || { echo "GameFlowDirector class_name missing"; exit 1; }
grep -q 'KEY_F4' "$FLOW" || { echo "F4 hub shortcut missing"; exit 1; }
grep -q 'KEY_F5' "$FLOW" || { echo "F5 map shortcut missing"; exit 1; }
grep -q 'KEY_F6' "$FLOW" || { echo "F6 report shortcut missing"; exit 1; }
grep -q 'start_ash_vault_slice' "$FLOW" || { echo "Ash Vault slice start missing"; exit 1; }

grep -q 'class_name RVSliceChecklistSystem3D' "$CHECK" || { echo "SliceChecklist class_name missing"; exit 1; }
grep -q 'report_text' "$CHECK" || { echo "report_text missing"; exit 1; }

grep -q 'RuntimeFeatureFlagsScript' "$MANAGER" || { echo "RuntimeLayerManager missing feature flags"; exit 1; }
grep -q 'GameFlowDirector099A' "$MANAGER" || { echo "RuntimeLayerManager missing GameFlowDirector099A"; exit 1; }
grep -q 'disabled' "$MANAGER" || { echo "RuntimeLayerManager disabled report missing"; exit 1; }
grep -q 'feature flags' "$DOC" -i || { echo "Milestone doc missing feature flag guidance"; exit 1; }

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "099A validation passed."
