#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== Relic Forge 3D validation =="

fail=0
need_file() {
  if [ ! -f "$1" ]; then
    echo "ERROR: missing $1"
    fail=1
  else
    echo "OK: $1"
  fi
}
need_dir() {
  if [ ! -d "$1" ]; then
    echo "ERROR: missing dir $1"
    fail=1
  else
    echo "OK: dir $1"
  fi
}

need_file project.godot
need_dir scenes
need_dir scripts
need_file README.md
need_file docs/PROJECT_STATUS_3D.md
need_file docs/PORTING_PLAN_2D_TO_3D.md
need_file tools/import_2d_snapshot_inert.py

if grep -R "class_name RVGameRoot\|class_name RVCombatArena" _ported_from_2d_raw 2>/dev/null | grep -v "\.txt:" >/dev/null 2>&1; then
  echo "ERROR: old 2D runtime scripts appear active inside _ported_from_2d_raw"
  fail=1
else
  echo "OK: imported 2D Godot scripts are inert"
fi

if [ -f project.godot ]; then
  echo "Project main scene:"
  grep -n 'run/main_scene' project.godot || true
fi

if [ -d .git ]; then
  echo "OK: git repo exists"
else
  echo "WARNING: git repo missing"
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "3D validation complete."
