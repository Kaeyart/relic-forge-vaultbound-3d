# 087Z — Legacy UI API Compatibility Repair

Godot still loads legacy scripts from old scenes even though the final greybox UI is now the active UI. Those legacy scripts reference old APIs that no longer exist.

This patch rewrites the legacy UI scripts as compatibility shims. They no longer drive the final UI. They only compile safely and, if still instantiated by old scenes, show minimal valid text.
