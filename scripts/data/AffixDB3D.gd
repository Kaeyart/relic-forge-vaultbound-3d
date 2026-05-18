class_name RVAffixDB3D
extends RefCounted

# Strict 3D ARPG affix database.
# Affixes are domain-gated by item_type / slot / tags / item level.
# This is intentionally conservative: no projectile stats on chest armor, no armor rolls on weapons, etc.

static func prefixes() -> Array[Dictionary]:
	return [
		# Weapons / offensive focuses
		{"id": "p_weapon_phys_01", "name": "Tempered", "kind": "prefix", "group": "weapon_physical_damage", "item_types": ["weapon"], "tags": ["attack", "melee", "weapon"], "stats": {"attack_damage": [5.0, 12.0]}, "level": 1, "weight": 110},
		{"id": "p_weapon_spell_01", "name": "Runed", "kind": "prefix", "group": "weapon_spell_damage", "item_types": ["weapon", "offhand"], "tags": ["spell", "caster"], "stats": {"spell_damage": [5.0, 12.0]}, "level": 1, "weight": 115},
		{"id": "p_weapon_fire_01", "name": "Cindered", "kind": "prefix", "group": "element_fire_damage", "item_types": ["weapon", "offhand", "jewelry"], "tags": ["fire"], "stats": {"fire_damage": [5.0, 13.0]}, "level": 1, "weight": 95},
		{"id": "p_weapon_lightning_01", "name": "Storm-Etched", "kind": "prefix", "group": "element_lightning_damage", "item_types": ["weapon", "offhand", "jewelry"], "tags": ["lightning"], "stats": {"lightning_damage": [5.0, 14.0]}, "level": 2, "weight": 90},
		{"id": "p_weapon_void_01", "name": "Hollow", "kind": "prefix", "group": "element_void_damage", "item_types": ["weapon", "offhand", "jewelry"], "tags": ["void"], "stats": {"void_damage": [6.0, 15.0]}, "level": 3, "weight": 80},
		{"id": "p_weapon_projectile_01", "name": "Splintering", "kind": "prefix", "group": "projectile_damage", "item_types": ["weapon", "offhand", "jewelry"], "tags": ["projectile"], "stats": {"projectile_damage": [4.0, 10.0]}, "level": 2, "weight": 70},

		# Armor / defense
		{"id": "p_armor_life_01", "name": "Stalwart", "kind": "prefix", "group": "maximum_life", "item_types": ["armor", "jewelry", "relic"], "tags": ["life", "defense"], "stats": {"max_life": [16.0, 38.0]}, "level": 1, "weight": 130},
		{"id": "p_armor_armor_01", "name": "Plated", "kind": "prefix", "group": "armor_rating", "item_types": ["armor", "relic"], "tags": ["armor", "defense"], "stats": {"armor": [12.0, 34.0]}, "level": 1, "weight": 120},
		{"id": "p_mana_01", "name": "Lucid", "kind": "prefix", "group": "maximum_mana", "item_types": ["armor", "jewelry", "offhand", "relic"], "tags": ["mana", "caster"], "stats": {"max_mana": [12.0, 32.0]}, "level": 1, "weight": 110},
		{"id": "p_hybrid_life_mana_01", "name": "Bound", "kind": "prefix", "group": "hybrid_life_mana", "item_types": ["jewelry", "relic"], "tags": ["life", "mana"], "stats": {"max_life": [8.0, 18.0], "max_mana": [8.0, 18.0]}, "level": 2, "weight": 75},
		{"id": "p_boot_speed_01", "name": "Swift", "kind": "prefix", "group": "movement_speed", "slots": ["boots"], "tags": ["speed"], "stats": {"move_speed_flat": [0.25, 0.65]}, "level": 1, "weight": 125},

		# Jewelry / utility
		{"id": "p_jewel_generic_damage_01", "name": "Potent", "kind": "prefix", "group": "generic_damage", "item_types": ["jewelry", "relic"], "tags": ["damage"], "stats": {"generic_damage": [3.0, 8.0]}, "level": 1, "weight": 95},
		{"id": "p_jewel_cooldown_01", "name": "Quickened", "kind": "prefix", "group": "cooldown_recovery", "item_types": ["jewelry", "relic", "offhand"], "tags": ["cooldown", "device"], "stats": {"cooldown_recovery": [0.03, 0.08]}, "level": 3, "weight": 55}
	]

