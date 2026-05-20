# 098B — Combat Feel Pass

## Purpose

098A stabilized runtime detection. 098B improves combat feel without final art assets.

This patch does not touch fragile damage code. Instead, it observes real enemy HP changes. If HP drops, it spawns hit feedback.

## Adds

- `CombatFeelSystem3D.gd`
- `CombatFeelLayer3D.gd`

## In-game result

- subtle player ground focus ring
- normal/magic/rare/boss enemy threat rings
- hit pulse rings when enemies take damage
- short floating damage labels

All generated nodes are marked with `rv_generated_visual` so the scanners added in 098A ignore them.
