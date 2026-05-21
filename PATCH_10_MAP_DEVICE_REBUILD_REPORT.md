# patch_10_map_device_rebuild

Installed into: `/home/kaey/Desktop/RelicForgeVaultbound3D`
Backup: `/home/kaey/Desktop/RelicForgeVaultbound3D/.patch_backups/patch_10_map_device_rebuild_20260521_225729`

Replaced:
- `scripts/ui/panels/MapDevicePanel3D.gd`
- `scenes/ui/panels/MapDevicePanel3D.tscn`

Scope:
- Rebuilt Map Device screen only.
- No combat, inventory, skill gem, forge, stash, or character screen changes.
- Map launch button calls the current scene's `_start_map()` when available; otherwise it tells the player to press T.
