#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

SYSTEM="$ROOT/scripts/systems/HubStationSystem3D.gd"
LAYER="$ROOT/scripts/visual/HubStationLayer3D.gd"
MANAGER="$ROOT/scripts/core/RuntimeLayerManager3D.gd"

[ -f "$SYSTEM" ] || { echo "Missing HubStationSystem3D.gd"; exit 1; }
[ -f "$LAYER" ] || { echo "Missing HubStationLayer3D.gd"; exit 1; }
[ -f "$MANAGER" ] || { echo "Missing RuntimeLayerManager3D.gd"; exit 1; }

grep -q 'class_name RVHubStationSystem3D' "$SYSTEM" || { echo "HubStationSystem class_name missing"; exit 1; }
grep -q 'station_specs' "$SYSTEM" || { echo "station_specs missing"; exit 1; }
grep -q 'map_device' "$SYSTEM" || { echo "map station missing"; exit 1; }
grep -q 'stash' "$SYSTEM" || { echo "stash station missing"; exit 1; }
grep -q 'forge' "$SYSTEM" || { echo "forge station missing"; exit 1; }
grep -q 'skill_altar' "$SYSTEM" || { echo "skill station missing"; exit 1; }

grep -q 'class_name RVHubStationLayer3D' "$LAYER" || { echo "HubStationLayer class_name missing"; exit 1; }
grep -q 'KEY_E' "$LAYER" || { echo "E interaction missing"; exit 1; }
grep -q 'HubStations098C' "$LAYER" || { echo "station root missing"; exit 1; }
grep -q 'HubStationPromptLayer098C' "$LAYER" || { echo "prompt layer missing"; exit 1; }
grep -q 'mark_generated_visual' "$LAYER" || { echo "generated visual marking missing"; exit 1; }
grep -q '_open_station' "$LAYER" || { echo "station open function missing"; exit 1; }

grep -q 'HubStationLayer098C' "$MANAGER" || { echo "RuntimeLayerManager missing HubStationLayer098C"; exit 1; }

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "098C validation passed."
