# Relic Forge: Vaultbound 3D — Clean Design Foundation

Patch 087D establishes the clean 3D design foundation. This is not a bulk migration of the old 2D project. The old project proved the ARPG loop, but many systems were patch-grown and should not be imported directly.

## Core Product Spine

The first playable 3D build exists to prove one loop:

```text
Hub → Map Device → Map Combat → Loot → Return to Hub → Equip/Craft → Next Map
```

Everything else is secondary until that loop is stable, readable, and fun.

## What We Keep From The 2D Prototype

The following concepts are retained:

- physical map items
- map device in the hub
- six-entry map portals
- returning to hub to deposit loot
- item drops with rarity and item level
- forge potential as item crafting stamina
- one health flask and one mana flask
- class identity as build direction
- eventual passive/atlas systems

## What We Do Not Copy Directly

The following 2D implementations should not be activated in the new repo:

- old passive tree UI
- old skill gem UI
- old inventory panel scripts
- old loot filter UI
- old CombatArena.gd
- old GameRoot.gd
- old generated/fallback UI layout code

Old code may be kept only as inert reference under `_ported_from_2d_raw/`.

## 3D Vertical Slice Target

The first serious slice needs:

```text
1 class
3–4 active skills
1 hub
1 map device
1 authored 3D map layout
3 enemy types
1 boss
basic loot
basic equipment
basic crafting
save/load
```

Recommended first class: **Sorceress**.

Recommended first skills:

- Fireball: projectile, fire, spell
- Storm Lance: piercing/line spell, lightning
- Rift Pulse: targeted area, void
- Arc Slash: short melee cone, physical/attack fallback

## System Order

1. Core 3D movement/combat/map loop
2. Items V2 with strict affix domains
3. Skills V2 with skill cores and skill mods
4. Crafting V2
5. Map items V2
6. Stash/loot filter
7. Character progression/passives
8. Atlas
9. Ascendancy
10. Art production pass

## Design Rules

### UI

Persistent UI layout belongs in `.tscn` scenes. Scripts bind data, connect signals, update labels, and instantiate reusable row components into scene-owned containers. Scripts must not generate whole panels or fallback scroll views.

### Items

Items must obey strict affix domains. A chest should not roll random projectile damage unless its base explicitly allows projectile affixes. Maps roll map modifiers. Weapons roll damage/casting/attack modifiers. Armor rolls defense/life/resistance.

### Skills

Do not rebuild the old gem system. V1 uses:

```text
Skill Core = active ability
Skill Mod = modifier attached to a skill
Skill Loadout = 4 active slots
```

This preserves modular ARPG buildcraft without reintroducing messy socket UI too early.

### Maps

Start with authored 3D map layouts. Procedural variation comes later. Each layout must include spawn point, enemy packs, elite pack, boss area, exit/portal point, blockers, and navigation.

## Minimum Viable Systems

This patch adds clean parse-safe foundations:

- `GameState3D.gd`
- `ItemDB3D.gd`
- `AffixDB3D.gd`
- `SkillDB3D.gd`
- `MapDB3D.gd`
- `CharacterClassSystem3D.gd`
- `LootSystem3D.gd`
- `CraftingSystem3D.gd`
- `MapLoopSystem3D.gd`
- `ProgressionSystem3D.gd`
- `SaveSystem3D.gd`

These are intended as the active clean systems for the new 3D repo.
