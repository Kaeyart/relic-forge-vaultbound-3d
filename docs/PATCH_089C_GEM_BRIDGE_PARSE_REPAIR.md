# 089C — Gem Bridge Parse Repair

## Problem

`GemInventoryBridge3D.gd` declared:

```gdscript
static func _get(state: Object, key: String, fallback: Variant = null) -> Variant:
```

Because the script extends `RefCounted`, Godot sees `_get` as an override of the built-in `Object._get(StringName) -> Variant` virtual. The signatures do not match, so the script cannot parse.

## Fix

- Renamed the helper from `_get(...)` to `_state_get(...)`.
- Updated all state reads inside `GemInventoryBridge3D.gd`.
- Added validator protection so this regression cannot re-enter the file.
