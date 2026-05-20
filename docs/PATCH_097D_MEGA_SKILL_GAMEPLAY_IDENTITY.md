# 097D — Mega Skill Gameplay Identity Pass

## Purpose

096D gave skills primitive visual identity. This patch gives the five starter active skills mechanical identity.

## Skill roles

### Fireball

Projectile skill.

- Fires a projectile.
- Supports extra projectiles.
- Has impact AoE.
- Can ignite through fire rules/spirit/supports.
- Quality and supports can scale projectile count and AoE.

### Storm Lance

Line skill.

- Hits in a long narrow line.
- Pierces packs.
- Chain Current increases reach/chain pressure.
- Applies shock metadata.

### Arc Slash

Close-range melee-caster skill.

- Cone/cleave in front of player.
- Faster, cheaper identity.
- Bleed Edge gives bleed pressure.

### Void Rift

Zone-control skill.

- Creates a duration zone.
- Ticks several times.
- Applies void slow metadata.
- Echoing Void creates extra delayed pulses.

### Ember Mine

Setup/burst skill.

- Places an armed mine.
- Mine arms after a short delay.
- Triggers when enemies enter the trigger radius.
- Explodes in an area.
- Fire rules can ignite.

## Progression

The patch grants gem XP on:

- cast
- hit
- kill

It uses `GemProgressionSystem3D.award_selected_skill_xp` if available.

## Safety

This patch is still compatibility-first.

It uses the existing `CombatArena3D.gd` enemy and projectile logic. It does not require a new projectile scene, enemy scene, or final VFX assets.
