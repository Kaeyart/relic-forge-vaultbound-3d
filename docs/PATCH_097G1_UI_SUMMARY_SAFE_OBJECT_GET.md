# 097G1 — UI Summary Safe Object.get Hotfix

## Issue

Godot reports:

`Too many arguments for get() call. Expected at most 1 but received 2.`

## Cause

`UIStateSummarySystem3D.gd` called:

```gdscript
state.get("some_key", fallback)
```

That is valid for `Dictionary.get()`, but not for `Object.get()`.

`Object.get()` only accepts one argument.

## Fix

Adds a helper:

```gdscript
static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant
```

Then replaces all fallback Object access with:

```gdscript
_state_get(state, "some_key", fallback)
```
