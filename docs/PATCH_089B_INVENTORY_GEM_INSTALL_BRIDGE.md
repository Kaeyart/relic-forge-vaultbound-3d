# 089B — Inventory Gem Install Bridge

Right-click or double-click gem items in the inventory now sends them into the skill gem model.

## Active gems

- Install into the currently selected active skill slot.
- Previous active gem moves into `gem_stash.active`.
- Level, XP, quality, and supports are preserved.

## Support gems

- Try to socket into the selected active skill.
- If incompatible or no unlocked socket exists, move to `gem_stash.support`.

## Spirit gems

- Install into `spirit_gem_slots` disabled.
- Toggle from the skill panel by right-clicking the spirit entry.

This patch uses the selected active slot as the target. A target picker can come later.
