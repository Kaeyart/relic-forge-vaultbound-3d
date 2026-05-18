# 087O — Mouse-Driven UI Overhaul

## Intent
The 3D project now has a working systems layer, but the UX is still too keyboard/text driven. This patch standardizes the UI interaction model.

## Scope
- Draggable root windows.
- Clickable panel tabs/buttons.
- Reusable mouse-driven widget layer.
- Panel update throttling via state signatures.
- Inventory, crafting, maps, skills, and character panels rebuilt around a shared base.

## Interaction Model
- Left click: select row/slot/button.
- Double click: primary action (equip/use/insert/open where applicable).
- Right click: secondary action (unequip/remove/toggle where applicable).
- Drag window by title bar.
- Escape closes current panel.

## Shared widgets
- `RVDraggableWindow.gd`
- `RVListEntryButton.gd`
- `RVItemSlotButton.gd`
- `RVPanelStateSignature.gd`

## Panel targets
- InventoryPanel3D
- CraftingPanel3D
- MapPanel3D
- SkillLoadoutPanel3D
- CharacterPanel3D

## Notes
This patch is an architectural UI pass. It intentionally focuses on interaction and scene ownership, not art polish.
