#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STATE="$ROOT/scripts/core/GameState3D.gd"

[ -f "$STATE" ] || { echo "Missing scripts/core/GameState3D.gd"; exit 1; }

COUNT_SPIRIT_MAX="$(grep -c '^var spirit_max:' "$STATE" || true)"
COUNT_SPIRIT_RESERVED="$(grep -c '^var spirit_reserved:' "$STATE" || true)"
COUNT_TO_SAVE="$(grep -c '^func to_save_dict() -> Dictionary:' "$STATE" || true)"
COUNT_APPLY="$(grep -c '^func apply_save_dict(data: Dictionary) -> void:' "$STATE" || true)"

if [ "$COUNT_SPIRIT_MAX" -ne 1 ]; then
  echo "Expected exactly one spirit_max declaration; found $COUNT_SPIRIT_MAX" >&2
  exit 1
fi

if [ "$COUNT_SPIRIT_RESERVED" -ne 1 ]; then
  echo "Expected exactly one spirit_reserved declaration; found $COUNT_SPIRIT_RESERVED" >&2
  exit 1
fi

if [ "$COUNT_TO_SAVE" -ne 1 ]; then
  echo "Expected exactly one to_save_dict wrapper; found $COUNT_TO_SAVE" >&2
  exit 1
fi

if [ "$COUNT_APPLY" -ne 1 ]; then
  echo "Expected exactly one apply_save_dict wrapper; found $COUNT_APPLY" >&2
  exit 1
fi

grep -q '^var spirit_gem_slots: Array = \[\]' "$STATE" || { echo "Missing spirit_gem_slots declaration"; exit 1; }
grep -q 'data\["spirit_gem_slots"\] = spirit_gem_slots' "$STATE" || { echo "Missing spirit_gem_slots save"; exit 1; }
grep -q 'spirit_gem_slots = Array(data.get("spirit_gem_slots", \[\]))' "$STATE" || { echo "Missing spirit_gem_slots load"; exit 1; }
grep -q 'data\["stash_tabs"\] = stash_tabs' "$STATE" || { echo "Missing stash_tabs save"; exit 1; }
grep -q '_rf_090f_ensure_stash_state_defaults()' "$STATE" || { echo "Missing stash default helper call"; exit 1; }

if grep -q $'^\t\tspirit_gem_slots = Array(data.get' "$STATE"; then
  echo "Broken double-indented load statement still inside to_save_dict" >&2
  exit 1
fi

if grep -q $'^\t\tdata\["spirit_gem_slots"\]' "$STATE"; then
  echo "Broken double-indented spirit save statement still present" >&2
  exit 1
fi

echo "093C validation passed."
