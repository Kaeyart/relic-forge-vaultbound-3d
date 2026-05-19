# 091A — Physical Stations, Quick Stash, Gem XP/Seed Repair

## Main changes

- Stash and Forge are now physical greybox hub stations.
- Stash and Forge/Crafting cannot be opened by generic key/menu access unless the player is near the correct station.
- Press E near the Stash station to open the Stash.
- Press E near the Forge station to open Crafting.
- Stash gets a Quick Deposit button.
- Quick Deposit moves current backpack items into stash tabs using affinity routing.
- Starter active/support/spirit gem items are seeded once into inventory.
- Active skill gems gain XP when the selected skill is cast in combat.
- Active skill gems level up when they hit their XP threshold.

## Files

- `scripts/systems/StationAccessSystem3D.gd`
- `scripts/systems/GemProgressionSystem3D.gd`
- patches `GameRoot3D.gd`
- patches `UIPanelRoot3D.gd`
- patches `StashSystem3D.gd`
- patches `StashPanel3D.gd`
- patches `GameState3D.gd`
