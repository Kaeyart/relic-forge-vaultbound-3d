#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for p in scripts/ui/GameHUD3D.gd scripts/ui/UIPanelRoot3D.gd scenes/ui/GameHUD3D.tscn scenes/ui/UIPanelRoot3D.tscn; do
  [ -f "$ROOT/$p" ] || { echo "Missing $p"; exit 1; }
done

if grep -R '@onready var .*%[A-Za-z]' "$ROOT/scripts/ui/GameHUD3D.gd" "$ROOT/scripts/ui/UIPanelRoot3D.gd" >/tmp/087s_bad_unique.txt 2>/dev/null; then
  cat /tmp/087s_bad_unique.txt
  echo "Found fragile %UniqueName binding in repaired root HUD/UI scripts." >&2
  exit 1
fi

echo "087S validation passed."
