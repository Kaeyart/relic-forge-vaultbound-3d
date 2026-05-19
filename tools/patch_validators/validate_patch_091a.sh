#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/systems/StationAccessSystem3D.gd scripts/systems/GemProgressionSystem3D.gd scripts/core/GameRoot3D.gd scripts/core/GameState3D.gd scripts/ui/UIPanelRoot3D.gd scripts/systems/StashSystem3D.gd scripts/ui/panels/StashPanel3D.gd; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

grep -q "PhysicalStashStation091A" "$ROOT/scripts/systems/StationAccessSystem3D.gd" || { echo "Missing physical stash station"; exit 1; }
grep -q "PhysicalForgeStation091A" "$ROOT/scripts/systems/StationAccessSystem3D.gd" || { echo "Missing physical forge station"; exit 1; }
grep -q "request_station_panel" "$ROOT/scripts/systems/StationAccessSystem3D.gd" || { echo "Missing station panel lock request"; exit 1; }

grep -q "ensure_starter_gem_items" "$ROOT/scripts/systems/GemProgressionSystem3D.gd" || { echo "Missing starter gem seeding"; exit 1; }
grep -q "award_selected_skill_xp" "$ROOT/scripts/systems/GemProgressionSystem3D.gd" || { echo "Missing gem XP award"; exit 1; }
grep -q "roll_gem_drop_to_backpack" "$ROOT/scripts/systems/GemProgressionSystem3D.gd" || { echo "Missing gem drop helper"; exit 1; }

grep -q "StationAccessSystemScript" "$ROOT/scripts/core/GameRoot3D.gd" || { echo "GameRoot missing StationAccess preload"; exit 1; }
grep -q "GemProgressionSystemScript" "$ROOT/scripts/core/GameRoot3D.gd" || { echo "GameRoot missing GemProgression preload"; exit 1; }
grep -q "_rf_091a_setup_physical_station_refine" "$ROOT/scripts/core/GameRoot3D.gd" || { echo "GameRoot missing station setup hook"; exit 1; }

grep -q "_rf_091a_block_station_panel" "$ROOT/scripts/ui/UIPanelRoot3D.gd" || { echo "UIPanelRoot missing station tab lock"; exit 1; }
grep -q "quick_deposit_inventory" "$ROOT/scripts/systems/StashSystem3D.gd" || { echo "StashSystem missing quick deposit"; exit 1; }
grep -q "_rf_091a_quick_deposit" "$ROOT/scripts/ui/panels/StashPanel3D.gd" || { echo "StashPanel missing quick deposit UI"; exit 1; }

grep -q "near_station_mode" "$ROOT/scripts/core/GameState3D.gd" || { echo "GameState missing near_station_mode"; exit 1; }
grep -q "gem_progression_seeded" "$ROOT/scripts/core/GameState3D.gd" || { echo "GameState missing gem_progression_seeded"; exit 1; }

echo "091A validation passed."
