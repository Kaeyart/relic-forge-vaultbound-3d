# 094B — Inventory Rebuild

## Goal

Stop treating inventory like a debug list.

This patch rebuilds the inventory panel around the actual ARPG task flow:

1. See equipped items.
2. See backpack space.
3. Click an item.
4. Immediately understand what it is.
5. Compare it to the equipped item.
6. Perform an obvious action.

## Layout

Left:
- Equipment slots in two columns:
  - Helm
  - Chest
  - Gloves
  - Boots
  - Weapon
  - Amulet
  - Ring 1
  - Ring 2
  - Relic
  - Offhand

Center:
- Backpack grid.
- Items use grid sizes.
- Item names are shortened inside cells.
- Item color follows rarity:
  - normal white
  - magic blue
  - rare yellow
  - unique orange

Right:
- Shared item-card detail.
- Equipped comparison is shown when applicable.

Bottom:
- Equip / Use
- Deposit
- Sort
- Salvage
- Close

## Interaction

- Click item: select.
- Double-click item: primary action.
- Right-click item: context menu.
- Click equipped slot: inspect equipped item.
- Unequip button returns selected equipped item to backpack.
- Deposit only works near the physical Stash station.

## Notes

This is still greybox UI. The important part is that the UX now has a coherent structure.
