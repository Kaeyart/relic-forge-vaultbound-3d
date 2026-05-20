# 097C — Mega Loot + Reward Integration

## Purpose

The previous milestone established combat readability and enemy/drop contracts. This patch connects that into the actual reward loop.

Goal:

> Enemy dies → real loot appears → loot is readable → player picks it up → correct system receives it.

## Adds

### `scripts/systems/RewardLoopSystem3D.gd`

Central reward translator and reward generator.

It handles:

- enemy reward bundles
- map-clear reward bundles
- rare enemy bonus loot
- boss reward loot
- drop normalization
- drop labels
- presentation data for loot beams
- pickup-compatible drop conversion

## Patches

### `scripts/combat/CombatArena3D.gd`

Changes:

- enemy death now uses `RewardLoopSystem3D.enemy_reward_bundle`
- boss/map-clear pile now uses `RewardLoopSystem3D.clear_reward_bundle`
- `_spawn_drops` now:
  - normalizes drops
  - gives every loot actor presentation metadata
  - places loot in a wider burst
  - optionally asks `LootPresentationLayer096F` for a reward burst

### `scripts/loot/LootActor3D.gd`

Changes:

- adds loot actors to the `loot` group
- stores `item_data` metadata for the 096F loot presentation layer
- uses reward-loop label/color helpers

### `scripts/systems/LootSystem3D.gd`

Adds a compatibility wrapper so future contract-style drops can still be picked up:

- `gear`
- `currency`
- `gem`
- `crystal`
- `item`
- `map`
- old active/support/spirit gem kinds

## Result

The reward loop should now feel much closer to an ARPG:

- normal monsters can drop basic rewards
- magic monsters feel more rewarding
- rares produce actual loot bursts
- map clear produces a visible reward pile
- loot beams can read actual item/gem/map/currency data
