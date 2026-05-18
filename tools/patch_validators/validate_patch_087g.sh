#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

echo "== validate_patch_087g =="
required=(
  "scenes/main/GameRoot3D.tscn"
  "scripts/core/GameRoot3D.gd"
  "scripts/core/GameState3D.gd"
  "scripts/data/GemDB3D.gd"
  "scripts/systems/SkillGemSystem3D.gd"
  "scripts/ui/SkillLoadoutPanel3D.gd"
  "scenes/ui/SkillLoadoutPanel3D.tscn"
)
for f in "${required[@]}"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: missing $f" >&2
    exit 1
  fi
  echo "OK: $f"
done

python3 - <<'PY'
from pathlib import Path
checks = {
    'scripts/data/GemDB3D.gd': ['active_gems', 'support_gems', 'spirit_gems', 'can_support'],
    'scripts/systems/SkillGemSystem3D.gd': ['set_active_for_slot', 'toggle_support_for_slot', 'toggle_spirit_gem', 'build_cast_data'],
    'scripts/core/GameRoot3D.gd': ['KEY_K', '_cast_selected_skill', 'SkillGemSystemScript.build_cast_data'],
    'scripts/core/GameState3D.gd': ['active_gem_inventory', 'support_gem_inventory', 'spirit_gem_inventory', 'skill_loadout'],
}
for file, needles in checks.items():
    text = Path(file).read_text()
    for n in needles:
        if n not in text:
            raise SystemExit(f'ERROR: {file} missing {n}')
print('OK: skill gem code signatures')
PY

if grep -R "func _get\|func _set" scripts/data/GemDB3D.gd scripts/systems/SkillGemSystem3D.gd scripts/core/GameState3D.gd >/tmp/087g_getset.txt; then
  echo "ERROR: forbidden _get/_set helper name found" >&2
  cat /tmp/087g_getset.txt >&2
  exit 1
fi

echo "validate_patch_087g complete"
