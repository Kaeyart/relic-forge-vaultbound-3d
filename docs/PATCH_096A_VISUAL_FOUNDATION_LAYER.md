# 096A — Visual Foundation Layer

## Goal

Start fixing the game's graphics without importing final art assets.

This patch creates a deliberate greybox visual language:

- consistent material palette
- lighting
- floor grid
- physical hub landmarks
- selection markers
- interaction rings
- drop beams
- combat telegraph primitives

## Added scripts

- `scripts/visual/VisualPalette3D.gd`
- `scripts/visual/PrimitiveKit3D.gd`
- `scripts/visual/VisualFoundationLayer3D.gd`
- `scripts/visual/DropBeam3D.gd`
- `scripts/visual/CombatTelegraph3D.gd`

## Patched

- `scripts/core/GameRoot3D.gd`

The patch adds a runtime `VisualFoundationLayer3D` child named:

`VisualFoundationLayer096A`

## Design rules

This is not final art. It is the base layer that makes the project feel intentionally staged before real assets arrive.
