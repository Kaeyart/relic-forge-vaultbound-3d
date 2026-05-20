class_name RVItemDB3D
extends RefCounted

const AffixDBScript := preload("res://scripts/data/AffixDB3D.gd")

static func bases() -> Dictionary:
	return {
		"iron_sword":{"name":"Iron Sword", "slot":"weapon", "item_type":"weapon", "tags":["weapon","attack","melee"], "implicit_stats":{"Attack Damage":0.05}},
		"ash_staff":{"name":"Ash Staff", "slot":"weapon", "item_type":"weapon", "tags":["weapon","spell","fire","caster"], "implicit_stats":{"Spell Damage":0.06,"Fire Damage":0.04}},
		"storm_focus":{"name":"Storm Focus", "slot":"offhand", "item_type":"offhand", "tags":["offhand","spell","lightning","caster"], "implicit_stats":{"Lightning Damage":0.05,"Maximum Mana":10}},
		"void_relic_blade":{"name":"Void-Touched Blade", "slot":"weapon", "item_type":"weapon", "tags":["weapon","attack","void","melee"], "implicit_stats":{"Void Damage":0.05}},
		"iron_helm":{"name":"Iron Helm", "slot":"head", "item_type":"armor", "tags":["armor","head"], "implicit_stats":{"Armor":12}},
		"guard_chest":{"name":"Guard Chestplate", "slot":"chest", "item_type":"armor", "tags":["armor","chest"], "implicit_stats":{"Armor":24,"Maximum Life":8}},
		"forge_gloves":{"name":"Forge Gloves", "slot":"gloves", "item_type":"armor", "tags":["armor","gloves"], "implicit_stats":{"Armor":10}},
		"traveler_boots":{"name":"Traveler Boots", "slot":"boots", "item_type":"armor", "tags":["armor","boots","movement"], "implicit_stats":{"Movement Speed":0.03}},
		"ember_ring":{"name":"Ember Ring", "slot":"ring", "item_type":"jewelry", "tags":["ring","fire","mana"], "implicit_stats":{"Fire Resistance":0.05}},
		"vault_amulet":{"name":"Vault Amulet", "slot":"amulet", "item_type":"jewelry", "tags":["amulet","spirit","caster"], "implicit_stats":{"Maximum Spirit":3}},
		"penitent_relic":{"name":"Penitent Relic", "slot":"relic", "item_type":"relic", "tags":["relic","life","spirit"], "implicit_stats":{"Maximum Life":12}},
	}


static func starter_bases() -> Array:
	return ["ash_staff", "storm_focus", "iron_helm", "guard_chest", "traveler_boots", "ember_ring", "vault_amulet"]


static func make_starter_weapon(rng: RandomNumberGenerator) -> Dictionary:
	return make_item("ash_staff", 1, "magic", rng)


static func random_equipment_drop(item_level: int, rng: RandomNumberGenerator, boss: bool = false) -> Dictionary:
	var keys: Array = bases().keys()
	var base_id: String = str(keys[rng.randi_range(0, keys.size() - 1)])
	var rarity: String = "normal"
	var roll: float = rng.randf()

	if boss:
		rarity = "rare" if roll < 0.78 else "magic"
	elif roll < 0.08:
		rarity = "rare"
	elif roll < 0.42:
		rarity = "magic"

	return make_item(base_id, item_level, rarity, rng)


