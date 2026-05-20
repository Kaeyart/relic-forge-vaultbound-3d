# 097B — Mega Repo Health + Runtime Integration Cleanup

## Purpose

The repo has survived aggressive patching. Now it needs hardening before more large gameplay features.

## Adds

### `scripts/core/RuntimeLayerManager3D.gd`

A central runtime layer manager that can ensure these layers exist if their scripts are present:

- `VisualFoundationLayer096A`
- `HubGreyboxPass096B`
- `CombatArenaGreyboxPass096C`
- `SkillVFXLayer096D`
- `EnemyReadabilityLayer096E`
- `LootPresentationLayer096F`
- `CombatFeedbackLayer096G`
- `CombatDirectorLayer097A` if 097A has been installed

It avoids duplicate spawning by checking node names first.

### `tools/deep_validate_3d_project.py`

A stronger repo validator. It checks:

- expected folders
- `project.godot`
- main scene existence
- missing `preload()` / `load()` paths
- missing `.tscn` ext_resource paths
- duplicate `class_name`
- suspicious multiple `extends`
- tracked backup/debris files
- `.gitignore` hygiene
- RuntimeLayerManager integration

### `tools/health_report_097b.sh`

Runs a full local health pass.

### `tools/cleanup_tracked_backups_097b.sh`

Dry-run helper for tracked backups. Use with `--apply` only after reviewing output.

## Safe migration

This patch does not remove old `_rf_096x_ensure_*` functions yet. The manager is installed first. Once validation is clean, the next hardening step can remove old duplicated ensure functions safely.
