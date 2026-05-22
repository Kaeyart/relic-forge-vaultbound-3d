# patch_24_gem_state_and_ui_fit

Fixes:
- Declares new gem-page state fields on GameState3D so SkillGemSystem3D can actually persist equipped_gem_page, hotbar_slots, and gem_inventory.
- Persists new gem state in save/load.
- Replaces InventoryPanel3D with a 1280x720-safe 3-column layout.
- Replaces SkillGemPanel3D with a narrower layout that fits inside UIPanelRoot's content area.
- Narrows UIPanelRoot sidebar/margins so panels no longer overflow the viewport.
- Ensures Gem Bench creates missing test uncut/support items even if spirit gems already exist.

Backup:
.patch_backups/patch_24_gem_state_and_ui_fit_20260522_144220
