#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/kaey/Desktop/RelicForgeVaultbound3D"
REPO_NAME="${1:-relic-forge-vaultbound-3d}"
VISIBILITY="${2:-private}"
OWNER="${3:-}"

cd "$ROOT"

echo "== Relic Forge Vaultbound 3D · New GitHub Repo Setup =="
echo "Repo name: $REPO_NAME"
echo "Visibility: $VISIBILITY"
echo

if ! command -v git >/dev/null 2>&1; then
  echo "git is not installed or not on PATH." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI 'gh' is not installed or not on PATH." >&2
  echo "Install it or create the GitHub repo manually, then add the remote." >&2
  exit 1
fi

gh auth status >/dev/null

if [ ! -d ".git" ]; then
  git init -b main
fi

git branch -M main

echo
echo "== Running validators if present =="
if [ -x "tools/patch_validators/validate_patch_095b.sh" ]; then
  tools/patch_validators/validate_patch_095b.sh
fi

if [ -x "tools/validate_3d_project.sh" ]; then
  tools/validate_3d_project.sh
else
  echo "No tools/validate_3d_project.sh found; skipping project validator."
fi

echo
echo "== Git status before commit =="
git status

echo
echo "== Creating local checkpoint commit if needed =="
git add -A
if git diff --cached --quiet; then
  echo "No staged changes to commit."
else
  git commit -m "Initial 3D ARPG foundation checkpoint"
fi

echo
echo "== Checking remotes =="
if git remote get-url origin >/dev/null 2>&1; then
  echo "An origin remote already exists:"
  git remote -v
  echo
  echo "For a brand-new GitHub repo, run:"
  echo "  git remote rename origin old-origin"
  echo "Then rerun this script."
  exit 2
fi

case "$VISIBILITY" in
  private)
    VIS_FLAG="--private"
    ;;
  public)
    VIS_FLAG="--public"
    ;;
  internal)
    VIS_FLAG="--internal"
    ;;
  *)
    echo "Visibility must be: private, public, or internal." >&2
    exit 1
    ;;
esac

if [ -n "$OWNER" ]; then
  FULL_NAME="$OWNER/$REPO_NAME"
else
  FULL_NAME="$REPO_NAME"
fi

echo
echo "== Creating GitHub repo =="
gh repo create "$FULL_NAME" "$VIS_FLAG" --source=. --remote=origin --push

echo
echo "== Done =="
git remote -v
git status
