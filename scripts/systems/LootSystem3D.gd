class_name RVLootSystem3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const MapDBScript := preload("res://scripts/data/MapDB3D.gd")
const GemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")
const GemProgressionSystemScript := preload("res://scripts/systems/GemProgressionSystem3D.gd")

static func enemy_drop_bundle(state: Object, enemy_level: int, elite: bool, boss: bool) -> Array[Dictionary]:
	var rng: RandomNumberGenerator = state.get("rng") if state != null else RandomNumberGenerator.new()
	var out: Array[Dictionary] = []
	var gold_amount: int = rng.randi_range(3, 8) + enemy_level * 2
	if elite: gold_amount *= 2
	if boss: gold_amount *= 5
	out.append({"kind":"gold", "amount":gold_amount, "label":"Gold x" + str(gold_amount), "auto_pickup":true, "rarity":"currency"})
	if rng.randf() < (0.22 if not boss else 1.0):
		var mat_amount: int = rng.randi_range(1, 3) if not boss else rng.randi_range(5, 10)
		out.append({"kind":"material", "material_id":"embers", "amount":mat_amount, "label":"Embers x" + str(mat_amount), "auto_pickup":true, "rarity":"currency"})
	var item_chance: float = 0.12
	if elite: item_chance = 0.48
	if boss: item_chance = 1.0
	if rng.randf() < item_chance:
		out.append({"kind":"item", "item":ItemDBScript.random_equipment_drop(enemy_level, rng, boss), "auto_pickup":false, "rarity":"gear"})
	if boss or (elite and rng.randf() < 0.20) or rng.randf() < 0.04:
		out.append(_random_gem_drop(rng, boss))
	if boss or rng.randf() < (0.08 if elite else 0.025):
		out.append({"kind":"map", "map":MapDBScript.make_map_item("ash_vault", max(1, int(enemy_level / 3) + 1), rng), "auto_pickup":false, "rarity":"map"})
	return out

static func boss_reward_bundle(state: Object, map_level: int) -> Array[Dictionary]:
	var rng: RandomNumberGenerator = state.get("rng") if state != null else RandomNumberGenerator.new()
	var out: Array[Dictionary] = []
	for i: int in range(2):
		out.append({"kind":"item", "item":ItemDBScript.random_equipment_drop(map_level + i, rng, true), "auto_pickup":false, "rarity":"gear"})
	out.append({"kind":"material", "material_id":"shards", "amount":rng.randi_range(4, 8), "label":"Shards", "auto_pickup":true, "rarity":"currency"})
	out.append(_random_gem_drop(rng, true))
	out.append({"kind":"map", "map":MapDBScript.make_map_item("chain_crossing", max(1, int(map_level / 3) + 1), rng), "auto_pickup":false, "rarity":"map"})
	return out

static func _random_gem_drop(rng: RandomNumberGenerator, boss: bool) -> Dictionary:
	var roll: float = rng.randf()
	if boss and roll < 0.25:
		var active_keys: Array = ["ember_mine", "void_rift", "arc_slash", "storm_lance"]
		var id: String = str(active_keys[rng.randi_range(0, active_keys.size() - 1)])
		return {"kind":"active_gem", "gem_id":id, "label":"Active Gem", "auto_pickup":false, "rarity":"gem"}
	if roll < 0.72:
		var support_keys: Array = ["controlled_power", "efficient_casting", "greater_area", "split_projectile", "chain_current", "ignition", "bleed_edge", "echoing_void"]
		var sid: String = str(support_keys[rng.randi_range(0, support_keys.size() - 1)])
		return {"kind":"support_gem", "gem_id":sid, "label":"Support Gem", "auto_pickup":false, "rarity":"gem"}
	var spirit_keys: Array = ["clarity", "vitality", "ember_pact", "storm_rhythm", "void_tithe", "iron_skin"]
	var spid: String = str(spirit_keys[rng.randi_range(0, spirit_keys.size() - 1)])
	return {"kind":"spirit_gem", "gem_id":spid, "label":"Spirit Gem", "auto_pickup":false, "rarity":"gem"}

static func apply_drop_to_state(state: Object, drop: Dictionary) -> void:
	if state == null or drop.is_empty(): return
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
			var gem_item: Dictionary = GemProgressionSystemScript.make_gem_item_from_drop(str(drop.get("kind", "")), str(drop.get("gem_id", "")))
			state.call("add_backpack_item", gem_item)
			if state.has_method("add_notice"):
				state.call("add_notice", "Picked up " + str(gem_item.get("display_name", "Gem")))
	state.call("recompute_stats")

static func label_for_drop(drop: Dictionary) -> String:
	match str(drop.get("kind", "")):
		"item": return str(Dictionary(drop.get("item", {})).get("display_name", "Item"))
		"map": return str(Dictionary(drop.get("map", {})).get("display_name", "Map"))
		"active_gem": return "Active Gem: " + str(drop.get("gem_id", ""))
		"support_gem": return "Support Gem: " + str(drop.get("gem_id", ""))
		"spirit_gem": return "Spirit Gem: " + str(drop.get("gem_id", ""))
		_: return str(drop.get("label", "Loot"))
