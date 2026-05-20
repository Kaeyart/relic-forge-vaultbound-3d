extends RefCounted
class_name RVRewardLoopSystem3D

const LootSystemScript := preload("res://scripts/systems/LootSystem3D.gd")
const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const MapDBScript := preload("res://scripts/data/MapDB3D.gd")
const MapDifficultySystemScript := preload("res://scripts/systems/MapDifficultySystem3D.gd")

static func enemy_reward_bundle(state: Object, enemy: Object) -> Array:
	var enemy_level: int = _enemy_level(enemy, state)
	var is_elite: bool = _enemy_bool(enemy, "is_elite", false)
	var is_boss: bool = _enemy_bool(enemy, "is_boss", false)
	var rarity: String = enemy_rarity(enemy, is_elite, is_boss)
	var rng: RandomNumberGenerator = _rng(state)

	var out: Array = []

	var base_bundle: Array = LootSystemScript.enemy_drop_bundle(state, enemy_level, is_elite or rarity == "magic" or rarity == "rare", is_boss)
	for value: Variant in base_bundle:
		if typeof(value) == TYPE_DICTIONARY:
			out.append(normalize_drop(Dictionary(value), state, enemy_level))

	if rarity == "magic":
		_append_magic_rewards(out, state, enemy_level, rng)
	elif rarity == "rare":
		_append_rare_rewards(out, state, enemy_level, rng)
	elif is_boss:
		_append_boss_bonus_rewards(out, state, enemy_level, rng)

	return MapDifficultySystemScript.apply_reward_modifiers(state, _clean_drops(out, state, enemy_level), false)


static func clear_reward_bundle(state: Object, map_level: int) -> Array:
	var rng: RandomNumberGenerator = _rng(state)
	var level: int = max(1, map_level)
	var out: Array = []

	var base_bundle: Array = LootSystemScript.boss_reward_bundle(state, level)
	for value: Variant in base_bundle:
		if typeof(value) == TYPE_DICTIONARY:
			out.append(normalize_drop(Dictionary(value), state, level))

	out.append(_gold_drop(rng.randi_range(30, 65) + level * 8))
	out.append(_material_drop("shards", rng.randi_range(3, 7) + int(level / 2), "Forge Shards"))
	out.append(_gear_drop(state, level + 1, "rare"))
	out.append(_gem_drop(rng, true, level))

	if rng.randf() < 0.75:
		out.append(_map_drop(state, max(1, level + rng.randi_range(0, 1))))
	if level >= 6 or rng.randf() < 0.28:
		out.append(_crystal_drop(level, rng.randi_range(1, 2)))

	return MapDifficultySystemScript.apply_reward_modifiers(state, _clean_drops(out, state, level), true)


static func normalize_drop(drop: Dictionary, state: Object = null, level: int = 1) -> Dictionary:
	if drop.is_empty():
		return {}

	var kind: String = str(drop.get("kind", "")).strip_edges().to_lower()
	var rng: RandomNumberGenerator = _rng(state)

	match kind:
		"gear":
			var item_data: Dictionary = {}
			if typeof(drop.get("item", {})) == TYPE_DICTIONARY:
				item_data = Dictionary(drop.get("item", {})).duplicate(true)
			if item_data.is_empty():
				var rarity: String = _safe_rarity(str(drop.get("rarity", "magic")))
				item_data = ItemDBScript.random_equipment_drop(max(1, int(drop.get("item_level", level))), rng, rarity == "rare" or rarity == "unique")
				if rarity == "unique":
					item_data["rarity"] = "unique"
					item_data["display_name"] = "Unique " + str(item_data.get("base_name", item_data.get("display_name", "Item")))
			return {
				"kind": "item",
				"item": item_data,
				"auto_pickup": false,
				"rarity": str(item_data.get("rarity", drop.get("rarity", "normal"))),
				"label": str(item_data.get("display_name", "Item")),
			}

		"currency":
			var amount: int = max(1, _to_int(drop.get("amount", drop.get("stack", 1)), 1))
			var currency_id: String = str(drop.get("currency_id", drop.get("material_id", "shards")))
			if currency_id == "gold":
				return _gold_drop(amount)
			return _material_drop(currency_id, amount, str(drop.get("name", drop.get("label", currency_id.capitalize()))))

		"crystal":
			return {
				"kind": "material",
				"material_id": "monster_crystals",
				"amount": max(1, _to_int(drop.get("amount", drop.get("stack", 1)), 1)),
				"label": str(drop.get("name", "Monster Crystal")),
				"auto_pickup": false,
				"rarity": "rare",
				"item_kind": "crystal",
				"category": "crystal",
			}

		"gem":
			var gem_type: String = str(drop.get("gem_type", "support")).strip_edges().to_lower()
			var gem_kind: String = "support_gem"
			if gem_type == "active":
				gem_kind = "active_gem"
			elif gem_type == "spirit":
				gem_kind = "spirit_gem"
			return {
				"kind": gem_kind,
				"gem_id": _gem_id_for_type(gem_type, rng),
				"label": str(drop.get("name", gem_type.capitalize() + " Gem")),
				"auto_pickup": false,
				"rarity": "gem",
			}

		"item", "map", "gold", "material", "active_gem", "support_gem", "spirit_gem":
			var copy: Dictionary = drop.duplicate(true)
			if not copy.has("label"):
				copy["label"] = label_for_drop(copy)
			if not copy.has("rarity"):
				copy["rarity"] = rarity_for_drop(copy)
			return copy

		_:
			var fallback: Dictionary = drop.duplicate(true)
			if not fallback.has("kind"):
				fallback["kind"] = "material"
			if not fallback.has("label"):
				fallback["label"] = label_for_drop(fallback)
			return fallback


