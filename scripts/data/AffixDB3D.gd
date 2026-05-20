class_name RVAffixDB3D
extends RefCounted

static func affixes() -> Array:
	return [
		{"id":"weapon_phys", "name":"Honed", "domain":["weapon"], "slot":"prefix", "min_level":1, "stats":{"Attack Damage":0.16}, "groups":["weapon","attack"]},
		{"id":"weapon_spell", "name":"Runic", "domain":["weapon","offhand","amulet","relic"], "slot":"prefix", "min_level":1, "stats":{"Spell Damage":0.16}, "groups":["caster"]},
		{"id":"weapon_fire", "name":"Ember", "domain":["weapon","ring","amulet","relic"], "slot":"prefix", "min_level":1, "stats":{"Fire Damage":0.15}, "groups":["fire"]},
		{"id":"weapon_lightning", "name":"Stormbound", "domain":["weapon","offhand","ring","amulet","relic"], "slot":"prefix", "min_level":1, "stats":{"Lightning Damage":0.15}, "groups":["lightning"]},
		{"id":"weapon_void", "name":"Hollow", "domain":["weapon","offhand","ring","amulet","relic"], "slot":"prefix", "min_level":4, "stats":{"Void Damage":0.17}, "groups":["void"]},
		{"id":"weapon_crit", "name":"Keen", "domain":["weapon","ring","amulet"], "slot":"suffix", "min_level":4, "stats":{"Critical Chance":0.06}, "groups":["crit"]},
		{"id":"weapon_crit_multi", "name":"Executioner's", "domain":["weapon","amulet"], "slot":"suffix", "min_level":8, "stats":{"Critical Damage":0.18}, "groups":["crit"]},
		{"id":"weapon_cast_speed", "name":"Quickened", "domain":["weapon","offhand","ring","amulet"], "slot":"suffix", "min_level":2, "stats":{"Cast Speed":0.08}, "groups":["speed","caster"]},
		{"id":"weapon_attack_speed", "name":"Razor", "domain":["weapon","gloves","ring"], "slot":"suffix", "min_level":2, "stats":{"Attack Speed":0.08}, "groups":["speed","attack"]},
		{"id":"weapon_projectile", "name":"Piercing", "domain":["weapon","amulet","ring"], "slot":"suffix", "min_level":3, "stats":{"Projectile Damage":0.12}, "groups":["projectile"]},
		{"id":"conversion_fire_lightning", "name":"Stormlit", "domain":["weapon","amulet","relic"], "slot":"prefix", "min_level":10, "stats":{"Fire To Lightning Conversion":0.25, "Lightning Damage":0.08}, "groups":["conversion","lightning"]},
		{"id":"conversion_spell_void", "name":"Abyssal", "domain":["weapon","offhand","amulet","relic"], "slot":"prefix", "min_level":12, "stats":{"Spell To Void Conversion":0.20, "Void Damage":0.10}, "groups":["conversion","void"]},

		{"id":"armor_life", "name":"Stalwart", "domain":["head","chest","gloves","boots","ring","amulet","relic"], "slot":"prefix", "min_level":1, "stats":{"Maximum Life":24.0}, "groups":["life"]},
		{"id":"armor_mana", "name":"Lucid", "domain":["head","chest","gloves","boots","ring","amulet","relic","offhand"], "slot":"prefix", "min_level":1, "stats":{"Maximum Mana":20.0}, "groups":["mana"]},
		{"id":"armor_rating", "name":"Plated", "domain":["head","chest","gloves","boots"], "slot":"prefix", "min_level":1, "stats":{"Armor":30.0}, "groups":["armor"]},
		{"id":"armor_recovery", "name":"Mending", "domain":["head","chest","gloves","boots","ring","amulet","relic"], "slot":"suffix", "min_level":5, "stats":{"Life Recovery":0.08}, "groups":["recovery"]},
		{"id":"boots_speed", "name":"Fleet", "domain":["boots"], "slot":"suffix", "min_level":1, "stats":{"Movement Speed":0.08}, "groups":["movement"]},
		{"id":"gloves_skill_speed", "name":"Practiced", "domain":["gloves"], "slot":"suffix", "min_level":5, "stats":{"Skill Speed":0.07}, "groups":["speed"]},

		{"id":"res_fire", "name":"Ashproof", "domain":["head","chest","gloves","boots","ring","amulet","relic","offhand"], "slot":"suffix", "min_level":1, "stats":{"Fire Resistance":0.14}, "groups":["resistance","fire"]},
		{"id":"res_cold", "name":"Frostguard", "domain":["head","chest","gloves","boots","ring","amulet","relic","offhand"], "slot":"suffix", "min_level":1, "stats":{"Cold Resistance":0.14}, "groups":["resistance","cold"]},
		{"id":"res_lightning", "name":"Grounded", "domain":["head","chest","gloves","boots","ring","amulet","relic","offhand"], "slot":"suffix", "min_level":1, "stats":{"Lightning Resistance":0.14}, "groups":["resistance","lightning"]},
		{"id":"res_void", "name":"Warded", "domain":["head","chest","gloves","boots","ring","amulet","relic","offhand"], "slot":"suffix", "min_level":4, "stats":{"Void Resistance":0.14}, "groups":["resistance","void"]},

		{"id":"offhand_block", "name":"Bulwark", "domain":["offhand"], "slot":"suffix", "min_level":1, "stats":{"Block Chance":0.07}, "groups":["block"]},
		{"id":"offhand_spell_block", "name":"Sanctified", "domain":["offhand"], "slot":"suffix", "min_level":6, "stats":{"Spell Block Chance":0.05}, "groups":["block","spell"]},
		{"id":"offhand_mana_recovery", "name":"Clear", "domain":["offhand","ring","amulet"], "slot":"suffix", "min_level":4, "stats":{"Mana Recovery":0.09}, "groups":["mana","recovery"]},

		{"id":"spirit", "name":"Consecrated", "domain":["amulet","relic","offhand"], "slot":"prefix", "min_level":4, "stats":{"Maximum Spirit":5.0}, "groups":["spirit"]},
		{"id":"jewelry_item_rarity", "name":"Gleaming", "domain":["ring","amulet","relic"], "slot":"suffix", "min_level":6, "stats":{"Item Rarity":0.10}, "groups":["loot"]},
		{"id":"jewelry_gem_xp", "name":"Studious", "domain":["ring","amulet","relic"], "slot":"suffix", "min_level":8, "stats":{"Gem Experience":0.10}, "groups":["gem"]},
		{"id":"jewelry_resource_efficiency", "name":"Efficient", "domain":["ring","amulet","relic","offhand"], "slot":"suffix", "min_level":8, "stats":{"Mana Cost Reduction":0.06}, "groups":["resource"]},
	]


