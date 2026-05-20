extends RefCounted
class_name RVMapDifficultySystem3D

const RARITY_NORMAL: String = "normal"
const RARITY_MAGIC: String = "magic"
const RARITY_RARE: String = "rare"


static func normalize_map_item(map_item: Dictionary, state: Object = null) -> Dictionary:
	if map_item.is_empty():
		return {}

	var rng: RandomNumberGenerator = _rng(state)
	var out: Dictionary = map_item.duplicate(true)
	var tier: int = clampi(_to_int(out.get("tier", out.get("map_tier", 1)), 1), 1, 15)
	var rarity: String = _safe_rarity(str(out.get("rarity", "")))
	var mods: Array = _as_array(out.get("mods", []))

	if rarity == "":
		rarity = rarity_from_mods(mods)

	if rarity == RARITY_NORMAL:
		mods = []
	elif rarity == RARITY_MAGIC and mods.is_empty():
		mods = roll_mods_for_rarity(RARITY_MAGIC, tier, rng)
	elif rarity == RARITY_RARE and mods.size() < 4:
		mods = roll_mods_for_rarity(RARITY_RARE, tier, rng)

	out["tier"] = tier
	out["map_tier"] = tier
	out["map_level"] = max(1, _to_int(out.get("map_level", tier), tier))
	out["rarity"] = rarity
	out["mods"] = mods
	out["entries"] = max(0, _to_int(out.get("entries", 6), 6))
	out["kind"] = "map"
	out["item_kind"] = "map"
	out["category"] = "map"
	out["slot"] = "map"

	var tags: Array = _as_array(out.get("tags", []))
	if not tags.has("map"):
		tags.append("map")
	out["tags"] = tags

	out["item_quantity"] = item_quantity(out)
	out["item_rarity"] = item_rarity(out)
	out["completion_requirement"] = completion_requirement_text(out)
	out["bonus_requirement"] = bonus_requirement_text(out)
	return out


static func rarity_from_mods(mods: Array) -> String:
	if mods.size() >= 4:
		return RARITY_RARE
	if mods.size() >= 1:
		return RARITY_MAGIC
	return RARITY_NORMAL


static func map_modifier_pool(tier: int = 1) -> Array:
	var pool: Array = [
		{"id":"pack_size", "name":"Crowded", "stats":{"Pack Size":0.22, "Item Quantity":0.10}, "danger":1},
		{"id":"commanded", "name":"Commanded", "stats":{"Magic Pack Chance":0.18, "Rare Monster Chance":0.08, "Item Rarity":0.08}, "danger":1},
		{"id":"giantblood", "name":"Giantblood", "stats":{"Monster Life":0.28, "Item Quantity":0.12}, "danger":1},
		{"id":"murderous", "name":"Murderous", "stats":{"Monster Damage":0.22, "Item Rarity":0.12}, "danger":1},
		{"id":"fast_hordes", "name":"Fast Hordes", "stats":{"Monster Speed":0.18, "Pack Size":0.12}, "danger":1},
		{"id":"resistant", "name":"Resistant", "stats":{"Monster Resistance":0.22, "Item Quantity":0.08}, "danger":1},
		{"id":"no_slows", "name":"No Slows", "stats":{"Enemies Cannot Be Slowed":1.0, "Item Quantity":0.12}, "danger":2},
		{"id":"crit_resistant", "name":"Crit Resistant", "stats":{"Enemies Resist Crits":1.0, "Item Rarity":0.14}, "danger":2},
		{"id":"hoarded", "name":"Hoarded", "stats":{"Item Quantity":0.18, "Item Rarity":0.18}, "danger":1},
		{"id":"gemveined", "name":"Gemveined", "stats":{"Gem Drop Chance":0.18, "Item Quantity":0.06}, "danger":1},
		{"id":"cartographer_mark", "name":"Cartographer Mark", "stats":{"Map Drop Chance":0.22, "Item Quantity":0.06}, "danger":1},
		{"id":"crystallized", "name":"Crystallized", "stats":{"Crystal Drop Chance":0.20, "Item Rarity":0.08}, "danger":1}
	]
	if tier >= 10:
		pool.append({"id":"brutal_command", "name":"Brutal Command", "stats":{"Monster Life":0.22, "Monster Damage":0.18, "Rare Monster Chance":0.10, "Item Quantity":0.16}, "danger":3})
		pool.append({"id":"deadly_packs", "name":"Deadly Packs", "stats":{"Pack Size":0.18, "Magic Pack Chance":0.18, "Monster Damage":0.16, "Item Rarity":0.16}, "danger":3})
	return pool