static func presentation_data_for_drop(drop: Dictionary) -> Dictionary:
	var normalized: Dictionary = normalize_drop(drop, null, 1)
	var kind: String = presentation_kind(normalized)
	var rarity: String = rarity_for_drop(normalized)
	var display: String = label_for_drop(normalized)

	var data: Dictionary = {
		"kind": kind,
		"item_kind": kind,
		"category": kind,
		"rarity": rarity,
		"name": display,
		"display_name": display,
	}

	if normalized.has("item") and typeof(normalized.get("item")) == TYPE_DICTIONARY:
		var item: Dictionary = Dictionary(normalized.get("item"))
		data["rarity"] = _safe_rarity(str(item.get("rarity", rarity)))
		data["slot"] = str(item.get("slot", ""))
		data["display_name"] = str(item.get("display_name", display))
		data["name"] = data["display_name"]
	elif normalized.has("map") and typeof(normalized.get("map")) == TYPE_DICTIONARY:
		var map_item: Dictionary = Dictionary(normalized.get("map"))
		data["kind"] = "map"
		data["item_kind"] = "map"
		data["category"] = "map"
		data["tier"] = int(map_item.get("tier", map_item.get("map_tier", 1)))
		data["display_name"] = str(map_item.get("display_name", display))
		data["name"] = data["display_name"]
	elif str(normalized.get("kind", "")).ends_with("gem"):
		data["kind"] = "gem"
		data["item_kind"] = "gem"
		data["category"] = "gem"
		data["gem_type"] = str(normalized.get("kind", "")).replace("_gem", "")
	elif str(normalized.get("item_kind", "")) == "crystal":
		data["kind"] = "crystal"
		data["item_kind"] = "crystal"
		data["category"] = "crystal"

	return data


static func label_for_drop(drop: Dictionary) -> String:
	if drop.is_empty():
		return "Loot"

	var kind: String = str(drop.get("kind", ""))
	match kind:
		"item":
			var item: Dictionary = Dictionary(drop.get("item", {}))
			return str(item.get("display_name", drop.get("label", "Item")))
		"map":
			var map_item: Dictionary = Dictionary(drop.get("map", {}))
			return str(map_item.get("display_name", drop.get("label", "Map")))
		"gold":
			return "Gold x" + str(drop.get("amount", 0))
		"material":
			if str(drop.get("item_kind", "")) == "crystal":
				return str(drop.get("label", "Monster Crystal")) + " x" + str(drop.get("amount", 1))
			return str(drop.get("label", drop.get("material_id", "Material"))) + " x" + str(drop.get("amount", 1))
		"active_gem":
			return "Active Gem: " + str(drop.get("gem_id", ""))
		"support_gem":
			return "Support Gem: " + str(drop.get("gem_id", ""))
		"spirit_gem":
			return "Spirit Gem: " + str(drop.get("gem_id", ""))
		_:
			return str(drop.get("label", "Loot"))


static func rarity_for_drop(drop: Dictionary) -> String:
	if drop.is_empty():
		return "normal"
	if drop.has("item") and typeof(drop.get("item")) == TYPE_DICTIONARY:
		return _safe_rarity(str(Dictionary(drop.get("item")).get("rarity", drop.get("rarity", "normal"))))
	if str(drop.get("kind", "")).ends_with("gem"):
		return "magic"
	if str(drop.get("kind", "")) == "map":
		var map_item: Dictionary = Dictionary(drop.get("map", {}))
		return _safe_rarity(str(map_item.get("rarity", drop.get("rarity", "normal"))))
	if str(drop.get("item_kind", "")) == "crystal":
		return "rare"
	if str(drop.get("kind", "")) == "gold" or str(drop.get("kind", "")) == "material":
		return "normal"
	return _safe_rarity(str(drop.get("rarity", "normal")))


