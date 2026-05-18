# 087X — Final UI Layout Visibility Repair

## Problem

The final UI scripts were being instantiated and the dim blocker appeared, but the actual modal shell/buttons were not visible. That points to scene layout, not the GameRoot runtime hook.

The previous generated `.tscn` files were missing enough explicit Godot 4 layout metadata that several container children could resolve to zero-size or fail to participate in container layout.

## Fix

This patch rewrites:

- `scenes/ui/UIPanelRoot3D.tscn`
- `scenes/ui/panels/InventoryPanel3D.tscn`
- `scenes/ui/panels/ForgePanel3D.tscn`
- `scenes/ui/panels/SkillGemPanel3D.tscn`
- `scenes/ui/panels/MapDevicePanel3D.tscn`
- `scenes/ui/panels/CharacterPanel3D.tscn`

All nodes now use explicit:
- `layout_mode`
- anchors/offsets where needed
- `size_flags_horizontal`
- `size_flags_vertical`
- `custom_minimum_size` on key panels/buttons
