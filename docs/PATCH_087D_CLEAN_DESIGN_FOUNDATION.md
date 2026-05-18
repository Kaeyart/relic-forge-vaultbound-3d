# Patch 087D — Clean 3D Design Foundation

This patch creates clean, parse-safe 3D-era systems for the new repo. It intentionally avoids activating the old 2D systems.

## Added

- docs/RELIC_FORGE_3D_CLEAN_DESIGN_FOUNDATION.md
- docs/PORTING_RULES_2D_TO_3D.md
- scripts/core/GameState3D.gd
- scripts/data/ItemDB3D.gd
- scripts/data/AffixDB3D.gd
- scripts/data/SkillDB3D.gd
- scripts/data/MapDB3D.gd
- scripts/systems/CharacterClassSystem3D.gd
- scripts/systems/LootSystem3D.gd
- scripts/systems/CraftingSystem3D.gd
- scripts/systems/MapLoopSystem3D.gd
- scripts/systems/ProgressionSystem3D.gd
- scripts/systems/SaveSystem3D.gd
- tools/patch_validators/validate_patch_087d.sh

## Intent

The new 3D project should become a clean ARPG foundation, not a contaminated clone of the 2D project.

## Next Patch

087E — 3D Core Loop Implementation

Goal:

- wire GameState3D into the runtime
- hub → map → combat → loot → return hub
- use clean item/skill/loot data from this patch
