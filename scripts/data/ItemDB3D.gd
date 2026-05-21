class_name RVItemDB3D
extends RefCounted

const AffixDBScript := preload("res://scripts/data/AffixDB3D.gd")

static func bases() -> Dictionary:
	return {
		# Weapons
		"ash_wand": {"name":"Ash Wand", "slot":"weapon", "item_type":"weapon", "weapon_family":"wand", "tags":["weapon","spell","caster","fire","projectile"], "implicit_stats":{"Spell Damage":0.06,"Cast Speed":0.03}},
		"storm_wand": {"name":"Storm Wand", "slot":"weapon", "item_type":"weapon", "weapon_family":"wand", "tags":["weapon","spell","caster","lightning","projectile"], "implicit_stats":{"Lightning Damage":0.07,"Cast Speed":0.02}},
		"iron_sword": {"name":"Iron Sword", "slot":"weapon", "item_type":"weapon", "weapon_family":"sword", "tags":["weapon","attack","melee","bleed"], "implicit_stats":{"Attack Damage":0.07,"Attack Speed":0.03}},
		"execution_axe": {"name":"Execution Axe", "slot":"weapon", "item_type":"weapon", "weapon_family":"axe", "tags":["weapon","attack","melee","bleed","fire"], "implicit_stats":{"Attack Damage":0.11,"Attack Speed":-0.03}},
		"ash_staff": {"name":"Ash Staff", "slot":"weapon", "item_type":"weapon", "weapon_family":"staff", "tags":["weapon","spell","fire","caster","area"], "implicit_stats":{"Spell Damage":0.08,"Fire Damage":0.05}},
		"void_relic_blade": {"name":"Void-Touched Blade", "slot":"weapon", "item_type":"weapon", "weapon_family":"blade", "tags":["weapon","attack","void","melee"], "implicit_stats":{"Void Damage":0.07,"Attack Damage":0.05}},
		"penitent_scepter": {"name":"Penitent Scepter", "slot":"weapon", "item_type":"weapon", "weapon_family":"scepter", "tags":["weapon","hybrid","spell","attack","spirit"], "implicit_stats":{"Spell Damage":0.05,"Attack Damage":0.05,"Maximum Spirit":2.0}},

		# Offhands
		"storm_focus": {"name":"Storm Focus", "slot":"offhand", "item_type":"offhand", "tags":["offhand","spell","lightning","caster"], "implicit_stats":{"Lightning Damage":0.06,"Maximum Mana":10.0}},
		"ember_focus": {"name":"Ember Focus", "slot":"offhand", "item_type":"offhand", "tags":["offhand","spell","fire","caster"], "implicit_stats":{"Fire Damage":0.06,"Maximum Mana":8.0}},
		"guard_shield": {"name":"Guard Shield", "slot":"offhand", "item_type":"offhand", "tags":["offhand","shield","armor","block"], "implicit_stats":{"Armor":30.0,"Block Chance":0.05}},
		"warded_codex": {"name":"Warded Codex", "slot":"offhand", "item_type":"offhand", "tags":["offhand","spell","void","ward"], "implicit_stats":{"Void Damage":0.05,"Ward":12.0}},

		# Armor
		"iron_helm": {"name":"Iron Helm", "slot":"head", "item_type":"armor", "tags":["armor","head"], "implicit_stats":{"Armor":14.0}},
		"seer_cowl": {"name":"Seer Cowl", "slot":"head", "item_type":"armor", "tags":["armor","head","caster","mana"], "implicit_stats":{"Maximum Mana":10.0,"Cast Speed":0.02}},
		"guard_chest": {"name":"Guard Chestplate", "slot":"chest", "item_type":"armor", "tags":["armor","chest"], "implicit_stats":{"Armor":28.0,"Maximum Life":10.0}},
		"ashwoven_robe": {"name":"Ashwoven Robe", "slot":"chest", "item_type":"armor", "tags":["armor","chest","caster","fire"], "implicit_stats":{"Maximum Mana":16.0,"Fire Resistance":0.05}},
		"forge_gloves": {"name":"Forge Gloves", "slot":"gloves", "item_type":"armor", "tags":["armor","gloves","fire"], "implicit_stats":{"Armor":10.0,"Ignite Chance":0.04}},
		"duelist_grips": {"name":"Duelist Grips", "slot":"gloves", "item_type":"armor", "tags":["armor","gloves","attack"], "implicit_stats":{"Attack Speed":0.03}},
		"traveler_boots": {"name":"Traveler Boots", "slot":"boots", "item_type":"armor", "tags":["armor","boots","movement"], "implicit_stats":{"Movement Speed":0.04}},
		"iron_greaves": {"name":"Iron Greaves", "slot":"boots", "item_type":"armor", "tags":["armor","boots"], "implicit_stats":{"Armor":16.0,"Maximum Life":6.0}},

		# Jewelry: current equip code equips by slot key, so rings use ring1/ring2 directly.
		"ember_ring": {"name":"Ember Ring", "slot":"ring1", "item_type":"jewelry", "tags":["ring","fire","mana"], "implicit_stats":{"Fire Damage":0.04,"Fire Resistance":0.05}},
		"storm_ring": {"name":"Storm Ring", "slot":"ring2", "item_type":"jewelry", "tags":["ring","lightning","projectile"], "implicit_stats":{"Lightning Damage":0.04,"Shock Chance":0.04}},
		"vault_amulet": {"name":"Vault Amulet", "slot":"amulet", "item_type":"jewelry", "tags":["amulet","spirit","caster"], "implicit_stats":{"Maximum Spirit":3.0,"Spell Damage":0.03}},
		"blood_amulet": {"name":"Blood Amulet", "slot":"amulet", "item_type":"jewelry", "tags":["amulet","life","attack","bleed"], "implicit_stats":{"Maximum Life":12.0,"Bleed Chance":0.05}},

		# Relics: build-enabler slot, intentionally broad.
		"penitent_relic": {"name":"Penitent Relic", "slot":"relic", "item_type":"relic", "tags":["relic","life","spirit"], "implicit_stats":{"Maximum Life":12.0,"Maximum Spirit":2.0}},
		"cinder_relic": {"name":"Cinder Relic", "slot":"relic", "item_type":"relic", "tags":["relic","fire","area"], "implicit_stats":{"Fire Damage":0.05,"Area Size":0.05}},
		"voltaic_relic": {"name":"Voltaic Relic", "slot":"relic", "item_type":"relic", "tags":["relic","lightning","chain"], "implicit_stats":{"Lightning Damage":0.05,"Chain Count":1.0}},
	}