static func roll_mods_for_rarity(rarity: String, tier: int, rng: RandomNumberGenerator) -> Array:
	var r: String = _safe_rarity(rarity)
	var count: int = 0
	if r == RARITY_MAGIC:
		count = rng.randi_range(1, 2)
	elif r == RARITY_RARE:
		count = rng.randi_range(4, 6)

	var pool: Array = map_modifier_pool(tier)
	pool.shuffle()

	var out: Array = []
	for value: Variant in pool:
		if out.size() >= count:
			break
		if typeof(value) == TYPE_DICTIONARY:
			out.append(Dictionary(value).duplicate(true))
	return out


static func active_map(state: Object, fallback: Dictionary = {}) -> Dictionary:
	if state != null:
		var activity: Variant = state.get("current_map_activity")
		if typeof(activity) == TYPE_DICTIONARY and not Dictionary(activity).is_empty():
			return normalize_map_item(Dictionary(activity), state)

		var active_item: Variant = state.get("active_map_item")
		if typeof(active_item) == TYPE_DICTIONARY and not Dictionary(active_item).is_empty():
			return normalize_map_item(Dictionary(active_item), state)

	return normalize_map_item(fallback, state)


static func active_tier(state: Object) -> int:
	var item: Dictionary = active_map(state)
	return clampi(_to_int(item.get("tier", 1), 1), 1, 15)


static func active_rarity(state: Object) -> String:
	var item: Dictionary = active_map(state)
	return _safe_rarity(str(item.get("rarity", RARITY_NORMAL)))


static func map_level(activity: Dictionary, state: Object = null) -> int:
	var item: Dictionary = active_map(state, activity)
	return max(1, _to_int(item.get("map_level", item.get("tier", 1)), 1))


static func stat_total(map_item: Dictionary, stat_name: String) -> float:
	var total: float = 0.0
	for value: Variant in _as_array(map_item.get("mods", [])):
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var mod: Dictionary = Dictionary(value)
		var stats: Dictionary = _as_dict(mod.get("stats", {}))
		total += _to_float(stats.get(stat_name, 0.0), 0.0)
	return total


static func item_quantity(map_item: Dictionary) -> float:
	return max(0.0, stat_total(map_item, "Item Quantity"))


static func item_rarity(map_item: Dictionary) -> float:
	return max(0.0, stat_total(map_item, "Item Rarity"))


static func pack_size_bonus(map_item: Dictionary) -> int:
	return int(round(stat_total(map_item, "Pack Size") * 10.0))


static func extra_pack_count(map_item: Dictionary) -> int:
	var tier: int = clampi(_to_int(map_item.get("tier", 1), 1), 1, 15)
	var rarity: String = _safe_rarity(str(map_item.get("rarity", RARITY_NORMAL)))
	var count: int = int(round(stat_total(map_item, "Pack Size") * 3.0))
	if rarity == RARITY_MAGIC:
		count += 1
	elif rarity == RARITY_RARE:
		count += 2
	if tier >= 10:
		count += 1
	return clampi(count, 0, 5)


