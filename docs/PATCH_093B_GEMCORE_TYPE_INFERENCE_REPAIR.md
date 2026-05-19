# 093B — GemCore Type Inference Repair

## Problem

Godot is treating warnings as errors. `GemCoreSystem3D.gd` used `:=` on values derived from Dictionaries / Variants.

Examples:

```gdscript
var level := max(1, _to_int(...))
var xp := _to_int(...) + max(...)
var res := float(base) * ...
```

Godot 4 can fail to infer these types when Variant values are involved.

## Fix

This patch replaces `GemCoreSystem3D.gd` with the same gem contract, but with explicit types on all risky locals:

```gdscript
var level: int = ...
var xp: int = ...
var res: float = ...
var data: Dictionary = ...
```

It does not change the gem design. It only makes the file compile under strict warning settings.
