#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

HUB="$ROOT/scripts/visual/HubGreyboxPass3D.gd"
GAME="$ROOT/scripts/core/GameRoot3D.gd"

[ -f "$HUB" ] || { echo "Missing scripts/visual/HubGreyboxPass3D.gd"; exit 1; }
[ -f "$GAME" ] || { echo "Missing scripts/core/GameRoot3D.gd"; exit 1; }

grep -q 'class_name RVHubGreyboxPass3D' "$HUB" || { echo "HubGreyboxPass class_name missing"; exit 1; }
grep -q 'func _build_stash_vault' "$HUB" || { echo "Stash vault builder missing"; exit 1; }
grep -q 'func _build_forge' "$HUB" || { echo "Forge builder missing"; exit 1; }
grep -q 'func _build_map_device' "$HUB" || { echo "Map device builder missing"; exit 1; }
grep -q 'func _build_gem_altar' "$HUB" || { echo "Gem altar builder missing"; exit 1; }
grep -q 'func _build_character_shrine' "$HUB" || { echo "Character shrine builder missing"; exit 1; }
grep -q 'func _build_descent_gate' "$HUB" || { echo "Descent gate builder missing"; exit 1; }
grep -q 'func _hide_basic_096a_stations' "$HUB" || { echo "096A station hider missing"; exit 1; }

grep -q 'HubGreyboxPassScript' "$GAME" || { echo "GameRoot missing HubGreyboxPass preload"; exit 1; }
grep -q '_rf_096b_ensure_hub_greybox' "$GAME" || { echo "GameRoot missing hub greybox ensure function"; exit 1; }
grep -q 'HubGreyboxPass096B' "$GAME" || { echo "GameRoot missing hub greybox node name"; exit 1; }

echo "096B validation passed."
