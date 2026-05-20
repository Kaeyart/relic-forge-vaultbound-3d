# 096D — Skill VFX Identity Pass

## Goal

Make active skills visually distinct before final art assets exist.

This patch does not change gameplay damage. It adds a visual-only cast layer that reacts to player casting input in combat.

## Adds

- `scripts/visual/SkillVFXLayer3D.gd`

## Patches

- `scripts/core/GameRoot3D.gd`

The runtime node is:

`SkillVFXLayer096D`

## Inputs

The layer listens for left mouse click and Space, only during combat mode.

## Skill identities

- `fireball`: ember orb projectile, trail, impact pulse
- `storm_lance`: thin blue beam, fork sparks
- `arc_slash`: short forward crescent / slash fan
- `void_rift`: violet floor rift and pulsing core
- `ember_mine`: planted ground glyph and delayed explosion pulse
- unknown skill: neutral cast flash
