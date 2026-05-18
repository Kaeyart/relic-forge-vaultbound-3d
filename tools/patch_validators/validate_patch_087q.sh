#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for p in \
  scripts/ui/UIPanelRoot3D.gd \
  scripts/ui/panels/InventoryPanel3D.gd \
  scripts/ui/panels/CraftingPanel3D.gd \
  scripts/ui/panels/MapPanel3D.gd \
  scripts/ui/panels/SkillLoadoutPanel3D.gd \
  scripts/ui/panels/CharacterPanel3D.gd \
  scenes/ui/UIPanelRoot3D.tscn \
  scenes/ui/panels/InventoryPanel3D.tscn \
  scenes/ui/panels/CraftingPanel3D.tscn \
  scenes/ui/panels/MapPanel3D.tscn \
  scenes/ui/panels/SkillLoadoutPanel3D.tscn \
  scenes/ui/panels/CharacterPanel3D.tscn; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done
echo "087Q basic file validation passed."
