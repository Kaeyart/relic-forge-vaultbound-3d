class_name RVItemDB3D
extends RefCounted

static func bases() -> Dictionary:
	return {
		"novice_wand": {"name": "Novice Wand", "slot": "weapon", "type": "weapon", "tags": ["weapon", "spell", "caster"], "level": 1},
		"iron_sword": {"name": "Iron Sword", "slot": "weapon", "type": "weapon", "tags": ["weapon", "attack", "melee"], "level": 1},
		"ash_staff": {"name": "Ash Staff", "slot": "weapon", "type": "weapon", "tags": ["weapon", "spell", "fire", "caster"], "level": 2},
		"warden_chest": {"name": "Warden Plate", "slot": "chest", "type": "armor", "tags": ["armor", "life", "defense"], "level": 1},
		"traveler_boots": {"name": "Traveler Boots", "slot": "boots", "type": "armor", "tags": ["armor", "speed", "defense"], "level": 1},
		"copper_ring": {"name": "Copper Ring", "slot": "ring1", "type": "jewelry", "tags": ["jewelry", "mana", "damage"], "level": 1},
		"ember_amulet": {"name": "Ember Amulet", "slot": "amulet", "type": "jewelry", "tags": ["jewelry", "fire", "spell"], "level": 2}
	}

static func base_ids_for_level(item_level: int) -> Array[String]:
	var result: Array[String] = []
	for id_value: Variant in bases().keys():
		var id: String = str(id_value)
		var data: Dictionary = bases()[id]
		if int(data.get("level", 1)) <= item_level:
			result.append(id)
	return result

static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var base: Dictionary = Dictionary(bases().get(base_id, bases()["novice_wand"])).duplicate(true)
	var item: Dictionary = {
		"uid": "item_" + str(rng.randi()),
		"base_id": base_id,
		"name": _rarity_prefix(rarity) + str(base.get("name", base_id)),
		"slot": str(base.get("slot", "weapon")),
		"type": str(base.get("type", "gear")),
		"tags": Array(base.get("tags", [])).duplicate(true),
		"level": item_level,
		"rarity": rarity,
		"forge_potential": _forge_potential_for_rarity(rarity, rng),
		"stats": {},
		"affixes": []
	}
	var affix_count: int = 0
	match rarity:
		"normal": affix_count = 0
		"magic": affix_count = rng.randi_range(1, 2)
		"rare": affix_count = rng.randi_range(3, 5)
		_: affix_count = 0
	for i: int in range(affix_count):
		_add_random_affix(item, rng)
	return item

static func make_random_drop(item_level: int, rng: RandomNumberGenerator, rarity_bias: float = 0.0) -> Dictionary:
	var ids: Array[String] = base_ids_for_level(item_level)
	if ids.is_empty():
		ids = ["novice_wand"]
	var base_id: String = ids[rng.randi_range(0, ids.size() - 1)]
	var roll: float = rng.randf() + rarity_bias
	var rarity: String = "normal"
	if roll > 0.92:
		rarity = "rare"
	elif roll > 0.62:
		rarity = "magic"
	return make_item(base_id, item_level, rarity, rng)

static func can_equip(item: Dictionary) -> bool:
	return not item.is_empty() and str(item.get("slot", "")) != ""

static func equip_item(state: Object, item_index: int) -> bool:
	if state == null:
		return false
	var backpack: Array = Array(state.get("backpack"))
	if item_index < 0 or item_index >= backpack.size():
		return false
	var item: Dictionary = Dictionary(backpack[item_index])
	if not can_equip(item):
		return false
	var slot: String = str(item.get("slot", ""))
	var equipped: Dictionary = Dictionary(state.get("equipped"))
	var old_item: Dictionary = Dictionary(equipped.get(slot, {}))
	equipped[slot] = item
	backpack.remove_at(item_index)
	if not old_item.is_empty():
		backpack.append(old_item)
	state.set("equipped", equipped)
	state.set("backpack", backpack)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	if state.has_method("add_notice"):
		state.call("add_notice", "Equipped " + str(item.get("name", "item")))
	return true

