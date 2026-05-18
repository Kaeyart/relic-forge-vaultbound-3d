# 087Q — Proper UI Suite

## Intent
The project needs a stable pre-art UI that feels like a real game interface instead of a debugging shell. This patch rebuilds the UI suite around proper scene-authored windows and a shared top bar.

## Included panels
- Inventory
- Forge
- Skill Gems
- Maps
- Character

## Interaction model
- Top bar buttons switch panels.
- ItemList rows are clickable.
- Double click performs primary actions when appropriate.
- Dedicated action buttons exist for major actions.
- Escape or Close closes the current panel.

## Notes
This patch focuses on usability and scene ownership rather than final art polish.
