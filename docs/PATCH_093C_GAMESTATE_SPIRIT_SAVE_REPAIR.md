# 093C — GameState Spirit Save Repair

## Problem

`GameState3D.gd` was corrupted by the 093A save/load patch.

Symptoms:

- `spirit_max` declared twice.
- `spirit_reserved` declared twice.
- `to_save_dict()` contains load statements.
- Several lines are indented as if they are inside a function, but Godot reads them as class-body code.

## Fix

This patch repairs only `scripts/core/GameState3D.gd`.

It:

- Removes the duplicate top-level `spirit_max` and `spirit_reserved` declarations added by 093A.
- Keeps the original gameplay values:
  - `spirit_max: int = 30`
  - `spirit_reserved: int = 0`
- Keeps `spirit_gem_slots`.
- Replaces the broken `to_save_dict()` wrapper with a valid one.
- Replaces the `apply_save_dict()` wrapper with a valid one.
