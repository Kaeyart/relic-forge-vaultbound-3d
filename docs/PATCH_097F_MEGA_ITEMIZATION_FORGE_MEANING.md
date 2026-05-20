# 097F — Mega Itemization + Forge Meaning Pass

## Purpose

The previous patches made the game drop loot and made maps reward the player. This patch makes those items matter.

The target feeling:

> A rare drop may be bad now, but it might become valuable through the forge.

## Itemization rules

### Rarity

Normal:
- base item only
- no random affixes
- high forge potential

Magic:
- 1–2 affixes
- moderate forge potential

Rare:
- 4–6 affixes
- lower forge potential
- higher immediate power

Unique:
- format supported
- not fully designed yet

## Slot rules

Weapons:
- damage
- spell/attack scaling
- cast/attack speed
- crit
- elemental/void damage
- conversion-style hooks

Armor:
- life
- armor
- mana
- resistances
- recovery
- boots-only movement speed

Jewelry:
- mana
- spirit
- rarity
- gem XP
- resistances
- utility
- damage specialization

Offhand:
- spell pressure
- mana
- block
- recovery
- defensive utility

Relic:
- spirit
- life
- gem/progression utility
- rarity hooks

## Forge actions

The forge now supports:

- `seal`: add a crafted affix
- `reforge`: reroll affix values
- `polish`: improve quality
- `upgrade`: upgrade rarity
- `remove`: remove weakest affix

Current UI still has Seal/Reforge/Polish buttons, but the system supports the extra actions for future UI expansion.

## Display cleanup

The item display now prefers:

- `Maximum Life`
- `Fire Resistance`
- `Spell Damage`
- `Critical Chance`
- `Block Chance`

It avoids raw keys such as:

- `max_health`
- `fire_resistance`
- `crit_chance`

Values are shown as clean integers or whole percentages.
