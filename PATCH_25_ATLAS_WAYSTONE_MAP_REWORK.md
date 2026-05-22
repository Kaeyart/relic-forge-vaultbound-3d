# patch_25_atlas_waystone_map_rework

Adds a POE2-style map skeleton:

- Atlas nodes with locked / available / completed state
- Waystones as required map keys
- Waystone tiers, rarity, modifiers, danger/reward scoring
- Precursor Tablets with charges
- Tablet slots from Waystone modifier count: 0-2 mods = 1, 3-5 = 2, 6+ = 3
- Towers reveal nearby nodes and reward tablets
- Powerful boss nodes have harder bosses and better reward weighting
- Map Device UI: Atlas + Waystone + Tablet + final launch summary
- Map launch consumes Waystone and tablet charges
- Boss kill completes maps and unlocks Atlas neighbors
- Completion grants Waystones/Tablets/materials for sustain testing

Test path:
1. Walk to Map Device, press E.
2. Select Atlas node.
3. Select Waystone.
4. Select optional Tablet.
5. Launch.
6. Kill the boss.
7. Return to hub.
8. Confirm node completed and neighbors unlock.
