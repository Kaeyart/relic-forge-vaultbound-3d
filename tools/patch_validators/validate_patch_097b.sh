#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

MANAGER="$ROOT/scripts/core/RuntimeLayerManager3D.gd"
GAME="$ROOT/scripts/core/GameRoot3D.gd"
DEEP="$ROOT/tools/deep_validate_3d_project.py"
HEALTH="$ROOT/tools/health_report_097b.sh"
CLEAN="$ROOT/tools/cleanup_tracked_backups_097b.sh"

[ -f "$MANAGER" ] || { echo "Missing scripts/core/RuntimeLayerManager3D.gd"; exit 1; }
[ -f "$GAME" ] || { echo "Missing scripts/core/GameRoot3D.gd"; exit 1; }
[ -x "$DEEP" ] || { echo "Missing or non-executable tools/deep_validate_3d_project.py"; exit 1; }
[ -x "$HEALTH" ] || { echo "Missing or non-executable tools/health_report_097b.sh"; exit 1; }
[ -x "$CLEAN" ] || { echo "Missing or non-executable tools/cleanup_tracked_backups_097b.sh"; exit 1; }

grep -q 'class_name RVRuntimeLayerManager3D' "$MANAGER" || { echo "RuntimeLayerManager class_name missing"; exit 1; }
grep -q 'VisualFoundationLayer096A' "$MANAGER" || { echo "RuntimeLayerManager missing 096A layer"; exit 1; }
grep -q 'CombatDirectorLayer097A' "$MANAGER" || { echo "RuntimeLayerManager missing optional 097A layer"; exit 1; }
grep -q 'func health_report' "$MANAGER" || { echo "RuntimeLayerManager health_report missing"; exit 1; }

grep -q 'RuntimeLayerManagerScript' "$GAME" || { echo "GameRoot missing RuntimeLayerManager preload"; exit 1; }
grep -q '_rf_097b_ensure_runtime_layer_manager' "$GAME" || { echo "GameRoot missing RuntimeLayerManager ensure function"; exit 1; }
grep -q 'RuntimeLayerManager097B' "$GAME" || { echo "GameRoot missing RuntimeLayerManager node name"; exit 1; }

grep -q '\*.bak_\*' "$ROOT/.gitignore" || { echo ".gitignore missing *.bak_*"; exit 1; }
grep -q '\*.orig' "$ROOT/.gitignore" || { echo ".gitignore missing *.orig"; exit 1; }
grep -q '\*.tmp' "$ROOT/.gitignore" || { echo ".gitignore missing *.tmp"; exit 1; }

python3 "$DEEP" --root "$ROOT"

echo "097B validation passed."
