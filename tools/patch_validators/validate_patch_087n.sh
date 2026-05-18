#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

echo "== validate_patch_087n =="
test -f scripts/systems/SkillGemSystem3D.gd

grep -q "static func _safe_index" scripts/systems/SkillGemSystem3D.gd
grep -q "static func _normalized_slots" scripts/systems/SkillGemSystem3D.gd
grep -q "if slots.is_empty()" scripts/systems/SkillGemSystem3D.gd

if grep -q "clampi(int(state.get(\"selected_skill_slot\")), 0, slots.size() - 1)" scripts/systems/SkillGemSystem3D.gd; then
  echo "ERROR: unsafe selected_skill_slot clamp remains"
  exit 1
fi
if grep -q "wrapi(cursor + step, 0, keys.size())" scripts/systems/SkillGemSystem3D.gd && ! grep -q "if keys.is_empty" scripts/systems/SkillGemSystem3D.gd; then
  echo "ERROR: possible wrapi with empty support keys"
  exit 1
fi

echo "OK: SkillGemSystem3D empty slot/index hardening present"
