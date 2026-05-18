class_name RVItemDB3D
extends RefCounted

const AffixDBScript := preload("res://scripts/data/AffixDB3D.gd")

static func bases() -> Dictionary:
	return {
		"apprentice_wand": {"name":"Apprentice Wand", "slot":"weapon", "item_type":"weapon", "tags":["weapon","caster","spell","projectile"], "implicit_stats":{"spell_damage":0.04}},
		"iron_sword": {"name":"Iron Sword", "slot":"weapon", "item_type":"weapon", "tags":["weapon","melee","attack"], "implicit_stats":{"attack_damage":0.06}},
		"ritual_focus": {"name":"Ritual Focus", "slot":"offhand", "item_type":"focus", "tags":["caster","jewelry","mana"], "implicit_stats":{"maximum_mana":10.0}},
		"cloth_robe": {"name":"Cloth Robe", "slot":"chest", "item_type":"armor", "tags":["armor","caster","life"], "implicit_stats":{"maximum_mana":8.0}},
		"iron_cuirass": {"name":"Iron Cuirass", "slot":"chest", "item_type":"armor", "tags":["armor","defense","life"], "implicit_stats":{"armor":14.0}},
		"travel_boots": {"name":"Travel Boots", "slot":"boots", "item_type":"armor", "tags":["armor","boots","movement","life"], "implicit_stats":{}},
		"linen_gloves": {"name":"Linen Gloves", "slot":"gloves", "item_type":"armor", "tags":["armor","life"], "implicit_stats":{}},
		"bone_helm": {"name":"Bone Helm", "slot":"head", "item_type":"armor", "tags":["armor","defense","life"], "implicit_stats":{"armor":8.0}},
		"copper_ring": {"name":"Copper Ring", "slot":"ring1", "item_type":"jewelry", "tags":["jewelry","caster","resistance"], "implicit_stats":{"maximum_mana":6.0}},
		"ash_amulet": {"name":"Ash Amulet", "slot":"amulet", "item_type":"jewelry", "tags":["jewelry","caster","fire","resistance"], "implicit_stats":{"fire_damage":0.04}},
		"vault_relic": {"name":"Vault Relic", "slot":"relic", "item_type":"relic", "tags":["jewelry","caster","defense"], "implicit_stats":{"maximum_spirit":5.0}},
	}

static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var base: Dictionary = Dictionary(bases().get(base_id, bases()["apprentice_wand"])).duplicate(true)
	var tags: Array = Array(base.get("tags", [])).duplicate(true)
	var rolled: Dictionary = AffixDBScript.roll_affixes(tags, item_level, rarity, rng)
	var item: Dictionary = {
		"uid": "item_" + str(Time.get_ticks_usec()) + "_" + str(rng.randi_range(1000,9999)),
		"base_id": base_id,
		"display_name": _rarity_prefix(rarity) + str(base.get("name", base_id)),
		"rarity": rarity,
		"item_level": item_level,
		"required_level": max(1, item_level - 2),
		"slot": str(base.get("slot", "")),
		"item_type": str(base.get("item_type", "")),
		"tags": tags,
		"implicit_stats": Dictionary(base.get("implicit_stats", {})).duplicate(true),
		"prefixes": Array(rolled.get("prefixes", [])).duplicate(true),
		"suffixes": Array(rolled.get("suffixes", [])).duplicate(true),
		"crafted_mods": [],
		"forge_potential": rng.randi_range(8, 22) + item_level,
	}
	item["total_stats"] = total_stats(item)
	return item

static func make_random_equipment(item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var ids: Array = bases().keys()
	return make_item(str(ids[rng.randi_range(0, ids.size() - 1)]), item_level, rarity, rng)

static func make_map_item(map_id: String, tier: int, rng: RandomNumberGenerator) -> Dictionary:
	return {
		"uid":"map_" + str(Time.get_ticks_usec()) + "_" + str(rng.randi_range(1000,9999)),
		"base_id": map_id,
		"display_name":"Ash Vault Map T" + str(tier),
		"item_type":"map",
		"slot":"",
		"rarity":"normal",
		"tier": tier,
		"map_level": max(1, tier),
		"tags":["map"],
		"mods": [],
	}

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

static func item_detail_text(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."
	var text: String = str(item.get("display_name", "Item")) + "\n"
	text += str(item.get("rarity", "normal")).capitalize() + " " + str(item.get("item_type", "")) + "  iLv " + str(item.get("item_level", 1)) + "\n"
	for affix: Dictionary in Array(item.get("prefixes", [])):
		text += "+ " + str(affix.get("name", "Prefix")) + "\n"
	for affix2: Dictionary in Array(item.get("suffixes", [])):
		text += "+ " + str(affix2.get("name", "Suffix")) + "\n"
	var stats: Dictionary = Dictionary(item.get("total_stats", {}))
	if not stats.is_empty():
		text += "\nStats:\n"
		for k: Variant in stats.keys():
			var v: float = float(stats[k])
			text += "  " + str(k).replace("_", " ").capitalize() + ": " + _format_stat(v) + "\n"
	text += "\nForge Potential: " + str(int(item.get("forge_potential", 0)))
	return text

static func _merge(out: Dictionary, stats: Dictionary) -> void:
	for key: Variant in stats.keys():
		out[str(key)] = float(out.get(str(key), 0.0)) + float(stats[key])

static func _rarity_prefix(rarity: String) -> String:
	match rarity:
		"magic": return "Runed "
		"rare": return "Vault-Forged "
		"unique": return "Unique "
	return ""

static func _format_stat(v: float) -> String:
	if abs(v) < 1.0:
		return str(snappedf(v * 100.0, 0.1)) + "%"
	return str(int(round(v)))
