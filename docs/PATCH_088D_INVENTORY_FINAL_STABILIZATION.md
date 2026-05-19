# 088D — Inventory Final Stabilization

## Goal

Close the inventory pass and stabilize presentation/data quality before moving to itemization proper.

## Adds

- Player-facing stat display names:
  - `max_health` / `max_hp` → `+X Health`
  - `fire_resistance` → `+X% Fire Resistance`
  - `crit_chance` → `+X% Critical Strike Chance`
  - etc.

- No decimal stat display. Values are rounded to whole numbers.

- Rarity colors:
  - normal white
  - magic blue
  - rare yellow
  - unique orange

- Item names are truncated based on item block size so they do not overflow.

- Sort button:
  - sorts by slot category, rarity, item level, name
  - re-packs backpack into the tetris grid

- Affix legality cleanup:
  - normal/magic/rare items are sanitized by slot
  - uniques are allowed to break rules later
  - weapons do not keep block chance
  - armor does not keep weapon-only damage rolls
  - jewelry/relics allow broader utility/build stats

## Scope boundary

This patch does not create the final item generation system. It prevents current/future non-unique items from displaying illegal stat soup inside the inventory and gives the next itemization pass a clean rule layer to build on.
