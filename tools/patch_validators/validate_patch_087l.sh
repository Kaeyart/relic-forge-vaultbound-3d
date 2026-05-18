#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

echo "== Validate 087L SaveSystem3D class collision repair =="

if grep -R "^class_name RVSaveSystem3D" -n --include='*.gd' scripts scenes 2>/dev/null; then
  echo "ERROR: RVSaveSystem3D class_name still exists in active scripts." >&2
  exit 1
fi

if [ ! -f scripts/systems/SaveSystem3D.gd ]; then
  echo "ERROR: scripts/systems/SaveSystem3D.gd missing." >&2
  exit 1
fi

if ! grep -q "extends RefCounted" scripts/systems/SaveSystem3D.gd; then
  echo "ERROR: SaveSystem3D.gd must extend RefCounted." >&2
  exit 1
fi

if ! grep -q "preload(\"res://scripts/systems/SaveSystem3D.gd\")" scripts/core/GameRoot3D.gd; then
  echo "ERROR: GameRoot3D.gd should use preload alias for SaveSystem3D.gd." >&2
  exit 1
fi

# Basic duplicate global class scan for active scripts.
python3 - <<'PY'
from pathlib import Path
from collections import defaultdict
root = Path('.')
exclude = {'.git', '.godot', '_ported_from_2d_raw', '.patch_backups', '.local_project_backups'}
classes = defaultdict(list)
for p in root.rglob('*.gd'):
    if any(part in exclude or part.startswith('.patch') for part in p.parts):
        continue
    for line in p.read_text(encoding='utf-8', errors='ignore').splitlines():
        line = line.strip()
        if line.startswith('class_name '):
            name = line.split()[1]
            classes[name].append(str(p))
errors = False
for name, paths in sorted(classes.items()):
    if len(paths) > 1:
        errors = True
        print(f'ERROR: duplicate class_name {name}:')
        for path in paths:
            print('  -', path)
if errors:
    raise SystemExit(1)
print('OK: no duplicate active class_name declarations')
PY

echo "087L validation complete."