static func unique_items() -> Dictionary:
	return {
		"starved_meteor_wand": {
			"name":"Starved Comet Rod", "base_id":"ash_wand", "min_level":1,
			"flavor":"Fireballs become a heavier promise. The sky answers slowly, then completely.",
			"stats":{"Spell Damage":0.22,"Fire Damage":0.30,"Cast Speed":-0.12,"Area Size":0.18},
			"rules":["unique_fireball_meteor"],
		},
		"boots_of_cinder_return": {
			"name":"Boots of the Cinder Return", "base_id":"traveler_boots", "min_level":1,
			"flavor":"Every escape leaves proof that you were there.",
			"stats":{"Movement Speed":0.12,"Fire Damage":0.14,"Ignite Chance":0.15},
			"rules":["unique_dash_burning_ground"],
		},
		"corpse_conductor": {
			"name":"Corpse Conductor", "base_id":"voltaic_relic", "min_level":2,
			"flavor":"Lightning does not care whether the body is still occupied.",
			"stats":{"Lightning Damage":0.22,"Chain Count":2.0,"Shock Chance":0.18,"Maximum Mana":-10.0},
			"rules":["unique_lightning_chains_corpses"],
		},
		"mine_litany_ring": {
			"name":"Litany of Buried Sparks", "base_id":"ember_ring", "min_level":2,
			"flavor":"A prayer placed underground is still a prayer.",
			"stats":{"Fire Damage":0.18,"Area Size":0.16,"Maximum Life":-8.0},
			"rules":["unique_mines_repeat"],
		},
		"shield_of_answered_blows": {
			"name":"Shield of Answered Blows", "base_id":"guard_shield", "min_level":3,
			"flavor":"It does not stop violence. It stores it.",
			"stats":{"Armor":55.0,"Block Chance":0.10,"Fire Damage":0.10,"Movement Speed":-0.04},
			"rules":["unique_block_explosion"],
		},
		"red_debt_amulet": {
			"name":"Red Debt Amulet", "base_id":"blood_amulet", "min_level":3,
			"flavor":"Mana is a polite fiction. Blood is always available.",
			"stats":{"Spell Damage":0.16,"Attack Damage":0.16,"Maximum Life":28.0,"Maximum Mana":-35.0},
			"rules":["unique_spend_life_before_mana"],
		},
		"hollow_executioner": {
			"name":"Hollow Executioner", "base_id":"execution_axe", "min_level":4,
			"flavor":"It is lighter after the first confession.",
			"stats":{"Attack Damage":0.34,"Bleed Chance":0.22,"Void Damage":0.12,"Cast Speed":-0.10},
			"rules":["unique_execute_low_life"],
		},
		"glass_bell_focus": {
			"name":"Glass Bell Focus", "base_id":"warded_codex", "min_level":5,
			"flavor":"Every spell rings twice. Every mistake does too.",
			"stats":{"Spell Damage":0.18,"Cast Speed":0.10,"Maximum Mana":20.0,"Armor":-20.0},
			"rules":["unique_echo_first_spell"],
		},
		"penitent_second_heart": {
			"name":"The Second Heart", "base_id":"penitent_relic", "min_level":6,
			"flavor":"It beats only when the first one fails.",
			"stats":{"Maximum Life":46.0,"Maximum Spirit":6.0,"Cooldown Recovery":0.08},
			"rules":["unique_cheat_death_cooldown"],
		},
		"storm_thread_ring": {
			"name":"Storm Thread Ring", "base_id":"storm_ring", "min_level":7,
			"flavor":"Pull once. The whole room notices.",
			"stats":{"Lightning Damage":0.20,"Projectile Damage":0.12,"Extra Projectiles":1.0,"Shock Chance":0.12},
			"rules":["unique_projectiles_seek_shocked"],
		},
	}

