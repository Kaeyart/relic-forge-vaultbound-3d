# 097A — Mega Combat Integration Pass

This patch bundles the next combat milestone instead of shipping one tiny patch at a time.

Included:

1. `MapThreatSystem3D.gd`
   - Tier 1–5: white-map style.
   - Tier 6–9: magic-map style.
   - Tier 10–15: rare-map style.
   - Defines magic pack size, rare count, and rare modifier count.

2. `EnemySpawnContractSystem3D.gd`
   - Normal monsters remain fodder.
   - Magic monsters are assigned as packs with one shared modifier.
   - Rare monsters are standalone threats.
   - Rares get 3–5 modifiers depending map tier.

3. `EnemyModifierRuntimeSystem3D.gd`
   - Regenerating restores HP if enemy HP properties exist.
   - Shielded creates barrier metadata.
   - Empowers Nearby boosts nearby monsters once.
   - Frenzied ramps after combat time.
   - Explodes on Death gets armed when enemy reaches zero HP.

4. `LootDropContractSystem3D.gd`
   - Adds a clean enemy-to-drop contract helper for later real loot integration.

5. `CombatDirectorLayer3D.gd`
   - Runtime layer that scans combat enemies and applies the above systems.

Runtime node:

`CombatDirectorLayer097A`
