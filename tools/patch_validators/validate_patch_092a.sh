#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in \
scripts/systems/UIAccessSystem3D.gd \
scripts/ui/UIPanelRoot3D.gd \
scripts/ui/GameHUD3D.gd \
scripts/core/GameRoot3D.gd \
scripts/core/GameState3D.gd \
scripts/systems/SkillGemSystem3D.gd \
scripts/systems/GemProgressionSystem3D.gd \
scripts/systems/LootSystem3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "static func request_panel" "$ROOT/scripts/systems/UIAccessSystem3D.gd" || { echo "UIAccess missing request_panel"; exit 1; }
grep -q "STATION_LOCKED_MODES" "$ROOT/scripts/systems/UIAccessSystem3D.gd" || { echo "UIAccess missing station lock list"; exit 1; }

FIRST_NONEMPTY="$(grep -n -m 1 '[^[:space:]]' "$ROOT/scripts/ui/UIPanelRoot3D.gd" | cut -d: -f2-)"
if [[ "$FIRST_NONEMPTY" != extends* ]]; then
  echo "UIPanelRoot first non-empty line must be extends" >&2
  exit 1
fi

grep -q "func _signature_for_mode" "$ROOT/scripts/ui/UIPanelRoot3D.gd" || { echo "UIPanelRoot missing dirty signatures"; exit 1; }
grep -q "UIAccessSystemScript.toggle_panel" "$ROOT/scripts/ui/UIPanelRoot3D.gd" || { echo "UIPanelRoot not using UIAccess"; exit 1; }
grep -q "UIAccessSystemScript.toggle_panel" "$ROOT/scripts/ui/GameHUD3D.gd" || { echo "GameHUD does not use UIAccess"; exit 1; }
grep -q "UIAccessSystemScript.toggle_panel" "$ROOT/scripts/core/GameRoot3D.gd" || { echo "GameRoot toggle does not use UIAccess"; exit 1; }

grep -q "_rf_092a_support_id" "$ROOT/scripts/systems/SkillGemSystem3D.gd" || { echo "SkillGemSystem missing support id helper"; exit 1; }
grep -q "_rf_092a_supports_contain" "$ROOT/scripts/systems/SkillGemSystem3D.gd" || { echo "SkillGemSystem missing support contains helper"; exit 1; }
grep -q "active_level_092a" "$ROOT/scripts/systems/SkillGemSystem3D.gd" || { echo "SkillGemSystem missing active level damage scaling"; exit 1; }

grep -q "make_gem_item_from_drop" "$ROOT/scripts/systems/GemProgressionSystem3D.gd" || { echo "GemProgression missing physical gem factory"; exit 1; }
grep -q "GemProgressionSystemScript.make_gem_item_from_drop" "$ROOT/scripts/systems/LootSystem3D.gd" || { echo "LootSystem not creating physical gem items"; exit 1; }
grep -q 'map_item\["kind"\] = "map"' "$ROOT/scripts/systems/LootSystem3D.gd" || { echo "LootSystem not creating physical map items"; exit 1; }

grep -q 'gem_progression_seeded = bool(data.get("gem_progression_seeded"' "$ROOT/scripts/core/GameState3D.gd" || { echo "GameState does not restore gem seed flag"; exit 1; }
grep -q 'data\["gem_progression_seeded"\] = gem_progression_seeded' "$ROOT/scripts/core/GameState3D.gd" || { echo "GameState does not save gem seed flag"; exit 1; }

echo "092A validation passed."
