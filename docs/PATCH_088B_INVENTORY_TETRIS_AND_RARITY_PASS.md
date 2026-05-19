# 088B — Inventory Tetris and Rarity Pass

## Goal

Make the inventory grid visible without scrolling and implement the first functional inventory-tetris layer.

## Changes

- Removes backpack scrolling from the inventory scene.
- Replaces `GridContainer` backpack display with an explicit `BackpackArea` control.
- Draws a fixed 10 x 8 visible grid.
- Places item buttons by `grid_x`, `grid_y`, `grid_w`, `grid_h`.
- Assigns missing grid positions automatically.
- Supports drag/drop item movement to empty cells.
- Rejects invalid placement if out-of-bounds or overlapping.
- Shows rarity colors before selection:
  - normal: white
  - magic: blue
  - rare: yellow
  - unique: orange

## Notes

This is still a greybox implementation. It uses buttons as item blocks, not final art icons.