static func threat_profile(state: Object, fallback: Dictionary = {}) -> Dictionary:
	var item: Dictionary = active_map(state, fallback)
	var tier: int = clampi(_to_int(item.get("tier", 1), 1), 1, 15)
	var rarity: String = _safe_rarity(str(item.get("rarity", RARITY_NORMAL)))

	var profile: Dictionary = {
		"tier": tier,
		"rarity": rarity,
		"band": "white" if tier < 6 else ("magic" if tier < 10 else "rare"),
		"magic_pack_chance": 0.36,
		"magic_pack_min": 2,
		"magic_pack_max": 5,
		"rare_chance": 0.18,
		"rare_max": 1,
		"rare_mod_count": 3 if tier < 6 else (4 if tier < 10 else 5),
		"normal_xp_mult": 1.0,
		"magic_xp_mult": 1.75,
		"rare_xp_mult": 4.0,
		"monster_life_mult": 1.0 + stat_total(item, "Monster Life"),
		"monster_damage_mult": 1.0 + stat_total(item, "Monster Damage"),
		"monster_speed_mult": 1.0 + stat_total(item, "Monster Speed"),
		"item_quantity": item_quantity(item),
		"item_rarity": item_rarity(item),
		"gem_drop_chance": stat_total(item, "Gem Drop Chance"),
		"map_drop_chance": stat_total(item, "Map Drop Chance"),
		"crystal_drop_chance": stat_total(item, "Crystal Drop Chance"),
		"enemies_cannot_be_slowed": stat_total(item, "Enemies Cannot Be Slowed") > 0.0,
		"enemies_resist_crits": stat_total(item, "Enemies Resist Crits") > 0.0
	}

	if tier >= 6:
		profile["magic_pack_chance"] = 0.50
		profile["rare_chance"] = 0.30
		profile["magic_pack_min"] = 3
		profile["magic_pack_max"] = 6
	if tier >= 10:
		profile["magic_pack_chance"] = 0.62
		profile["rare_chance"] = 0.44
		profile["rare_max"] = 2
		profile["magic_pack_min"] = 4
		profile["magic_pack_max"] = 7

	if rarity == RARITY_MAGIC:
		profile["magic_pack_chance"] = _to_float(profile["magic_pack_chance"], 0.4) + 0.08
		profile["normal_xp_mult"] = 1.08
		profile["magic_xp_mult"] = 1.92
	elif rarity == RARITY_RARE:
		profile["magic_pack_chance"] = _to_float(profile["magic_pack_chance"], 0.4) + 0.14
		profile["rare_chance"] = _to_float(profile["rare_chance"], 0.2) + 0.12
		profile["rare_max"] = max(2, _to_int(profile["rare_max"], 1))
		profile["normal_xp_mult"] = 1.18
		profile["magic_xp_mult"] = 2.12
		profile["rare_xp_mult"] = 5.2

	profile["magic_pack_chance"] = clampf(_to_float(profile["magic_pack_chance"], 0.4) + stat_total(item, "Magic Pack Chance"), 0.0, 0.92)
	profile["rare_chance"] = clampf(_to_float(profile["rare_chance"], 0.2) + stat_total(item, "Rare Monster Chance"), 0.0, 0.85)
	return profile


static func apply_map_mods_to_enemy(enemy: Object, state: Object) -> void:
	if enemy == null:
		return
	var profile: Dictionary = threat_profile(state)
	_scale_float_property(enemy, "max_hp", _to_float(profile.get("monster_life_mult", 1.0), 1.0))
	_scale_float_property(enemy, "hp", _to_float(profile.get("monster_life_mult", 1.0), 1.0))
	_scale_float_property(enemy, "health", _to_float(profile.get("monster_life_mult", 1.0), 1.0))
	_scale_float_property(enemy, "current_hp", _to_float(profile.get("monster_life_mult", 1.0), 1.0))
	_scale_float_property(enemy, "damage", _to_float(profile.get("monster_damage_mult", 1.0), 1.0))
	_scale_float_property(enemy, "attack_damage", _to_float(profile.get("monster_damage_mult", 1.0), 1.0))
	_scale_float_property(enemy, "speed", _to_float(profile.get("monster_speed_mult", 1.0), 1.0))
	_scale_float_property(enemy, "move_speed", _to_float(profile.get("monster_speed_mult", 1.0), 1.0))
	if bool(profile.get("enemies_cannot_be_slowed", false)):
		enemy.set_meta("rv_slow_immune", true)
	if bool(profile.get("enemies_resist_crits", false)):
		enemy.set_meta("rv_map_crit_resistant", true)


