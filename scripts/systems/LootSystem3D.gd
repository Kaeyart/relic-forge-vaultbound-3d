class_name RVLootSystem3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const MapDBScript := preload("res://scripts/data/MapDB3D.gd")
const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

static func enemy_drop_bundle(state: Object, enemy_level: int, elite: bool, boss: bool) -> Array[Dictionary]:
	var rng: RandomNumberGenerator = _rng(state)
	var out: Array[Dictionary] = []
	var gold_amount: int = rng.randi_range(3, 8) + enemy_level * 2
	if elite:
		gold_amount *= 2
	if boss:
		gold_amount *= 5
	out.append({"kind": "gold", "amount": gold_amount, "label": "Gold x" + str(gold_amount), "auto_pickup": true, "rarity": "currency"})
	if rng.randf() < (0.24 if not boss else 1.0):
		var mat_amount: int = rng.randi_range(1, 3) if not boss else rng.randi_range(5, 10)
		out.append({"kind": "material", "material_id": "embers", "amount": mat_amount, "label": "Embers x" + str(mat_amount), "auto_pickup": true, "rarity": "currency"})
	var item_chance: float = 0.13
	if elite:
		item_chance = 0.50
	if boss:
		item_chance = 1.0
	if rng.randf() < item_chance:
		out.append({"kind": "item", "item": ItemDBScript.random_equipment_drop(enemy_level, rng, boss), "auto_pickup": false, "rarity": "gear"})
	var gem_chance: float = 0.045
	if elite:
		gem_chance = 0.18
	if boss:
		gem_chance = 1.0
	if rng.randf() < gem_chance:
		out.append(_random_gem_drop(rng, boss))
	if boss or rng.randf() < (0.08 if elite else 0.025):
		out.append({"kind": "map", "map": MapDBScript.make_map_item("ash_vault", max(1, int(enemy_level / 3) + 1), rng), "auto_pickup": false, "rarity": "map"})
	return out

static func boss_reward_bundle(state: Object, map_level: int) -> Array[Dictionary]:
	var rng: RandomNumberGenerator = _rng(state)
	var out: Array[Dictionary] = []
	for i: int in range(2):
		out.append({"kind": "item", "item": ItemDBScript.random_equipment_drop(map_level + i, rng, true), "auto_pickup": false, "rarity": "gear"})
	out.append({"kind": "material", "material_id": "shards", "amount": rng.randi_range(4, 8), "label": "Shards", "auto_pickup": true, "rarity": "currency"})
	out.append(_random_gem_drop(rng, true))
	out.append({"kind": "map", "map": MapDBScript.make_map_item("chain_crossing", max(1, int(map_level / 3) + 1), rng), "auto_pickup": false, "rarity": "map"})
	return out

static func _random_gem_drop(rng: RandomNumberGenerator, boss: bool) -> Dictionary:
	var roll: float = rng.randf()
	if boss and roll < 0.30:
		var active_keys: Array = SkillGemSystemScript.ACTIVE_ORDER
		var id: String = str(active_keys[rng.randi_range(0, active_keys.size() - 1)])
		return {"kind": "active_gem", "gem_id": id, "label": "Active Gem: " + str(SkillGemSystemScript.active_data(id).get("name", id)), "auto_pickup": false, "rarity": "gem"}
	if roll < 0.72:
		var support_keys: Array = SkillGemSystemScript.SUPPORT_ORDER
		var sid: String = str(support_keys[rng.randi_range(0, support_keys.size() - 1)])
		return {"kind": "support_gem", "gem_id": sid, "label": "Support Gem: " + str(SkillGemSystemScript.support_data(sid).get("name", sid)), "auto_pickup": false, "rarity": "gem"}
	var spirit_keys: Array = SkillGemSystemScript.SPIRIT_ORDER
	var spid: String = str(spirit_keys[rng.randi_range(0, spirit_keys.size() - 1)])
	return {"kind": "spirit_gem", "gem_id": spid, "label": "Spirit Gem: " + str(SkillGemSystemScript.spirit_data(spid).get("name", spid)), "auto_pickup": false, "rarity": "gem"}

static func apply_drop_to_state(state: Object, drop: Dictionary) -> void:
	if state == null or drop.is_empty():
		return
	match str(drop.get("kind", "")):
		"gold":
			state.set("gold", int(state.get("gold")) + int(drop.get("amount", 0)))
		"material":
			state.call("add_material", str(drop.get("material_id", "embers")), int(drop.get("amount", 1)))
		"item":
			state.call("add_backpack_item", Dictionary(drop.get("item", {})))
		"map":
			var map_item: Dictionary = Dictionary(drop.get("map", {}))
			map_item["kind"] = "map"
			map_item["item_kind"] = "map"
			map_item["category"] = "map"
			map_item["slot"] = "map"
			if not map_item.has("rarity"):
				map_item["rarity"] = "magic" if Array(map_item.get("mods", [])).size() > 0 else "normal"
			map_item["tags"] = Array(map_item.get("tags", []))
			if not Array(map_item["tags"]).has("map"):
				map_item["tags"].append("map")
			state.call("add_backpack_item", map_item)
			if state.has_method("add_notice"):
				state.call("add_notice", "Picked up map: " + str(map_item.get("display_name", "Map")))
		"active_gem", "support_gem", "spirit_gem":
			var gem_item: Dictionary = SkillGemSystemScript.make_gem_item_from_drop(str(drop.get("kind", "")), str(drop.get("gem_id", "")))
			state.call("add_backpack_item", gem_item)
			if state.has_method("add_notice"):
				state.call("add_notice", "Picked up " + str(gem_item.get("display_name", "Gem")))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")

static func label_for_drop(drop: Dictionary) -> String:
	match str(drop.get("kind", "")):
		"item":
			return str(Dictionary(drop.get("item", {})).get("display_name", "Item"))
		"map":
			return str(Dictionary(drop.get("map", {})).get("display_name", "Map"))
		"active_gem":
			return "Active Gem: " + str(SkillGemSystemScript.active_data(str(drop.get("gem_id", ""))).get("name", drop.get("gem_id", "")))
		"support_gem":
			return "Support Gem: " + str(SkillGemSystemScript.support_data(str(drop.get("gem_id", ""))).get("name", drop.get("gem_id", "")))
		"spirit_gem":
			return "Spirit Gem: " + str(SkillGemSystemScript.spirit_data(str(drop.get("gem_id", ""))).get("name", drop.get("gem_id", "")))
		_:
			return str(drop.get("label", "Loot"))

static func _rng(state: Object) -> RandomNumberGenerator:
	if state != null:
		var value: Variant = state.get("rng")
		if value is RandomNumberGenerator:
			return value as RandomNumberGenerator
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng
