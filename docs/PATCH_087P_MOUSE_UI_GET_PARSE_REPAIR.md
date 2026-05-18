# 087P — Mouse UI get() Parse Repair

087O introduced new mouse-driven UI scripts, but several scripts used `state.get(key, fallback)`. In Godot, `Object.get()` takes only one argument. This patch rewrites the UI scripts to use local helper methods for fallback access.

It also removes a typed lambda default that caused inference errors in the crafting panel.
