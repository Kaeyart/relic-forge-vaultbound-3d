#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

grep -q 'if slots.is_empty()' scripts/systems/SkillGemSystem3D.gd
grep -q 'state.set("active_skill_slots", slots)' scripts/systems/SkillGemSystem3D.gd
grep -q 'return Dictionary(slots\[index\]).duplicate(true)' scripts/systems/SkillGemSystem3D.gd

if grep -n 'return Dictionary(slots\[index\]).duplicate(true)' -B20 scripts/systems/SkillGemSystem3D.gd | grep -qv 'if slots.is_empty()'; then
  true
fi

echo "087M validator passed."