static func presentation_kind(drop: Dictionary) -> String:
	var kind: String = str(drop.get("kind", "")).strip_edges().to_lower()
	if kind == "item":
		return "unique" if rarity_for_drop(drop) == "unique" else "gear"
	if kind == "map":
		return "map"
	if kind.ends_with("gem"):
		return "gem"
	if kind == "gold" or kind == "material":
		if str(drop.get("item_kind", "")) == "crystal":
			return "crystal"
		return "currency"
	return str(drop.get("item_kind", kind if kind != "" else "gear"))


static func color_for_drop(drop: Dictionary) -> Color:
	var kind: String = presentation_kind(drop)
	var rarity: String = rarity_for_drop(drop)
	if kind == "currency":
		return Color(1.0, 0.82, 0.22, 1.0)
	if kind == "gem":
		return Color(0.72, 0.42, 1.0, 1.0)
	if kind == "map":
		return Color(0.34, 0.72, 1.0, 1.0)
	if kind == "crystal":
		return Color(0.42, 1.0, 0.86, 1.0)
	match rarity:
		"magic":
			return Color(0.34, 0.54, 1.0, 1.0)
		"rare":
			return Color(1.0, 0.82, 0.22, 1.0)
		"unique":
			return Color(1.0, 0.46, 0.12, 1.0)
		_:
			return Color(0.92, 0.92, 0.88, 1.0)


static func apply_drop_to_state(state: Object, drop: Dictionary) -> void:
	var normalized: Dictionary = normalize_drop(drop, state, 1)
	LootSystemScript.apply_drop_to_state(state, normalized)


static func _append_magic_rewards(out: Array, state: Object, level: int, rng: RandomNumberGenerator) -> void:
	out.append(_material_drop("embers", rng.randi_range(1, 3), "Embers"))
	if rng.randf() < 0.28:
		out.append(_gear_drop(state, level, "magic"))
	if rng.randf() < 0.14:
		out.append(_gem_drop(rng, false, level))


static func _append_rare_rewards(out: Array, state: Object, level: int, rng: RandomNumberGenerator) -> void:
	out.append(_gold_drop(rng.randi_range(18, 36) + level * 3))
	out.append(_material_drop("shards", rng.randi_range(2, 5), "Forge Shards"))
	out.append(_gear_drop(state, level + 1, "rare"))

	if rng.randf() < 0.55:
		out.append(_gear_drop(state, level, "magic"))
	if rng.randf() < 0.42:
		out.append(_gem_drop(rng, true, level))
	if rng.randf() < 0.25:
		out.append(_map_drop(state, max(1, int(level / 3) + 1)))
	if level >= 6 or rng.randf() < 0.18:
		out.append(_crystal_drop(level, 1))


static func _append_boss_bonus_rewards(out: Array, state: Object, level: int, rng: RandomNumberGenerator) -> void:
	out.append(_gold_drop(rng.randi_range(40, 90) + level * 5))
	out.append(_gear_drop(state, level + 2, "rare"))
	out.append(_gem_drop(rng, true, level))


static func _gear_drop(state: Object, level: int, rarity: String) -> Dictionary:
	var rng: RandomNumberGenerator = _rng(state)
	var boss_roll: bool = rarity == "rare" or rarity == "unique"
	var item: Dictionary = ItemDBScript.random_equipment_drop(max(1, level), rng, boss_roll)
	if rarity == "unique":
		item["rarity"] = "unique"
		item["display_name"] = "Unique " + str(item.get("base_name", item.get("display_name", "Item")))
	return {
		"kind": "item",
		"item": item,
		"auto_pickup": false,
		"rarity": str(item.get("rarity", rarity)),
		"label": str(item.get("display_name", "Item")),
	}


static func _map_drop(state: Object, tier: int) -> Dictionary:
	var rng: RandomNumberGenerator = _rng(state)
	var map_id: String = "ash_vault"
	if tier >= 5:
		map_id = "chain_crossing"
	var map_item: Dictionary = MapDBScript.make_map_item(map_id, clampi(tier, 1, 15), rng)
	map_item["kind"] = "map"
	map_item["item_kind"] = "map"
	map_item["category"] = "map"
	return {
		"kind": "map",
		"map": map_item,
		"auto_pickup": false,
		"rarity": str(map_item.get("rarity", "normal")),
		"label": str(map_item.get("display_name", "Map")),
	}