static func starter_bases() -> Array[String]:
	return ["ash_wand", "storm_focus", "seer_cowl", "ashwoven_robe", "traveler_boots", "ember_ring", "vault_amulet"]

static func make_starter_weapon(rng: RandomNumberGenerator) -> Dictionary:
	return make_item("ash_wand", 1, "magic", rng)

static func random_equipment_drop(item_level: int, rng: RandomNumberGenerator, boss: bool = false) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var unique_chance: float = 0.018 + float(item_level) * 0.0015
	if boss:
		unique_chance += 0.055
	if rng.randf() < unique_chance:
		return random_unique_drop(item_level, rng)

	var keys: Array = bases().keys()
	var base_id: String = str(keys[rng.randi_range(0, keys.size() - 1)])
	var rarity: String = roll_rarity(rng, boss)
	return make_item(base_id, item_level, rarity, rng)

static func roll_rarity(rng: RandomNumberGenerator, boss: bool = false, rarity_bonus: float = 0.0) -> String:
	var roll: float = rng.randf()
	var rare_chance: float = 0.12 + rarity_bonus
	var magic_chance: float = 0.48 + rarity_bonus
	if boss:
		rare_chance = 0.78
		magic_chance = 1.0
	if roll < rare_chance:
		return "rare"
	if roll < magic_chance:
		return "magic"
	return "normal"

static func random_unique_drop(item_level: int, rng: RandomNumberGenerator) -> Dictionary:
	var pool: Array[String] = []
	for key_value: Variant in unique_items().keys():
		var key: String = str(key_value)
		var data: Dictionary = Dictionary(unique_items()[key])
		if int(data.get("min_level", 1)) <= item_level:
			pool.append(key)
	if pool.is_empty():
		pool.append("starved_meteor_wand")
	return make_unique(str(pool[rng.randi_range(0, pool.size() - 1)]), item_level, rng)

