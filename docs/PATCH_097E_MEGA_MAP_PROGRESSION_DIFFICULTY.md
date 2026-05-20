# 097E — Mega Map Progression + Difficulty Integration

## Goal

Maps now become the spine of the run loop.

`Map item → tier/rarity/modifiers → enemy density/risk → reward quantity/rarity → completion/bonus completion`

## Map rules

Tier 1–5:
- completion: clear the map
- bonus: clear the map

Tier 6–9:
- completion: clear the map
- bonus: clear a magic or rare map

Tier 10–15:
- completion: clear the map
- bonus: clear a rare map

## Map rarity

Normal:
- no modifiers
- baseline reward

Magic:
- 1–2 modifiers
- more enemy pressure
- better reward

Rare:
- 4–6 modifiers
- much harder
- much better reward

## Modifier examples

- Crowded: Pack Size and Item Quantity
- Commanded: Magic Pack Chance and Rare Monster Chance
- Giantblood: Monster Life
- Murderous: Monster Damage
- Fast Hordes: Monster Speed
- No Slows: Enemies Cannot Be Slowed
- Crit Resistant: Enemies Resist Crits
- Gemveined: Gem Drop Chance
- Cartographer Mark: Map Drop Chance
- Crystallized: Crystal Drop Chance
