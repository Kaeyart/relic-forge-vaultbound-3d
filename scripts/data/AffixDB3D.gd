class_name RVAffixDB3D
extends RefCounted

static func affixes() -> Dictionary:
	return {
		"squire_life": {"name":"Squire's", "type":"prefix", "tags":["armor","jewelry","life"], "min_level":1, "stats":{"maximum_life":18.0}},
		"knight_life": {"name":"Knight's", "type":"prefix", "tags":["armor","jewelry","life"], "min_level":5, "stats":{"maximum_life":34.0}},
		"mana_thread": {"name":"Threaded", "type":"prefix", "tags":["caster","jewelry","mana"], "min_level":1, "stats":{"maximum_mana":16.0}},
		"mana_font": {"name":"Fonted", "type":"prefix", "tags":["caster","jewelry","mana"], "min_level":6, "stats":{"maximum_mana":32.0}},
		"ironhide": {"name":"Ironhide", "type":"prefix", "tags":["armor","defense"], "min_level":1, "stats":{"armor":16.0}},
		"bastion": {"name":"Bastion", "type":"prefix", "tags":["armor","defense"], "min_level":8, "stats":{"armor":38.0}},
		"ember_spell": {"name":"Embercall", "type":"prefix", "tags":["weapon","caster","fire"], "min_level":1, "stats":{"spell_damage":0.09,"fire_damage":0.08}},
		"storm_spell": {"name":"Stormcall", "type":"prefix", "tags":["weapon","caster","lightning"], "min_level":1, "stats":{"spell_damage":0.08,"lightning_damage":0.09}},
		"void_spell": {"name":"Abyssal", "type":"prefix", "tags":["weapon","caster","void"], "min_level":1, "stats":{"spell_damage":0.08,"void_damage":0.09}},
		"blade_damage": {"name":"Sharpened", "type":"prefix", "tags":["weapon","melee","attack"], "min_level":1, "stats":{"attack_damage":0.12}},
		"projectile_focus": {"name":"Piercer's", "type":"suffix", "tags":["weapon","projectile"], "min_level":1, "stats":{"projectile_damage":0.11}},
		"cast_speed": {"name":"of Quickening", "type":"suffix", "tags":["weapon","caster","jewelry"], "min_level":1, "stats":{"cast_speed":0.08}},
		"attack_speed": {"name":"of Tempo", "type":"suffix", "tags":["weapon","attack"], "min_level":1, "stats":{"attack_speed":0.08}},
		"fire_res": {"name":"of Ash Warding", "type":"suffix", "tags":["armor","jewelry","resistance"], "min_level":1, "stats":{"fire_resistance":0.11}},
		"lightning_res": {"name":"of Copper Warding", "type":"suffix", "tags":["armor","jewelry","resistance"], "min_level":1, "stats":{"lightning_resistance":0.11}},
		"void_res": {"name":"of Hollow Warding", "type":"suffix", "tags":["armor","jewelry","resistance"], "min_level":1, "stats":{"void_resistance":0.11}},
		"move_speed": {"name":"of the Strider", "type":"suffix", "tags":["boots","movement"], "min_level":1, "stats":{"movement_speed":0.08}},
	}

static func roll_affixes(base_tags: Array, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var prefixes: Array[Dictionary] = []
	var suffixes: Array[Dictionary] = []
	var count: int = 0
	match rarity:
		"normal": count = 0
		"magic": count = rng.randi_range(1, 2)
		"rare": count = rng.randi_range(3, 5)
		"unique": count = 0
		_: count = 1
	var attempts: int = 0
	while count > 0 and attempts < 80:
		attempts += 1
		var affix: Dictionary = _random_valid_affix(base_tags, item_level, rng)
		if affix.is_empty():
			break
		var target: Array[Dictionary] = prefixes if str(affix.get("type", "prefix")) == "prefix" else suffixes
		if target.size() >= 3:
			continue
		if _has_affix(target, str(affix.get("id", ""))):
			continue
		target.append(affix)
		count -= 1
	return {"prefixes": prefixes, "suffixes": suffixes}

static func _random_valid_affix(base_tags: Array, item_level: int, rng: RandomNumberGenerator) -> Dictionary:
	var pool: Array[Dictionary] = []
	for id_value: Variant in affixes().keys():
		var data: Dictionary = Dictionary(affixes()[id_value]).duplicate(true)
		if int(data.get("min_level", 1)) > item_level:
			continue
		if not _tags_overlap(base_tags, Array(data.get("tags", []))):
			continue
		data["id"] = str(id_value)
		pool.append(data)
	if pool.is_empty():
		return {}
	return pool[rng.randi_range(0, pool.size() - 1)].duplicate(true)

static func _tags_overlap(a: Array, b: Array) -> bool:
	for av: Variant in a:
		if b.has(str(av)):
			return true
	return false

static func _has_affix(list: Array, id: String) -> bool:
	for affix: Dictionary in list:
		if str(affix.get("id", "")) == id:
			return true
	return false
