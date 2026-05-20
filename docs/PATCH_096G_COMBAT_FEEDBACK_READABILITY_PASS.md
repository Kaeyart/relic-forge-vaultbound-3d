# 096G — Combat Feedback Readability Pass

## Goal

After arena visuals, skill VFX, enemy rarity visuals, and loot beams, the missing piece is combat feedback.

The player needs to clearly see what got hit, how much health enemies have left, when a hit landed, and when an enemy dies.

## Adds

- `scripts/visual/CombatFeedbackLayer3D.gd`

## Patches

- `scripts/core/GameRoot3D.gd`

Runtime node:

`CombatFeedbackLayer096G`

## Visual features

- Enemy health bars.
- Health bar fill updates from common enemy HP properties.
- Hit flash when HP decreases.
- Floating damage number when HP decreases.
- Death burst when HP reaches zero.
- Magic and rare bars use metadata from 096E when available.

## Safety

This is a compatibility visual layer.

It scans likely enemy `Node3D` objects by group/name, reads common HP fields, and adds only visual children. It does not alter damage, enemy movement, AI, XP, loot, or combat rules.
