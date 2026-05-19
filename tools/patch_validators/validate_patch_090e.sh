#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STASH="$ROOT/scripts/systems/StashSystem3D.gd"
PANEL="$ROOT/scripts/ui/panels/StashPanel3D.gd"

[ -f "$STASH" ] || { echo "Missing scripts/systems/StashSystem3D.gd"; exit 1; }
[ -f "$PANEL" ] || { echo "Missing scripts/ui/panels/StashPanel3D.gd"; exit 1; }

grep -q "SYSTEM_TAB_AFFINITY_BY_ID" "$STASH" || { echo "Missing fixed system affinity tabs"; exit 1; }
grep -q "PLAYER_TAB_AFFINITIES" "$STASH" || { echo "Missing player tab affinity restriction"; exit 1; }
grep -q "_buy_target_category_id" "$STASH" || { echo "Missing buy target category logic"; exit 1; }
grep -q "cat_custom" "$STASH" || { echo "Missing Custom category migration/target"; exit 1; }
grep -q "_new_player_tab" "$STASH" || { echo "Missing player tab creator"; exit 1; }
grep -q "system_tab" "$STASH" || { echo "Missing system tab marker"; exit 1; }
grep -q "locked_affinity" "$STASH" || { echo "Missing locked affinity marker"; exit 1; }
grep -q "Built-in affinity tab" "$STASH" || { echo "Missing system tab summary"; exit 1; }

if grep -q "static func _get" "$STASH"; then
  echo "Forbidden Object virtual helper name found: static func _get" >&2
  exit 1
fi

echo "090E validation passed."
