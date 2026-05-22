# Patch 32 — Item Combat Integration and Validation

This patch stops items from being mostly tooltip text and wires them into gameplay.

Adds:
- `ItemCombatIntegrationSystem3D.gd`
  - canonical stat aliases
  - item stats applied to skill damage/cost/cooldown/projectiles/chain/area/status chance
  - relic rule hooks for Fireball, Storm Lance, Void Rift, melee trigger, bleed explosion hooks
  - player damage mitigation from armor, block, resist/reduction, Ward / Runic Ward
  - requirement checks for equipping items
  - item build-impact text helpers
- `ItemValidationSystem3D.gd`
  - item shape validator
  - duplicate UID checks
  - prefix/suffix cap checks
  - affix group warnings
  - socket limit checks
  - runtime report text and F9 smoke-test hook

Patches:
- `SkillGemSystem3D.gd`: selected cast data is enhanced by equipped item stats and relic rules.
- `CombatArena3D.gd`: player damage taken and skill damage to enemies use item runtime hooks.
- `GameState3D.gd`: runtime defaults, Ward fields, equip requirement checks.
- `GameRoot3D.gd`: F9 item validation smoke test.
- `LootActor3D.gd`: loot filter labels/colors drive ground loot presentation.
- Inventory/Forge panels: display runtime/build/validation details.

Acceptance target:
- Fire/Lightning/Void/Spell/Attack/Projectile/Area stats alter selected skill behavior.
- Defensive item stats reduce incoming damage.
- Runic Ward can absorb emergency damage.
- Relic rules cause visible gameplay modifiers, not just text.
- Invalid items cannot be equipped.
- F9 reports item runtime validation.
