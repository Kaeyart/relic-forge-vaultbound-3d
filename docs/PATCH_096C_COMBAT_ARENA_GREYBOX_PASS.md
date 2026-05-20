# 096C — Combat Arena Greybox Pass

This patch makes combat arenas feel staged before final art assets.

It adds:

- `scripts/visual/CombatArenaGreyboxPass3D.gd`

It patches:

- `scripts/core/GameRoot3D.gd`

The runtime node is:

`CombatArenaGreyboxPass096C`

The pass is visible only when `state.mode == "combat"`.
