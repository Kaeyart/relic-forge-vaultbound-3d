# 088A — Inventory Layout Rebuild

## Goal

Replace the current rough inventory panel with the requested ARPG inventory layout.

## Layout

Left equipment panel:

- Left column: Helm, Chest, Gloves, Boots, Weapon
- Right column: Amulet, Ring 1, Ring 2, Relic, Offhand

Right panel:

- Backpack grid occupying roughly two thirds of the inventory screen.
- Items are snapped into grid cells visually.
- Full multi-cell inventory Tetris placement is reserved for 088B.

Bottom panel:

- Selected item details.
- Equipped comparison.
- Equip, Unequip, Deposit, Salvage buttons.

Top right:

- Close button.

## Notes

088A is layout, comparison, selection, and actions. 088B should implement true item width/height, grid coordinates, occupancy, and snap-to-grid drag movement.