static func make_unique(unique_id: String, item_level: int, rng: RandomNumberGenerator) -> Dictionary:
	var uniques: Dictionary = unique_items()
	var unique: Dictionary = Dictionary(uniques.get(unique_id, uniques["starved_meteor_wand"])).duplicate(true)
	var base_id: String = str(unique.get("base_id", "ash_wand"))
	var base: Dictionary = Dictionary(bases().get(base_id, bases()["ash_wand"])).duplicate(true)
	var item: Dictionary = _base_item_shell(base_id, base, item_level, "unique", rng)
	item["unique_id"] = unique_id
	item["display_name"] = str(unique.get("name", base.get("name", "Unique")))
	item["unique_text"] = str(unique.get("flavor", ""))
	item["unique_rules"] = Array(unique.get("rules", [])).duplicate(true)
	item["prefixes"] = []
	item["suffixes"] = []
	item["crafted_mods"] = []
	item["unique_stats"] = Dictionary(unique.get("stats", {})).duplicate(true)
	item["forge_potential"] = max(2, int(round(float(item.get("forge_potential", 8)) * 0.45)))
	item["total_stats"] = total_stats(item)
	return item

static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var base: Dictionary = Dictionary(bases().get(base_id, bases()["iron_sword"])).duplicate(true)
	var clean_rarity: String = str(rarity).to_lower()
	if clean_rarity == "unique":
		return random_unique_drop(item_level, rng)
	var item: Dictionary = _base_item_shell(base_id, base, item_level, clean_rarity, rng)
	var prefixes: Array[Dictionary] = []
	var suffixes: Array[Dictionary] = []	
	for affix: Dictionary in AffixDBScript.roll_affixes(base, clean_rarity, item_level, rng):
		if str(affix.get("slot", "prefix")) == "suffix":
			suffixes.append(affix)
		else:
			prefixes.append(affix)
	item["prefixes"] = prefixes
	item["suffixes"] = suffixes
	item["display_name"] = _display_name(str(base.get("name", base_id)), clean_rarity, prefixes, suffixes, rng)
	item["total_stats"] = total_stats(item)
	return item

