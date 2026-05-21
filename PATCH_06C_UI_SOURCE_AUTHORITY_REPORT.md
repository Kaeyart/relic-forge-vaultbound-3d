# patch_06c_ui_source_authority_purge report

Project: `/home/kaey/Desktop/RelicForgeVaultbound3D`
Backup: `/home/kaey/Desktop/RelicForgeVaultbound3D/.patch_backups/patch_06c_ui_source_authority_purge_20260521_173535`
Archive: `/home/kaey/Desktop/RelicForgeVaultbound3D/_archived/legacy_ui_source_purge/20260521_173535`

## Patched
- scenes/main/GameRoot3D.tscn: forced embedded legacy UI/labels hidden
- scripts/core/GameRoot3D.gd: replaced legacy _update_ui with no-op/hide
- scripts/core/GameRoot3D.gd: expanded legacy UI hiding helper
- scripts/systems/UIStackAuthority3D.gd: strict runtime authority installed
- project.godot: added UIStackAuthority3D autoload

## Removed local Godot editor caches
- .godot/global_script_class_cache.cfg
- .godot/editor/script_editor_cache.cfg
- .godot/editor/editor_layout.cfg
- .godot/editor/project_metadata.cfg

## Kept canonical UI files
- `resources/ui/RVUITheme.tres`
- `scenes/ui/GameHUD3D.tscn`
- `scenes/ui/UIPanelRoot3D.tscn`
- `scenes/ui/lab/UILayoutLab3D.tscn`
- `scenes/ui/panels/CharacterPanel3D.tscn`
- `scenes/ui/panels/ForgePanel3D.tscn`
- `scenes/ui/panels/InventoryPanel3D.tscn`
- `scenes/ui/panels/MapDevicePanel3D.tscn`
- `scenes/ui/panels/SkillGemPanel3D.tscn`
- `scenes/ui/panels/StashPanel3D.tscn`
- `scripts/systems/UIAccessSystem3D.gd`
- `scripts/systems/UIAccessSystem3D.gd.uid`
- `scripts/systems/UIFoundationSystem3D.gd`
- `scripts/systems/UIFoundationSystem3D.gd.uid`
- `scripts/ui/GameHUD3D.gd`
- `scripts/ui/GameHUD3D.gd.uid`
- `scripts/ui/RVUIStyle3D.gd`
- `scripts/ui/RVUIStyle3D.gd.uid`
- `scripts/ui/UIPanelRoot3D.gd`
- `scripts/ui/UIPanelRoot3D.gd.uid`
- `scripts/ui/lab/UILayoutLab3D.gd`
- `scripts/ui/lab/UILayoutLab3D.gd.uid`
- `scripts/ui/lab/UIMockState3D.gd`
- `scripts/ui/lab/UIMockState3D.gd.uid`
- `scripts/ui/panels/BaseTextPanel3D.gd`
- `scripts/ui/panels/BaseTextPanel3D.gd.uid`
- `scripts/ui/panels/CharacterPanel3D.gd`
- `scripts/ui/panels/CharacterPanel3D.gd.uid`
- `scripts/ui/panels/ForgePanel3D.gd`
- `scripts/ui/panels/ForgePanel3D.gd.uid`
- `scripts/ui/panels/InventoryPanel3D.gd`
- `scripts/ui/panels/InventoryPanel3D.gd.uid`
- `scripts/ui/panels/MapDevicePanel3D.gd`
- `scripts/ui/panels/MapDevicePanel3D.gd.uid`
- `scripts/ui/panels/SkillGemPanel3D.gd`
- `scripts/ui/panels/SkillGemPanel3D.gd.uid`
- `scripts/ui/panels/StashPanel3D.gd`
- `scripts/ui/panels/StashPanel3D.gd.uid`

## Archived non-canonical UI files
- `scripts/ui/FinalUIPanelRoot3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/FinalUIPanelRoot3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/HUD3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/HUD3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/SimpleHUD3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/SimpleHUD3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/SkillLoadoutPanel3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/SkillLoadoutPanel3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/components/UIFoundationActionBar3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/components/UIFoundationActionBar3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/components/UIFoundationItemCard3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/components/UIFoundationItemCard3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/panels/CraftingPanel3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/panels/CraftingPanel3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/panels/MapPanel3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/panels/MapPanel3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/panels/SkillLoadoutPanel3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/panels/SkillLoadoutPanel3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/widgets/DraggableWindow.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/widgets/DraggableWindow.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/widgets/ItemSlotButton.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/widgets/ItemSlotButton.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/widgets/ListEntryButton.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/widgets/ListEntryButton.gd.uid` — not in canonical patch_05 UI allowlist
- `scripts/ui/widgets/UISlotButton3D.gd` — not in canonical patch_05 UI allowlist
- `scripts/ui/widgets/UISlotButton3D.gd.uid` — not in canonical patch_05 UI allowlist
- `scenes/ui/HUD3D.tscn` — not in canonical patch_05 UI allowlist
- `scenes/ui/SkillLoadoutPanel3D.tscn` — not in canonical patch_05 UI allowlist
- `scenes/ui/panels/CraftingPanel3D.tscn` — not in canonical patch_05 UI allowlist
- `scenes/ui/panels/MapPanel3D.tscn` — not in canonical patch_05 UI allowlist
- `scenes/ui/panels/SkillLoadoutPanel3D.tscn` — not in canonical patch_05 UI allowlist
- `scripts/systems/FinalUIActions3D.gd` — non-canonical UI system
- `scripts/systems/FinalUIActions3D.gd.uid` — non-canonical UI system
- `scripts/systems/FinalUISchema3D.gd` — non-canonical UI system
- `scripts/systems/FinalUISchema3D.gd.uid` — non-canonical UI system
- `scripts/systems/UIFoundationSystem3D.gd.bak_095d2` — non-canonical UI system
- `scripts/systems/UIFoundationSystem3D.gd.bak_097f` — non-canonical UI system
- `scripts/systems/UIItemFormatSystem3D.gd` — non-canonical UI system
- `scripts/systems/UIItemFormatSystem3D.gd.uid` — non-canonical UI system
- `scripts/systems/UIStateSummarySystem3D.gd` — non-canonical UI system
- `scripts/systems/UIStateSummarySystem3D.gd.bak_097g1` — non-canonical UI system
- `scripts/systems/UIStateSummarySystem3D.gd.uid` — non-canonical UI system
- `scripts/systems/UIUXSystem3D.gd` — non-canonical UI system
- `scripts/systems/UIUXSystem3D.gd.uid` — non-canonical UI system

## Remaining references to archived legacy UI paths
- `scripts/core/RuntimeLayerManager3D.gd` still references `res://scripts/ui/FinalUIPanelRoot3D.gd`

## Warnings
- None

Rollback:
`/home/kaey/Desktop/RelicForgeVaultbound3D/.patch_backups/patch_06c_ui_source_authority_purge_20260521_173535/rollback_patch_06c.sh`
