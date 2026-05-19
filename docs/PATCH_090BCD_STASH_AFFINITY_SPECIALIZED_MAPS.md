# 090BCD — Stash Search, Custom Affinity, Specialized Tabs, Map Completion

## 090B — Search + Custom Item Affinity

- Global search and per-tab search are preserved and expanded.
- Search now checks:
  - item name
  - rarity
  - slot
  - type/kind
  - tags
  - stats
  - map tier
  - gem fields
  - custom stash tab name
- Right-click a stash tab to open a customize popup.
- Tabs can now define custom item affinity rules:
  - rarity filter
  - equipment slot filter
  - item kind filter
  - minimum tier
  - maximum tier
- Auto-routing checks custom item tabs for item rules.

## 090C — Specialized Affinity Tabs

The existing item grid is still greybox, but the display logic is now affinity-aware:

- Currency tab:
  - stacks matching currency/material items.
  - displays stack count.
- Map tab:
  - sorts by tier, rarity, name.
  - displays tier, rarity, completion, bonus, and bonus requirement.
- Gem tab:
  - displays active/support/spirit type, base color, carved/uncarved state, level, quality.
- Crystal tab:
  - displays crystal type and stack count.
- Unique tab:
  - displays quality and power tier when available.

## 090D — Map Completion Rules

Map bonus rules are now formalized:

- Tier 1–5:
  - bonus requirement: normal map or better.
  - no modifier requirement.
- Tier 6–9:
  - bonus requirement: magic map or better.
- Tier 10–15:
  - bonus requirement: rare map.

The system exposes:
- `map_bonus_requirement_text(item)`
- `map_bonus_requirements_met(item)`
- `complete_map_item(state, item, completed_extra_goal)`
- map display state for completed/bonus completed

A later gameplay patch should call `complete_map_item(...)` when the player finishes a map.
