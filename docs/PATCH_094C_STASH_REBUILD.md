# 094C — Stash Rebuild

## Goal

Make the stash feel like an ARPG stash instead of a debug item dump.

## Layout

Left:
- Categories
- Built-in Affinity category
- Custom/player categories
- New Category button

Top:
- Tabs inside selected category
- Mandatory tabs:
  - Currency
  - Maps
  - Gems
  - Crystals
  - Uniques
- Bought item tabs
- Buy Item Tab button
- Customize Tab button

Center:
- Specialized content views:
  - Currency as stack rows
  - Maps as tier/rarity/completion cards
  - Gems grouped by Active / Support / Spirit
  - Crystals as material stacks
  - Uniques as collection cards
  - Normal item tabs as item cards/grid

Right:
- Selected tab summary
- Selected item card
- Selected item actions

Bottom:
- Search box
- Search current/global toggle
- Quick Deposit All
- Withdraw
- Close

## Interaction

- Click category: select category.
- Click tab: select tab.
- Click item: select item.
- Double-click item: withdraw.
- Right-click item: context menu.
- Quick Deposit All routes backpack items into stash affinities.
- Buy Item Tab creates player-owned item tabs only.
