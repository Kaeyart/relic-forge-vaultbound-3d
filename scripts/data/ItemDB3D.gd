class_name RVItemDB3D
extends RefCounted

const AffixDBScript := preload("res://scripts/data/AffixDB3D.gd")

static func bases() -> Dictionary:
	return {
		"iron_sword":{"name":"Iron Sword", "slot":"weapon", "item_type":"weapon", "tags":["weapon","attack","melee"], "implicit_stats":{"Attack Damage":0.05}},
		"ash_staff":{"name":"Ash Staff", "slot":"weapon", "item_type":"weapon", "tags":["weapon","spell","fire","caster"], "implicit_stats":{"Spell Damage":0.06,"Fire Damage":0.04}},
		"storm_focus":{"name":"Storm Focus", "slot":"offhand", "item_type":"offhand", "tags":["offhand","spell","lightning","caster"], "implicit_stats":{"Lightning Damage":0.05,"Maximum Mana":10.0}},
		"void_relic_blade":{"name":"Void-Touched Blade", "slot":"weapon", "item_type":"weapon", "tags":["weapon","attack","void","melee"], "implicit_stats":{"Void Damage":0.05}},
		"iron_helm":{"name":"Iron Helm", "slot":"head", "item_type":"armor", "tags":["armor","head"], "implicit_stats":{"Armor":12.0}},
		"guard_chest":{"name":"Guard Chestplate", "slot":"chest", "item_type":"armor", "tags":["armor","chest"], "implicit_stats":{"Armor":24.0,"Maximum Life":8.0}},
		"forge_gloves":{"name":"Forge Gloves", "slot":"gloves", "item_type":"armor", "tags":["armor","gloves"], "implicit_stats":{"Armor":10.0}},
		"traveler_boots":{"name":"Traveler Boots", "slot":"boots", "item_type":"armor", "tags":["armor","boots","movement"], "implicit_stats":{"Movement Speed":0.03}},
		"ember_ring":{"name":"Ember Ring", "slot":"ring", "item_type":"jewelry", "tags":["ring","fire","mana"], "implicit_stats":{"Fire Resistance":0.05}},
		"vault_amulet":{"name":"Vault Amulet", "slot":"amulet", "item_type":"jewelry", "tags":["amulet","spirit","caster"], "implicit_stats":{"Maximum Spirit":3.0}},
		"penitent_relic":{"name":"Penitent Relic", "slot":"relic", "item_type":"relic", "tags":["relic","life","spirit"], "implicit_stats":{"Maximum Life":12.0}}
	}

static func starter_bases() -> Array[String]:
	return ["ash_staff", "storm_focus", "iron_helm", "guard_chest", "traveler_boots", "ember_ring", "vault_amulet"]

static func make_starter_weapon(rng: RandomNumberGenerator) -> Dictionary:
	return make_item("ash_staff", 1, "magic", rng)

static func random_equipment_drop(item_level: int, rng: RandomNumberGenerator, boss: bool = false) -> Dictionary:
	var keys: Array = bases().keys()
	var base_id: String = str(keys[rng.randi_range(0, keys.size() - 1)])
	var rarity: String = "normal"
	var roll: float = rng.randf()
	if boss:
		rarity = "rare" if roll < 0.72 else "magic"
	elif roll < 0.10:
		rarity = "rare"
	elif roll < 0.45:
		rarity = "magic"
	return make_item(base_id, item_level, rarity, rng)

static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var base: Dictionary = Dictionary(bases().get(base_id, bases()["iron_sword"])).duplicate(true)
	var prefixes: Array[Dictionary] = []
	var suffixes: Array[Dictionary] = []
	for affix: Dictionary in AffixDBScript.roll_affixes(base, rarity, item_level, rng):
		if str(affix.get("slot", "prefix")) == "suffix": suffixes.append(affix)
		else: prefixes.append(affix)
	var item: Dictionary = {
		"uid": "item_" + str(Time.get_ticks_usec()) + "_" + str(rng.randi()),
		"base_id": base_id,
		"base_name": str(base.get("name", base_id)),
		"display_name": _display_name(str(base.get("name", base_id)), rarity, prefixes, suffixes),
		"rarity": rarity,
		"item_level": max(1, item_level),
		"required_level": max(1, int(item_level * 0.75)),
		"slot": str(base.get("slot", "")),
		"item_type": str(base.get("item_type", "")),
		"tags": Array(base.get("tags", [])).duplicate(true),
		"implicit_stats": Dictionary(base.get("implicit_stats", {})).duplicate(true),
		"prefixes": prefixes,
		"suffixes": suffixes,
		"crafted_mods": [],
		"forge_potential": _forge_potential(rarity, item_level, rng),
		"total_stats": {}
	}
	item["total_stats"] = total_stats(item)
	return item