static func _base_item_shell(base_id: String, base: Dictionary, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	return {
		"uid": "item_" + str(Time.get_ticks_usec()) + "_" + str(rng.randi()),
		"kind": "item",
		"item_kind": "equipment",
		"category": "equipment",
		"base_id": base_id,
		"base_name": str(base.get("name", base_id)),
		"display_name": str(base.get("name", base_id)),
		"rarity": rarity,
		"item_level": max(1, item_level),
		"required_level": max(1, int(ceil(float(max(1, item_level)) * 0.72))),
		"slot": str(base.get("slot", "")),
		"item_type": str(base.get("item_type", "")),
		"weapon_family": str(base.get("weapon_family", "")),
		"tags": Array(base.get("tags", [])).duplicate(true),
		"implicit_stats": Dictionary(base.get("implicit_stats", {})).duplicate(true),
		"prefixes": [],
		"suffixes": [],
		"crafted_mods": [],
		"unique_stats": {},
		"unique_rules": [],
		"quality": 0,
		"sockets": _socket_count_for_item(base, item_level, rarity, rng),
		"forge_potential": _forge_potential(rarity, item_level, rng),
		"total_stats": {},
	}

static func _display_name(base_name: String, rarity: String, prefixes: Array, suffixes: Array, rng: RandomNumberGenerator) -> String:
	if rarity == "normal":
		return base_name
	if rarity == "magic":
		if not prefixes.is_empty():
			return str(Dictionary(prefixes[0]).get("name", "Tempered")) + " " + base_name
		if not suffixes.is_empty():
			return base_name + " of " + str(Dictionary(suffixes[0]).get("name", "Focus"))
		return "Tempered " + base_name
	if rarity == "rare":
		var first: Array[String] = ["Vault", "Ash", "Gilded", "Hollow", "Crimson", "Runic", "Dread", "Iron", "Saint", "Storm"]
		var second: Array[String] = ["Brand", "Oath", "Spire", "Grasp", "Mark", "Song", "Burden", "Crown", "Vow", "Engine"]
		return first[rng.randi_range(0, first.size() - 1)] + " " + second[rng.randi_range(0, second.size() - 1)] + " " + base_name
	return base_name

static func _socket_count_for_item(base: Dictionary, item_level: int, rarity: String, rng: RandomNumberGenerator) -> int:
	var item_type: String = str(base.get("item_type", ""))
	var base_count: int = 0
	match item_type:
		"weapon", "offhand": base_count = 2
		"armor": base_count = 1
		"jewelry", "relic": base_count = 1
		_: base_count = 0
	if rarity == "rare" or rarity == "unique":
		base_count += 1
	if item_level >= 8 and rng.randf() < 0.35:
		base_count += 1
	return clampi(base_count, 0, 4)

static func _forge_potential(rarity: String, item_level: int, rng: RandomNumberGenerator) -> int:
	var base: int = 18 + int(float(item_level) * 0.85)
	match rarity:
		"normal": base += 12
		"magic": base += 6
		"rare": base -= 1
		"unique": base -= 8
	return max(2, base + rng.randi_range(-3, 5))

static func total_stats(item: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	_merge(out, Dictionary(item.get("implicit_stats", {})))
	_merge(out, Dictionary(item.get("unique_stats", {})))
	for affix: Dictionary in Array(item.get("prefixes", [])):
		_merge(out, Dictionary(affix.get("stats", {})))
	for affix2: Dictionary in Array(item.get("suffixes", [])):
		_merge(out, Dictionary(affix2.get("stats", {})))
	for crafted: Dictionary in Array(item.get("crafted_mods", [])):
		_merge(out, Dictionary(crafted.get("stats", {})))
	var quality: float = float(item.get("quality", 0)) / 100.0
	if quality > 0.0:
		for key_value: Variant in out.keys():
			var key: String = str(key_value)
			if _quality_scales_stat(key):
				out[key] = float(out[key]) * (1.0 + quality)
	return out

static func _merge(target: Dictionary, stats: Dictionary) -> void:
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		target[key] = float(target.get(key, 0.0)) + float(stats[key_value])

static func _quality_scales_stat(key: String) -> bool:
	return ["Armor", "Ward", "Attack Damage", "Spell Damage", "Fire Damage", "Lightning Damage", "Void Damage", "Projectile Damage"].has(key)

static func item_detail(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."
	var text: String = str(item.get("display_name", "Item")) + "\n"
	text += str(item.get("rarity", "normal")).capitalize() + " " + str(item.get("slot", "")) + " · ilvl " + str(item.get("item_level", 1)) + " · FP " + str(item.get("forge_potential", 0)) + " · Sockets " + str(item.get("sockets", 0)) + "\n"
	if str(item.get("unique_text", "")) != "":
		text += "\n" + str(item.get("unique_text", "")) + "\n"
	if not Dictionary(item.get("implicit_stats", {})).is_empty():
		text += "\nImplicit: " + _stats_text(Dictionary(item.get("implicit_stats", {}))) + "\n"
	if not Dictionary(item.get("unique_stats", {})).is_empty():
		text += "\nUnique: " + _stats_text(Dictionary(item.get("unique_stats", {}))) + "\n"
	if not Array(item.get("prefixes", [])).is_empty():
		text += "\nPrefixes:\n"
		for p: Dictionary in Array(item.get("prefixes", [])):
			text += " " + str(p.get("name", "Affix")) + " T" + str(p.get("tier", 1)) + " — " + _stats_text(Dictionary(p.get("stats", {}))) + "\n"
	if not Array(item.get("suffixes", [])).is_empty():
		text += "\nSuffixes:\n"
		for s: Dictionary in Array(item.get("suffixes", [])):
			text += " " + str(s.get("name", "Affix")) + " T" + str(s.get("tier", 1)) + " — " + _stats_text(Dictionary(s.get("stats", {}))) + "\n"
	if not Array(item.get("crafted_mods", [])).is_empty():
		text += "\nCrafted:\n"
		for c: Dictionary in Array(item.get("crafted_mods", [])):
			text += " " + str(c.get("name", "Craft")) + " — " + _stats_text(Dictionary(c.get("stats", {}))) + "\n"
	if not Array(item.get("unique_rules", [])).is_empty():
		text += "\nRules: " + ", ".join(PackedStringArray(_string_array(Array(item.get("unique_rules", []))))) + "\n"
	text += "\nTotal: " + _stats_text(Dictionary(item.get("total_stats", {})))
	return text

static func _stats_text(stats: Dictionary) -> String:
	if stats.is_empty():
		return "none"
	var parts: Array[String] = []
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		var value: float = float(stats[key_value])
		var sign: String = "+" if value >= 0.0 else ""
		if _is_percent_stat(key):
			parts.append(key + " " + sign + str(snappedf(value * 100.0, 0.1)) + "%")
		else:
			parts.append(key + " " + sign + str(int(round(value))))
	return ", ".join(parts)

static func _is_percent_stat(key: String) -> bool:
	return not ["Maximum Life", "Maximum Mana", "Maximum Spirit", "Armor", "Ward", "Extra Projectiles", "Chain Count"].has(key)

static func add_random_crafted_mod(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if item.is_empty():
		return item
	if int(item.get("forge_potential", 0)) <= 0:
		return item
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var slot: String = str(item.get("slot", ""))
	var candidates: Array[Dictionary] = [
		{"name":"Sealed Life", "stats":{"Maximum Life":14.0}},
		{"name":"Sealed Clarity", "stats":{"Maximum Mana":12.0}},
	]
	match slot:
		"weapon":
			candidates.append({"name":"Sealed Power", "stats":{"Spell Damage":0.08,"Attack Damage":0.08}})
			candidates.append({"name":"Sealed Flame", "stats":{"Fire Damage":0.10}})
		"offhand":
			candidates.append({"name":"Sealed Ward", "stats":{"Ward":14.0,"Block Chance":0.03}})
		"boots":
			candidates.append({"name":"Sealed Stride", "stats":{"Movement Speed":0.05}})
		"gloves":
			candidates.append({"name":"Sealed Speed", "stats":{"Cast Speed":0.04,"Attack Speed":0.04}})
		"amulet", "ring1", "ring2", "relic":
			candidates.append({"name":"Sealed Spark", "stats":{"Lightning Damage":0.08,"Shock Chance":0.05}})
			candidates.append({"name":"Sealed Spirit", "stats":{"Maximum Spirit":3.0}})
	var pick: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]
	var crafts: Array = Array(item.get("crafted_mods", [])).duplicate(true)
	crafts.append({"id":"crafted_" + str(pick.get("name", "mod")).to_lower().replace(" ", "_"), "name":str(pick.get("name", "Craft")), "stats":Dictionary(pick.get("stats", {}))})
	item["crafted_mods"] = crafts
	item["forge_potential"] = max(0, int(item.get("forge_potential", 0)) - rng.randi_range(2, 4))
	item["total_stats"] = total_stats(item)
	return item

static func reforge_item(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if item.is_empty():
		return item
	var rarity: String = str(item.get("rarity", "normal"))
	if rarity == "unique":
		return item
	return make_item(str(item.get("base_id", "iron_sword")), int(item.get("item_level", 1)), "rare", rng)

static func polish_item(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return item
	var fp: int = int(item.get("forge_potential", 0))
	if fp <= 0:
		return item
	item["quality"] = clampi(int(item.get("quality", 0)) + 4, 0, 20)
	item["forge_potential"] = max(0, fp - 1)
	item["total_stats"] = total_stats(item)
	return item

static func _string_array(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value: Variant in values:
		out.append(str(value))
	return out