static func apply_reward_modifiers(state: Object, drops: Array, boss_or_clear: bool = false) -> Array:
	var item: Dictionary = active_map(state)
	if item.is_empty():
		return drops

	var rng: RandomNumberGenerator = _rng(state)
	var quantity: float = item_quantity(item)
	var rarity_bonus: float = item_rarity(item)
	var gem_bonus: float = stat_total(item, "Gem Drop Chance")
	var map_bonus: float = stat_total(item, "Map Drop Chance")
	var crystal_bonus: float = stat_total(item, "Crystal Drop Chance")

	var out: Array = []
	for value: Variant in drops:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var drop: Dictionary = Dictionary(value).duplicate(true)
		_upgrade_drop_by_rarity(drop, rarity_bonus, rng)
		out.append(drop)

	var extra_rolls: int = int(floor(quantity * 3.0))
	if rng.randf() < fmod(quantity * 3.0, 1.0):
		extra_rolls += 1
	if boss_or_clear:
		extra_rolls += 1

	for i: int in range(extra_rolls):
		out.append({"kind":"material", "material_id":"shards", "amount":rng.randi_range(1, 3), "label":"Map Shards", "auto_pickup":true, "rarity":"currency"})

	if rng.randf() < gem_bonus + (0.10 if boss_or_clear else 0.0):
		out.append({"kind":"support_gem", "gem_id":"controlled_power", "label":"Support Gem", "auto_pickup":false, "rarity":"gem"})

	if rng.randf() < map_bonus + (0.12 if boss_or_clear else 0.0):
		out.append({"kind":"map", "map":_make_map_drop_proxy(item, rng), "auto_pickup":false, "rarity":"map"})

	if rng.randf() < crystal_bonus:
		out.append({"kind":"material", "material_id":"monster_crystals", "amount":rng.randi_range(1, 2), "label":"Monster Crystal", "auto_pickup":false, "rarity":"rare", "item_kind":"crystal", "category":"crystal"})

	return out


static func _upgrade_drop_by_rarity(drop: Dictionary, rarity_bonus: float, rng: RandomNumberGenerator) -> void:
	if rarity_bonus <= 0.0 or str(drop.get("kind", "")) != "item":
		return
	if typeof(drop.get("item", {})) != TYPE_DICTIONARY:
		return
	var item: Dictionary = Dictionary(drop.get("item", {})).duplicate(true)
	var current: String = _safe_rarity(str(item.get("rarity", "normal")))
	if current == RARITY_NORMAL and rng.randf() < rarity_bonus:
		item["rarity"] = RARITY_MAGIC
	elif current == RARITY_MAGIC and rng.randf() < rarity_bonus * 0.35:
		item["rarity"] = RARITY_RARE
	drop["item"] = item
	drop["rarity"] = str(item.get("rarity", current))


