#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
for p in scripts/systems/GemCoreSystem3D.gd scripts/systems/GemProgressionSystem3D.gd scripts/systems/SkillGemSystem3D.gd scripts/ui/panels/InventoryPanel3D.gd scripts/core/GameState3D.gd; do [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }; done
GEM="$ROOT/scripts/systems/GemCoreSystem3D.gd"
grep -q 'const GEM_ACTIVE' "$GEM" || { echo "GemCore missing active type"; exit 1; }
grep -q 'const GEM_SUPPORT' "$GEM" || { echo "GemCore missing support type"; exit 1; }
grep -q 'const GEM_SPIRIT' "$GEM" || { echo "GemCore missing spirit type"; exit 1; }
grep -q 'unlocked_support_sockets' "$GEM" || { echo "GemCore missing socket unlocks"; exit 1; }
grep -q 'install_active_from_inventory' "$GEM" || { echo "GemCore missing active install"; exit 1; }
grep -q 'install_support_from_inventory_to_active' "$GEM" || { echo "GemCore missing active support install"; exit 1; }
grep -q 'install_support_from_inventory_to_spirit' "$GEM" || { echo "GemCore missing spirit support install"; exit 1; }
grep -q 'install_spirit_from_inventory' "$GEM" || { echo "GemCore missing spirit install"; exit 1; }
grep -q 'quality_effect_text' "$GEM" || { echo "GemCore missing quality effect text"; exit 1; }
grep -q 'active_quality_extra_projectiles' "$GEM" || { echo "GemCore missing projectile quality effect"; exit 1; }
grep -q 'GemCoreSystemScript' "$ROOT/scripts/systems/GemProgressionSystem3D.gd" || { echo "GemProgression not bridged"; exit 1; }
grep -q 'GemInstallChooser093A' "$ROOT/scripts/ui/panels/InventoryPanel3D.gd" || { echo "Inventory missing chooser"; exit 1; }
grep -q '_rf_093a_support_id' "$ROOT/scripts/systems/SkillGemSystem3D.gd" || { echo "SkillGemSystem missing support helper"; exit 1; }
grep -q 'spirit_gem_slots' "$ROOT/scripts/core/GameState3D.gd" || { echo "GameState missing spirit slots"; exit 1; }
if grep -q 'static func _get' "$GEM"; then echo "Forbidden _get helper" >&2; exit 1; fi
echo "093A validation passed."
