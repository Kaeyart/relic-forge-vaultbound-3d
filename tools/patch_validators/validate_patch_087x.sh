#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scenes/ui/UIPanelRoot3D.tscn scenes/ui/panels/InventoryPanel3D.tscn scenes/ui/panels/ForgePanel3D.tscn scenes/ui/panels/SkillGemPanel3D.tscn scenes/ui/panels/MapDevicePanel3D.tscn scenes/ui/panels/CharacterPanel3D.tscn; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q 'layout_mode = 2' "$ROOT/scenes/ui/UIPanelRoot3D.tscn" || { echo "UIPanelRoot3D missing container layout modes"; exit 1; }
grep -q 'offset_left = 64.0' "$ROOT/scenes/ui/UIPanelRoot3D.tscn" || { echo "UIPanelRoot3D shell offsets missing"; exit 1; }
grep -q 'node name="Shell"' "$ROOT/scenes/ui/UIPanelRoot3D.tscn" || { echo "UIPanelRoot3D Shell missing"; exit 1; }
grep -q 'node name="Content"' "$ROOT/scenes/ui/UIPanelRoot3D.tscn" || { echo "UIPanelRoot3D Content missing"; exit 1; }

echo "087X validation passed."
