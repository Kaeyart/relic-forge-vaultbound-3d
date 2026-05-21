# patch_14_inventory_grid_item_state

Inventory gameplay refinement pass.

## Adds

- Real 8x6 backpack grid model.
- Item width/height fields: `grid_w`, `grid_h`.
- Item coordinates: `grid_x`, `grid_y`.
- Persistent flags: `identified`, `favorite`, `locked`, `new_item`.
- Safe UID normalization.
- Item-size rules by item type/slot.
- Inventory UI now shows cell occupancy, overflow, item flags, grid position, tags, and stronger comparison data.
- Installer attempts to wire inventory panel hotkeys into `GameRoot3D.gd`:
  - `Y` appraise selected.
  - `L` lock/unlock selected.
  - `V` favorite/unfavorite selected.
  - `Delete`/`Backspace` drop selected if not locked/favorited.
- Installer archives old save files named `relic_forge_3d_save.json` so the next boot starts fresh.

## Why the save reset is intentional

Old item dictionaries from earlier patches do not match the new item-state model. This patch backs them up instead of deleting them.

## Next inventory targets

- `patch_15_inventory_actions_salvage_stash`
- `patch_16_gear_sockets_runes`
- `patch_17_inventory_comparison_build_relevance`
