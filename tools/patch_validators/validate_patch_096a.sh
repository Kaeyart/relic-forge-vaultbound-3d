#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for file in scripts/visual/VisualPalette3D.gd scripts/visual/PrimitiveKit3D.gd scripts/visual/VisualFoundationLayer3D.gd scripts/visual/DropBeam3D.gd scripts/visual/CombatTelegraph3D.gd; do
  [ -f "$ROOT/$file" ] || { echo "Missing $file"; exit 1; }
done

GAME="$ROOT/scripts/core/GameRoot3D.gd"
[ -f "$GAME" ] || { echo "Missing scripts/core/GameRoot3D.gd"; exit 1; }

grep -q 'VisualFoundationLayerScript' "$GAME" || { echo "GameRoot missing VisualFoundationLayer preload"; exit 1; }
grep -q '_rf_096a_ensure_visual_foundation' "$GAME" || { echo "GameRoot missing visual foundation ensure function"; exit 1; }
grep -q 'VisualFoundationLayer096A' "$GAME" || { echo "GameRoot missing visual layer node name"; exit 1; }

grep -q 'func _build_hub_landmarks' "$ROOT/scripts/visual/VisualFoundationLayer3D.gd" || { echo "Visual layer missing hub landmarks"; exit 1; }
grep -q 'func _build_player_markers' "$ROOT/scripts/visual/VisualFoundationLayer3D.gd" || { echo "Visual layer missing player markers"; exit 1; }
grep -q 'func setup_circle' "$ROOT/scripts/visual/CombatTelegraph3D.gd" || { echo "CombatTelegraph missing setup_circle"; exit 1; }
grep -q 'func setup' "$ROOT/scripts/visual/DropBeam3D.gd" || { echo "DropBeam missing setup"; exit 1; }

echo "096A validation passed."
