# Relic Forge: Vaultbound 3D

Clean Godot 4 top-down 3D ARPG reboot of the Relic Forge: Vaultbound prototype.

This repository is intentionally separate from the old 2D project. The old project remains the source of truth for system design history, but old scripts/scenes are imported here only as inert reference snapshots until each system is deliberately ported.

## Current goal

Build a clean 3D vertical slice:

- top-down ARPG movement
- hub -> map -> hub loop
- combat with player skills, enemies, XP, loot, flasks
- modular 3D map environments
- clean UI scenes
- gradually port itemization, crafting, skill gems, passive tree, classes, stash, loot filter, and map device

## Important rule

Do not copy old `.gd` scripts directly into active `res://scripts` unless they have been ported and validated. The old 2D repo contains useful systems, but also patch-era UI and Node2D assumptions.

Raw imports live in:

```text
_ported_from_2d_raw/
```

Many files there are renamed to `.gd.txt`, `.tscn.txt`, or `.tres.txt` so Godot will not parse them automatically.

## Validate

```bash
cd /home/kaey/Desktop/RelicForgeVaultbound3D
tools/validate_3d_project.sh
git status
```
