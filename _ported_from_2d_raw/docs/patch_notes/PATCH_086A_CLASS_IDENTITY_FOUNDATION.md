# Patch 086A — Class Identity Foundation

This patch adds the first proper class identity layer for **Relic Forge: Vaultbound**.

## Goals

- Make class choice visible and meaningful.
- Preserve the existing class/passive/ascendancy API so old UI routes keep working.
- Add four starter class lanes without implementing full ascendancies yet.
- Connect class identity to passive start nodes, class tags, class rules, starter skills, and baseline stat bonuses.

## Starter Classes

### Sorceress
Spell, fire, lightning, mana, spirit.

Starter skills: `Fireball`, `Storm Lance`.

### Warden
Melee, armor, bleed, life sustain.

Starter skills: `Cleave`, `Frost Nova`.

### Voidbinder
Void, curse, ailment pressure, mana/spirit risk reward.

Starter skills: `Void Rift`, `Fireball`.

### Machinist
Traps, projectiles, cooldowns, devices.

Starter skills: `Blade Trap`, `Storm Lance`.

## Files

- `scripts/data/ClassDB.gd`
- `scripts/data/PassiveAtlasDB.gd`
- `scripts/systems/ClassIdentitySystem.gd`
- `scripts/core/GameState.gd` patched with class identity state/default hooks

## Notes

This is **not** the ascendancy patch. Ascendancies should come after class identity is stable and tested.

Expected next step:

`086B — Class/Passive UI polish and starter build sanity`
