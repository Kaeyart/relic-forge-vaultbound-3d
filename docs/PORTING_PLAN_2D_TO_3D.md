# 2D → 3D Porting Plan

## Principle

Import behavior, data, and design. Do not import patch-era architecture blindly.

The 2D project proved these systems:

- maps as physical items
- six-entry map portals
- loot filter
- stash tabs/affinities
- item bases/affixes/forge potential
- crafting currencies and verbs
- flasks
- XP and skill gem XP
- passive tree
- class identity

The 3D project should port those systems one at a time into clean 3D-compatible scripts.

## Inert snapshot

`tools/import_2d_snapshot_inert.py` copies old files into `_ported_from_2d_raw/` and renames Godot runtime file extensions to `.txt`. This gives us reference access without causing Godot parse/class-name conflicts.

## Active porting rule

A system becomes active only when:

- it has no Node2D-only assumptions unless explicitly wrapped
- it has no UI fallback generation
- it uses scene-owned UI for persistent panels
- it validates in Godot
- it has a small runtime test path

## First active ports

### 088A — Clean GameState3D

Create a new state class with only fields needed by 3D runtime:

- mode
- player stats
- flasks
- skills
- XP/gold/materials
- inventory shell
- current map activity shell

### 088B — Itemization + Loot

Port data and generation logic, not UI.

### 088C — Skill Gems + Skills

Port gem data and active skill definitions. Keep VFX simple.

### 088D — Crafting Verbs

Port item mutation functions and forge potential.

### 088E — UI Panels V1

Only after active systems are stable.
