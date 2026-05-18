# 087S — Final UI Node Binding Repair

087R used `%NodeName` unique-node lookup in `GameHUD3D.gd` and `UIPanelRoot3D.gd`. The generated scenes did not reliably resolve those unique names at runtime, so the HUD crashed before it could connect buttons.

This patch uses explicit node paths instead and guards all optional UI nodes.
