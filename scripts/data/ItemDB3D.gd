class_name RVItemDB3D
extends RefCounted

const AffixDBScript := preload("res://scripts/data/AffixDB3D.gd")

static func bases() -> Dictionary:
	return {
		# Weapons
		"novice_wand": {"name": "Novice Wand", "slot": "weapon", "item_type": "weapon", "tags": ["weapon", "spell", "caster", "projectile", "damage"], "level": 1, "implicit_stats": {"spell_damage": 2.0}},
		"iron_sword": {"name": "Iron Sword", "slot": "weapon", "item_type": "weapon", "tags": ["weapon", "attack", "melee", "physical", "damage"], "level": 1, "implicit_stats": {"attack_damage": 3.0}},
		"ash_staff": {"name": "Ash Staff", "slot": "weapon", "item_type": "weapon", "tags": ["weapon", "spell", "fire", "caster", "projectile", "damage"], "level": 2, "implicit_stats": {"spell_damage": 3.0, "fire_damage": 2.0}},
		"storm_scepter": {"name": "Storm Scepter", "slot": "weapon", "item_type": "weapon", "tags": ["weapon", "spell", "lightning", "caster", "damage"], "level": 3, "implicit_stats": {"spell_damage": 3.0, "lightning_damage": 3.0}},
		"rift_blade": {"name": "Rift Blade", "slot": "weapon", "item_type": "weapon", "tags": ["weapon", "attack", "melee", "void", "damage"], "level": 4, "implicit_stats": {"attack_damage": 4.0, "void_damage": 2.0}},

		# Offhands / focuses
		"plain_focus": {"name": "Plain Focus", "slot": "offhand", "item_type": "offhand", "tags": ["offhand", "spell", "caster", "mana"], "level": 1, "implicit_stats": {"max_mana": 8.0}},
		"ember_focus": {"name": "Ember Focus", "slot": "offhand", "item_type": "offhand", "tags": ["offhand", "spell", "caster", "fire", "mana"], "level": 3, "implicit_stats": {"max_mana": 10.0, "fire_damage": 2.0}},
		"ward_shield": {"name": "Ward Shield", "slot": "offhand", "item_type": "offhand", "tags": ["offhand", "armor", "defense", "resistance"], "level": 2, "implicit_stats": {"armor": 12.0}},

		# Armor
		"leather_hood": {"name": "Leather Hood", "slot": "head", "item_type": "armor", "tags": ["armor", "defense", "life"], "level": 1, "implicit_stats": {"armor": 4.0}},
		"iron_helm": {"name": "Iron Helm", "slot": "head", "item_type": "armor", "tags": ["armor", "defense", "life"], "level": 3, "implicit_stats": {"armor": 9.0}},
		"travel_garb": {"name": "Travel Garb", "slot": "chest", "item_type": "armor", "tags": ["armor", "defense", "life", "speed"], "level": 1, "implicit_stats": {"armor": 7.0}},
		"warden_plate": {"name": "Warden Plate", "slot": "chest", "item_type": "armor", "tags": ["armor", "defense", "life"], "level": 2, "implicit_stats": {"armor": 16.0, "max_life": 5.0}},
		"ember_robe": {"name": "Ember Robe", "slot": "chest", "item_type": "armor", "tags": ["armor", "defense", "caster", "mana", "fire"], "level": 3, "implicit_stats": {"max_mana": 8.0}},
		"work_gloves": {"name": "Work Gloves", "slot": "gloves", "item_type": "armor", "tags": ["armor", "defense", "attack", "life"], "level": 1, "implicit_stats": {"armor": 4.0}},
		"rune_wraps": {"name": "Rune Wraps", "slot": "gloves", "item_type": "armor", "tags": ["armor", "defense", "spell", "caster", "mana"], "level": 2, "implicit_stats": {"max_mana": 5.0}},
		"traveler_boots": {"name": "Traveler Boots", "slot": "boots", "item_type": "armor", "tags": ["armor", "defense", "speed", "life"], "level": 1, "implicit_stats": {"move_speed_flat": 0.15}},
		"iron_greaves": {"name": "Iron Greaves", "slot": "boots", "item_type": "armor", "tags": ["armor", "defense", "life"], "level": 3, "implicit_stats": {"armor": 10.0}},

		# Jewelry / relics
		"copper_ring": {"name": "Copper Ring", "slot": "ring", "item_type": "jewelry", "tags": ["jewelry", "mana", "damage", "resistance"], "level": 1, "implicit_stats": {"max_mana": 4.0}},
		"ember_ring": {"name": "Ember Ring", "slot": "ring", "item_type": "jewelry", "tags": ["jewelry", "fire", "spell", "damage", "resistance"], "level": 2, "implicit_stats": {"fire_damage": 2.0}},
		"storm_ring": {"name": "Storm Ring", "slot": "ring", "item_type": "jewelry", "tags": ["jewelry", "lightning", "spell", "damage", "resistance"], "level": 3, "implicit_stats": {"lightning_damage": 2.0}},
		"ember_amulet": {"name": "Ember Amulet", "slot": "amulet", "item_type": "jewelry", "tags": ["jewelry", "fire", "spell", "caster", "damage", "mana"], "level": 2, "implicit_stats": {"spell_damage": 2.0, "max_mana": 5.0}},
		"bone_talisman": {"name": "Bone Talisman", "slot": "amulet", "item_type": "jewelry", "tags": ["jewelry", "life", "defense", "resistance"], "level": 1, "implicit_stats": {"max_life": 6.0}},
		"relic_shard": {"name": "Relic Shard", "slot": "relic", "item_type": "relic", "tags": ["relic", "utility", "flask", "damage", "life", "mana", "resistance"], "level": 2, "implicit_stats": {"generic_damage": 1.0}}
	}

