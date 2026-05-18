class_name RVAffixDB3D
extends RefCounted

static func affixes() -> Array[Dictionary]:
	return [
		{"id":"weapon_added_fire", "name":"Ember", "domain":["weapon"], "tags":["fire","attack","spell"], "slot":"prefix", "min_level":1, "stats":{"Fire Damage":0.10}},
		{"id":"weapon_spell_power", "name":"Runic", "domain":["weapon","offhand","relic","amulet"], "tags":["spell"], "slot":"prefix", "min_level":1, "stats":{"Spell Damage":0.12}},
		{"id":"weapon_attack_power", "name":"Honed", "domain":["weapon"], "tags":["attack","melee"], "slot":"prefix", "min_level":1, "stats":{"Attack Damage":0.12}},
		{"id":"weapon_projectile", "name":"Piercing", "domain":["weapon","amulet","ring"], "tags":["projectile"], "slot":"suffix", "min_level":2, "stats":{"Projectile Damage":0.10}},
		{"id":"weapon_cast_speed", "name":"Quickened", "domain":["weapon","offhand","ring","amulet"], "tags":["caster"], "slot":"suffix", "min_level":2, "stats":{"Cast Speed":0.07}},
		{"id":"weapon_attack_speed", "name":"Razor", "domain":["weapon","gloves","ring"], "tags":["attack"], "slot":"suffix", "min_level":2, "stats":{"Attack Speed":0.07}},
		{"id":"all_lightning", "name":"Stormbound", "domain":["weapon","offhand","ring","amulet","relic"], "tags":["lightning"], "slot":"prefix", "min_level":1, "stats":{"Lightning Damage":0.12}},
		{"id":"all_void", "name":"Hollow", "domain":["weapon","offhand","ring","amulet","relic"], "tags":["void"], "slot":"prefix", "min_level":3, "stats":{"Void Damage":0.13}},
		{"id":"armor_life", "name":"Stalwart", "domain":["head","chest","gloves","boots","ring","amulet","relic"], "tags":["life"], "slot":"prefix", "min_level":1, "stats":{"Maximum Life":22.0}},
		{"id":"armor_mana", "name":"Lucid", "domain":["head","chest","gloves","boots","ring","amulet","relic","offhand"], "tags":["mana"], "slot":"prefix", "min_level":1, "stats":{"Maximum Mana":18.0}},
		{"id":"armor_rating", "name":"Plated", "domain":["head","chest","gloves","boots"], "tags":["armor"], "slot":"prefix", "min_level":1, "stats":{"Armor":28.0}},
		{"id":"boots_speed", "name":"Fleet", "domain":["boots"], "tags":["movement"], "slot":"suffix", "min_level":1, "stats":{"Movement Speed":0.08}},
		{"id":"res_fire", "name":"Ashproof", "domain":["head","chest","gloves","boots","ring","amulet","relic"], "tags":["resistance","fire"], "slot":"suffix", "min_level":1, "stats":{"Fire Resistance":0.12}},
		{"id":"res_lightning", "name":"Grounded", "domain":["head","chest","gloves","boots","ring","amulet","relic"], "tags":["resistance","lightning"], "slot":"suffix", "min_level":1, "stats":{"Lightning Resistance":0.12}},
		{"id":"res_void", "name":"Warded", "domain":["head","chest","gloves","boots","ring","amulet","relic"], "tags":["resistance","void"], "slot":"suffix", "min_level":3, "stats":{"Void Resistance":0.12}},
		{"id":"cooldown", "name":"Measured", "domain":["boots","gloves","ring","amulet","relic"], "tags":["cooldown"], "slot":"suffix", "min_level":4, "stats":{"Cooldown Recovery":0.06}},
		{"id":"spirit", "name":"Consecrated", "domain":["amulet","relic","offhand"], "tags":["spirit"], "slot":"prefix", "min_level":4, "stats":{"Maximum Spirit":5.0}}
	]

static func roll_affixes(base: Dictionary, rarity: String, item_level: int, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var slot: String = str(base.get("slot", ""))
	var count: int = 0
	match rarity:
		"magic": count = rng.randi_range(1, 2)
		"rare": count = rng.randi_range(3, 5)
		"unique": count = 0
		_: count = 0
	var out: Array[Dictionary] = []
	var used: Dictionary = {}
	var prefix_count: int = 0
	var suffix_count: int = 0
	var pool: Array[Dictionary] = []
	for affix: Dictionary in affixes():
		if int(affix.get("min_level", 1)) > item_level:
			continue
		if not Array(affix.get("domain", [])).has(slot):
			continue
		pool.append(affix)
	for i: int in range(count * 5):
		if out.size() >= count or pool.is_empty():
			break
		var pick: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
		var id: String = str(pick.get("id", ""))
		if id == "" or used.has(id):
			continue
		var kind: String = str(pick.get("slot", "prefix"))
		if kind == "prefix" and prefix_count >= 3:
			continue
		if kind == "suffix" and suffix_count >= 3:
			continue
		used[id] = true
		if kind == "prefix": prefix_count += 1
		else: suffix_count += 1
		var rolled: Dictionary = pick.duplicate(true)
		rolled["tier"] = max(1, int(ceil(float(item_level) / 8.0)))
		rolled["stats"] = _scale_stats(Dictionary(pick.get("stats", {})), int(rolled["tier"]))
		out.append(rolled)
	return out

static func _scale_stats(stats: Dictionary, tier: int) -> Dictionary:
	var out: Dictionary = {}
	var mult: float = 1.0 + float(max(0, tier - 1)) * 0.18
	for key_value: Variant in stats.keys():
		out[str(key_value)] = float(stats[key_value]) * mult
	return out
