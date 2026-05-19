# 090F — Stash Mandatory Tabs + Persistence Repair

Mandatory built-in tabs are always restored and are never bought: Currency, Maps, Gems, Crystals, and Uniques.

The player only buys normal item tabs. If the player buys while viewing Affinity, the tab is moved to Custom. Existing broken player tabs under Affinity are migrated to Custom.

This patch also wraps `GameState3D.to_save_dict()` and `GameState3D.apply_save_dict()` so stash tabs and contents persist.
