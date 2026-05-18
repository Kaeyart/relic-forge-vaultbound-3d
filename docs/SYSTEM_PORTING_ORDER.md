# System Porting Order

## Phase 0 — Keep old systems inert

- Snapshot old 2D files into `_ported_from_2d_raw/`.
- Do not copy old scripts directly into active `scripts/`.

## Phase 1 — Runtime core

1. GameRoot3D
2. PlayerActor3D
3. CombatArena3D
4. EnemyActor3D
5. ProjectileActor3D
6. HUD3D / minimal UI

## Phase 2 — Economy core

1. GameState3D
2. SaveSystem3D
3. ItemDB3D
4. ItemAffixDB3D
5. LootDropSystem3D
6. Inventory/Stash data only

## Phase 3 — Buildcraft

1. SkillSystem3D
2. SkillGemDB3D
3. SkillGemSystem3D
4. CraftingCurrencySystem3D
5. PassiveTreeDB3D as pure data
6. PassiveTreeSystem3D with no recursive update trap
7. ClassIdentitySystem3D

## Phase 4 — UI

1. Inventory panel
2. Skill gem panel
3. Crafting panel
4. Map device panel
5. Stash panel
6. Loot filter panel
7. Passive tree panel

## Phase 5 — 3D-specific content

1. Modular environment kit
2. Enemy models/animations
3. Player model/animations
4. Skill VFX
5. Loot pickups
6. Map layouts/navmesh
