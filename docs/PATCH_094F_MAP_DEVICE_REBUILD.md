# 094F — Map Device Rebuild

## Goal

Make maps feel like a run launcher, not another stash list.

## Layout

Left:
- Available map items from backpack and map stash tabs.
- Filters:
  - rarity
  - tier range
  - backpack / stash / all source

Center:
- Selected map preview.
- Shows tier, rarity, mods, objective requirement, completion state, and bonus state.
- Uses the shared item-card formatter.

Right:
- Atlas progress summary.
- Completion and bonus counts by tier band:
  - Tier 1–5: white/basic maps
  - Tier 6–9: magic bonus requirement
  - Tier 10–15: rare bonus requirement

Bottom:
- Open Map
- Clear Selection
- Close

## Completion rules displayed

- Tier 1–5:
  - Completion: clear the map.
  - Bonus: clear the map.

- Tier 6–9:
  - Completion: clear the map.
  - Bonus: complete as Magic or Rare.

- Tier 10–15:
  - Completion: clear the map.
  - Bonus: complete as Rare.

## Behavior

`Open Map` sets:

- `active_map_item`
- `active_map_tier`
- `active_map_rarity`
- `active_map_name`

Then it attempts to call the main scene's existing map start function:

- `_start_map()`
- `start_map()`
- `_open_selected_map()`

If no compatible function exists, it sets `mode = "combat"` as a fallback.
