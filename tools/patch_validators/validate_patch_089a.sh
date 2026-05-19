#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/ui/panels/SkillGemPanel3D.gd scenes/ui/panels/SkillGemPanel3D.tscn scripts/ui/UIPanelRoot3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "MAX_SUPPORT_SOCKETS" "$ROOT/scripts/ui/panels/SkillGemPanel3D.gd" || { echo "Skill panel missing max sockets"; exit 1; }
grep -q "_unlocked_sockets" "$ROOT/scripts/ui/panels/SkillGemPanel3D.gd" || { echo "Skill panel missing socket unlock logic"; exit 1; }
grep -q "spirit_gem_slots" "$ROOT/scripts/ui/panels/SkillGemPanel3D.gd" || { echo "Skill panel missing spirit slots model"; exit 1; }
grep -q "gem_stash" "$ROOT/scripts/ui/panels/SkillGemPanel3D.gd" || { echo "Skill panel missing gem stash model"; exit 1; }
grep -q "RemoveActiveDrop" "$ROOT/scenes/ui/panels/SkillGemPanel3D.tscn" || { echo "Skill scene missing active remove drop zone"; exit 1; }
grep -q "SupportSocketGrid" "$ROOT/scenes/ui/panels/SkillGemPanel3D.tscn" || { echo "Skill scene missing support sockets"; exit 1; }
grep -q "SpiritBox" "$ROOT/scenes/ui/panels/SkillGemPanel3D.tscn" || { echo "Skill scene missing spirit box"; exit 1; }
grep -q "_rf_089a_apply_shell_layout" "$ROOT/scripts/ui/UIPanelRoot3D.gd" || { echo "UIPanelRoot missing skill half-screen layout hook"; exit 1; }

if grep -R '@onready var .*%[A-Za-z]' "$ROOT/scripts/ui/panels/SkillGemPanel3D.gd" >/tmp/089a_bad_unique.txt 2>/dev/null; then
  cat /tmp/089a_bad_unique.txt
  echo "Found fragile %UniqueName binding in SkillGemPanel3D." >&2
  exit 1
fi

echo "089A validation passed."
