# Patch 086F — UI Clickability + Passive Tree Performance Repair

This patch stops the passive tree from rebuilding during normal frame updates and resets UIPanelRoot to a simple scene-owned panel switcher.

## Rules

- UIPanelRoot shows one scene-owned panel at a time.
- UIPanelRoot updates only the active panel.
- UIPanelRoot does not recursively disable UI input anymore.
- Passive tree DB is cached.
- Passive tree buttons are built once per panel lifetime.
- Passive node visuals update in place.
- Left-click selects. Right-click allocates.
