# 095C — Character Reserved Word Fix

## Problem

`CharacterPanel3D.gd` uses this local variable:

```gdscript
var class_name: String = ...
```

In GDScript, `class_name` is a keyword. Godot then fails parsing this block and reports follow-up errors on the line that tries to concatenate `class_name`.

## Fix

Rename the local variable:

```gdscript
var class_display: String = ...
```

And update:

```gdscript
lines.append("[b]" + class_display + "[/b]")
```

No gameplay behavior changes.
