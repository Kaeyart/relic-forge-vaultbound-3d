# Patch 087L — SaveSystem3D Class Name Collision Repair

Fixes a Godot parser error where `RVSaveSystem3D` collided with an existing global script class registration.

## Change

`SaveSystem3D.gd` is used through preload aliases such as:

```gdscript
const SaveSystemScript := preload("res://scripts/systems/SaveSystem3D.gd")
```

It does not need a global `class_name`. This patch removes `class_name RVSaveSystem3D` from active scripts and keeps the save system preload-safe.

## Reason

The clean 3D repo is intentionally avoiding global-class reliance where preload aliases are enough. This reduces Godot global class cache and duplicate-class failures during rapid patching.
