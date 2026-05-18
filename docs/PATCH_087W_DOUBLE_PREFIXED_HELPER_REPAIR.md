# 087W — Double-Prefixed Helper Repair

The active `GameRoot3D.gd` contains calls such as:

`_rf_087u__rf_087v_float(state.get("notice_time"))`

No function with that name exists. The real helpers are `_rf_087u_float`, `_rf_087u_int`, `_rf_087v_float`, and `_rf_087v_int`.

This patch normalizes accidental double-prefixed helper calls back to the 087V helpers:

- `_rf_087u__rf_087v_float(...)` → `_rf_087v_float(...)`
- `_rf_087u__rf_087v_int(...)` → `_rf_087v_int(...)`
- plus equivalent repeated/nested forms if they exist elsewhere.

It scans:
- `scripts/core/GameRoot3D.gd`
- `scripts/ui/**/*.gd`
- `scripts/systems/**/*.gd`
