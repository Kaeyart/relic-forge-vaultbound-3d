# Patch 087H — GameState3D `class_name` Parse Repair

Fixes a GDScript keyword collision introduced by 087G.

`class_name` is a GDScript declaration keyword, so this field is invalid:

```gdscript
var class_name: String = "Sorceress"
```

It is now:

```gdscript
var class_display_name: String = "Sorceress"
```

This unblocks `GameState3D.gd`, which also resolves the dependent `GameRoot3D.gd` preload/global-class errors.
