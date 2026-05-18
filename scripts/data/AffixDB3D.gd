class_name RVAffixDB3D
extends RefCounted

static var _cache_ready: bool = false
static var _affixes: Dictionary = {}

static func all_affixes() -> Dictionary:
	_ensure_cache()
	return _affixes

static func affix(affix_id: String) -> Dictionary:
	_ensure_cache()
	return Dictionary(_affixes.get(affix_id, {})).duplicate(true)

static func roll_affixes(item: Dictionary, rarity: String, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var count: int = 0
	match rarity:
		"Magic": count = rng.randi_range(1, 2)
		"Rare": count = rng.randi_range(3, 5)
		_: count = 0
	var rolled: Array[Dictionary] = []
	var used_groups: Array[String] = []
	for i: int in range(count):
		var next_affix: Dictionary = roll_affix(item, used_groups, rng)
		if next_affix.is_empty():
			break
		rolled.append(next_affix)
		used_groups.append(str(next_affix.get("group", next_affix.get("id", ""))))
	return rolled

static func roll_affix(item: Dictionary, used_groups: Array[String], rng: RandomNumberGenerator) -> Dictionary:
	_ensure_cache()
	var candidates: Array[Dictionary] = []
	var allowed_tags: Array = Array(item.get("allowed_affix_tags", []))
	var item_level: int = int(item.get("item_level", 1))
	var slot: String = str(item.get("slot", ""))
	var item_type: String = str(item.get("item_type", ""))
	for key: Variant in _affixes.keys():
		var data: Dictionary = Dictionary(_affixes[key])
		if int(data.get("min_item_level", 1)) > item_level:
			continue
		if used_groups.has(str(data.get("group", data.get("id", "")))):
			continue
		if not _slot_allowed(data, slot, item_type):
			continue
		if not _tags_intersect(allowed_tags, Array(data.get("tags", []))):
			continue
		candidates.append(data)
	if candidates.is_empty():
		return {}
	var picked: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)].duplicate(true)
	var value_min: float = float(picked.get("value_min", 1.0))
	var value_max: float = float(picked.get("value_max", value_min))
	picked["value"] = snappedf(rng.randf_range(value_min, value_max), 0.1)
	return picked

static func apply_affixes_to_stats(base_stats: Dictionary, affixes: Array) -> Dictionary:
	var out: Dictionary = base_stats.duplicate(true)
	for value: Variant in affixes:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(value)
		var stat: String = str(data.get("stat", ""))
		if stat == "":
			continue
		out[stat] = float(out.get(stat, 0.0)) + float(data.get("value", 0.0))
	return out

static func _slot_allowed(data: Dictionary, slot: String, item_type: String) -> bool:
	var slots: Array = Array(data.get("slots", []))
	var types: Array = Array(data.get("item_types", []))
	return slots.has(slot) or types.has(item_type)

static func _tags_intersect(a: Array, b: Array) -> bool:
	for tag_value: Variant in a:
		if b.has(str(tag_value)):
			return true
	return false

static func _ensure_cache() -> void:
	if _cache_ready:
		return
	_cache_ready = true
	_affixes = {
		"life_flat": {"id":"life_flat", "name":"of Vitality", "group":"life", "stat":"max_hp", "value_min":18, "value_max":45, "min_item_level":1, "slots":["head","chest","gloves","boots","amulet","ring1","ring2","relic"], "item_types":["armor","jewelry"], "tags":["life","defense"]},
		"mana_flat": {"id":"mana_flat", "name":"of Focus", "group":"mana", "stat":"max_mana", "value_min":12, "value_max":38, "min_item_level":1, "slots":["weapon","offhand","amulet","ring1","ring2","relic"], "item_types":["weapon","jewelry"], "tags":["mana","caster"]},
		"fire_damage": {"id":"fire_damage", "name":"Scorched", "group":"fire_damage", "stat":"fire_damage_pct", "value_min":6, "value_max":22, "min_item_level":1, "slots":["weapon","offhand","amulet","ring1","ring2"], "item_types":["weapon","jewelry"], "tags":["fire","elemental","damage","spell"]},
		"lightning_damage": {"id":"lightning_damage", "name":"Stormbound", "group":"lightning_damage", "stat":"lightning_damage_pct", "value_min":6, "value_max":22, "min_item_level":1, "slots":["weapon","offhand","amulet","ring1","ring2"], "item_types":["weapon","jewelry"], "tags":["lightning","elemental","damage","spell"]},
		"void_damage": {"id":"void_damage", "name":"Hollow", "group":"void_damage", "stat":"void_damage_pct", "value_min":7, "value_max":24, "min_item_level":3, "slots":["weapon","offhand","amulet","ring1","ring2","relic"], "item_types":["weapon","jewelry"], "tags":["void","damage","spell"]},
		"spell_damage": {"id":"spell_damage", "name":"Arcanist's", "group":"spell_damage", "stat":"spell_damage_pct", "value_min":5, "value_max":18, "min_item_level":1, "slots":["weapon","offhand","amulet"], "item_types":["weapon","jewelry"], "tags":["spell","damage","caster"]},
		"attack_damage": {"id":"attack_damage", "name":"Bloodied", "group":"attack_damage", "stat":"attack_damage_pct", "value_min":5, "value_max":20, "min_item_level":1, "slots":["weapon","gloves","amulet","ring1","ring2"], "item_types":["weapon","armor","jewelry"], "tags":["attack","melee","damage"]},
		"armor_flat": {"id":"armor_flat", "name":"Plated", "group":"armor", "stat":"armor", "value_min":15, "value_max":60, "min_item_level":1, "slots":["head","chest","gloves","boots"], "item_types":["armor"], "tags":["armor","defense"]},
		"move_speed": {"id":"move_speed", "name":"Fleet", "group":"move_speed", "stat":"move_speed", "value_min":0.15, "value_max":0.55, "min_item_level":1, "slots":["boots"], "item_types":["armor"], "tags":["speed","movement"]},
		"cooldown_recovery": {"id":"cooldown_recovery", "name":"Quickened", "group":"cooldown", "stat":"cooldown_recovery_pct", "value_min":4, "value_max":14, "min_item_level":4, "slots":["boots","gloves","amulet","relic"], "item_types":["armor","jewelry"], "tags":["cooldown","skill"]}
	}
