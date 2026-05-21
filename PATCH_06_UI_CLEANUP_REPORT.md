# patch_06_ui_stack_cleanup report

Project: `/home/kaey/Desktop/RelicForgeVaultbound3D`
Backup: `/home/kaey/Desktop/RelicForgeVaultbound3D/.patch_backups/patch_06_ui_stack_cleanup_20260521_165441`
Archive: `/home/kaey/Desktop/RelicForgeVaultbound3D/_archived/legacy_ui/patch_06_ui_stack_cleanup_20260521_165441`

Patched scenes/main/GameRoot3D.tscn: embedded legacy UI CanvasLayer now starts hidden.
Patched GameRoot3D.gd: added runtime legacy embedded UI disable helper.
Patched GameRoot3D.gd: calls legacy UI disable helper during runtime UI update/boot.

## Legacy UI archive pass
KEPT because referenced: `scenes/ui/HUD3D.tscn`
  - `.godot/editor/project_metadata.cfg`
  - `.godot/editor/editor_layout.cfg`
KEPT because referenced: `scenes/ui/SkillLoadoutPanel3D.tscn`
  - `.godot/editor/project_metadata.cfg`
  - `.godot/editor/editor_layout.cfg`
ARCHIVED: `scripts/ui/GameHUD3D.gd.bak_092a`
KEPT because referenced: `scripts/ui/HUD3D.gd`
  - `.godot/global_script_class_cache.cfg`
ARCHIVED: `scripts/ui/HUD3D.gd.uid`
KEPT because referenced: `scripts/ui/SimpleHUD3D.gd`
  - `scenes/ui/HUD3D.tscn`
ARCHIVED: `scripts/ui/SimpleHUD3D.gd.uid`
KEPT because referenced: `scripts/ui/SkillLoadoutPanel3D.gd`
  - `scenes/ui/SkillLoadoutPanel3D.tscn`
  - `docs/PATCH_090G_SKILLLOADOUT_CLASSNAME_CONFLICT_REPAIR.md`
  - `.godot/editor/script_editor_cache.cfg`
  - `.godot/editor/editor_layout.cfg`
ARCHIVED: `scripts/ui/SkillLoadoutPanel3D.gd.bak_090g`
ARCHIVED: `scripts/ui/SkillLoadoutPanel3D.gd.uid`
ARCHIVED: `scripts/ui/UIPanelRoot3D.gd.bak_091b`
ARCHIVED: `scripts/ui/UIPanelRoot3D.gd.bak_092a`
ARCHIVED: `scripts/ui/UIPanelRoot3D.gd.bak_094a`
ARCHIVED: `scripts/ui/UIPanelRoot3D.gd.bak_097g`
ARCHIVED: `scripts/ui/panels/CharacterPanel3D.gd.bak_094a`
ARCHIVED: `scripts/ui/panels/CharacterPanel3D.gd.bak_095a`
ARCHIVED: `scripts/ui/panels/CharacterPanel3D.gd.bak_095c`
ARCHIVED: `scripts/ui/panels/CharacterPanel3D.gd.bak_095d2`
ARCHIVED: `scripts/ui/panels/ForgePanel3D.gd.bak_094a`
ARCHIVED: `scripts/ui/panels/ForgePanel3D.gd.bak_094e`
ARCHIVED: `scripts/ui/panels/ForgePanel3D.gd.bak_095d2`
ARCHIVED: `scripts/ui/panels/InventoryPanel3D.gd.bak_094a`
ARCHIVED: `scripts/ui/panels/InventoryPanel3D.gd.bak_094b`
ARCHIVED: `scripts/ui/panels/InventoryPanel3D.gd.bak_095d2`
ARCHIVED: `scripts/ui/panels/MapDevicePanel3D.gd.bak_094a`
ARCHIVED: `scripts/ui/panels/MapDevicePanel3D.gd.bak_094f`
ARCHIVED: `scripts/ui/panels/MapDevicePanel3D.gd.bak_095d2`
ARCHIVED: `scripts/ui/panels/SkillGemPanel3D.gd.bak_094a`
ARCHIVED: `scripts/ui/panels/SkillGemPanel3D.gd.bak_094d`
ARCHIVED: `scripts/ui/panels/SkillGemPanel3D.gd.bak_095d2`
ARCHIVED: `scripts/ui/panels/StashPanel3D.gd.bak_094a`
ARCHIVED: `scripts/ui/panels/StashPanel3D.gd.bak_094c`
ARCHIVED: `scripts/ui/panels/StashPanel3D.gd.bak_095d2`

