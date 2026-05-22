# Patch 33 — Class, Ascendancy, Passive Tree Skeleton

Adds the first progression skeleton for:
- 3 classes: Sorceress, Warrior, Huntress
- 9 ascendancies: 3 per class
- character passive tree data/systems/UI
- ascendancy tree data/systems/UI
- stat/rule aggregation into GameState recompute_stats
- save/load fields for class/ascendancy/passive progression
- global UI access for Passive Tree and Ascendancy

Controls:
- I Inventory
- K Skill Gems
- P Passive Tree
- O Ascendancy

Demo behavior:
- New/fresh saves get at least 3 passive points for testing.
- Ascendancy choice is locked once selected, but nodes can be refunded.
- Class can be switched from the Passive Tree screen for prototype testing.
- Later, class switching should be removed and replaced with a true new-character flow.

This patch intentionally does not add the Atlas passive tree. That should remain its own patch.
