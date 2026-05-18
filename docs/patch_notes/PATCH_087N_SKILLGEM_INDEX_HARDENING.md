# Patch 087N — SkillGem Index Hardening

Fixes runtime crashes from empty or malformed `active_skill_slots` arrays after the big 3D ARPG systems pass.

Changes:

- Normalizes active skill slots to a single schema: `active` + `active_id` + `supports`.
- Rebuilds default slots if save/state data is empty.
- Guards every slot index access.
- Guards support/spirit cursor wrapping when no keys exist.
- Keeps support compatibility validation.
- Keeps active/support/spirit gem design intact.
