#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

python3 <<'PY'
from pathlib import Path
hub = Path('scenes/hub/VaultHub3D.tscn')
main = Path('scenes/main/GameRoot3D.tscn')
assert hub.exists(), 'missing VaultHub3D.tscn'
assert main.exists(), 'missing GameRoot3D.tscn'
s = hub.read_text(encoding='utf-8')
assert '[sub_resource type="BoxMesh" id="BoxMesh_floor"]' in s, 'missing floor subresource'
assert '[sub_resource type="BoxMesh" id="BoxMesh_device"]' in s, 'missing device subresource'
assert s.index('[sub_resource type="BoxMesh" id="BoxMesh_floor"]') < s.index('mesh = SubResource("BoxMesh_floor")'), 'floor subresource declared after use'
assert s.index('[sub_resource type="BoxMesh" id="BoxMesh_device"]') < s.index('mesh = SubResource("BoxMesh_device")'), 'device subresource declared after use'
assert 'path="res://scenes/hub/VaultHub3D.tscn"' in main.read_text(encoding='utf-8'), 'main scene does not instance VaultHub3D'
print('087K scene resource parse repair validation passed.')
PY
