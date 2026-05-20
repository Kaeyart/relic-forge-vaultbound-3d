#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Relic Forge 3D health report 097B"
echo "================================="
echo
echo "Root: $ROOT"
echo

echo "[1/5] Git status"
git status --short || true
echo

echo "[2/5] Tracked backup/debris files"
BACKUPS="$(git ls-files | grep -E '(\\.bak($|_)|\\.orig$|\\.tmp$|\\.rej$)' || true)"
if [ -z "$BACKUPS" ]; then
  echo "No tracked backup/debris files found."
else
  echo "$BACKUPS"
fi
echo

echo "[3/5] Deep validation"
python3 tools/deep_validate_3d_project.py --root "$ROOT"
echo

echo "[4/5] Existing project validator"
if [ -x tools/validate_3d_project.sh ]; then
  tools/validate_3d_project.sh
else
  echo "tools/validate_3d_project.sh not executable or missing."
fi
echo

echo "[5/5] Optional Godot headless parse check"
if command -v godot >/dev/null 2>&1; then
  godot --headless --path "$ROOT" --quit || true
elif command -v godot4 >/dev/null 2>&1; then
  godot4 --headless --path "$ROOT" --quit || true
else
  echo "No godot/godot4 command found in PATH. Skipping."
fi
