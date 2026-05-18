# Patch 086G — UI Runtime Stabilization

Fixes the UI regression cluster after passive tree/class patches.

## Main fixes

- Stops `GameRoot` from recursively setting every HUD/panel control to `MOUSE_FILTER_IGNORE`.
- Makes `UIPanelRoot` update only the active panel, and only when its signature changes.
- Rewrites passive tree runtime to build once and update visual state in place.
- Removes hot-path `PassiveTreeSystem.ensure_defaults()` calls from every node state query.
- Hides duplicate unbound `SupportGemCard16+` clones that were intercepting Skill Gems clicks.
- Repairs bound Skill Gems buttons to `MOUSE_FILTER_STOP`.
- Adds InventoryPanel signature gating so it does not rebuild runtime item buttons every frame.

## Test order

1. Walk in hub.
2. Open Inventory and click item/equipment buttons.
3. Open Skill Gems and click active/support/spirit/socket buttons.
4. Open Passive Tree and check open time.
5. Drag/pan passive tree empty space.
6. Left-click a passive node to select.
7. Right-click an available node to allocate.
8. Close panels and walk again.
