# Patch 087M — Skill Slot Empty Runtime Repair

Fixes a runtime crash where `SkillGemSystem3D.selected_slot()` indexed `slots[0]` while `active_skill_slots` was empty after save/load or a migration patch.

## Fixes

- Makes `selected_slot()` tolerate missing or empty `active_skill_slots`.
- Restores a safe default 4-slot skill loadout when missing.
- Normalizes slot dictionaries to contain `active_id` and `supports`.
- Clamps and writes back `selected_skill_slot`.
- Hardens `selected_cast_data()` against empty fallback state.
