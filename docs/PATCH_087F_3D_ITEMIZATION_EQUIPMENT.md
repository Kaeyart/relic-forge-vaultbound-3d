# Patch 087F — 3D Itemization + Equipment Foundation

This patch turns the clean 3D prototype loot into a more trustworthy ARPG item system.

## Goals

- Strict item schema.
- Slot/tag-aware affix pools.
- Proper prefix/suffix separation.
- Equipment stat application.
- Gear that visibly affects HP, mana, armor, speed, resistances, and skill damage.
- Better inventory text with selected item detail and compare text.
- Tuned enemy/elite/boss loot weighting.

## Important Design Rule

Items must not roll nonsense affixes.

Weapons roll offensive stats. Armor rolls defensive/survival stats. Boots may roll movement. Jewelry and relics roll hybrid utility/offense/defense. Maps will get their own modifier system later.

## Current Equipment Slots

- weapon
- offhand
- head
- chest
- gloves
- boots
- amulet
- ring1
- ring2
- relic

Ring bases use slot `ring` and auto-equip into `ring1`, then `ring2`, then replace `ring1`.

## New/Updated Files

- `scripts/data/AffixDB3D.gd`
- `scripts/data/ItemDB3D.gd`
- `scripts/data/SkillDB3D.gd`
- `scripts/core/GameState3D.gd`
- `scripts/systems/LootSystem3D.gd`
- `scripts/ui/GameHUD3D.gd`
- `tools/patch_validators/validate_patch_087f.sh`

## Test Checklist

1. Run a map.
2. Kill trash packs and elites.
3. Kill the boss.
4. Open inventory with `I`.
5. Use `[` and `]` to select items.
6. Verify selected item detail shows prefixes/suffixes/total stats.
7. Press `U` to equip selected gear.
8. Open character panel with `C`.
9. Verify HP/mana/armor/resists/build stats update.
10. Cast Fireball/Storm Lance/Arc Slash and verify stronger gear affects combat feel.
