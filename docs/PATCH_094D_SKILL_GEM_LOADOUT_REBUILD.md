# 094D — Skill Gem Loadout Rebuild

## Goal

Make skill gems understandable and usable.

This patch replaces the skill panel with a real loadout editor.

## Layout

Left:
- Active skill slots 1–4.
- Each slot shows active gem name, level, XP, quality, and socket count.

Center:
- Selected active gem detail.
- Six visible support sockets.
- Locked sockets show the level requirement.
- Filled sockets show support gem name, level, quality.
- Clicking a socket selects it.
- Remove Support sends the support gem back to inventory.

Right:
- Available gems from backpack.
- Filter: All / Active / Support / Spirit.
- Click selects a gem.
- Double-click installs if possible.
- Action button installs active/support/spirit based on gem type.

Bottom:
- Spirit gems.
- Toggle enabled/disabled.
- Shows reservation cost and total reserved/max spirit.
- Spirit gems can have support sockets.
- Support gems can be socketed into selected spirit gem.

## Rules implemented

- Active gems install into active skill slots.
- Support gems socket into the selected active gem by default.
- Support gems can also socket into selected spirit gem with the Spirit Target action.
- Spirit gems install into spirit gem list disabled by default.
- Active and spirit gems start with two sockets.
- Socket unlock display follows GemCoreSystem3D.
- Gem level, XP, and quality are always visible.
