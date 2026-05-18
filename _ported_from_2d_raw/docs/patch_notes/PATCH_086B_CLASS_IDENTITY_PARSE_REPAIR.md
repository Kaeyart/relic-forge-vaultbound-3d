# Patch 086B — Class Identity Parse Repair

Fixes 086A class identity parse failures by making `GameState.gd` use a preload alias instead of relying on Godot global-class registration order.

## Fixes

- Adds parse-safe `scripts/systems/ClassIdentitySystem.gd`.
- Adds `ClassIdentitySystemScript := preload(...)` to `GameState.gd`.
- Replaces direct `RVClassIdentitySystem.*` calls in `GameState.gd` with `ClassIdentitySystemScript.*`.
- Provides four starter class identities: Sorceress, Warden, Voidbinder, Machinist.
