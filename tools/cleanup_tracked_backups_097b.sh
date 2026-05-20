#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BACKUPS="$(git ls-files | grep -E '(\\.bak($|_)|\\.orig$|\\.tmp$|\\.rej$)' || true)"

if [ -z "$BACKUPS" ]; then
  echo "No tracked backup/debris files found."
  exit 0
fi

echo "Tracked backup/debris files:"
echo "$BACKUPS"
echo

if [ "${1:-}" != "--apply" ]; then
  echo "Dry run only."
  echo "To remove these from git tracking while keeping local files:"
  echo "  tools/cleanup_tracked_backups_097b.sh --apply"
  exit 0
fi

echo "$BACKUPS" | while IFS= read -r file; do
  [ -n "$file" ] || continue
  git rm --cached -- "$file"
done

echo
echo "Removed backup/debris files from git tracking."
echo "Local files are still on disk."
echo "Review with: git status"
