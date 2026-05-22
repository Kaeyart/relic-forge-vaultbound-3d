# patch_26_station_access_core_repair

Purpose: repair hub station access after the Atlas/Waystone map patch.

Rules:
- Inventory and Skill Gems remain global.
- Only physical hub stations are Map Device, Forge, and Stash.
- Character Shrine, Gem Bench station, and extra training station are removed from the physical station layout.
- Press E near a station to open that panel.
- No HUD prompt spam. Station names are visible as world labels above the stations.

Test:
1. Boot hub.
2. Confirm only MAP DEVICE, FORGE, STASH station labels exist.
3. Walk to each station and press E.
4. Map Device opens maps panel.
5. Forge opens forge panel.
6. Stash opens stash panel.
7. Press I and K globally.
8. Press M/F/C/H and verify they do not directly open station panels.