static func roll_affixes(base: Dictionary, rarity: String, item_level: int, rng: RandomNumberGenerator) -> Array:
	var count: int = affix_count_for_rarity(rarity, rng)
	return roll_specific_count(base, item_level, count, rng)


static func affix_count_for_rarity(rarity: String, rng: RandomNumberGenerator) -> int:
	match rarity.strip_edges().to_lower():
		"magic":
			return rng.randi_range(1, 2)
		"rare":
			return rng.randi_range(4, 6)
		_:
			return 0


static func roll_specific_count(base: Dictionary, item_level: int, count: int, rng: RandomNumberGenerator, used_ids: Array = []) -> Array:
	var slot: String = str(base.get("slot", ""))
	var tags: Array = _as_array(base.get("tags", []))
	var pool: Array = []

	for value: Variant in affixes():
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var affix: Dictionary = value
		if int(affix.get("min_level", 1)) > item_level:
			continue
		if not _domain_matches(affix, slot, tags):
			continue
		if used_ids.has(str(affix.get("id", ""))):
			continue
		pool.append(affix)

	var out: Array = []
	var used: Dictionary = {}
	var prefix_count: int = 0
	var suffix_count: int = 0

	for existing: Variant in used_ids:
		used[str(existing)] = true

	var attempts: int = max(12, count * 12)
	for i: int in range(attempts):
		if out.size() >= count or pool.is_empty():
			break

		var pick: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
		var id: String = str(pick.get("id", ""))
		if id == "" or used.has(id):
			continue

		var affix_slot: String = str(pick.get("slot", "prefix"))
		if affix_slot == "prefix" and prefix_count >= 3:
			continue
		if affix_slot == "suffix" and suffix_count >= 3:
			continue

		used[id] = true
		if affix_slot == "prefix":
			prefix_count += 1
		else:
			suffix_count += 1

		out.append(roll_affix_values(pick, item_level, rng))

	return out


