# Patch 087E — 3D Core Loop Implementation

This patch wires the clean 3D systems into a playable loop:

Hub → Map Device → 3D Combat Map → Kill Enemies → Loot → Return Hub → Run Again.

It intentionally does not port the old 2D UI/passive/tree systems. The 3D repo stays clean.

## Included

- `GameRoot3D.gd` runtime loop
- `GameState3D.gd` state/save model
- 3D hub with map device
- 3D combat map with walls/blockers
- Enemy spawning, boss, projectiles, area/line skills
- Gold/material/item/map drops
- Basic equipment and inventory text panel
- Simple HUD
- Save/load

## Controls

- WASD / arrows: move
- Left click / Space: cast selected skill
- 1–6: select skill
- Q/R: cycle skill
- Z/X: health/mana flasks
- E: interact / return after map clear
- T: start map from hub / return to hub from combat
- I: inventory
- C: character
- M: maps
- H: help
- [ and ]: inventory cursor
- U: equip selected backpack item
- F5: save
- F8: clear UI lock

## Design Notes

This is not the final ARPG. It is the clean 3D spine. Passive tree, atlas, complex crafting, skill mods UI, stash, and advanced itemization should be added only after this loop is stable.
