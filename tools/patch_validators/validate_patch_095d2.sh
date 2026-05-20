#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

TARGETS=(
scripts/systems/UIFoundationSystem3D.gd
scripts/systems/StashSystem3D.gd
scripts/systems/GemCoreSystem3D.gd
scripts/systems/SkillGemSystem3D.gd
scripts/systems/GemProgressionSystem3D.gd
scripts/ui/panels/InventoryPanel3D.gd
scripts/ui/panels/StashPanel3D.gd
scripts/ui/panels/SkillGemPanel3D.gd
scripts/ui/panels/ForgePanel3D.gd
scripts/ui/panels/MapDevicePanel3D.gd
scripts/ui/panels/CharacterPanel3D.gd
)

FOUND_HELPER=0

for rel in "${TARGETS[@]}"; do
  file="$ROOT/$rel"
  [ -f "$file" ] || continue

  if grep -q '_rf095d_as_array' "$file"; then
    FOUND_HELPER=1
  fi

  if grep -nE '(^|[^A-Za-z0-9_])Array\(' "$file"; then
    echo "Unsafe Array(...) constructor remains in $rel" >&2
    exit 1
  fi
done

if [ "$FOUND_HELPER" -ne 1 ]; then
  echo "Expected at least one _rf095d_as_array helper to be installed." >&2
  exit 1
fi

grep -q '_rf095d_as_array(item.get("affixes", \[\]))' "$ROOT/scripts/systems/UIFoundationSystem3D.gd" || {
  echo "UIFoundationSystem3D affixes cast was not repaired." >&2
  exit 1
}

echo "095D2 validation passed."
