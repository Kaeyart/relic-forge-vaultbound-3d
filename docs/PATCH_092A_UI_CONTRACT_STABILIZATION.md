# 092A — UI Interaction Contract + Refresh Stabilization

This is a stabilization patch, not a content patch.

## Fixes

- Adds one shared panel access system.
- HUD buttons, UI tabs, and GameRoot key toggles now use the same panel access rule.
- Stash and Forge/Crafting are station-locked everywhere.
- Stash/Forge no longer open from HUD or generic key access unless the player is near the matching physical station.
- `UIPanelRoot3D.gd` now uses dirty signatures instead of rebuilding the active panel every frame.
- Fixes `gem_progression_seeded` save/load so starter gems do not keep reseeding.
- Fixes support gem string/dictionary mismatch inside `SkillGemSystem3D`.
- Active gem level/quality now affects cast damage.
- Gem drops are now physical inventory gem items.
- Map drops are now physical inventory map items, so they can route into the stash Map tab.

## Expected behavior

- Inventory, Skills, Character, and Maps can be opened normally.
- Stash opens only near the physical Stash.
- Forge opens only near the physical Forge.
- Clicking the HUD Forge button away from the Forge gives a notice instead of opening.
- UI panels should feel less jumpy because they no longer fully rebuild every frame.
- Support gems installed as dictionaries still count in combat.
