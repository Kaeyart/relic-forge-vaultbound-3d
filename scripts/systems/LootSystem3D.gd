class_name RVLootSystem3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")

static func roll_enemy_loot(state: Object, enemy_data: Dictionary, map_item: Dictionary) -> Array[Dictionary]:
	var drops: Array[Dictionary] = []
	if state == null:
		return drops
	var rng: RandomNumberGenerator = state.get("rng")
	var level: int = max(1, int(map_item.get("level", state.get("level"))))
	var elite: bool = bool(enemy_data.get("elite", false))
	var boss: bool = bool(enemy_data.get("boss", false))
	var preferred_tags: Array = _preferred_drop_tags_for_state(state)

	var gold_min: int = 2 + level
	var gold_max: int = 6 + level * 3
	if elite:
		gold_min += 3
		gold_max += 14
	if boss:
		gold_min += 15
		gold_max += 55
	drops.append({"kind": "gold", "amount": rng.randi_range(gold_min, gold_max)})

	var gear_rolls: int = 0
	var gear_chance: float = 0.20
	var rarity_bias: float = 0.0
	if elite:
		gear_chance = 0.72
		rarity_bias = 0.10
	if boss:
		gear_chance = 1.0
		gear_rolls = 2
		rarity_bias = 0.24
	if rng.randf() < gear_chance:
		gear_rolls += 1
	for i: int in range(gear_rolls):
		var use_preferred: Array = preferred_tags if rng.randf() < 0.55 else []
		drops.append({"kind": "item", "item": ItemDBScript.make_random_drop(level, rng, rarity_bias, use_preferred)})

	var material_chance: float = 0.05
	if elite:
		material_chance = 0.18
	if boss:
		material_chance = 1.0
	if rng.randf() < material_chance:
		drops.append({"kind": "material", "id": "embers", "amount": rng.randi_range(1, 2 + (3 if boss else 0))})
	if boss or rng.randf() < (0.08 if elite else 0.015):
		drops.append({"kind": "material", "id": "shards", "amount": rng.randi_range(1, 1 + (2 if boss else 0))})
	if boss and rng.randf() < 0.35:
		drops.append({"kind": "material", "id": "runes", "amount": 1})

	if boss and rng.randf() < 0.78:
		drops.append({"kind": "map", "map": {"id": "ash_vault_t" + str(level + 1), "name": "Ash Vault", "tier": level + 1, "level": level + 1, "rarity": "normal", "mods": []}})
	return drops

static func apply_pickup(state: Object, drop: Dictionary) -> void:
	if state == null or drop.is_empty():
		return
	match str(drop.get("kind", "")):
		"gold":
			state.call("add_gold", int(drop.get("amount", 0)))
		"material":
			state.call("add_material", str(drop.get("id", "embers")), int(drop.get("amount", 1)))
		"item":
			state.call("add_item", Dictionary(drop.get("item", {})))
		"map":
			var stash: Array = Array(state.get("map_stash"))
			stash.append(Dictionary(drop.get("map", {})))
			state.set("map_stash", stash)
			state.set("last_loot_text", "+ map: " + str(Dictionary(drop.get("map", {})).get("name", "Map")))

static func _preferred_drop_tags_for_state(state: Object) -> Array:
	var class_id: String = str(state.get("character_class_id"))
	match class_id:
		"sorceress": return ["spell", "caster", "fire", "lightning", "mana"]
		"warden": return ["attack", "melee", "life", "armor", "defense"]
		"voidbinder": return ["spell", "void", "mana", "caster"]
		"machinist": return ["projectile", "cooldown", "device", "damage"]
		_: return []
