#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

SKILL="$ROOT/scripts/systems/SkillGameplaySystem3D.gd"
COMBAT="$ROOT/scripts/combat/CombatArena3D.gd"

[ -f "$SKILL" ] || { echo "Missing scripts/systems/SkillGameplaySystem3D.gd"; exit 1; }
[ -f "$COMBAT" ] || { echo "Missing scripts/combat/CombatArena3D.gd"; exit 1; }

grep -q 'class_name RVSkillGameplaySystem3D' "$SKILL" || { echo "SkillGameplay class_name missing"; exit 1; }
grep -q 'static func enrich_cast_data' "$SKILL" || { echo "enrich_cast_data missing"; exit 1; }
grep -q 'static func resolve_hit_damage' "$SKILL" || { echo "resolve_hit_damage missing"; exit 1; }
grep -q 'static func apply_on_hit_status' "$SKILL" || { echo "apply_on_hit_status missing"; exit 1; }
grep -q 'static func update_enemy_statuses' "$SKILL" || { echo "status runtime missing"; exit 1; }
grep -q 'identity_for_active' "$SKILL" || { echo "identity helper missing"; exit 1; }

grep -q 'SkillGameplaySystemScript' "$COMBAT" || { echo "CombatArena missing SkillGameplay preload"; exit 1; }
grep -q '_cast_fireball' "$COMBAT" || { echo "Fireball gameplay path missing"; exit 1; }
grep -q '_cast_storm_lance' "$COMBAT" || { echo "Storm Lance gameplay path missing"; exit 1; }
grep -q '_cast_arc_slash' "$COMBAT" || { echo "Arc Slash gameplay path missing"; exit 1; }
grep -q '_cast_void_rift' "$COMBAT" || { echo "Void Rift gameplay path missing"; exit 1; }
grep -q '_cast_ember_mine' "$COMBAT" || { echo "Ember Mine gameplay path missing"; exit 1; }
grep -q 'skill_runtime_effects' "$COMBAT" || { echo "runtime effects storage missing"; exit 1; }
grep -q '_update_skill_runtime_effects' "$COMBAT" || { echo "runtime effect updater missing"; exit 1; }
grep -q 'resolve_hit_damage' "$COMBAT" || { echo "damage resolver not used"; exit 1; }

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "097D validation passed."
