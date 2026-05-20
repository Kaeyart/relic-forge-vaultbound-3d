# Milestone 0.1 — Playable ARPG Slice

## Goal

The goal is not another isolated feature. The goal is one complete loop that can be played and judged as a game.

## Target loop

1. Start in hub.
2. Walk to Map Device.
3. Press `E`.
4. Choose/open Ash Vault.
5. Enter combat.
6. Fight normal enemies.
7. Fight at least one magic/rare threat.
8. Clear combat.
9. Loot drops.
10. Pick up loot.
11. Return to hub.
12. Inspect inventory.
13. Compare/equip/forge an item.
14. Start another map stronger than before.

## Hard rule

Do not add new systems until this loop feels acceptable.

## Checklist

- No visual garbage on hub start.
- Hub stations are visible and readable.
- Map Device can be reached physically.
- Map can be started.
- Combat arena starts with enemies.
- Enemy count is sane.
- Generated visuals do not become enemies.
- Loot appears only from kills/clear rewards.
- Generated visuals do not become loot.
- Loot can be picked up.
- Inventory displays item names/stats cleanly.
- Forge can act on an item.
- Player can return to hub.
- Loop can be repeated.

## Runtime shortcuts

- `F3`: vertical slice debug overlay, if 098A is installed.
- `F4`: force return to hub.
- `F5`: start Ash Vault test map.
- `F6`: print checklist report to Godot output.

## Feature flags

Feature flags live in `state.runtime_feature_flags`.

Useful flags:

```gdscript
state.runtime_feature_flags["hub_station_layer"] = true
state.runtime_feature_flags["combat_feel_layer"] = true
state.runtime_feature_flags["vertical_slice_debug_overlay"] = true
state.runtime_feature_flags["hub_greybox_layer"] = false
```

The point is not to delete layers when they are noisy. Turn them off.
