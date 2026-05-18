# Patch 086C — Class Identity Helper Name Repair

Fixes a Godot parser conflict in `ClassIdentitySystem.gd` caused by helper functions named `_set()` / `_get()`.

Godot `Object` already defines virtual `_set(StringName, Variant)` and `_get(StringName)`. Defining helpers with those names and different signatures can make the script fail to parse.

Changes:

- Renames `static func _set(...)` to `static func _state_set(...)`.
- Renames `static func _get(...)` to `static func _state_get(...)` if present.
- Renames helper call sites safely.
- Does not change class identity gameplay data.
