# 095D — Safe Array Casts

Godot is throwing:

```text
Invalid call. Nonexistent 'Array' constructor.
```

The cause is code like:

```gdscript
var affixes: Array = Array(item.get("affixes", []))
```

This patch adds safe `_rf095d_as_array(value)` helpers and replaces unsafe `Array(value)` calls in the rebuilt UI/system files.

No gameplay behavior changes.
