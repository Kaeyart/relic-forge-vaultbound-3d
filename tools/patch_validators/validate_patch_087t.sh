#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/ui/panels/InventoryPanel3D.gd scripts/ui/panels/ForgePanel3D.gd scripts/ui/panels/MapDevicePanel3D.gd scripts/ui/panels/CharacterPanel3D.gd scripts/ui/panels/SkillGemPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

if grep -R '@onready var .*%[A-Za-z]' "$ROOT/scripts/ui/panels" >/tmp/087t_bad_unique.txt 2>/dev/null; then
  cat /tmp/087t_bad_unique.txt
  echo "Found fragile %UniqueName binding in repaired panel scripts." >&2
  exit 1
fi

echo "087T validation passed."
