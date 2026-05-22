# Patch 34 — Passive Tree Identity Expansion

Expands the class/passive/ascendancy skeleton into a more serious build foundation.

Adds/replaces:
- Expanded PassiveTreeDB3D with class lanes, notables, center clusters, and keystones
- Safer PassiveTreeSystem3D with allocation/refund validation and node filtering
- Expanded AscendancyDB3D with 8-node subclass trees
- Safer AscendancySystem3D with dependency-safe refunds and validation
- ClassProgressionSystem3D demo seeding for testing points
- Rebuilt PassiveTreePanel3D with filters, search, node detail, validation, and class switching
- Rebuilt AscendancyPanel3D with subclass choices, node detail, and validation

Controls:
- P = Passive Tree
- O = Ascendancy

Testing target:
- Press P, switch between Sorceress/Warrior/Huntress, allocate class-lane nodes, center nodes, and keystones.
- Press O, choose an ascendancy and allocate subclass nodes.
- Refund should prevent breaking dependency chains.
- build_stats/build_rules should update through GameState recompute_stats.

This still does not implement the full combat behavior for every ascendancy rule. That belongs in the next patch.
