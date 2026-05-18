# 087U — GameRoot Numeric Cast Repair

The uploaded `GameRoot3D.gd` still uses direct `float(...)` and `int(...)` casts on values pulled from `state.get(...)`.

In this project state values can be null, strings, floats, ints, or saved variants depending on save/load history. Godot can throw `Invalid call. Nonexistent 'float' constructor` / `int constructor` when those constructors are hit with bad variants.

This patch:
- Adds `_rf_087u_float(value, fallback)` and `_rf_087u_int(value, fallback)`.
- Replaces direct `float(...)` / `int(...)` constructor calls in `GameRoot3D.gd`.
- Leaves typed declarations such as `var x: float` untouched.
- Does not change gameplay logic.