static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var base: Dictionary = _base(base_id)
	var safe_rarity: String = _safe_rarity(rarity)
	var level: int = max(1, item_level)
	var affixes: Array = AffixDBScript.roll_affixes(base, safe_rarity, level, rng)
	var prefixes: Array = []
	var suffixes: Array = []

	for value: Variant in affixes:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var affix: Dictionary = value
		if str(affix.get("slot", "prefix")) == "suffix":
			suffixes.append(affix)
		else:
			prefixes.append(affix)

	var item: Dictionary = {
		"uid": "item_" + str(Time.get_ticks_usec()) + "_" + str(rng.randi()),
		"base_id": base_id,
		"base_name": str(base.get("name", base_id)),
		"display_name": _display_name(str(base.get("name", base_id)), safe_rarity, prefixes, suffixes, rng),
		"rarity": safe_rarity,
		"item_level": level,
		"required_level": max(1, roundi(level * 0.75)),
		"slot": str(base.get("slot", "")),
		"item_type": str(base.get("item_type", "")),
		"kind": "item",
		"item_kind": "gear",
		"tags": _as_array(base.get("tags", [])).duplicate(true),
		"implicit_stats": _as_dict(base.get("implicit_stats", {})).duplicate(true),
		"prefixes": prefixes,
		"suffixes": suffixes,
		"crafted_mods": [],
		"affixes": _flatten_affixes(prefixes, suffixes, []),
		"quality": 0,
		"forge_potential": _forge_potential(safe_rarity, level, rng),
		"total_stats": {},
	}
	item["total_stats"] = total_stats(item)
	return item


