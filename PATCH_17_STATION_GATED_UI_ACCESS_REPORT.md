# patch_17_station_gated_ui_access report

- Replaced UIAccessSystem3D.gd with station-gated panel access.
- Patched GameRoot3D.gd direct UI hotkey.
- Patched GameRoot3D.gd direct UI hotkey.
- Patched GameRoot3D.gd direct UI hotkey.
- Patched GameRoot3D.gd direct UI hotkey.
- Patched GameRoot3D.gd direct UI hotkey.
- Patched panel close key handling: Esc closes all, I/K close their own global panels.
- Removed T launch shortcut from Map Device panel.
- Removed forge 1/2/3 action shortcuts.
- Disabled station-gated global buttons/tabs in scenes/ui/GameHUD3D.tscn
- Disabled station-gated global buttons/tabs in scenes/ui/UIPanelRoot3D.tscn
- Ensured UIPanelRoot3D.gd mode changes pass through UIAccessSystem gating.
