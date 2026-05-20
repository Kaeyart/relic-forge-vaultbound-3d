# 096F — Loot Presentation Pass

## Goal

Loot needs to read like ARPG loot even before final item art exists.

This patch adds a visual-only loot presentation layer.

## Adds

- `scripts/systems/LootPresentationSystem3D.gd`
- `scripts/visual/LootPresentationLayer3D.gd`

## Patches

- `scripts/core/GameRoot3D.gd`

Runtime node:

`LootPresentationLayer096F`

## Visual additions

- Rarity-colored ground ring.
- Rarity-colored vertical beam.
- Floating item name label.
- Item-kind marker:
  - Gear
  - Currency
  - Gem
  - Map
  - Crystal
  - Unique
- Reward burst helper for later use.

## Safety

This is a compatibility layer.

It scans world `Node3D` objects that look like loot/drop/item nodes by group, metadata, or name. It does not change item logic. It only adds a child decorator named:

`LootPresentationDecorator096F`
