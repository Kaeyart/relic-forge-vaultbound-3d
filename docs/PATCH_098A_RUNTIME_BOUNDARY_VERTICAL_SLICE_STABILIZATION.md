# 098A — Runtime Boundary + Vertical Slice Stabilization

## Purpose

The last two bugs came from the same architectural issue:

- loot presentation scanned its own labels/rings/beams as loot
- enemy readability/combat director scanned its own labels/badges as enemies

This patch creates a single detection boundary so visual/debug nodes stop becoming gameplay nodes.

## Adds

### `RuntimeDetectionSystem3D.gd`

Central runtime detection contract.

It owns:

- generated visual marking
- generated visual rejection
- real enemy detection
- real loot detection
- scene sanity report
- candidate collection helpers

### `VerticalSliceSmokeTestSystem3D.gd`

Lightweight report helper for the target slice:

`hub → map → combat → loot → return hub → improve character → next map`

### `VerticalSliceDebugOverlay3D.gd`

Optional F3 overlay.

Shows mode, panel mode, active map, selected skill, real enemy count, real loot count, generated visual count, and warnings.

## Design rule

From now on:

- gameplay nodes need gameplay signals: group, metadata, script method, or runtime properties
- generated visual nodes set `rv_generated_visual`
- scanners ignore `rv_generated_visual`
- name-only detection is only a weak fallback with runtime properties
