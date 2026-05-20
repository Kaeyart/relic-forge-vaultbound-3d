# 099A — Milestone 0.1 Playable Slice Consolidation

## Purpose

The project has enough horizontal systems. This patch consolidates the playable slice.

It adds:

- feature flags
- a safer runtime layer manager
- a game flow director
- a milestone checklist reporter

## Why

Recent bugs came from runtime layers overlapping and scanning too broadly. Even after fixing detection, the project needs a way to disable optional layers without deleting them.

## Adds

### RuntimeFeatureFlags3D.gd

Central feature flags.

Flags can be stored in:

```gdscript
state.runtime_feature_flags
```

The layer manager reads these flags and skips or hides disabled layers.

### RuntimeLayerManager3D.gd

Replaced with a clean manager.

It supports:

- feature flags
- disabled layers
- optional missing layers
- duplicate removal
- bind_game
- visible/process toggling

### GameFlowDirector3D.gd

Runtime layer for the milestone slice.

Hotkeys:

- `F4`: force hub
- `F5`: start Ash Vault test map
- `F6`: print slice checklist

### SliceChecklistSystem3D.gd

Creates a compact report for the target loop.

It checks:

- mode
- panel mode
- active map
- real enemy count
- real loot count
- generated visual count
- obvious warnings

## Important

This is a consolidation patch. It deliberately avoids new itemization, enemy types, map mods, or UI feature depth.
