#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D
FILE="scripts/combat/CombatArena3D.gd"
[ -f "$FILE" ] || { echo "ERROR: missing $FILE"; exit 1; }
if grep -q "abs(w.z)" "$FILE"; then
  echo "ERROR: stale MeshInstance3D z-access crash remains: abs(w.z)"
  exit 1
fi
if ! grep -q "func _make_box_prop" "$FILE"; then
  echo "ERROR: _make_box_prop helper missing"
  exit 1
fi
if ! grep -q "StaticBody3D" "$FILE"; then
  echo "ERROR: arena props are not using StaticBody3D"
  exit 1
fi
if ! grep -q "VaultBlockerA" "$FILE"; then
  echo "ERROR: internal arena blocker pass missing"
  exit 1
fi
echo "OK: Patch 087I combat arena wall build repair validated."