static func item_text(item: Dictionary) -> String:
	if item.is_empty():
		return "Empty"
	var text: String = str(item.get("name", "Item")) + " [" + str(item.get("rarity", "normal")) + "]\n"
	text += "Lv " + str(int(item.get("level", 1))) + " · " + str(item.get("slot", "")) + " · FP " + str(int(item.get("forge_potential", 0))) + "\n"
	var stats: Dictionary = Dictionary(item.get("stats", {}))
	for key_value: Variant in stats.keys():
		text += "  " + _stat_label(str(key_value)) + ": +" + str(snappedf(float(stats[key_value]), 0.1)) + "\n"
	return text

static func _add_random_affix(item: Dictionary, rng: RandomNumberGenerator) -> void:
	var pool: Array[Dictionary] = []
	var tags: Array = Array(item.get("tags", []))
	for affix: Dictionary in _affixes():
		if int(affix.get("level", 1)) > int(item.get("level", 1)):
			continue
		var allowed: bool = false
		for tag_value: Variant in Array(affix.get("tags", [])):
			if tags.has(str(tag_value)):
				allowed = true
				break
		if allowed:
			pool.append(affix)
	if pool.is_empty():
		return
	var chosen: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var stat: String = str(chosen.get("stat", "damage"))
	var amount: float = rng.randf_range(float(chosen.get("min", 1.0)), float(chosen.get("max", 2.0)))
	var stats: Dictionary = Dictionary(item.get("stats", {}))
	stats[stat] = float(stats.get(stat, 0.0)) + amount
	item["stats"] = stats
	var affixes: Array = Array(item.get("affixes", []))
	affixes.append({"name": str(chosen.get("name", stat)), "stat": stat, "amount": amount})
	item["affixes"] = affixes

static func _affixes() -> Array[Dictionary]:
	return [
		{"name": "of Flame", "tags": ["fire", "spell", "weapon", "jewelry"], "stat": "fire_damage", "min": 4.0, "max": 9.0, "level": 1},
		{"name": "of Force", "tags": ["attack", "melee", "weapon"], "stat": "attack_damage", "min": 4.0, "max": 10.0, "level": 1},
		{"name": "of Focus", "tags": ["spell", "caster", "weapon", "jewelry"], "stat": "spell_damage", "min": 4.0, "max": 10.0, "level": 1},
		{"name": "of Vitality", "tags": ["life", "armor", "jewelry", "defense"], "stat": "max_life", "min": 12.0, "max": 30.0, "level": 1},
		{"name": "of Mind", "tags": ["mana", "jewelry", "caster"], "stat": "max_mana", "min": 10.0, "max": 25.0, "level": 1},
		{"name": "of Haste", "tags": ["speed", "armor", "boots"], "stat": "move_speed_flat", "min": 0.15, "max": 0.45, "level": 1},
		{"name": "of Storms", "tags": ["spell", "caster", "weapon", "jewelry"], "stat": "lightning_damage", "min": 5.0, "max": 12.0, "level": 2},
		{"name": "of the Rift", "tags": ["spell", "caster", "jewelry"], "stat": "void_damage", "min": 5.0, "max": 12.0, "level": 2}
	]

static func _forge_potential_for_rarity(rarity: String, rng: RandomNumberGenerator) -> int:
	match rarity:
		"normal": return rng.randi_range(12, 18)
		"magic": return rng.randi_range(8, 15)
		"rare": return rng.randi_range(4, 11)
		_: return rng.randi_range(4, 10)

static func _rarity_prefix(rarity: String) -> String:
	match rarity:
		"magic": return "Tempered "
		"rare": return "Vaultforged "
		_: return ""

static func _stat_label(stat: String) -> String:
	return stat.replace("_", " ").capitalize()
