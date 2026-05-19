# 095A — Character Panel / Stat Sheet Rebuild

## Goal

Make the Character panel useful.

The previous character UI was too close to a debug dump. This patch rebuilds it as a proper ARPG stat sheet.

## Layout

Left:
- Character summary
- Class / level
- HP / Mana / Spirit
- Gold
- Current mode
- Active skill summary

Center:
- Offense
- Defense
- Resources
- Resistances
- Utility

Right:
- Equipment overview
- Spirit gems
- Build notes / warnings

## Important UX rule

No raw keys like `max_health`, `fire_resistance`, or `crit_chance` should be shown directly.

The panel now converts stat keys into player-facing labels:

- `max_health` → Maximum Health
- `fire_resistance` → Fire Resistance
- `crit_chance` → Critical Chance
- etc.

## Scope

This patch is display-focused. It does not change character balance yet.

After this patch, the major system UIs have real rebuilds:
- Inventory
- Stash
- Skills
- Forge
- Map Device
- Character
