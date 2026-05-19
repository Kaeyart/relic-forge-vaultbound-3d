#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STASH="$ROOT/scripts/systems/StashSystem3D.gd"
PANEL="$ROOT/scripts/ui/panels/StashPanel3D.gd"
STATE="$ROOT/scripts/core/GameState3D.gd"

[ -f "$STASH" ] || { echo "Missing StashSystem3D.gd"; exit 1; }
[ -f "$PANEL" ] || { echo "Missing StashPanel3D.gd"; exit 1; }
[ -f "$STATE" ] || { echo "Missing GameState3D.gd"; exit 1; }

grep -q "RF_090F_SYSTEM_TAB_IDS" "$STASH" || { echo "Missing mandatory system tab IDs"; exit 1; }
grep -q "tab_currency" "$STASH" || { echo "Missing Currency tab repair"; exit 1; }
grep -q "tab_maps" "$STASH" || { echo "Missing Maps tab repair"; exit 1; }
grep -q "tab_gems" "$STASH" || { echo "Missing Gems tab repair"; exit 1; }
grep -q "tab_crystals" "$STASH" || { echo "Missing Crystals tab repair"; exit 1; }
grep -q "tab_uniques" "$STASH" || { echo "Missing Uniques tab repair"; exit 1; }
grep -q "rf_090f_repair_state" "$STASH" || { echo "Missing repair function"; exit 1; }
grep -q "Bought item stash tab" "$STASH" || { echo "buy_tab was not repaired"; exit 1; }
grep -q "rf_090f_repair_state(state_ref)" "$PANEL" || { echo "StashPanel does not call repair function"; exit 1; }

grep -q "RF-090F stash persistence state" "$STATE" || { echo "GameState missing stash variables"; exit 1; }
grep -q "_rf_pre_090f_to_save_dict" "$STATE" || { echo "GameState save wrapper missing"; exit 1; }
grep -q "_rf_pre_090f_apply_save_dict" "$STATE" || { echo "GameState load wrapper missing"; exit 1; }
grep -q "map_completion" "$STATE" || { echo "GameState missing map_completion"; exit 1; }

if grep -q "static func _get" "$STASH"; then
  echo "Forbidden Object virtual helper name found: static func _get" >&2
  exit 1
fi

echo "090F validation passed."
