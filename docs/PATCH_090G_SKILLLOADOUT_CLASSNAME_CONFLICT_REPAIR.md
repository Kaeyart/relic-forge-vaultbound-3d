# 090G — SkillLoadoutPanel `class_name` Conflict Repair

Godot reports:

```text
res://scripts/ui/SkillLoadoutPanel3D.gd:1 - Parse Error:
Class "RVSkillLoadoutPanel3D" hides a global script class.
```

The root-level legacy script still declares:

```gdscript
class_name RVSkillLoadoutPanel3D
```

Another script already owns that global class name. This patch removes only that one line and leaves the rest of the file intact.