static func base_ids_for_level(item_level: int, preferred_tags: Array = []) -> Array[String]:
	var result: Array[String] = []
	for id_value: Variant in bases().keys():
		var id: String = str(id_value)
		var data: Dictionary = bases()[id]
		if int(data.get("level", 1)) > item_level:
			continue
		if not preferred_tags.is_empty():
			var base_tags: Array = Array(data.get("tags", []))
			var has_preferred: bool = false
			for tag_value: Variant in preferred_tags:
				if base_tags.has(str(tag_value)):
					has_preferred = true
					break
			if not has_preferred:
				continue
		result.append(id)
	return result

static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var base: Dictionary = Dictionary(bases().get(base_id, bases()["novice_wand"])).duplicate(true)
	var normalized_rarity: String = _normalize_rarity(rarity)
	var item: Dictionary = {
		"uid": "item_" + str(rng.randi()) + "_" + str(Time.get_ticks_msec()),
		"base_id": base_id,
		"display_name": str(base.get("name", base_id)),
		"name": str(base.get("name", base_id)),
		"rarity": normalized_rarity,
		"item_level": max(1, item_level),
		"level": max(1, item_level),
		"required_level": max(1, int(base.get("level", 1))),
		"slot": str(base.get("slot", "weapon")),
		"item_type": str(base.get("item_type", base.get("type", "gear"))),
		"type": str(base.get("item_type", base.get("type", "gear"))),
		"tags": Array(base.get("tags", [])).duplicate(true),
		"base_tags": Array(base.get("tags", [])).duplicate(true),
		"implicit_stats": Dictionary(base.get("implicit_stats", {})).duplicate(true),
		"prefixes": [],
		"suffixes": [],
		"crafted_mods": [],
		"forge_potential": _forge_potential_for_rarity(normalized_rarity, rng),
		"quality": 0,
		"total_stats": {},
		"stats": {}
	}
	_roll_starting_affixes(item, rng)
	_rebuild_item_stats(item)
	item["name"] = _build_display_name(item)
	return item

static func make_random_drop(item_level: int, rng: RandomNumberGenerator, rarity_bias: float = 0.0, preferred_tags: Array = []) -> Dictionary:
	var ids: Array[String] = base_ids_for_level(item_level, preferred_tags)
	if ids.is_empty():
		ids = base_ids_for_level(item_level)
	if ids.is_empty():
		ids = ["novice_wand"]
	var base_id: String = ids[rng.randi_range(0, ids.size() - 1)]
	var rarity: String = roll_rarity(rng, rarity_bias)
	return make_item(base_id, item_level, rarity, rng)

