# 098C — Hub Station Whitebox Pass

## Purpose

The game loop needs the hub to become a place, not a list of global hotkeys.

This patch adds a physical whitebox hub layer with readable stations:

- Map Device
- Stash
- Forge
- Skill Altar
- Character Mirror

The art is intentionally plain. The important thing is interaction structure.

## Player flow

1. Return to hub.
2. Walk to a station.
3. See interaction prompt.
4. Press `E`.
5. Correct panel opens.

## Design target

The hub should communicate the run loop spatially:

- Map Device = start/continue runs
- Stash = long-term storage
- Forge = improve gear
- Skill Altar = manage active/support/spirit gems
- Character Mirror = inspect build

## Safety

This patch is runtime-layer based.

It does not delete existing UI shortcuts yet. It adds the physical station interaction path first. Once this is stable, the next patch can make global panel hotkeys respect station proximity.
