# 094E — Forge Rebuild

## Goal

Make the Forge feel like a workbench instead of a debug list.

## Layout

Left:
- Craftable backpack items.
- Click selects an item.
- Items show rarity, slot/type, forge potential.

Center:
- Crafting operations.
- Each operation shows its purpose.

Right:
- Current item card.
- Preview result.
- Cost.
- Risk.
- Forge potential change.

Bottom:
- Apply Craft.
- Clear.
- Close.

## Operations

This is still greybox deterministic crafting, but the UX is now correct.

Operations included:

- Refine Values
  - improves numeric stats slightly
  - costs gold and 1 scrap
  - spends 1 forge potential

- Add Random Affix
  - adds a legal-ish stat affix
  - costs gold and 2 scrap
  - spends 2 forge potential

- Upgrade Rarity
  - normal → magic → rare
  - costs gold and shards
  - spends 3 forge potential

- Add Quality
  - adds item quality
  - costs gold and 1 crystal
  - spends 1 forge potential

- Risky Restore Potential
  - can restore potential, fail, or damage the item
  - costs gold and crystals
  - high risk
  - does not require existing potential

## Notes

This patch intentionally keeps crafting logic inside the panel for now. Later we should extract it into a proper `ForgeSystem3D.gd`, but first we need a usable UI and stable player-facing flow.
