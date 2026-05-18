#!/usr/bin/env python3
from __future__ import annotations
import argparse
import shutil
from pathlib import Path
from datetime import datetime

RUNTIME_EXTENSIONS = {".gd", ".tscn", ".tres", ".res", ".import"}
SKIP_DIRS = {".git", ".godot", ".import", "__pycache__", ".local_project_backups"}
SKIP_PREFIXES = (".patch",)

# Curated imports: system/design-relevant, not the whole old repo cache.
IMPORT_PATHS = [
    "scripts/core/GameState.gd",
    "scripts/core/SaveSystem.gd",
    "scripts/data",
    "scripts/systems",
    "scripts/ui",
    "scripts/combat",
    "scripts/hub",
    "scripts/player",
    "scenes/ui",
    "scenes/hub",
    "scenes/combat",
    "scenes/prefabs",
    "docs",
    "data",
    "assets/ui",
]


def should_skip(path: Path) -> bool:
    for part in path.parts:
        if part in SKIP_DIRS:
            return True
        if part.startswith(SKIP_PREFIXES):
            return True
    return False


def inert_name(src: Path) -> str:
    if src.suffix in RUNTIME_EXTENSIONS:
        return src.name + ".txt"
    return src.name


def copy_inert(src: Path, dst: Path) -> int:
    count = 0
    if not src.exists():
        return 0
    if src.is_file():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst / inert_name(src) if dst.is_dir() else dst)
        return 1
    for file in src.rglob("*"):
        if should_skip(file):
            continue
        rel = file.relative_to(src)
        out = dst / rel.parent / inert_name(file)
        if file.is_dir():
            out.mkdir(parents=True, exist_ok=True)
            continue
        out.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file, out)
        count += 1
    return count


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--old", required=True)
    parser.add_argument("--new", required=True)
    args = parser.parse_args()

    old = Path(args.old).expanduser().resolve()
    new = Path(args.new).expanduser().resolve()
    dest = new / "_ported_from_2d_raw"
    dest.mkdir(parents=True, exist_ok=True)

    total = 0
    lines = []
    lines.append("# Imported 2D Snapshot Index")
    lines.append("")
    lines.append(f"Generated: {datetime.now().isoformat(timespec='seconds')}")
    lines.append(f"Old repo: `{old}`")
    lines.append(f"New repo: `{new}`")
    lines.append("")
    lines.append("Runtime Godot files are renamed to `.txt` so they do not register global classes or parse inside the 3D project.")
    lines.append("")
    lines.append("## Imported paths")
    lines.append("")

    for rel_text in IMPORT_PATHS:
        src = old / rel_text
        dst = dest / rel_text
        if not src.exists():
            lines.append(f"- MISSING `{rel_text}`")
            continue
        if src.is_file():
            dst = dst.parent
        count = copy_inert(src, dst)
        total += count
        lines.append(f"- `{rel_text}` → {count} files")

    lines.append("")
    lines.append(f"Total copied files: **{total}**")
    lines.append("")
    lines.append("## Porting note")
    lines.append("")
    lines.append("Use these files as reference only. When porting a system, create a new 3D-safe script in active `scripts/` instead of renaming the old file in place.")

    (new / "docs" / "PORTED_2D_SNAPSHOT_INDEX.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Imported {total} old-project files inertly into {dest}")
    print(f"Wrote {new / 'docs' / 'PORTED_2D_SNAPSHOT_INDEX.md'}")


if __name__ == "__main__":
    main()
