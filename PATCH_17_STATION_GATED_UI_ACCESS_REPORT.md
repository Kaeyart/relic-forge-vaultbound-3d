# patch_17_station_gated_ui_access report

- Replaced UIAccessSystem3D.gd with station-gated panel access.
- Disabled station-gated global buttons/tabs in scenes/ui/GameHUD3D.tscn
- Disabled station-gated global buttons/tabs in scenes/ui/UIPanelRoot3D.tscn
- Ensured UIPanelRoot3D.gd mode changes pass through UIAccessSystem gating.
