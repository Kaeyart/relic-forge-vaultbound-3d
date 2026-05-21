class_name RVAffixDB3D
extends RefCounted

# patch_02: expanded ARPG affix pool.
# Values are stored as additive stat modifiers. Percent-like stats use decimals:
# 0.10 means +10% when read by combat/gem systems.

static func affixes() -> Array[Dictionary]:
	return [
		# Weapon / caster prefixes
		{"id":"weapon_spell_power", "name":"Runic", "domain":["weapon","offhand","amulet","ring1","ring2","relic"], "tags":["spell","caster"], "slot":"prefix", "min_level":1, "weight":110, "stats":{"Spell Damage":0.12}},
		{"id":"weapon_attack_power", "name":"Honed", "domain":["weapon","gloves","amulet","ring1","ring2","relic"], "tags":["attack","melee"], "slot":"prefix", "min_level":1, "weight":110, "stats":{"Attack Damage":0.12}},
		{"id":"weapon_fire_power", "name":"Ember", "domain":["weapon","offhand","amulet","ring1","ring2","relic"], "tags":["fire","spell","attack"], "slot":"prefix", "min_level":1, "weight":100, "stats":{"Fire Damage":0.11}},
		{"id":"weapon_lightning_power", "name":"Stormbound", "domain":["weapon","offhand","amulet","ring1","ring2","relic"], "tags":["lightning","spell","projectile"], "slot":"prefix", "min_level":1, "weight":95, "stats":{"Lightning Damage":0.12}},
		{"id":"weapon_void_power", "name":"Hollow", "domain":["weapon","offhand","amulet","ring1","ring2","relic"], "tags":["void","spell","control"], "slot":"prefix", "min_level":3, "weight":80, "stats":{"Void Damage":0.13}},
		{"id":"weapon_projectile_power", "name":"Piercing", "domain":["weapon","offhand","amulet","ring1","ring2","relic"], "tags":["projectile"], "slot":"prefix", "min_level":2, "weight":75, "stats":{"Projectile Damage":0.10}},
		{"id":"weapon_crit_focus", "name":"Surgical", "domain":["weapon","offhand","amulet","ring1","ring2"], "tags":["critical"], "slot":"prefix", "min_level":5, "weight":55, "stats":{"Critical Chance":0.05,"Critical Damage":0.15}},
		{"id":"weapon_battle_mage", "name":"War-Scribed", "domain":["weapon","relic","amulet"], "tags":["hybrid"], "slot":"prefix", "min_level":6, "weight":45, "stats":{"Spell Damage":0.08,"Attack Damage":0.08}},

		# Offensive suffixes
		{"id":"cast_speed", "name":"Quickened", "domain":["weapon","offhand","gloves","amulet","ring1","ring2","relic"], "tags":["caster","speed"], "slot":"suffix", "min_level":2, "weight":90, "stats":{"Cast Speed":0.07}},
		{"id":"attack_speed", "name":"Razor", "domain":["weapon","gloves","amulet","ring1","ring2"], "tags":["attack","speed"], "slot":"suffix", "min_level":2, "weight":90, "stats":{"Attack Speed":0.07}},
		{"id":"cooldown_recovery", "name":"Measured", "domain":["weapon","offhand","boots","gloves","amulet","ring1","ring2","relic"], "tags":["cooldown"], "slot":"suffix", "min_level":4, "weight":55, "stats":{"Cooldown Recovery":0.06}},
		{"id":"ignite_chance", "name":"Kindling", "domain":["weapon","offhand","gloves","amulet","ring1","ring2","relic"], "tags":["fire","ailment"], "slot":"suffix", "min_level":3, "weight":65, "stats":{"Ignite Chance":0.10,"Fire Damage":0.04}},
		{"id":"shock_chance", "name":"Conductive", "domain":["weapon","offhand","gloves","amulet","ring1","ring2","relic"], "tags":["lightning","ailment"], "slot":"suffix", "min_level":3, "weight":65, "stats":{"Shock Chance":0.10,"Lightning Damage":0.04}},
		{"id":"bleed_chance", "name":"Serrated", "domain":["weapon","gloves","amulet","ring1","ring2","relic"], "tags":["bleed","attack"], "slot":"suffix", "min_level":3, "weight":65, "stats":{"Bleed Chance":0.12,"Attack Damage":0.04}},
		{"id":"extra_projectile_minor", "name":"Forking", "domain":["weapon","offhand","amulet","relic"], "tags":["projectile"], "slot":"suffix", "min_level":9, "weight":24, "stats":{"Extra Projectiles":1.0,"Projectile Damage":-0.08}},

		# Defensive prefixes
		{"id":"life_flat", "name":"Stalwart", "domain":["head","chest","gloves","boots","amulet","ring1","ring2","relic","offhand"], "tags":["life"], "slot":"prefix", "min_level":1, "weight":120, "stats":{"Maximum Life":22.0}},
		{"id":"mana_flat", "name":"Lucid", "domain":["head","chest","gloves","boots","amulet","ring1","ring2","relic","offhand","weapon"], "tags":["mana"], "slot":"prefix", "min_level":1, "weight":105, "stats":{"Maximum Mana":18.0}},
		{"id":"armor_flat", "name":"Plated", "domain":["head","chest","gloves","boots","offhand"], "tags":["armor"], "slot":"prefix", "min_level":1, "weight":110, "stats":{"Armor":28.0}},
		{"id":"ward_flat", "name":"Warded", "domain":["head","chest","gloves","boots","offhand","relic"], "tags":["ward"], "slot":"prefix", "min_level":5, "weight":50, "stats":{"Ward":14.0}},
		{"id":"spirit_flat", "name":"Consecrated", "domain":["amulet","relic","offhand"], "tags":["spirit"], "slot":"prefix", "min_level":4, "weight":45, "stats":{"Maximum Spirit":5.0}},

		# Defensive suffixes
		{"id":"boots_speed", "name":"Fleet", "domain":["boots"], "tags":["movement"], "slot":"suffix", "min_level":1, "weight":105, "stats":{"Movement Speed":0.08}},
		{"id":"fire_res", "name":"Ashproof", "domain":["head","chest","gloves","boots","amulet","ring1","ring2","relic","offhand"], "tags":["resistance","fire"], "slot":"suffix", "min_level":1, "weight":90, "stats":{"Fire Resistance":0.12}},
		{"id":"lightning_res", "name":"Grounded", "domain":["head","chest","gloves","boots","amulet","ring1","ring2","relic","offhand"], "tags":["resistance","lightning"], "slot":"suffix", "min_level":1, "weight":90, "stats":{"Lightning Resistance":0.12}},
		{"id":"void_res", "name":"Veiled", "domain":["head","chest","gloves","boots","amulet","ring1","ring2","relic","offhand"], "tags":["resistance","void"], "slot":"suffix", "min_level":3, "weight":80, "stats":{"Void Resistance":0.12}},
		{"id":"all_res", "name":"Sanctified", "domain":["chest","amulet","ring1","ring2","relic","offhand"], "tags":["resistance"], "slot":"suffix", "min_level":8, "weight":35, "stats":{"Fire Resistance":0.07,"Lightning Resistance":0.07,"Void Resistance":0.07}},
		{"id":"block_chance", "name":"Interposing", "domain":["offhand","chest","relic"], "tags":["block"], "slot":"suffix", "min_level":4, "weight":45, "stats":{"Block Chance":0.06}},
	]