static func _display_name(base_name: String, rarity: String, prefixes: Array, suffixes: Array) -> String:
	if rarity == "normal":
		return base_name
	if rarity == "magic":
		var affix_name: String = "Tempered"
		if not prefixes.is_empty(): affix_name = str(Dictionary(prefixes[0]).get("name", affix_name))
		elif not suffixes.is_empty(): affix_name = str(Dictionary(suffixes[0]).get("name", affix_name))
		return affix_name + " " + base_name
	if rarity == "rare":
		return "Vault-Forged " + base_name
	return base_name

static func _forge_potential(rarity: String, item_level: int, rng: RandomNumberGenerator) -> int:
	var base: int = 18 + int(item_level * 0.8)
	if rarity == "normal": base += 10
	elif rarity == "magic": base += 5
	elif rarity == "rare": base -= 2
	return max(4, base + rng.randi_range(-3, 5))

static func total_stats(item: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	_merge(out, Dictionary(item.get("implicit_stats", {})))
	for affix: Dictionary in Array(item.get("prefixes", [])):
		_merge(out, Dictionary(affix.get("stats", {})))
	for affix2: Dictionary in Array(item.get("suffixes", [])):
		_merge(out, Dictionary(affix2.get("stats", {})))
	for crafted: Dictionary in Array(item.get("crafted_mods", [])):
		_merge(out, Dictionary(crafted.get("stats", {})))
	return out

static func _merge(target: Dictionary, stats: Dictionary) -> void:
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		target[key] = float(target.get(key, 0.0)) + float(stats[key_value])

static func item_detail(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."
	var text: String = str(item.get("display_name", "Item")) + "\n"
	text += str(item.get("rarity", "normal")).capitalize() + " " + str(item.get("slot", "")) + " · ilvl " + str(item.get("item_level", 1)) + " · FP " + str(item.get("forge_potential", 0)) + "\n"
	if not Array(item.get("prefixes", [])).is_empty():
		text += "\nPrefixes:\n"
		for p: Dictionary in Array(item.get("prefixes", [])):
			text += "  " + str(p.get("name", "Affix")) + " — " + _stats_text(Dictionary(p.get("stats", {}))) + "\n"
	if not Array(item.get("suffixes", [])).is_empty():
		text += "\nSuffixes:\n"
		for s: Dictionary in Array(item.get("suffixes", [])):
			text += "  " + str(s.get("name", "Affix")) + " — " + _stats_text(Dictionary(s.get("stats", {}))) + "\n"
	if not Array(item.get("crafted_mods", [])).is_empty():
		text += "\nCrafted:\n"
		for c: Dictionary in Array(item.get("crafted_mods", [])):
			text += "  " + str(c.get("name", "Craft")) + " — " + _stats_text(Dictionary(c.get("stats", {}))) + "\n"
	text += "\nTotal: " + _stats_text(Dictionary(item.get("total_stats", {})))
	return text

static func _stats_text(stats: Dictionary) -> String:
	if stats.is_empty(): return "none"
	var parts: Array[String] = []
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		var value: float = float(stats[key_value])
		if abs(value) < 1.0:
			parts.append(key + " +" + str(snappedf(value * 100.0, 0.1)) + "%")
		else:
			parts.append(key + " +" + str(int(round(value))))
	return ", ".join(parts)

static func add_random_crafted_mod(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if item.is_empty(): return item
	var fp: int = int(item.get("forge_potential", 0))
	if fp <= 0: return item
	var slot: String = str(item.get("slot", ""))
	var stats: Dictionary = {"Maximum Life": 12.0}
	var name: String = "Sealed Life"
	if slot == "weapon":
		stats = {"Spell Damage": 0.07}
		name = "Sealed Power"
	elif slot == "boots":
		stats = {"Movement Speed": 0.04}
		name = "Sealed Stride"
	elif slot == "offhand" or slot == "amulet" or slot == "relic":
		stats = {"Maximum Mana": 10.0}
		name = "Sealed Clarity"
	var crafts: Array = Array(item.get("crafted_mods", [])).duplicate(true)
	crafts.append({"id":"crafted_" + name.to_lower().replace(" ", "_"), "name":name, "stats":stats})
	item["crafted_mods"] = crafts
	item["forge_potential"] = max(0, fp - 3)
	item["total_stats"] = total_stats(item)
	return item