static func _gem_drop(rng: RandomNumberGenerator, good: bool, level: int) -> Dictionary:
	var roll: float = rng.randf()
	if good and roll < 0.34:
		var active_ids: Array = ["ember_mine", "void_rift", "arc_slash", "storm_lance"]
		return {"kind": "active_gem", "gem_id": str(active_ids[rng.randi_range(0, active_ids.size() - 1)]), "label": "Active Gem", "auto_pickup": false, "rarity": "magic"}
	if roll < 0.72:
		var support_ids: Array = ["controlled_power", "efficient_casting", "greater_area", "split_projectile", "chain_current", "ignition", "bleed_edge", "echoing_void"]
		return {"kind": "support_gem", "gem_id": str(support_ids[rng.randi_range(0, support_ids.size() - 1)]), "label": "Support Gem", "auto_pickup": false, "rarity": "magic"}
	var spirit_ids: Array = ["clarity", "vitality", "ember_pact", "storm_rhythm", "void_tithe", "iron_skin"]
	return {"kind": "spirit_gem", "gem_id": str(spirit_ids[rng.randi_range(0, spirit_ids.size() - 1)]), "label": "Spirit Gem", "auto_pickup": false, "rarity": "magic"}


static func _gold_drop(amount: int) -> Dictionary:
	return {"kind": "gold", "amount": max(1, amount), "label": "Gold x" + str(max(1, amount)), "auto_pickup": true, "rarity": "normal"}


static func _material_drop(material_id: String, amount: int, label: String) -> Dictionary:
	return {"kind": "material", "material_id": material_id, "amount": max(1, amount), "label": label, "auto_pickup": true, "rarity": "normal"}


static func _crystal_drop(level: int, amount: int) -> Dictionary:
	return {
		"kind": "material",
		"material_id": "monster_crystals",
		"amount": max(1, amount),
		"label": "Monster Crystal",
		"auto_pickup": false,
		"rarity": "rare",
		"item_kind": "crystal",
		"category": "crystal",
		"tier": level,
	}


static func _clean_drops(drops: Array, state: Object, level: int) -> Array:
	var out: Array = []
	for value: Variant in drops:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var normalized: Dictionary = normalize_drop(Dictionary(value), state, level)
		if normalized.is_empty():
			continue
		normalized["label"] = label_for_drop(normalized)
		normalized["rarity"] = rarity_for_drop(normalized)
		out.append(normalized)
	return out


static func enemy_rarity(enemy: Object, is_elite: bool = false, is_boss: bool = false) -> String:
	if enemy != null and enemy.has_meta("rv_enemy_rarity"):
		var r: String = str(enemy.get_meta("rv_enemy_rarity")).strip_edges().to_lower()
		if r == "magic" or r == "rare" or r == "unique":
			return r
	if is_boss:
		return "rare"
	if is_elite:
		return "magic"
	return "normal"


static func _enemy_level(enemy: Object, state: Object) -> int:
	if enemy != null and _has_property(enemy, "enemy_level"):
		return max(1, _to_int(enemy.get("enemy_level"), 1))
	if state != null:
		return max(1, _to_int(state.get("level"), 1))
	return 1


static func _enemy_bool(enemy: Object, prop: String, fallback: bool) -> bool:
	if enemy != null and _has_property(enemy, prop):
		return bool(enemy.get(prop))
	return fallback


static func _gem_id_for_type(gem_type: String, rng: RandomNumberGenerator) -> String:
	if gem_type == "active":
		var active_ids: Array = ["fireball", "storm_lance", "arc_slash", "void_rift", "ember_mine"]
		return str(active_ids[rng.randi_range(0, active_ids.size() - 1)])
	if gem_type == "spirit":
		var spirit_ids: Array = ["clarity", "vitality", "ember_pact", "storm_rhythm", "void_tithe", "iron_skin"]
		return str(spirit_ids[rng.randi_range(0, spirit_ids.size() - 1)])
	var support_ids: Array = ["controlled_power", "efficient_casting", "greater_area", "split_projectile", "chain_current", "ignition", "bleed_edge", "echoing_void"]
	return str(support_ids[rng.randi_range(0, support_ids.size() - 1)])


static func _rng(state: Object) -> RandomNumberGenerator:
	if state != null:
		var value: Variant = state.get("rng")
		if value != null and value is RandomNumberGenerator:
			return value as RandomNumberGenerator
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng


static func _safe_rarity(value: String) -> String:
	var r: String = value.strip_edges().to_lower()
	if r == "magic" or r == "rare" or r == "unique":
		return r
	return "normal"


static func _has_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false
	var props: Array = obj.get_property_list()
	for value: Variant in props:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(value)
		if str(data.get("name", "")) == prop:
			return true
	return false


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
