# 096E — Enemy Rarity + Modifier Pass

## Goal

This corrects the enemy plan.

Enemies should not all be special. Most enemies are fodder. The pressure comes from rarity tiers and modifiers.

## Enemy tiers

### Normal

Normal monsters are baseline enemies.

- Common.
- No special modifiers.
- Low visual noise.
- Low-to-normal XP.

### Magic

Magic monsters appear as enhanced pack enemies.

- One modifier.
- More XP.
- Blue visual treatment.
- More dangerous than normal, but still not rare-level.

### Rare

Rare monsters are standalone threats.

- 3 to 5 modifiers depending map tier.
- More XP.
- Gold/orange visual treatment.
- Can become harder than bosses if the modifier stack is nasty.

Modifier count:

- Tier 1–5: 3 rare modifiers.
- Tier 6–9: 4 rare modifiers.
- Tier 10–15: 5 rare modifiers.

## Modifier family

The included modifier pool is PoE-style, but project-owned:

- More Life
- More Damage
- Swift
- Armored
- Elemental Resistant
- Immune to Crits
- Cannot Be Slowed
- Empowers Nearby Monsters
- Regenerating
- Shielded
- Burning Aura
- Frost Aura
- Storm Aura
- Explodes on Death
- Projectile Resistant
- Summons Aid
- Frenzied

## Implementation

Adds:

- `scripts/systems/EnemyModifierSystem3D.gd`
- `scripts/visual/EnemyReadabilityLayer3D.gd`

Patches:

- `scripts/core/GameRoot3D.gd`

Runtime node:

- `EnemyReadabilityLayer096E`

## Safety

This is a compatibility layer.

It scans combat enemy nodes and uses metadata plus property-safe mutation. If an enemy exposes properties like `max_hp`, `hp`, `damage`, `move_speed`, or `xp_reward`, it adjusts them. If not, the modifier data still exists as metadata and the visual layer still works.