static func roll_rarity(rng: RandomNumberGenerator, rarity_bias: float = 0.0) -> String:
	var roll: float = rng.randf() + rarity_bias
	if roll >= 0.94:
		return "rare"
	if roll >= 0.60:
		return "magic"
	return "normal"

static func normalize_item(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return {}
	var out: Dictionary = item.duplicate(true)
	if not out.has("item_level"):
		out["item_level"] = int(out.get("level", 1))
	if not out.has("required_level"):
		out["required_level"] = int(out.get("item_level", 1))
	if not out.has("item_type"):
		out["item_type"] = str(out.get("type", "gear"))
	if not out.has("prefixes"):
		out["prefixes"] = Array(out.get("affixes", [])).duplicate(true)
	if not out.has("suffixes"):
		out["suffixes"] = []
	if not out.has("crafted_mods"):
		out["crafted_mods"] = []
	if not out.has("implicit_stats"):
		out["implicit_stats"] = {}
	_rebuild_item_stats(out)
	if not out.has("display_name"):
		out["display_name"] = str(out.get("name", "Item"))
	out["name"] = _build_display_name(out)
	return out

static func can_equip(item: Dictionary) -> bool:
	return not item.is_empty() and str(item.get("slot", "")) != "" and str(item.get("item_type", item.get("type", ""))) != "map"

static func equip_item(state: Object, item_index: int) -> bool:
	if state == null:
		return false
	var backpack: Array = Array(state.get("backpack"))
	if item_index < 0 or item_index >= backpack.size():
		return false
	var item: Dictionary = normalize_item(Dictionary(backpack[item_index]))
	if not can_equip(item):
		return false
	var slot: String = _resolve_equip_slot(state, item)
	if slot == "":
		return false
	var equipped: Dictionary = Dictionary(state.get("equipped"))
	var old_item: Dictionary = normalize_item(Dictionary(equipped.get(slot, {})))
	equipped[slot] = item
	backpack.remove_at(item_index)
	if not old_item.is_empty():
		backpack.append(old_item)
	state.set("equipped", equipped)
	state.set("backpack", backpack)
	state.set("inventory_cursor", clampi(int(state.get("inventory_cursor")), 0, max(0, backpack.size() - 1)))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	if state.has_method("add_notice"):
		state.call("add_notice", "Equipped " + str(item.get("name", "item")))
	return true

static func item_text(item: Dictionary) -> String:
	item = normalize_item(item)
	if item.is_empty():
		return "Empty"
	var text: String = str(item.get("name", "Item")) + " [" + str(item.get("rarity", "normal")).to_upper() + "]\n"
	text += "Item Lv " + str(int(item.get("item_level", 1))) + " · Req Lv " + str(int(item.get("required_level", 1))) + " · " + _slot_label(str(item.get("slot", ""))) + " · FP " + str(int(item.get("forge_potential", 0))) + "\n"
	var implicit_stats: Dictionary = Dictionary(item.get("implicit_stats", {}))
	if not implicit_stats.is_empty():
		text += "\nImplicit\n"
		text += _stats_lines(implicit_stats)
	var prefixes: Array = Array(item.get("prefixes", []))
	if not prefixes.is_empty():
		text += "\nPrefixes\n"
		for prefix_value: Variant in prefixes:
			text += _affix_line(Dictionary(prefix_value))
	var suffixes: Array = Array(item.get("suffixes", []))
	if not suffixes.is_empty():
		text += "\nSuffixes\n"
		for suffix_value: Variant in suffixes:
			text += _affix_line(Dictionary(suffix_value))
	var total_stats: Dictionary = Dictionary(item.get("total_stats", item.get("stats", {})))
	if not total_stats.is_empty():
		text += "\nTotal Stats\n"
		text += _stats_lines(total_stats)
	return text

static func compact_item_line(item: Dictionary) -> String:
	item = normalize_item(item)
	if item.is_empty():
		return "Empty"
	return str(item.get("name", "Item")) + " | " + str(item.get("rarity", "normal")) + " | Lv" + str(int(item.get("item_level", 1))) + " | " + _slot_label(str(item.get("slot", "")))

static func best_equipped_for_compare(state: Object, item: Dictionary) -> Dictionary:
	if state == null or item.is_empty():
		return {}
	var equipped: Dictionary = Dictionary(state.get("equipped"))
	var slot: String = str(item.get("slot", ""))
	if slot == "ring":
		var ring1: Dictionary = normalize_item(Dictionary(equipped.get("ring1", {})))
		var ring2: Dictionary = normalize_item(Dictionary(equipped.get("ring2", {})))
		if ring1.is_empty():
			return ring2
		if ring2.is_empty():
			return ring1
		return ring1
	return normalize_item(Dictionary(equipped.get(slot, {})))

static func compare_text(new_item: Dictionary, old_item: Dictionary) -> String:
	new_item = normalize_item(new_item)
	old_item = normalize_item(old_item)
	if new_item.is_empty():
		return ""
	if old_item.is_empty():
		return "No equipped item in this slot."
	var text: String = "Compared to: " + str(old_item.get("name", "Equipped")) + "\n"
	var new_stats: Dictionary = Dictionary(new_item.get("total_stats", {}))
	var old_stats: Dictionary = Dictionary(old_item.get("total_stats", {}))
	var keys: Array[String] = []
	for key_value: Variant in new_stats.keys():
		var key: String = str(key_value)
		if not keys.has(key):
			keys.append(key)
	for old_key_value: Variant in old_stats.keys():
		var old_key: String = str(old_key_value)
		if not keys.has(old_key):
			keys.append(old_key)
	for stat: String in keys:
		var delta: float = float(new_stats.get(stat, 0.0)) - float(old_stats.get(stat, 0.0))
		if abs(delta) >= 0.01:
			text += _stat_label(stat) + ": " + ("+" if delta >= 0.0 else "") + str(snappedf(delta, 0.01)) + "\n"
	return text

static func _roll_starting_affixes(item: Dictionary, rng: RandomNumberGenerator) -> void:
	var rarity: String = str(item.get("rarity", "normal"))
	var prefix_target: int = 0
	var suffix_target: int = 0
	match rarity:
		"magic":
			if rng.randf() < 0.55:
				prefix_target = 1
				suffix_target = 1 if rng.randf() < 0.45 else 0
			else:
				prefix_target = 0
				suffix_target = 1
		"rare":
			var total: int = rng.randi_range(4, 6)
			prefix_target = clampi(rng.randi_range(2, 3), 1, 3)
			suffix_target = clampi(total - prefix_target, 1, 3)
		_:
			return
	_add_random_affixes(item, "prefix", prefix_target, rng)
	_add_random_affixes(item, "suffix", suffix_target, rng)

static func _add_random_affixes(item: Dictionary, kind: String, count: int, rng: RandomNumberGenerator) -> void:
	var arr_key: String = "prefixes" if kind == "prefix" else "suffixes"
	var affixes: Array = Array(item.get(arr_key, []))
	var used_groups: Array = []
	for prefix_value: Variant in Array(item.get("prefixes", [])):
		used_groups.append(str(Dictionary(prefix_value).get("group", Dictionary(prefix_value).get("id", ""))))
	for suffix_value: Variant in Array(item.get("suffixes", [])):
		used_groups.append(str(Dictionary(suffix_value).get("group", Dictionary(suffix_value).get("id", ""))))
	for i: int in range(max(0, count)):
		var template: Dictionary = AffixDBScript.roll_affix(item, kind, used_groups, rng)
		if template.is_empty():
			break
		var rolled: Dictionary = AffixDBScript.apply_affix_roll(item, template, rng)
		if rolled.is_empty():
			break
		used_groups.append(str(rolled.get("group", rolled.get("id", ""))))
		affixes.append(rolled)
	item[arr_key] = affixes

static func _rebuild_item_stats(item: Dictionary) -> void:
	var total: Dictionary = {}
	_merge_stats(total, Dictionary(item.get("implicit_stats", {})))
	for prefix_value: Variant in Array(item.get("prefixes", [])):
		_merge_stats(total, Dictionary(Dictionary(prefix_value).get("stats", {})))
	for suffix_value: Variant in Array(item.get("suffixes", [])):
		_merge_stats(total, Dictionary(Dictionary(suffix_value).get("stats", {})))
	for crafted_value: Variant in Array(item.get("crafted_mods", [])):
		_merge_stats(total, Dictionary(Dictionary(crafted_value).get("stats", {})))
	item["total_stats"] = total
	item["stats"] = total.duplicate(true) # compatibility with current combat/stat code

static func _merge_stats(target: Dictionary, source: Dictionary) -> void:
	for key_value: Variant in source.keys():
		var key: String = str(key_value)
		target[key] = float(target.get(key, 0.0)) + float(source[key_value])

static func _resolve_equip_slot(state: Object, item: Dictionary) -> String:
	var slot: String = str(item.get("slot", ""))
	if slot != "ring":
		return slot
	var equipped: Dictionary = Dictionary(state.get("equipped"))
	if Dictionary(equipped.get("ring1", {})).is_empty():
		return "ring1"
	if Dictionary(equipped.get("ring2", {})).is_empty():
		return "ring2"
	return "ring1"

static func _build_display_name(item: Dictionary) -> String:
	var base_name: String = str(item.get("display_name", item.get("name", "Item")))
	var rarity: String = str(item.get("rarity", "normal"))
	match rarity:
		"magic":
			var prefix_name: String = ""
			var suffix_name: String = ""
			var prefixes: Array = Array(item.get("prefixes", []))
			var suffixes: Array = Array(item.get("suffixes", []))
			if not prefixes.is_empty():
				prefix_name = str(Dictionary(prefixes[0]).get("name", ""))
			if not suffixes.is_empty():
				suffix_name = str(Dictionary(suffixes[0]).get("name", ""))
			var name: String = base_name
			if prefix_name != "":
				name = prefix_name + " " + name
			if suffix_name != "":
				name += " " + suffix_name
			return name
		"rare":
			return _rare_prefix(item) + " " + base_name
		_:
			return base_name

static func _rare_prefix(item: Dictionary) -> String:
	var tags: Array = Array(item.get("tags", []))
	if tags.has("fire"):
		return "Cinderbrand"
	if tags.has("lightning"):
		return "Stormvault"
	if tags.has("void"):
		return "Nullforged"
	if tags.has("life") or tags.has("armor"):
		return "Warden"
	return "Vaultforged"

static func _forge_potential_for_rarity(rarity: String, rng: RandomNumberGenerator) -> int:
	match rarity:
		"normal": return rng.randi_range(16, 24)
		"magic": return rng.randi_range(11, 19)
		"rare": return rng.randi_range(6, 14)
		_: return rng.randi_range(6, 12)

static func _normalize_rarity(rarity: String) -> String:
	match rarity:
		"normal", "magic", "rare", "unique": return rarity
		_: return "normal"

static func _affix_line(affix: Dictionary) -> String:
	var text: String = "  " + str(affix.get("name", "Affix")) + " T" + str(int(affix.get("tier", 1))) + "\n"
	text += _stats_lines(Dictionary(affix.get("stats", {})), "    ")
	return text

static func _stats_lines(stats: Dictionary, indent: String = "  ") -> String:
	var text: String = ""
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		text += indent + _stat_label(key) + ": +" + str(snappedf(float(stats[key_value]), 0.01)) + _stat_suffix(key) + "\n"
	return text

static func _slot_label(slot: String) -> String:
	match slot:
		"ring": return "Ring"
		"ring1": return "Ring 1"
		"ring2": return "Ring 2"
		"offhand": return "Offhand"
		_: return slot.replace("_", " ").capitalize()

static func _stat_label(stat: String) -> String:
	return stat.replace("_", " ").capitalize()

static func _stat_suffix(stat: String) -> String:
	if stat.ends_with("_resist"):
		return "%"
	if stat in ["cast_speed", "attack_speed", "crit_chance", "cooldown_recovery", "flask_recovery"]:
		return "%"
	return ""
