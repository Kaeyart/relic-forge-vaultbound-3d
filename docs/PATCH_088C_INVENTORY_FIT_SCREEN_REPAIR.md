# 088C — Inventory Fit-Screen Repair

## Problem

088B made the backpack tetris area fixed at 794x554 plus a 220px bottom panel. Inside the modal shell this could exceed the available screen height, causing the inventory to not fit.

## Fix

- The backpack grid now computes cell size from the actual `BackpackArea` size.
- The scene no longer forces a huge backpack minimum size.
- Equipment slot buttons are shorter.
- The bottom item/compare/action panel is reduced.
- The tetris grid remains 10 columns x 8 rows.

## Result

The inventory should fit the modal shell without scrolling while keeping the tetris layout.
