# Relic Forge: Vaultbound 3D

This is a clean 3D repo bootstrap created separately from the existing 2D project.

The intent is to avoid contaminating the current repo while we test whether the game should become a top-down/isometric 3D ARPG.

## Current scope

- 3D hub
- 3D combat arena
- 3D player capsule
- 3D enemy capsules
- projectile, line, melee, and nova test skills
- simple HUD
- simple save file
- basic XP, gold, flasks, backpack test reward

## Not migrated yet

The old 2D repo is not copied by default. This is intentional.

Systems to migrate selectively later:

- itemization database
- crafting currency system
- stash system
- skill gem data
- passive tree data
- class identity data
- map item data
- UI panels, rebuilt cleanly instead of blindly copied

## Controls

- WASD / arrows: move
- Left click / Space: cast selected skill
- 1–6: select skill
- Q/R: cycle skill
- E: interact / exit cleared map
- T: start test map from hub / portal back from combat
- Z: health flask
- X: mana flask
- F5: save
