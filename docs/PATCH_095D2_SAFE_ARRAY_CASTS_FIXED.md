# 095D2 — Safe Array Casts Fixed Installer

The previous 095D zip had an escaped Python string problem in the installer script.

This fixed patch performs the intended repair:

```gdscript
Array(item.get("affixes", []))
```

becomes:

```gdscript
_rf095d_as_array(item.get("affixes", []))
```

It also installs `_rf095d_as_array(value)` helpers into affected scripts.
