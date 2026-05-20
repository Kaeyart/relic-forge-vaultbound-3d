#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

SUMMARY="$ROOT/scripts/systems/UIStateSummarySystem3D.gd"

[ -f "$SUMMARY" ] || { echo "Missing UIStateSummarySystem3D.gd"; exit 1; }

grep -q 'class_name RVUIStateSummarySystem3D' "$SUMMARY" || { echo "summary class_name missing"; exit 1; }
grep -q 'static func _state_get' "$SUMMARY" || { echo "_state_get helper missing"; exit 1; }

python3 - <<'PY' "$SUMMARY"
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")

# Object.get fallback misuse: state.get("x", fallback)
bad = re.findall(r'state\.get\s*\(\s*"[^"]+"\s*,', text)
if bad:
    print("Found unsafe Object.get fallback calls:")
    for item in bad:
        print("  " + item)
    raise SystemExit(1)

print("No unsafe state.get(key, fallback) calls found.")
PY

if [ -x "$ROOT/tools/deep_validate_3d_project.py" ]; then
  python3 "$ROOT/tools/deep_validate_3d_project.py" --root "$ROOT"
fi

echo "097G1 validation passed."
