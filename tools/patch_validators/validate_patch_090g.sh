#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LEGACY="$ROOT/scripts/ui/SkillLoadoutPanel3D.gd"

if [ -f "$LEGACY" ]; then
  if grep -q '^class_name RVSkillLoadoutPanel3D$' "$LEGACY"; then
    echo "Duplicate legacy global class_name still present in scripts/ui/SkillLoadoutPanel3D.gd" >&2
    exit 1
  fi
fi

echo "090G validation passed."
