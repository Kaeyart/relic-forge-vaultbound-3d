# 2D → 3D Porting Rules

## Rule 1 — Do Not Activate Old Scripts Blindly

Do not copy old `.gd` files into active 3D `res://scripts` unless they have been reviewed and rewritten. The old repo contains patch-era assumptions, global-class load-order dependencies, UI ownership issues, and 2D-specific code.

## Rule 2 — Port Concepts, Not Code

Acceptable to port:

- item naming ideas
- crafting verb flavor
- map loop rules
- class fantasy
- skill concepts
- affix names after cleanup

Not acceptable to port directly:

- old panel scripts
- old passive tree script/UI
- old combat arena
- old Godot scene fallback generation logic

## Rule 3 — Every Active System Must Be 3D-Native

3D gameplay systems should use:

- `CharacterBody3D` or `Node3D` world entities
- `Vector3` positions
- `Area3D` or physics/raycast checks
- `NavigationAgent3D` or authored pathing where needed
- 2D UI only through `CanvasLayer`

## Rule 4 — Small Systems First

A system is not allowed into the main loop until it has:

- a narrow API
- a validator
- no editor parse errors
- no generated persistent UI layout
- a clear test path

## Rule 5 — Data Is Cheap, Runtime Coupling Is Expensive

It is fine to add clean data tables for items, affixes, skills, maps, and classes. It is not fine to wire every system into every other system in one patch.

## Recommended Porting Order

1. GameState3D
2. SkillDB3D + simple casting
3. ItemDB3D + AffixDB3D
4. LootSystem3D
5. Inventory/equipment UI
6. CraftingSystem3D
7. MapLoopSystem3D
8. SaveSystem3D
9. Character classes
10. Progression
