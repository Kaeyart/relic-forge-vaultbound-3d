# patch_28_hub_environment_blockout_rebuild

Purpose: replace the weak hub blockout with a production-style primitive environment based on the provided concept image.

Active hub layout:
- Center: raised circular Map Device dais with blue arcane core, pylons, rings, and floor inlays.
- Left: forge wing with furnace, fire, anvil, workbench, tools, braziers, and orange lighting.
- Right: stash wing with vault chest, shelves, crates, rug, storage props, and warm lighting.
- North: shrine/reliquary alcove with stairs, door, statues, candles, banners.
- Perimeter: walls, pillars, chains, parapets, floor tiles, brass inlays, foreground braziers.

Station access:
- Only Map Device, Forge, and Stash remain as physical stations.
- Player returns/spawns near the south entrance at z=5.4.
- Station labels remain above their matching visual stations.

Files replaced:
- scripts/visual/HubGreyboxPass3D.gd
- scripts/systems/StationAccessSystem3D.gd
- scenes/hub/VaultHub3D.tscn

Backup location:
- .patch_backups/patch_28_hub_environment_blockout_rebuild_*/
