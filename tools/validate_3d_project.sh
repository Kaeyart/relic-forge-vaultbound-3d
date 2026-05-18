#!/usr/bin/env bash
set -euo pipefail
cd /home/kaey/Desktop/RelicForgeVaultbound3D

echo "== Relic Forge Vaultbound 3D validate =="
[ -f project.godot ] && echo "OK: project.godot" || { echo "ERROR: missing project.godot"; exit 1; }
[ -f scenes/main/GameRoot3D.tscn ] && echo "OK: 3D main scene" || { echo "ERROR: missing GameRoot3D.tscn"; exit 1; }
[ -f scripts/core/GameRoot3D.gd ] && echo "OK: 3D root script" || { echo "ERROR: missing GameRoot3D.gd"; exit 1; }
if grep -q 'GameRoot3D.tscn' project.godot; then echo "OK: main scene set"; else echo "ERROR: main scene not set"; exit 1; fi

echo "== Key tree =="
find scenes scripts docs tools -maxdepth 3 -type f | sort | sed 's/^/FILE /' | head -120

echo "== Git status =="
git status --short || true

echo "validate_3d_project complete. Open Godot and press Play for runtime confirmation."
