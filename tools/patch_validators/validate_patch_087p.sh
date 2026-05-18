#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for p in \
  scripts/ui/UIPanelRoot3D.gd \
  scripts/ui/panels/InventoryPanel3D.gd \
  scripts/ui/panels/CraftingPanel3D.gd \
  scripts/ui/panels/MapPanel3D.gd \
  scripts/ui/panels/SkillLoadoutPanel3D.gd \
  scripts/ui/panels/CharacterPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done
if grep -R 'state_ref\.get("[^"]*", ' "$ROOT/scripts/ui" >/tmp/087p_bad_get.txt 2>/dev/null; then
  cat /tmp/087p_bad_get.txt
  echo "Found Object.get(key, fallback) usage in UI scripts." >&2
  exit 1
fi
echo "087P validation passed."
