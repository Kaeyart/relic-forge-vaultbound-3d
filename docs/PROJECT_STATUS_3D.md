# Relic Forge: Vaultbound 3D — Project Status

## Status

This is the clean 3D reboot repo. It should stay separate from the 2D project until the 3D direction is proven.

## Current architecture

The new repo should own:

- `project.godot`
- `scenes/main/GameRoot3D.tscn`
- 3D hub/combat/player/enemy/projectile scenes
- lightweight runtime scripts
- clean docs/tools

The old 2D systems are imported as inert reference files under `_ported_from_2d_raw/`.

## Do not activate yet

Do not directly activate old 2D UI scripts, old passive tree scripts, or old CombatArena/GameRoot scripts. They are useful references but contain Node2D assumptions and patch-era UI ownership issues.

## Next production targets

1. Confirm 3D movement/combat loop runs.
2. Port core data definitions as pure data, not old runtime scripts.
3. Port save/game-state cleanly.
4. Port itemization and loot.
5. Port skill gems.
6. Port crafting.
7. Port passive tree only after UI architecture is stable.
8. Port classes/ascendancies.
9. Port stash/map device/loot filter.