## Canonical UI stack kept
OK: `resources/ui/RVUITheme.tres`
OK: `scenes/ui/GameHUD3D.tscn`
OK: `scenes/ui/UIPanelRoot3D.tscn`
OK: `scenes/ui/lab/UILayoutLab3D.tscn`
OK: `scripts/ui/GameHUD3D.gd`
OK: `scripts/ui/RVUIStyle3D.gd`
OK: `scripts/ui/UIPanelRoot3D.gd`
OK: `scripts/ui/lab/UILayoutLab3D.gd`
OK: `scripts/ui/lab/UIMockState3D.gd`

## Remaining UI file inventory
- `scenes/ui/GameHUD3D.tscn`
- `scenes/ui/HUD3D.tscn`
- `scenes/ui/SkillLoadoutPanel3D.tscn`
- `scenes/ui/UIPanelRoot3D.tscn`
- `scenes/ui/lab/UILayoutLab3D.tscn`
- `scenes/ui/panels/CharacterPanel3D.tscn`
- `scenes/ui/panels/CraftingPanel3D.tscn`
- `scenes/ui/panels/ForgePanel3D.tscn`
- `scenes/ui/panels/InventoryPanel3D.tscn`
- `scenes/ui/panels/MapDevicePanel3D.tscn`
- `scenes/ui/panels/MapPanel3D.tscn`
- `scenes/ui/panels/SkillGemPanel3D.tscn`
- `scenes/ui/panels/SkillLoadoutPanel3D.tscn`
- `scenes/ui/panels/StashPanel3D.tscn`
- `scripts/ui/FinalUIPanelRoot3D.gd`
- `scripts/ui/FinalUIPanelRoot3D.gd.uid`
- `scripts/ui/GameHUD3D.gd`
- `scripts/ui/GameHUD3D.gd.uid`
- `scripts/ui/HUD3D.gd`
- `scripts/ui/RVUIStyle3D.gd`
- `scripts/ui/RVUIStyle3D.gd.uid`
- `scripts/ui/SimpleHUD3D.gd`
- `scripts/ui/SkillLoadoutPanel3D.gd`
- `scripts/ui/UIPanelRoot3D.gd`
- `scripts/ui/UIPanelRoot3D.gd.uid`
- `scripts/ui/components/UIFoundationActionBar3D.gd`
- `scripts/ui/components/UIFoundationActionBar3D.gd.uid`
- `scripts/ui/components/UIFoundationItemCard3D.gd`
- `scripts/ui/components/UIFoundationItemCard3D.gd.uid`
- `scripts/ui/lab/UILayoutLab3D.gd`
- `scripts/ui/lab/UILayoutLab3D.gd.uid`
- `scripts/ui/lab/UIMockState3D.gd`
- `scripts/ui/lab/UIMockState3D.gd.uid`
- `scripts/ui/panels/BaseTextPanel3D.gd`
- `scripts/ui/panels/BaseTextPanel3D.gd.uid`
- `scripts/ui/panels/CharacterPanel3D.gd`
- `scripts/ui/panels/CharacterPanel3D.gd.uid`
- `scripts/ui/panels/CraftingPanel3D.gd`
- `scripts/ui/panels/CraftingPanel3D.gd.uid`
- `scripts/ui/panels/ForgePanel3D.gd`
- `scripts/ui/panels/ForgePanel3D.gd.uid`
- `scripts/ui/panels/InventoryPanel3D.gd`
- `scripts/ui/panels/InventoryPanel3D.gd.uid`
- `scripts/ui/panels/MapDevicePanel3D.gd`
- `scripts/ui/panels/MapDevicePanel3D.gd.uid`
- `scripts/ui/panels/MapPanel3D.gd`
- `scripts/ui/panels/MapPanel3D.gd.uid`
- `scripts/ui/panels/SkillGemPanel3D.gd`
- `scripts/ui/panels/SkillGemPanel3D.gd.uid`
- `scripts/ui/panels/SkillLoadoutPanel3D.gd`
- `scripts/ui/panels/SkillLoadoutPanel3D.gd.uid`
- `scripts/ui/panels/StashPanel3D.gd`
- `scripts/ui/panels/StashPanel3D.gd.uid`
- `scripts/ui/widgets/DraggableWindow.gd`
- `scripts/ui/widgets/DraggableWindow.gd.uid`
- `scripts/ui/widgets/ItemSlotButton.gd`
- `scripts/ui/widgets/ItemSlotButton.gd.uid`
- `scripts/ui/widgets/ListEntryButton.gd`
- `scripts/ui/widgets/ListEntryButton.gd.uid`
- `scripts/ui/widgets/UISlotButton3D.gd`
- `scripts/ui/widgets/UISlotButton3D.gd.uid`
- `resources/ui/RVUITheme.tres`
