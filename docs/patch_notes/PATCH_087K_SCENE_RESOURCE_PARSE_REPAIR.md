# Patch 087K — Scene Resource Parse Repair

Fixes a scene-load regression from Patch 087J.

## Problem

`VaultHub3D.tscn` referenced `SubResource("BoxMesh_floor")` and `SubResource("BoxMesh_device")` before those internal resources were declared. Godot rejected the scene, and because `GameRoot3D.tscn` instances `VaultHub3D.tscn`, the main scene failed too.

## Fix

- Rewrites `scenes/hub/VaultHub3D.tscn` with sub-resources declared before nodes.
- Normalizes the `GameRoot3D.tscn` load step count.
- Does not change gameplay systems.
