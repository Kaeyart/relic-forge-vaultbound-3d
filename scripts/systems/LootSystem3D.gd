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

	var active_ids: Array[String] = [
		"fireball",
		"ember_mine",
		"storm_lance",
		"chain_spark",
		"arc_slash",
		"void_rift",
		"blood_cleave",
		"bone_spear",
		"ash_nova",
		"shield_burst",
		"infernal_step",
		"furnace_totem",
	]

	var support_ids: Array[String] = [
		"split_projectile",
		"chain_current",
		"ignition",
		"focused_area",
		"wild_spread",
		"spell_echo",
		"molten_catalyst",
		"arcane_dampener",
		"chained_fury",
		"burning_focus",
		"brutality",
		"bloodletting",
	]

	var spirit_ids: Array[String] = [
		"clarity",
		"vitality",
		"iron_skin",
		"ember_pact",
		"storm_rhythm",
		"void_tithe",
		"revenant_guard",
		"execution_focus",
	]

	var gem_level: int = 1
	if boss:
		gem_level = 3
	else:
		gem_level = 1

	if boss and roll < 0.30:
		var id: String = active_ids[rng.randi_range(0, active_ids.size() - 1)]
		return _make_uncut_gem_drop("active", id, gem_level)

	if roll < 0.72:
		var sid: String = support_ids[rng.randi_range(0, support_ids.size() - 1)]
		return _make_uncut_gem_drop("support", sid, gem_level)

	var spid: String = spirit_ids[rng.randi_range(0, spirit_ids.size() - 1)]
	return _make_uncut_gem_drop("spirit", spid, gem_level)


static func apply_drop_to_state(state: Object, drop: Dictionary) -> void:
	if state == null or drop.is_empty():
		return

	var kind: String = str(drop.get("kind", ""))

	match kind:
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

		"active_gem", "support_gem", "spirit_gem", "uncut_skill_gem", "uncut_support_gem", "uncut_spirit_gem":
			var gem_item: Dictionary = _drop_to_uncut_gem_item(drop)
			if not gem_item.is_empty():
				state.call("add_backpack_item", gem_item)
				if state.has_method("add_notice"):
					state.call("add_notice", "Picked up " + str(gem_item.get("display_name", "Uncut Gem")))

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

static func _make_uncut_gem_drop(gem_type: String, suggested_gem_id: String, gem_level: int = 1) -> Dictionary:
	var kind: String = "uncut_skill_gem"
	var display_type: String = "Uncut Skill Gem"

	match gem_type:
		"active", "skill":
			kind = "uncut_skill_gem"
			display_type = "Uncut Skill Gem"
		"support":
			kind = "uncut_support_gem"
			display_type = "Uncut Support Gem"
		"spirit":
			kind = "uncut_spirit_gem"
			display_type = "Uncut Spirit Gem"

	return {
		"kind": kind,
		"item_kind": kind,
		"category": "gem",
		"gem_id": suggested_gem_id,
		"gem_level": maxi(1, gem_level),
		"level": maxi(1, gem_level),
		"label": display_type + " Lv. " + str(maxi(1, gem_level)),
		"auto_pickup": false,
		"rarity": "gem",
	}


static func _drop_to_uncut_gem_item(drop: Dictionary) -> Dictionary:
	var source_kind: String = str(drop.get("kind", ""))
	var gem_id: String = str(drop.get("gem_id", ""))
	var gem_level: int = maxi(1, int(drop.get("gem_level", drop.get("level", 1))))

	var kind: String = "uncut_skill_gem"
	var display_type: String = "Uncut Skill Gem"
	var can_create: String = "active"

	match source_kind:
		"active_gem", "skill_gem", "uncut_skill_gem", "uncut_active_gem":
			kind = "uncut_skill_gem"
			display_type = "Uncut Skill Gem"
			can_create = "active"
		"support_gem", "uncut_support_gem":
			kind = "uncut_support_gem"
			display_type = "Uncut Support Gem"
			can_create = "support"
		"spirit_gem", "uncut_spirit_gem":
			kind = "uncut_spirit_gem"
			display_type = "Uncut Spirit Gem"
			can_create = "spirit"
		_:
			if source_kind.find("support") >= 0:
				kind = "uncut_support_gem"
				display_type = "Uncut Support Gem"
				can_create = "support"
			elif source_kind.find("spirit") >= 0:
				kind = "uncut_spirit_gem"
				display_type = "Uncut Spirit Gem"
				can_create = "spirit"

	var uid: String = str(drop.get("uid", ""))
	if uid == "":
		uid = kind + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000)

	return {
		"uid": uid,
		"id": uid,
		"kind": kind,
		"item_kind": kind,
		"category": "gem",
		"slot": "",
		"rarity": "gem",
		"gem_id": gem_id,
		"gem_level": gem_level,
		"gem_tier": gem_level,
		"level": gem_level,
		"can_create": can_create,
		"display_name": display_type + " Lv. " + str(gem_level),
		"name": display_type + " Lv. " + str(gem_level),
		"label": display_type + " Lv. " + str(gem_level),
		"description": "Use at the Gem Bench to carve this into a " + can_create + " gem.",
		"identified": true,
		"new_item": true,
		"favorite": false,
		"locked": false,
		"grid_w": 1,
		"grid_h": 1,
	}