static func normalize_item(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return {}
	var out: Dictionary = item.duplicate(true)
	if not out.has("quality"):
		out["quality"] = 0
	if not out.has("forge_potential"):
		out["forge_potential"] = 8
	if not out.has("crafted_mods"):
		out["crafted_mods"] = []
	out["affixes"] = _flatten_affixes(_as_array(out.get("prefixes", [])), _as_array(out.get("suffixes", [])), _as_array(out.get("crafted_mods", [])))
	out["total_stats"] = total_stats(out)
	if not out.has("display_name") or str(out.get("display_name", "")) == "":
		out["display_name"] = _fallback_display_name(out)
	return out


static func total_stats(item: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	var quality: int = clampi(_to_int(item.get("quality", 0), 0), 0, 20)
	var implicit: Dictionary = _as_dict(item.get("implicit_stats", {})).duplicate(true)
	var quality_mult: float = 1.0 + float(quality) * 0.01

	for key_value: Variant in implicit.keys():
		var key: String = str(key_value)
		implicit[key] = _scale_value(implicit.get(key, 0.0), quality_mult)

	_merge(out, implicit)

	for affix_value: Variant in _as_array(item.get("prefixes", [])):
		if typeof(affix_value) == TYPE_DICTIONARY:
			_merge(out, _as_dict(affix_value.get("stats", {})))
	for affix2_value: Variant in _as_array(item.get("suffixes", [])):
		if typeof(affix2_value) == TYPE_DICTIONARY:
			_merge(out, _as_dict(affix2_value.get("stats", {})))
	for crafted_value: Variant in _as_array(item.get("crafted_mods", [])):
		if typeof(crafted_value) == TYPE_DICTIONARY:
			_merge(out, _as_dict(crafted_value.get("stats", {})))

	return out


static func item_detail(item: Dictionary) -> String:
	return item_detail_text(item)


static func item_detail_text(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."

	var safe: Dictionary = normalize_item(item)
	var lines: Array[String] = []
	lines.append(str(safe.get("display_name", "Item")))
	lines.append(_rarity_text(str(safe.get("rarity", "normal"))) + " " + _slot_text(str(safe.get("slot", ""))) + " · Item Level " + str(safe.get("item_level", 1)) + " · Forge Potential " + str(safe.get("forge_potential", 0)))
	lines.append("Quality: +" + str(clampi(_to_int(safe.get("quality", 0), 0), 0, 20)) + "%")

	_append_affix_section(lines, "Implicit", [{"name":"Base", "stats":_as_dict(safe.get("implicit_stats", {}))}], false)
	_append_affix_section(lines, "Prefixes", _as_array(safe.get("prefixes", [])), true)
	_append_affix_section(lines, "Suffixes", _as_array(safe.get("suffixes", [])), true)
	_append_affix_section(lines, "Crafted", _as_array(safe.get("crafted_mods", [])), true)

	var totals: Dictionary = _as_dict(safe.get("total_stats", {}))
	if not totals.is_empty():
		lines.append("")
		lines.append("Total Stats")
		for key_value: Variant in totals.keys():
			var key: String = str(key_value)
			lines.append(" • " + stat_line(key, totals.get(key, 0)))

	return "\n".join(lines)


static func compare_items_text(candidate: Dictionary, equipped: Dictionary) -> String:
	if candidate.is_empty():
		return "No candidate item."
	if equipped.is_empty():
		return "No equipped item in this slot."

	var c_stats: Dictionary = _as_dict(normalize_item(candidate).get("total_stats", {}))
	var e_stats: Dictionary = _as_dict(normalize_item(equipped).get("total_stats", {}))
	var keys: Array[String] = []

	for key_c: Variant in c_stats.keys():
		var kc: String = str(key_c)
		if not keys.has(kc):
			keys.append(kc)
	for key_e: Variant in e_stats.keys():
		var ke: String = str(key_e)
		if not keys.has(ke):
			keys.append(ke)

	var lines: Array[String] = ["Compare vs " + str(equipped.get("display_name", "Equipped"))]
	if keys.is_empty():
		lines.append("No comparable stats.")
		return "\n".join(lines)

	for key: String in keys:
		var delta: float = _to_float(c_stats.get(key, 0.0), 0.0) - _to_float(e_stats.get(key, 0.0), 0.0)
		if abs(delta) < 0.001:
			lines.append(" ±0 " + stat_label(key))
		elif delta > 0.0:
			lines.append(" + " + stat_value(key, delta) + " " + stat_label(key))
		else:
			lines.append(" - " + stat_value(key, abs(delta)) + " " + stat_label(key))

	return "\n".join(lines)


static func stat_line(key: String, value: Variant) -> String:
	return stat_label(key) + ": " + stat_value(key, _to_float(value, 0.0))


static func stat_label(key: String) -> String:
	var clean: String = key.strip_edges().to_lower()
	var labels: Dictionary = {
		"max_health":"Maximum Life",
		"maximum_health":"Maximum Life",
		"maximum_life":"Maximum Life",
		"maximum life":"Maximum Life",
		"max_mana":"Maximum Mana",
		"maximum_mana":"Maximum Mana",
		"maximum mana":"Maximum Mana",
		"maximum_spirit":"Maximum Spirit",
		"maximum spirit":"Maximum Spirit",
		"spell_damage":"Spell Damage",
		"spell damage":"Spell Damage",
		"attack_damage":"Attack Damage",
		"attack damage":"Attack Damage",
		"fire_damage":"Fire Damage",
		"fire damage":"Fire Damage",
		"cold_damage":"Cold Damage",
		"cold damage":"Cold Damage",
		"lightning_damage":"Lightning Damage",
		"lightning damage":"Lightning Damage",
		"void_damage":"Void Damage",
		"void damage":"Void Damage",
		"crit_chance":"Critical Chance",
		"critical chance":"Critical Chance",
		"critical_damage":"Critical Damage",
		"critical damage":"Critical Damage",
		"crit_multi":"Critical Damage",
		"fire_resistance":"Fire Resistance",
		"fire resistance":"Fire Resistance",
		"cold_resistance":"Cold Resistance",
		"cold resistance":"Cold Resistance",
		"lightning_resistance":"Lightning Resistance",
		"lightning resistance":"Lightning Resistance",
		"void_resistance":"Void Resistance",
		"void resistance":"Void Resistance",
		"movement_speed":"Movement Speed",
		"movement speed":"Movement Speed",
		"cast_speed":"Cast Speed",
		"cast speed":"Cast Speed",
		"attack_speed":"Attack Speed",
		"attack speed":"Attack Speed",
		"block_chance":"Block Chance",
		"block chance":"Block Chance",
	}
	if labels.has(clean):
		return str(labels[clean])
	return _title_case(clean.replace("_", " "))


static func stat_value(key: String, value: float) -> String:
	if _is_percent_stat(key):
		return str(int(round(value * 100.0))) + "%"
	return str(int(round(value)))


static func sort_key(item: Dictionary) -> String:
	var rarity_order: Dictionary = {"unique":"0", "rare":"1", "magic":"2", "normal":"3"}
	var rarity: String = str(item.get("rarity", "normal"))
	var slot: String = str(item.get("slot", ""))
	var level: int = 9999 - _to_int(item.get("item_level", 1), 1)
	return str(rarity_order.get(rarity, "9")) + "_" + slot + "_" + str(level) + "_" + str(item.get("display_name", ""))


static func add_random_crafted_mod(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	return add_crafted_mod(item, rng)


static func add_crafted_mod(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var safe: Dictionary = normalize_item(item)
	if _to_int(safe.get("forge_potential", 0), 0) < 3:
		return safe

	var crafts: Array = _as_array(safe.get("crafted_mods", [])).duplicate(true)
	if crafts.size() >= 2:
		return safe

	var crafted: Dictionary = AffixDBScript.crafted_affix_for_item(safe, rng)
	crafts.append(crafted)
	safe["crafted_mods"] = crafts
	safe["forge_potential"] = max(0, _to_int(safe.get("forge_potential", 0), 0) - 3)
	safe["affixes"] = _flatten_affixes(_as_array(safe.get("prefixes", [])), _as_array(safe.get("suffixes", [])), crafts)
	safe["total_stats"] = total_stats(safe)
	return safe


static func reroll_affix_values(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var safe: Dictionary = normalize_item(item)
	if _to_int(safe.get("forge_potential", 0), 0) < 4:
		return safe

	var level: int = _to_int(safe.get("item_level", 1), 1)
	var prefixes: Array = []
	var suffixes: Array = []
	var crafted: Array = []

	for value: Variant in _as_array(safe.get("prefixes", [])):
		if typeof(value) == TYPE_DICTIONARY:
			prefixes.append(AffixDBScript.reroll_affix_values(value, level, rng))
	for value2: Variant in _as_array(safe.get("suffixes", [])):
		if typeof(value2) == TYPE_DICTIONARY:
			suffixes.append(AffixDBScript.reroll_affix_values(value2, level, rng))
	for value3: Variant in _as_array(safe.get("crafted_mods", [])):
		if typeof(value3) == TYPE_DICTIONARY:
			crafted.append(AffixDBScript.reroll_affix_values(value3, level, rng))

	safe["prefixes"] = prefixes
	safe["suffixes"] = suffixes
	safe["crafted_mods"] = crafted
	safe["forge_potential"] = max(0, _to_int(safe.get("forge_potential", 0), 0) - 4)
	safe["affixes"] = _flatten_affixes(prefixes, suffixes, crafted)
	safe["total_stats"] = total_stats(safe)
	return safe


static func improve_quality(item: Dictionary, amount: int = 5) -> Dictionary:
	var safe: Dictionary = normalize_item(item)
	if _to_int(safe.get("forge_potential", 0), 0) < 1:
		return safe
	var current: int = clampi(_to_int(safe.get("quality", 0), 0), 0, 20)
	if current >= 20:
		return safe

	safe["quality"] = clampi(current + max(1, amount), 0, 20)
	safe["forge_potential"] = max(0, _to_int(safe.get("forge_potential", 0), 0) - 1)
	safe["total_stats"] = total_stats(safe)
	return safe


static func upgrade_rarity(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var safe: Dictionary = normalize_item(item)
	var rarity: String = str(safe.get("rarity", "normal"))
	var next_rarity: String = ""
	if rarity == "normal":
		next_rarity = "magic"
	elif rarity == "magic":
		next_rarity = "rare"
	else:
		return safe

	var fp_cost: int = 4 if next_rarity == "magic" else 6
	if _to_int(safe.get("forge_potential", 0), 0) < fp_cost:
		return safe

	var base: Dictionary = _base(str(safe.get("base_id", "iron_sword")))
	var target_count: int = 2 if next_rarity == "magic" else 5
	var current_ids: Array = _affix_ids(safe)
	var current_count: int = _as_array(safe.get("prefixes", [])).size() + _as_array(safe.get("suffixes", [])).size()
	var needed: int = max(0, target_count - current_count)
	var rolled: Array = AffixDBScript.roll_specific_count(base, _to_int(safe.get("item_level", 1), 1), needed, rng, current_ids)

	var prefixes: Array = _as_array(safe.get("prefixes", [])).duplicate(true)
	var suffixes: Array = _as_array(safe.get("suffixes", [])).duplicate(true)
	for value: Variant in rolled:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var affix: Dictionary = value
		if str(affix.get("slot", "prefix")) == "suffix":
			suffixes.append(affix)
		else:
			prefixes.append(affix)

	safe["rarity"] = next_rarity
	safe["prefixes"] = prefixes
	safe["suffixes"] = suffixes
	safe["forge_potential"] = max(0, _to_int(safe.get("forge_potential", 0), 0) - fp_cost)
	safe["display_name"] = _fallback_display_name(safe)
	safe["affixes"] = _flatten_affixes(prefixes, suffixes, _as_array(safe.get("crafted_mods", [])))
	safe["total_stats"] = total_stats(safe)
	return safe


static func remove_weakest_affix(item: Dictionary) -> Dictionary:
	var safe: Dictionary = normalize_item(item)
	if _to_int(safe.get("forge_potential", 0), 0) < 4:
		return safe

	var best_section: String = ""
	var best_index: int = -1
	var best_weight: float = INF

	for section: String in ["prefixes", "suffixes"]:
		var arr: Array = _as_array(safe.get(section, []))
		for i: int in range(arr.size()):
			if typeof(arr[i]) != TYPE_DICTIONARY:
				continue
			var affix: Dictionary = arr[i]
			var weight: float = AffixDBScript.stat_weight(_as_dict(affix.get("stats", {})))
			if weight < best_weight:
				best_weight = weight
				best_section = section
				best_index = i

	if best_section == "" or best_index < 0:
		return safe

	var target: Array = _as_array(safe.get(best_section, [])).duplicate(true)
	target.remove_at(best_index)
	safe[best_section] = target
	safe["forge_potential"] = max(0, _to_int(safe.get("forge_potential", 0), 0) - 4)
	safe["affixes"] = _flatten_affixes(_as_array(safe.get("prefixes", [])), _as_array(safe.get("suffixes", [])), _as_array(safe.get("crafted_mods", [])))
	safe["total_stats"] = total_stats(safe)
	return safe


static func _base(base_id: String) -> Dictionary:
	var all: Dictionary = bases()
	if all.has(base_id):
		return _as_dict(all[base_id]).duplicate(true)
	return _as_dict(all["iron_sword"]).duplicate(true)


static func _display_name(base_name: String, rarity: String, prefixes: Array, suffixes: Array, rng: RandomNumberGenerator) -> String:
	match rarity:
		"normal":
			return base_name
		"magic":
			if not prefixes.is_empty() and typeof(prefixes[0]) == TYPE_DICTIONARY:
				return str(prefixes[0].get("name", "Tempered")) + " " + base_name
			if not suffixes.is_empty() and typeof(suffixes[0]) == TYPE_DICTIONARY:
				return base_name + " of " + str(suffixes[0].get("name", "Craft"))
			return "Tempered " + base_name
		"rare":
			var rare_prefixes: Array = ["Vault-Forged", "Ash-Crowned", "Oathbound", "Black-Iron", "Saintless", "Cinder-Sealed"]
			return str(rare_prefixes[rng.randi_range(0, rare_prefixes.size() - 1)]) + " " + base_name
		"unique":
			return "Unique " + base_name
		_:
			return base_name


static func _fallback_display_name(item: Dictionary) -> String:
	var base_name: String = str(item.get("base_name", item.get("display_name", "Item")))
	var rarity: String = str(item.get("rarity", "normal"))
	if rarity == "normal":
		return base_name
	if rarity == "magic":
		var prefixes: Array = _as_array(item.get("prefixes", []))
		var suffixes: Array = _as_array(item.get("suffixes", []))
		if not prefixes.is_empty() and typeof(prefixes[0]) == TYPE_DICTIONARY:
			return str(prefixes[0].get("name", "Tempered")) + " " + base_name
		if not suffixes.is_empty() and typeof(suffixes[0]) == TYPE_DICTIONARY:
			return base_name + " of " + str(suffixes[0].get("name", "Craft"))
		return "Tempered " + base_name
	if rarity == "rare":
		return "Vault-Forged " + base_name
	if rarity == "unique":
		return "Unique " + base_name
	return base_name


static func _forge_potential(rarity: String, item_level: int, rng: RandomNumberGenerator) -> int:
	var base: int = 22 + roundi(item_level * 0.7)
	match rarity:
		"normal":
			base += 10
		"magic":
			base += 4
		"rare":
			base -= 3
		"unique":
			base -= 8
	return max(4, base + rng.randi_range(-3, 5))


static func _flatten_affixes(prefixes: Array, suffixes: Array, crafted: Array) -> Array:
	var out: Array = []
	for source: Array in [prefixes, suffixes, crafted]:
		for value: Variant in source:
			if typeof(value) == TYPE_DICTIONARY:
				out.append(value)
	return out


static func _append_affix_section(lines: Array[String], title: String, arr: Array, include_names: bool) -> void:
	if arr.is_empty():
		return
	lines.append("")
	lines.append(title)
	for value: Variant in arr:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var affix: Dictionary = value
		var stats: Dictionary = _as_dict(affix.get("stats", {}))
		if stats.is_empty():
			continue
		var prefix: String = " • "
		if include_names:
			prefix += str(affix.get("name", "Affix")) + ": "
		for key_value: Variant in stats.keys():
			var key: String = str(key_value)
			lines.append(prefix + stat_line(key, stats.get(key, 0)))


static func _affix_ids(item: Dictionary) -> Array:
	var out: Array = []
	for value: Variant in _flatten_affixes(_as_array(item.get("prefixes", [])), _as_array(item.get("suffixes", [])), _as_array(item.get("crafted_mods", []))):
		if typeof(value) == TYPE_DICTIONARY:
			out.append(str(value.get("id", "")))
	return out


static func _merge(target: Dictionary, stats: Dictionary) -> void:
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		target[key] = _to_float(target.get(key, 0.0), 0.0) + _to_float(stats.get(key_value, 0.0), 0.0)


static func _scale_value(value: Variant, mult: float) -> Variant:
	var number: float = _to_float(value, 0.0) * mult
	if abs(number) >= 1.0:
		return int(round(number))
	return snappedf(number, 0.01)


static func _is_percent_stat(key: String) -> bool:
	var clean: String = key.strip_edges().to_lower()
	if clean.find("resistance") >= 0:
		return true
	if clean.find("damage") >= 0 and clean != "damage":
		return true
	if clean.find("speed") >= 0:
		return true
	if clean.find("chance") >= 0:
		return true
	if clean.find("recovery") >= 0:
		return true
	if clean.find("rarity") >= 0:
		return true
	if clean.find("experience") >= 0:
		return true
	if clean.find("reduction") >= 0:
		return true
	if clean.find("conversion") >= 0:
		return true
	return false


static func _rarity_text(value: String) -> String:
	match value.strip_edges().to_lower():
		"normal":
			return "Normal"
		"magic":
			return "Magic"
		"rare":
			return "Rare"
		"unique":
			return "Unique"
		_:
			return _title_case(value)


static func _slot_text(value: String) -> String:
	if value == "":
		return "No Slot"
	return _title_case(value.replace("_", " "))


static func _safe_rarity(value: String) -> String:
	match value.strip_edges().to_lower():
		"magic":
			return "magic"
		"rare":
			return "rare"
		"unique":
			return "unique"
		_:
			return "normal"


static func _title_case(value: String) -> String:
	var words: PackedStringArray = value.split(" ", false)
	for i: int in range(words.size()):
		var word: String = words[i]
		if word.length() > 0:
			words[i] = word.substr(0, 1).to_upper() + word.substr(1).to_lower()
	return " ".join(words)


static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value
	return []


static func _as_dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return value
	return {}


static func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return value
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
			return value
		TYPE_FLOAT:
			return roundi(value)
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return roundi(s.to_float())
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
