# 087V — UI Numeric Cast Repair

The final greybox HUD still used direct `float(_state_get(...))` and `int(...)` conversions.
That can crash when saved state values are null or schema-drifted variants.

This patch:
- Rewrites `GameHUD3D.gd` with safe numeric helpers.
- Patches `GameRoot3D.gd` direct `float(state.get(...))`, `int(state.get(...))`, `float(state.call(...))`, and `int(state.call(...))`.
- Patches `SkillGemPanel3D.gd` cast detail conversion defensively.
