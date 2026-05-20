# 097G — Mega UI/UX Polish Pass

## Purpose

The systems are now deeper: items, forge potential, maps, gems, stash, combat rewards, and skills all have more meaning.

The UI needs better navigation and feedback.

This patch improves the panel root without requiring final UI art.

## Adds

### `scripts/systems/UIUXSystem3D.gd`

Central panel UX helper.

It owns:

- panel order
- keyboard shortcut mapping
- footer/action text
- panel summaries
- panel mode labels
- next/previous panel selection

### `scripts/systems/UIStateSummarySystem3D.gd`

State summarizer.

It provides concise status text for:

- inventory
- stash
- forge
- skill gems
- maps
- character

## Patches

### `scripts/ui/UIPanelRoot3D.gd`

Adds:

- `UIUXSystemScript` preload
- bottom action bar
- panel-specific summary text
- keyboard shortcut routing:
  - `I` inventory
  - `B` stash
  - `F` forge
  - `G` skills
  - `M` maps
  - `C` character
  - `Tab` next panel
  - `Shift + Tab` previous panel
  - `Esc` close
- action bar refresh when mode/state changes

## UX target

Panels should stop feeling like isolated debug screens.

The shell should communicate:

- where you are
- what you can do
- what matters in the current panel
- how to move between panels quickly

## Safety

This is compatibility-first. It does not delete existing panel scripts. It augments `UIPanelRoot3D.gd` and leaves individual panels intact.
