# 091B — UIPanelRoot `extends` Order Repair

## Problem

Godot reports:

```text
res://scripts/ui/UIPanelRoot3D.gd:2 - Parse Error:
Unexpected "extends" in class body.
```

The 091A UI panel lock patch inserted:

```gdscript
const StationAccessSystemScript := preload(...)
extends CanvasLayer
```

That order is invalid. `extends` must be at the top of the script header before normal constants and variables.

## Fix

This patch rewrites the file header so it becomes:

```gdscript
extends CanvasLayer

const StationAccessSystemScript := preload("res://scripts/systems/StationAccessSystem3D.gd")
```

It preserves the rest of `UIPanelRoot3D.gd`.
