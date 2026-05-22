# patch_21_ui_click_stability

Installed at: ven 22 mag 2026, 14:22:12, CEST
Backup: /home/kaey/Desktop/RelicForgeVaultbound3D/.patch_backups/patch_21_ui_click_stability_20260522_142212

Fixes:
- Stops UIPanelRoot3D from updating/re-rendering the active panel every frame when state has not changed.
- Prevents buttons from being destroyed between mouse down and mouse up.
- Makes SkillGemPanel3D buttons fire on mouse-down for both left-click and right-click.
- Keeps gem carving/socketing explicit: click uncut -> click target, click support -> click socket.

Files replaced:
- scripts/ui/UIPanelRoot3D.gd
- scripts/ui/panels/SkillGemPanel3D.gd
