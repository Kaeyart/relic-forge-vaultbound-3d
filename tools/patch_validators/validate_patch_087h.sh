#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

if grep -nE '^var[[:space:]]+class_name\b' scripts/core/GameState3D.gd; then
  echo "ERROR: GameState3D.gd still declares reserved variable 'class_name'." >&2
  exit 1
fi

grep -q 'var class_display_name: String' scripts/core/GameState3D.gd || {
  echo "ERROR: class_display_name field missing from GameState3D.gd" >&2
  exit 1
}

grep -q 'class_name RVGameState3D' scripts/core/GameState3D.gd || {
  echo "ERROR: RVGameState3D class header missing" >&2
  exit 1
}

grep -q 'preload("res://scripts/core/GameState3D.gd")' scripts/core/GameRoot3D.gd || {
  echo "ERROR: GameRoot3D.gd does not preload GameState3D.gd" >&2
  exit 1
}

echo "OK: patch 087H GameState3D class_name parse repair"
