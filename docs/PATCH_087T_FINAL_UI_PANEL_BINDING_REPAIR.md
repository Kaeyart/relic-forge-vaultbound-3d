# 087T — Final UI Panel Binding Repair

The runtime crash now comes from child panel scripts such as `InventoryPanel3D.gd`. They still use `%EquipButton` and similar unique-name lookups. Those lookups are returning null in the generated scene tree.

This patch replaces all panel `%` bindings with explicit scene paths and null-safe button wiring.

Affected:
- InventoryPanel3D
- ForgePanel3D
- SkillGemPanel3D
- MapDevicePanel3D
- CharacterPanel3D
