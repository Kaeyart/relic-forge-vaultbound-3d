# 090E — Stash Tab Buying Repair

## Problem

The 090A/090BCD stash system allowed the current selected category to decide where a bought tab appeared. If the player was viewing the Affinity category and pressed Buy Tab, the bought tab could appear beside Currency/Maps/Gems/etc. That made it feel like the player was buying broken special affinity tabs instead of ordinary stash tabs.

## Correct rule

Special affinity tabs are built-in and fixed:

- Currency
- Maps
- Gems
- Crystals
- Uniques

The player only buys ordinary item tabs. Bought tabs can later be turned into `custom_items` tabs with filters such as rarity/slot/kind/tier. They should not become duplicate currency/map/gem/crystal/unique tabs.

## Fix

- Ensures required categories exist:
  - General
  - Affinity
  - Custom
- Ensures built-in affinity tabs exist exactly as system tabs.
- Buying a tab creates a normal player tab with an empty `items` array.
- If buying while viewing Affinity, the new tab is placed in Custom.
- Existing accidental player tabs in Affinity are migrated into Custom.
- Player tab affinity is constrained to:
  - `none`
  - `custom_items`
- System affinity tabs keep their fixed affinity.