static func roll_affixes(base: Dictionary, rarity: String, item_level: int, rng: RandomNumberGenerator) -> Array[Dictionary]:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()

	var count: int = affix_count_for_rarity(rarity, rng)
	if count <= 0:
		return []

	var slot: String = str(base.get("slot", ""))
	var base_tags: Array = Array(base.get("tags", []))
	var pool: Array[Dictionary] = []
	for affix: Dictionary in affixes():
		if int(affix.get("min_level", 1)) > item_level:
			continue
		if not Array(affix.get("domain", [])).has(slot):
			continue
		pool.append(affix)

	var out: Array[Dictionary] = []
	var used: Dictionary = {}
	var prefix_count: int = 0
	var suffix_count: int = 0
	var attempts: int = max(12, count * 8)
	for _i: int in range(attempts):
		if out.size() >= count or pool.is_empty():
			break
		var pick: Dictionary = _weighted_pick(pool, base_tags, rng)
		var id: String = str(pick.get("id", ""))
		if id == "" or used.has(id):
			continue
		var kind: String = str(pick.get("slot", "prefix"))
		if kind == "prefix" and prefix_count >= 3:
			continue
		if kind == "suffix" and suffix_count >= 3:
			continue

		used[id] = true
		if kind == "prefix":
			prefix_count += 1
		else:
			suffix_count += 1

		var rolled: Dictionary = pick.duplicate(true)
		rolled["tier"] = tier_for_level(item_level)
		rolled["stats"] = _scale_stats(Dictionary(pick.get("stats", {})), int(rolled["tier"]), rng)
		out.append(rolled)

	return out

static func affix_count_for_rarity(rarity: String, rng: RandomNumberGenerator) -> int:
	match str(rarity).to_lower():
		"magic":
			return rng.randi_range(1, 2)
		"rare":
			return rng.randi_range(4, 6)
		"unique":
			return 0
		_:
			return 0

static func tier_for_level(item_level: int) -> int:
	return clampi(int(ceil(float(max(1, item_level)) / 7.0)), 1, 10)

static func _weighted_pick(pool: Array[Dictionary], base_tags: Array, rng: RandomNumberGenerator) -> Dictionary:
	var total: float = 0.0
	var weights: Array[float] = []
	for affix: Dictionary in pool:
		var weight: float = float(affix.get("weight", 50))
		for tag_value: Variant in Array(affix.get("tags", [])):
			if base_tags.has(str(tag_value)):
				weight *= 1.35
		weights.append(weight)
		total += weight
	var roll: float = rng.randf() * max(0.001, total)
	var acc: float = 0.0
	for i: int in range(pool.size()):
		acc += weights[i]
		if roll <= acc:
			return pool[i]
	return pool[pool.size() - 1]

static func _scale_stats(stats: Dictionary, tier: int, rng: RandomNumberGenerator) -> Dictionary:
	var out: Dictionary = {}
	var tier_mult: float = 1.0 + float(max(0, tier - 1)) * 0.18
	var variance: float = rng.randf_range(0.86, 1.16) if rng != null else 1.0
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		out[key] = float(stats[key_value]) * tier_mult * variance
	return out
