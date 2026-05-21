# 100A — Full UI Redesign Consolidation

## Purpose

This patch stops the UI from being a pile of debug panels.

It adds one final-target UI shell that covers:

1. UI shell style
2. Skill Gem UI
3. Inventory UI
4. Forge UI
5. Stash UI
6. Map Device UI
7. Character UI
8. Reward UI

## Design rules

- One consistent modal shell.
- Three-column layout maximum.
- Close button always top-right.
- Actions always in bottom bar.
- Selection state must be visible.
- Details panel always on the right.
- Debug text stays out of normal UI.
- Inventory contains uncut gems.
- Skill panel contains cut/installed gems.

## Skill gem contract

Inventory contains:

- Uncut Active Gem
- Uncut Support Gem
- Uncut Spirit Gem

Skill panel contains:

- installed active skills
- support sockets under selected active/spirit skill
- spirit skills with on/off toggle

Flow:

- Cut Uncut Active Gem → choose active skill → installs active skill
- Cut Uncut Support Gem → choose support identity → choose target skill
- Cut Uncut Spirit Gem → choose spirit skill → installs spirit
- Toggle installed spirit on/off
- Supports modify gameplay data and visual summary data

## Safety

This patch does not delete every old UI script. It adds `FinalUIPanelRoot3D.gd`, registers it through the runtime layer manager, and gives the project a clean UI shell target.
