#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHAR="$ROOT/scripts/ui/panels/CharacterPanel3D.gd"

[ -f "$CHAR" ] || { echo "Missing scripts/ui/panels/CharacterPanel3D.gd"; exit 1; }

grep -q 'CharacterRoot095A' "$CHAR" || { echo "Character 095A root missing"; exit 1; }
grep -q 'func _summary_text' "$CHAR" || { echo "Summary text missing"; exit 1; }
grep -q 'func _combined_stats' "$CHAR" || { echo "Combined stats missing"; exit 1; }
grep -q 'func _equipment_text' "$CHAR" || { echo "Equipment overview missing"; exit 1; }
grep -q 'func _skills_text' "$CHAR" || { echo "Skills overview missing"; exit 1; }
grep -q 'func _notes_text' "$CHAR" || { echo "Build notes missing"; exit 1; }
grep -q 'Offense' "$CHAR" || { echo "Offense section missing"; exit 1; }
grep -q 'Defense' "$CHAR" || { echo "Defense section missing"; exit 1; }
grep -q 'Resistances' "$CHAR" || { echo "Resistance section missing"; exit 1; }
grep -q 'GemCoreSystemScript.normalize_active' "$CHAR" || { echo "Active gem summary not wired"; exit 1; }
grep -q 'UIFoundationSystemScript.stat_label' "$CHAR" || { echo "Readable stat labels not used"; exit 1; }

echo "095A validation passed."