static func suffixes() -> Array[Dictionary]:
	return [
		# Resists and survival suffixes
		{"id": "s_fire_res_01", "name": "of Ash Ward", "kind": "suffix", "group": "fire_resist", "item_types": ["armor", "jewelry", "relic", "offhand"], "tags": ["resistance", "fire", "defense"], "stats": {"fire_resist": [8.0, 22.0]}, "level": 1, "weight": 110},
		{"id": "s_lightning_res_01", "name": "of Grounding", "kind": "suffix", "group": "lightning_resist", "item_types": ["armor", "jewelry", "relic", "offhand"], "tags": ["resistance", "lightning", "defense"], "stats": {"lightning_resist": [8.0, 22.0]}, "level": 1, "weight": 105},
		{"id": "s_void_res_01", "name": "of the Veil", "kind": "suffix", "group": "void_resist", "item_types": ["armor", "jewelry", "relic", "offhand"], "tags": ["resistance", "void", "defense"], "stats": {"void_resist": [8.0, 22.0]}, "level": 2, "weight": 85},
		{"id": "s_all_res_01", "name": "of Warding", "kind": "suffix", "group": "all_resist", "item_types": ["jewelry", "relic", "offhand"], "tags": ["resistance", "defense"], "stats": {"fire_resist": [4.0, 10.0], "lightning_resist": [4.0, 10.0], "void_resist": [4.0, 10.0]}, "level": 3, "weight": 55},

		# Weapon / caster suffixes
		{"id": "s_cast_speed_01", "name": "of Invocation", "kind": "suffix", "group": "cast_speed", "item_types": ["weapon", "offhand", "jewelry"], "tags": ["spell", "caster"], "stats": {"cast_speed": [0.04, 0.10]}, "level": 1, "weight": 85},
		{"id": "s_attack_speed_01", "name": "of Readiness", "kind": "suffix", "group": "attack_speed", "item_types": ["weapon", "jewelry"], "tags": ["attack", "melee"], "stats": {"attack_speed": [0.04, 0.11]}, "level": 1, "weight": 85},
		{"id": "s_crit_01", "name": "of Precision", "kind": "suffix", "group": "critical_chance", "item_types": ["weapon", "jewelry", "offhand"], "tags": ["damage"], "stats": {"crit_chance": [0.02, 0.06]}, "level": 2, "weight": 65},

		# Flask and utility suffixes
		{"id": "s_flask_life_01", "name": "of Recovery", "kind": "suffix", "group": "flask_recovery", "slots": ["belt", "relic", "amulet"], "item_types": ["relic", "jewelry"], "tags": ["flask", "utility"], "stats": {"flask_recovery": [0.06, 0.14]}, "level": 2, "weight": 65},
		{"id": "s_resource_regen_01", "name": "of Flow", "kind": "suffix", "group": "mana_regen", "item_types": ["jewelry", "offhand", "relic"], "tags": ["mana", "caster"], "stats": {"mana_regen": [0.8, 2.2]}, "level": 1, "weight": 75}
	]

static func affixes_for(item: Dictionary, kind: String) -> Array[Dictionary]:
	var source: Array[Dictionary] = prefixes() if kind == "prefix" else suffixes()
	var result: Array[Dictionary] = []
	var item_level: int = int(item.get("item_level", item.get("level", 1)))
	var item_type: String = str(item.get("item_type", item.get("type", "")))
	var slot: String = str(item.get("slot", ""))
	var tags: Array = Array(item.get("tags", item.get("base_tags", [])))
	for affix: Dictionary in source:
		if int(affix.get("level", 1)) > item_level:
			continue
		if not _domain_matches(affix, item_type, slot):
			continue
		if not _tags_match(affix, tags):
			continue
		result.append(affix.duplicate(true))
	return result

static func roll_affix(item: Dictionary, kind: String, used_groups: Array, rng: RandomNumberGenerator) -> Dictionary:
	var pool: Array[Dictionary] = []
	for affix: Dictionary in affixes_for(item, kind):
		if used_groups.has(str(affix.get("group", affix.get("id", "")))):
			continue
		pool.append(affix)
	if pool.is_empty():
		return {}
	var total_weight: int = 0
	for affix2: Dictionary in pool:
		total_weight += max(1, int(affix2.get("weight", 100)))
	var roll: int = rng.randi_range(1, max(1, total_weight))
	var cursor: int = 0
	for chosen: Dictionary in pool:
		cursor += max(1, int(chosen.get("weight", 100)))
		if roll <= cursor:
			return chosen.duplicate(true)
	return pool[0].duplicate(true)

static func apply_affix_roll(item: Dictionary, affix: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if affix.is_empty():
		return {}
	var rolled: Dictionary = {
		"id": str(affix.get("id", "")),
		"name": str(affix.get("name", "")),
		"kind": str(affix.get("kind", "prefix")),
		"group": str(affix.get("group", affix.get("id", ""))),
		"tier": _tier_for_level(int(item.get("item_level", item.get("level", 1)))) ,
		"stats": {}
	}
	var out_stats: Dictionary = {}
	var stat_ranges: Dictionary = Dictionary(affix.get("stats", {}))
	for stat_key: Variant in stat_ranges.keys():
		var stat_name: String = str(stat_key)
		var range_value: Variant = stat_ranges[stat_key]
		var amount: float = 0.0
		if typeof(range_value) == TYPE_ARRAY:
			var arr: Array = Array(range_value)
			var min_value: float = float(arr[0]) if arr.size() > 0 else 0.0
			var max_value: float = float(arr[1]) if arr.size() > 1 else min_value
			amount = rng.randf_range(min_value, max_value)
		else:
			amount = float(range_value)
		out_stats[stat_name] = snappedf(amount, 0.01)
	rolled["stats"] = out_stats
	return rolled

static func _domain_matches(affix: Dictionary, item_type: String, slot: String) -> bool:
	var types: Array = Array(affix.get("item_types", []))
	var slots: Array = Array(affix.get("slots", []))
	var type_ok: bool = types.is_empty() or types.has(item_type)
	var slot_ok: bool = slots.is_empty() or slots.has(slot)
	return type_ok and slot_ok

static func _tags_match(affix: Dictionary, item_tags: Array) -> bool:
	var required_tags: Array = Array(affix.get("tags", []))
	if required_tags.is_empty():
		return true
	for tag_value: Variant in required_tags:
		if item_tags.has(str(tag_value)):
			return true
	return false

static func _tier_for_level(item_level: int) -> int:
	if item_level >= 20:
		return 4
	if item_level >= 12:
		return 3
	if item_level >= 6:
		return 2
	return 1