static func roll_affix_values(template: Dictionary, item_level: int, rng: RandomNumberGenerator) -> Dictionary:
	var rolled: Dictionary = template.duplicate(true)
	var tier: int = max(1, int(ceil(item_level / 7.0)))
	var quality_roll: float = 0.84 + rng.randf() * 0.32
	var tier_mult: float = 1.0 + float(max(0, tier - 1)) * 0.17

	var stats: Dictionary = {}
	var template_stats: Dictionary = _as_dict(template.get("stats", {}))
	for key_value: Variant in template_stats.keys():
		var key: String = str(key_value)
		var base_value: float = _to_float(template_stats.get(key, 0.0), 0.0)
		stats[key] = _clean_value(base_value * tier_mult * quality_roll)

	rolled["tier"] = tier
	rolled["roll_quality"] = int(round(quality_roll * 100.0))
	rolled["stats"] = stats
	return rolled


static func reroll_affix_values(affix: Dictionary, item_level: int, rng: RandomNumberGenerator) -> Dictionary:
	var template: Dictionary = affix.duplicate(true)
	return roll_affix_values(template, item_level, rng)


static func crafted_affix_for_item(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var slot: String = str(item.get("slot", ""))
	var item_level: int = max(1, _to_int(item.get("item_level", 1), 1))

	var options: Array = []
	if slot == "weapon":
		options = [
			{"id":"crafted_spell_damage", "name":"Sealed Power", "slot":"crafted", "stats":{"Spell Damage":0.10}},
			{"id":"crafted_attack_damage", "name":"Sealed Edge", "slot":"crafted", "stats":{"Attack Damage":0.10}},
			{"id":"crafted_crit", "name":"Sealed Precision", "slot":"crafted", "stats":{"Critical Chance":0.04}},
		]
	elif slot == "offhand":
		options = [
			{"id":"crafted_block", "name":"Sealed Guard", "slot":"crafted", "stats":{"Block Chance":0.05}},
			{"id":"crafted_mana", "name":"Sealed Clarity", "slot":"crafted", "stats":{"Maximum Mana":16.0}},
			{"id":"crafted_spell_damage", "name":"Sealed Power", "slot":"crafted", "stats":{"Spell Damage":0.08}},
		]
	elif slot == "boots":
		options = [
			{"id":"crafted_speed", "name":"Sealed Stride", "slot":"crafted", "stats":{"Movement Speed":0.05}},
			{"id":"crafted_life", "name":"Sealed Life", "slot":"crafted", "stats":{"Maximum Life":18.0}},
		]
	elif slot == "ring" or slot == "amulet" or slot == "relic":
		options = [
			{"id":"crafted_spirit", "name":"Sealed Spirit", "slot":"crafted", "stats":{"Maximum Spirit":3.0}},
			{"id":"crafted_rarity", "name":"Sealed Treasure", "slot":"crafted", "stats":{"Item Rarity":0.06}},
			{"id":"crafted_mana", "name":"Sealed Clarity", "slot":"crafted", "stats":{"Maximum Mana":18.0}},
		]
	else:
		options = [
			{"id":"crafted_life", "name":"Sealed Life", "slot":"crafted", "stats":{"Maximum Life":20.0}},
			{"id":"crafted_armor", "name":"Sealed Iron", "slot":"crafted", "stats":{"Armor":24.0}},
			{"id":"crafted_resistance", "name":"Sealed Ward", "slot":"crafted", "stats":{"Fire Resistance":0.08, "Lightning Resistance":0.08}},
		]

	var pick: Dictionary = options[rng.randi_range(0, options.size() - 1)]
	return roll_affix_values(pick, item_level, rng)


static func stat_weight(stats: Dictionary) -> float:
	var total: float = 0.0
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		var value: float = abs(_to_float(stats.get(key, 0.0), 0.0))
		if value < 1.0:
			total += value * 100.0
		else:
			total += value
	return total


static func _domain_matches(affix: Dictionary, slot: String, tags: Array) -> bool:
	var domains: Array = _as_array(affix.get("domain", []))
	if domains.has(slot):
		return true
	for tag_value: Variant in tags:
		if domains.has(str(tag_value)):
			return true
	return false


static func _clean_value(value: float) -> Variant:
	if abs(value) >= 1.0:
		return int(round(value))
	return snappedf(value, 0.01)


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