static func _make_map_drop_proxy(current_map: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var tier: int = clampi(_to_int(current_map.get("tier", 1), 1) + rng.randi_range(0, 1), 1, 15)
	var rarity: String = RARITY_NORMAL
	if tier >= 10 and rng.randf() < 0.30:
		rarity = RARITY_RARE
	elif tier >= 6 and rng.randf() < 0.45:
		rarity = RARITY_MAGIC
	return normalize_map_item({
		"uid":"map_" + str(Time.get_ticks_usec()) + "_" + str(rng.randi()),
		"base_id":str(current_map.get("base_id", "ash_vault")),
		"display_name":str(current_map.get("display_name", "Map")),
		"tier":tier,
		"map_level":max(1, tier),
		"layout":str(current_map.get("layout", "box_blockers")),
		"rarity":rarity,
		"entries":6
	}, null)


static func completion_requirement_met(map_item: Dictionary) -> bool:
	return not map_item.is_empty()


static func bonus_requirement_met(map_item: Dictionary) -> bool:
	if map_item.is_empty():
		return false
	var tier: int = clampi(_to_int(map_item.get("tier", 1), 1), 1, 15)
	var rarity: String = _safe_rarity(str(map_item.get("rarity", RARITY_NORMAL)))
	if tier <= 5:
		return true
	if tier <= 9:
		return rarity == RARITY_MAGIC or rarity == RARITY_RARE
	return rarity == RARITY_RARE


static func completion_requirement_text(map_item: Dictionary) -> String:
	var tier: int = clampi(_to_int(map_item.get("tier", 1), 1), 1, 15)
	if tier <= 5:
		return "Clear the map."
	if tier <= 9:
		return "Clear the map. Bonus requires magic or rare."
	return "Clear the map. Bonus requires rare."


static func bonus_requirement_text(map_item: Dictionary) -> String:
	var tier: int = clampi(_to_int(map_item.get("tier", 1), 1), 1, 15)
	if tier <= 5:
		return "Bonus: complete this map."
	if tier <= 9:
		return "Bonus: complete as magic or rare."
	return "Bonus: complete as rare."


static func complete_current_map_state(state: Object) -> Dictionary:
	if state == null:
		return {"completed": false, "bonus": false, "map_id": ""}

	var activity: Dictionary = active_map(state)
	if activity.is_empty():
		return {"completed": false, "bonus": false, "map_id": ""}

	var map_id: String = str(activity.get("base_id", "ash_vault"))
	var completed: Dictionary = _as_dict(state.get("completed_maps"))
	var bonus_completed: Dictionary = _as_dict(state.get("bonus_completed_maps"))
	var records: Dictionary = _as_dict(state.get("map_completion_records"))

	var completed_now: bool = completion_requirement_met(activity)
	var bonus_now: bool = bonus_requirement_met(activity)

	if completed_now:
		completed[map_id] = true
		state.set("completed_maps", completed)
		state.set("maps_completed", _to_int(state.get("maps_completed"), 0) + 1)

	if bonus_now:
		bonus_completed[map_id] = true
		state.set("bonus_completed_maps", bonus_completed)
		state.set("map_bonus_completed", _to_int(state.get("map_bonus_completed"), 0) + 1)

	records[map_id] = {
		"completed": bool(completed.get(map_id, false)),
		"bonus": bool(bonus_completed.get(map_id, false)),
		"best_tier": max(_to_int(activity.get("tier", 1), 1), _to_int(_as_dict(records.get(map_id, {})).get("best_tier", 0), 0)),
		"last_rarity": str(activity.get("rarity", RARITY_NORMAL))
	}
	state.set("map_completion_records", records)

	return {"completed": completed_now, "bonus": bonus_now, "map_id": map_id}


static func describe_map(map_item: Dictionary, state: Object = null) -> String:
	if map_item.is_empty():
		return "No map selected."

	var item: Dictionary = normalize_map_item(map_item, state)
	var rarity: String = _safe_rarity(str(item.get("rarity", RARITY_NORMAL)))
	var text: String = str(item.get("display_name", "Map")) + " · " + rarity.capitalize() + " · Tier " + str(item.get("tier", 1)) + " · Level " + str(item.get("map_level", 1)) + "\n"
	text += "Entries: " + str(item.get("entries", 6)) + "\n"
	text += bonus_requirement_text(item) + "\n"

	var quantity: float = item_quantity(item)
	var rarity_bonus: float = item_rarity(item)
	if quantity > 0.0 or rarity_bonus > 0.0:
		text += "Rewards: +" + str(int(round(quantity * 100.0))) + "% Quantity, +" + str(int(round(rarity_bonus * 100.0))) + "% Rarity\n"

	var mods: Array = _as_array(item.get("mods", []))
	if mods.is_empty():
		text += "No modifiers.\n"
	else:
		text += "Modifiers:\n"
		for value: Variant in mods:
			if typeof(value) == TYPE_DICTIONARY:
				text += " • " + str(Dictionary(value).get("name", "Map Mod")) + "\n"
	return text


static func _scale_float_property(obj: Object, prop: String, mult: float) -> void:
	if mult == 1.0 or not _has_property(obj, prop):
		return
	obj.set(prop, _to_float(obj.get(prop), 0.0) * mult)


static func _has_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false
	for value: Variant in obj.get_property_list():
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("name", "")) == prop:
			return true
	return false


static func _safe_rarity(value: String) -> String:
	var r: String = value.strip_edges().to_lower()
	if r == RARITY_MAGIC or r == RARITY_RARE:
		return r
	if r == "":
		return ""
	return RARITY_NORMAL


static func _rng(state: Object) -> RandomNumberGenerator:
	if state != null:
		var value: Variant = state.get("rng")
		if value != null and value is RandomNumberGenerator:
			return value as RandomNumberGenerator
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng


static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value
	return []


static func _as_dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


static func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(int(value))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		_:
			return fallback


static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
