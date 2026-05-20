#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path
from typing import Iterable

RESOURCE_RE = re.compile(r"(?:preload|load)\(\s*[\"'](res://[^\"']+)[\"']\s*\)")
EXT_RESOURCE_RE = re.compile(r"path=[\"'](res://[^\"']+)[\"']")
CLASS_RE = re.compile(r"^\s*class_name\s+([A-Za-z_][A-Za-z0-9_]*)\s*$", re.M)
EXTENDS_RE = re.compile(r"^\s*extends\s+.+$", re.M)

EXPECTED_DIRS = (
    "scenes",
    "scripts",
    "scripts/core",
    "scripts/systems",
    "scripts/visual",
    "scripts/loot",
    "tools",
    "docs",
)

BACKUP_PATTERNS = (".bak", ".bak_", ".orig", ".tmp", ".rej")


def run(cmd: list[str], cwd: Path) -> tuple[int, str, str]:
    try:
        p = subprocess.run(cmd, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
        return p.returncode, p.stdout, p.stderr
    except Exception as exc:
        return 999, "", str(exc)


def res_to_path(root: Path, res_path: str) -> Path:
    return root / res_path.replace("res://", "", 1)


def iter_files(root: Path, suffixes: tuple[str, ...]) -> Iterable[Path]:
    skip_dirs = {".git", ".godot", ".import", "__pycache__"}
    for path in root.rglob("*"):
        if any(part in skip_dirs for part in path.parts):
            continue
        if path.is_file() and path.suffix in suffixes:
            yield path


def git_tracked(root: Path) -> list[str]:
    code, out, _err = run(["git", "ls-files"], root)
    if code != 0:
        return []
    return [line.strip() for line in out.splitlines() if line.strip()]


def parse_project_main_scene(root: Path) -> str | None:
    project = root / "project.godot"
    if not project.exists():
        return None
    text = project.read_text(encoding="utf-8", errors="replace")
    match = re.search(r"run/main_scene\s*=\s*[\"']([^\"']+)[\"']", text)
    if not match:
        return None
    return match.group(1)


def check_expected_dirs(root: Path, errors: list[str], warnings: list[str]) -> None:
    for rel in EXPECTED_DIRS:
        if not (root / rel).exists():
            errors.append(f"Missing expected directory: {rel}")


def check_main_scene(root: Path, errors: list[str], warnings: list[str]) -> None:
    if not (root / "project.godot").exists():
        errors.append("Missing project.godot")
        return

    main_scene = parse_project_main_scene(root)
    if not main_scene:
        errors.append("project.godot does not define run/main_scene")
        return

    path = res_to_path(root, main_scene)
    if not path.exists():
        errors.append(f"Main scene does not exist: {main_scene}")
    else:
        warnings.append(f"Main scene: {main_scene}")


def check_gd_resources(root: Path, errors: list[str], warnings: list[str]) -> None:
    for gd in iter_files(root, (".gd",)):
        text = gd.read_text(encoding="utf-8", errors="replace")
        rel = gd.relative_to(root).as_posix()
        for match in RESOURCE_RE.finditer(text):
            res = match.group(1)
            if not res_to_path(root, res).exists():
                errors.append(f"Missing script resource in {rel}: {res}")


def check_scene_resources(root: Path, errors: list[str], warnings: list[str]) -> None:
    for scene in iter_files(root, (".tscn", ".tres")):
        text = scene.read_text(encoding="utf-8", errors="replace")
        rel = scene.relative_to(root).as_posix()
        for match in EXT_RESOURCE_RE.finditer(text):
            res = match.group(1)
            if not res_to_path(root, res).exists():
                errors.append(f"Missing scene resource in {rel}: {res}")


def check_class_names(root: Path, errors: list[str], warnings: list[str]) -> None:
    classes: dict[str, list[str]] = {}
    for gd in iter_files(root, (".gd",)):
        text = gd.read_text(encoding="utf-8", errors="replace")
        rel = gd.relative_to(root).as_posix()

        class_matches = CLASS_RE.findall(text)
        if len(class_matches) > 1:
            errors.append(f"Multiple class_name declarations in {rel}: {class_matches}")
        for cls in class_matches:
            classes.setdefault(cls, []).append(rel)

        extends_matches = EXTENDS_RE.findall(text)
        if len(extends_matches) > 1:
            warnings.append(f"Suspicious multiple extends in {rel}: {len(extends_matches)}")

    for cls, files in sorted(classes.items()):
        if len(files) > 1:
            errors.append(f"Duplicate global class_name {cls}: {files}")


def check_tracked_backups(root: Path, errors: list[str], warnings: list[str]) -> None:
    tracked = git_tracked(root)
    if not tracked:
        warnings.append("Could not inspect tracked files with git ls-files.")
        return

    backups = []
    for rel in tracked:
        name = Path(rel).name
        if any(pattern in name for pattern in BACKUP_PATTERNS):
            backups.append(rel)

    if backups:
        warnings.append(f"Tracked backup/debris files: {len(backups)}")
        for rel in backups[:40]:
            warnings.append(f"  tracked backup: {rel}")
        if len(backups) > 40:
            warnings.append(f"  ... plus {len(backups) - 40} more")


def check_gitignore(root: Path, errors: list[str], warnings: list[str]) -> None:
    gitignore = root / ".gitignore"
    if not gitignore.exists():
        warnings.append("Missing .gitignore")
        return
    text = gitignore.read_text(encoding="utf-8", errors="replace")
    for pattern in ["*.bak_*", "*.orig", "*.tmp", "*.rej", "__pycache__/"]:
        if pattern not in text:
            warnings.append(f".gitignore missing recommended pattern: {pattern}")


def check_runtime_layers(root: Path, errors: list[str], warnings: list[str]) -> None:
    manager = root / "scripts/core/RuntimeLayerManager3D.gd"
    if not manager.exists():
        errors.append("Missing scripts/core/RuntimeLayerManager3D.gd")
        return

    game = root / "scripts/core/GameRoot3D.gd"
    if not game.exists():
        errors.append("Missing scripts/core/GameRoot3D.gd")
        return

    text = game.read_text(encoding="utf-8", errors="replace")
    if "RuntimeLayerManagerScript" not in text:
        errors.append("GameRoot3D.gd missing RuntimeLayerManagerScript preload")
    if "_rf_097b_ensure_runtime_layer_manager" not in text:
        errors.append("GameRoot3D.gd missing _rf_097b_ensure_runtime_layer_manager")
    if "RuntimeLayerManager097B" not in text:
        errors.append("GameRoot3D.gd missing RuntimeLayerManager097B node name")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".", help="Project root")
    parser.add_argument("--json", action="store_true", help="Print JSON")
    args = parser.parse_args()

    root = Path(args.root).expanduser().resolve()
    errors: list[str] = []
    warnings: list[str] = []

    if not root.exists():
        print(f"ERROR: root does not exist: {root}")
        return 2

    check_expected_dirs(root, errors, warnings)
    check_main_scene(root, errors, warnings)
    check_gd_resources(root, errors, warnings)
    check_scene_resources(root, errors, warnings)
    check_class_names(root, errors, warnings)
    check_tracked_backups(root, errors, warnings)
    check_gitignore(root, errors, warnings)
    check_runtime_layers(root, errors, warnings)

    result = {
        "root": str(root),
        "status": "fail" if errors else "pass",
        "errors": errors,
        "warnings": warnings,
        "error_count": len(errors),
        "warning_count": len(warnings),
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print("Relic Forge 3D deep validation")
        print("--------------------------------")
        print(f"Root: {root}")
        print(f"Status: {result['status'].upper()}")
        print(f"Errors: {len(errors)}")
        for item in errors:
            print(f"ERROR: {item}")
        print(f"Warnings: {len(warnings)}")
        for item in warnings:
            print(f"WARN: {item}")

    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
