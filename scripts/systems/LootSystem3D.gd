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
	var gold_min: int = 2 + level
	var gold_max: int = 6 + level * 3
	if elite:
		gold_max += 12
	if boss:
		gold_max += 40
	drops.append({"kind": "gold", "amount": rng.randi_range(gold_min, gold_max)})
	var gear_chance: float = 0.18
	if elite:
		gear_chance = 0.62
	if boss:
		gear_chance = 1.0
	if rng.randf() < gear_chance:
		var bias: float = 0.08 if elite else 0.0
		if boss:
			bias = 0.22
		drops.append({"kind": "item", "item": ItemDBScript.make_random_drop(level, rng, bias)})
	if rng.randf() < (0.12 if elite else 0.04) or boss:
		drops.append({"kind": "material", "id": "embers", "amount": rng.randi_range(1, 2 + (2 if boss else 0))})
	if boss and rng.randf() < 0.75:
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
