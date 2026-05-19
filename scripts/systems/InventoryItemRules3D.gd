extends RefCounted

const UNIQUE_RARITY: String = "unique"

const STAT_DISPLAY_NAMES: Dictionary = {
	"max_health": "Health",
	"max_hp": "Health",
	"health": "Health",
	"life": "Health",
	"max_life": "Health",
	"added_health": "Health",

	"max_mana": "Mana",
	"mana": "Mana",
	"added_mana": "Mana",

	"armor": "Armor",
	"armour": "Armor",
	"evasion": "Evasion",
	"ward": "Ward",
	"block_chance": "Block Chance",
	"block": "Block Chance",

	"fire_resistance": "Fire Resistance",
	"fire_resist": "Fire Resistance",
	"cold_resistance": "Cold Resistance",
	"cold_resist": "Cold Resistance",
	"lightning_resistance": "Lightning Resistance",
	"lightning_resist": "Lightning Resistance",
	"void_resistance": "Void Resistance",
	"void_resist": "Void Resistance",
	"all_resistance": "All Resistance",
	"all_resist": "All Resistance",

	"weapon_damage": "Weapon Damage",
	"attack_damage": "Attack Damage",
	"spell_damage": "Spell Damage",
	"fire_damage": "Fire Damage",
	"lightning_damage": "Lightning Damage",
	"void_damage": "Void Damage",
	"projectile_damage": "Projectile Damage",
	"minion_damage": "Minion Damage",

	"crit_chance": "Critical Strike Chance",
	"critical_chance": "Critical Strike Chance",
	"crit_multiplier": "Critical Strike Multiplier",
	"critical_multiplier": "Critical Strike Multiplier",
	"attack_speed": "Attack Speed",
	"cast_speed": "Cast Speed",
	"cooldown_recovery": "Cooldown Recovery",
	"movement_speed": "Movement Speed",

	"spirit": "Spirit",
	"spirit_max": "Spirit",
	"forge_potential": "Forge Potential",
}

const PERCENT_STATS: Array = [
	"fire_resistance", "fire_resist", "cold_resistance", "cold_resist",
	"lightning_resistance", "lightning_resist", "void_resistance", "void_resist",
	"all_resistance", "all_resist",
	"block_chance", "block",
	"crit_chance", "critical_chance", "crit_multiplier", "critical_multiplier",
	"attack_speed", "cast_speed", "cooldown_recovery", "movement_speed",
	"weapon_damage", "attack_damage", "spell_damage", "fire_damage",
	"lightning_damage", "void_damage", "projectile_damage", "minion_damage",
]

const SLOT_ORDER: Dictionary = {
	"weapon": 0,
	"offhand": 1,
	"head": 2,
	"chest": 3,
	"gloves": 4,
	"boots": 5,
	"amulet": 6,
	"ring1": 7,
	"ring2": 8,
	"ring": 8,
	"relic": 9,
	"": 99,
}

const RARITY_ORDER: Dictionary = {
	"unique": 0,
	"rare": 1,
	"magic": 2,
	"normal": 3,
	"": 4,
}

const UNIVERSAL_STATS: Array = [
	"max_health", "max_hp", "health", "life", "max_life", "added_health",
	"max_mana", "mana", "added_mana",
	"fire_resistance", "fire_resist",
	"cold_resistance", "cold_resist",
	"lightning_resistance", "lightning_resist",
	"void_resistance", "void_resist",
	"all_resistance", "all_resist",
]

const WEAPON_STATS: Array = [
	"weapon_damage", "attack_damage", "spell_damage", "fire_damage", "lightning_damage",
	"void_damage", "projectile_damage", "minion_damage", "crit_chance",
	"critical_chance", "crit_multiplier", "critical_multiplier", "attack_speed", "cast_speed",
]

const OFFHAND_STATS: Array = [
	"armor", "armour", "ward", "block_chance", "block", "spell_damage", "cast_speed",
	"cooldown_recovery", "crit_chance", "critical_chance",
]

const ARMOR_STATS: Array = [
	"armor", "armour", "evasion", "ward", "movement_speed", "cooldown_recovery",
]

const JEWELRY_STATS: Array = [
	"weapon_damage", "attack_damage", "spell_damage", "fire_damage", "lightning_damage",
	"void_damage", "projectile_damage", "minion_damage", "crit_chance", "critical_chance",
	"crit_multiplier", "critical_multiplier", "attack_speed", "cast_speed",
	"cooldown_recovery", "movement_speed", "spirit", "spirit_max",
]

static func sanitize_inventory_state(state: Object) -> bool:
	if state == null:
		return false
	var changed: bool = false

	var backpack_value: Variant = state.get("backpack")
	if typeof(backpack_value) == TYPE_ARRAY:
		var backpack: Array = Array(backpack_value)
		for i: int in range(backpack.size()):
			if typeof(backpack[i]) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = Dictionary(backpack[i])
			if sanitize_item(item):
				changed = true
			backpack[i] = item
		if changed:
			state.set("backpack", backpack)

	var equipped_value: Variant = state.get("equipped")
	if typeof(equipped_value) == TYPE_DICTIONARY:
		var equipped: Dictionary = Dictionary(equipped_value)
		for slot_key: Variant in equipped.keys():
			if typeof(equipped[slot_key]) != TYPE_DICTIONARY:
				continue
			var eq_item: Dictionary = Dictionary(equipped[slot_key])
			if sanitize_item(eq_item):
				changed = true
			equipped[slot_key] = eq_item
		if changed:
			state.set("equipped", equipped)

	return changed

static func sanitize_item(item: Dictionary) -> bool:
	if item.is_empty():
		return false
	var rarity: String = str(item.get("rarity", "normal")).to_lower()
	if rarity == UNIQUE_RARITY:
		_round_all_numeric_stats(item)
		return false

	var changed: bool = false
	for stat_container_key: String in ["total_stats", "stats", "affixes"]:
		if typeof(item.get(stat_container_key, {})) != TYPE_DICTIONARY:
			continue
		var stats: Dictionary = Dictionary(item.get(stat_container_key, {}))
		var clean: Dictionary = {}
		for key_value: Variant in stats.keys():
			var key: String = str(key_value)
			if is_stat_allowed_on_slot(key, normalized_slot(item)):
				clean[key] = int(round(safe_float(stats[key_value])))
			else:
				changed = true
		if clean != stats:
			item[stat_container_key] = clean
			changed = true

	if _round_all_numeric_stats(item):
		changed = true
	return changed

static func _round_all_numeric_stats(item: Dictionary) -> bool:
	var changed: bool = false
	for stat_container_key: String in ["total_stats", "stats", "affixes"]:
		if typeof(item.get(stat_container_key, {})) != TYPE_DICTIONARY:
			continue
		var stats: Dictionary = Dictionary(item.get(stat_container_key, {}))
		for key_value: Variant in stats.keys():
			var rounded: int = int(round(safe_float(stats[key_value])))
			if stats[key_value] != rounded:
				stats[key_value] = rounded
				changed = true
		item[stat_container_key] = stats
	return changed

static func is_stat_allowed_on_slot(stat_key: String, slot: String) -> bool:
	var key: String = stat_key.strip_edges().to_lower()
	if UNIVERSAL_STATS.has(key):
		return true
	match slot:
		"weapon":
			return WEAPON_STATS.has(key)
		"offhand":
			return OFFHAND_STATS.has(key) or ARMOR_STATS.has(key)
		"head", "chest", "gloves", "boots":
			return ARMOR_STATS.has(key)
		"amulet", "ring", "ring1", "ring2", "relic":
			return JEWELRY_STATS.has(key)
		_:
			return false

static func normalized_slot(item: Dictionary) -> String:
	var slot: String = str(item.get("slot", "")).to_lower()
	match slot:
		"helm":
			return "head"
		"ring":
			return "ring1"
		_:
			return slot

static func display_stat_line(stat_key: String, raw_value: Variant) -> String:
	var key: String = str(stat_key).strip_edges()
	var label: String = str(STAT_DISPLAY_NAMES.get(key, _titleize_stat_key(key)))
	var value: int = int(round(safe_float(raw_value)))
	var prefix: String = "+" if value >= 0 else ""
	var suffix: String = "%" if is_percent_stat(key) else ""
	return prefix + str(value) + suffix + " " + label

static func display_stat_delta(stat_key: String, current_value: Variant, next_value: Variant) -> String:
	var key: String = str(stat_key).strip_edges()
	var label: String = str(STAT_DISPLAY_NAMES.get(key, _titleize_stat_key(key)))
	var cur: int = int(round(safe_float(current_value)))
	var nxt: int = int(round(safe_float(next_value)))
	var diff: int = nxt - cur
	var suffix: String = "%" if is_percent_stat(key) else ""
	var sign: String = "+" if diff >= 0 else ""
	return label + ": " + str(cur) + suffix + " → " + str(nxt) + suffix + " (" + sign + str(diff) + suffix + ")"

static func is_percent_stat(stat_key: String) -> bool:
	return PERCENT_STATS.has(str(stat_key).strip_edges().to_lower())

static func sort_key_for_item(item: Dictionary) -> Array:
	var slot: String = normalized_slot(item)
	var rarity: String = str(item.get("rarity", "normal")).to_lower()
	return [
		int(SLOT_ORDER.get(slot, 99)),
		int(RARITY_ORDER.get(rarity, 99)),
		-int(round(safe_float(item.get("item_level", 1)))),
		str(item.get("display_name", item.get("name", "Item"))).to_lower()
	]

static func compare_items_for_sort(a: Variant, b: Variant) -> bool:
	var ia: Dictionary = Dictionary(a) if typeof(a) == TYPE_DICTIONARY else {}
	var ib: Dictionary = Dictionary(b) if typeof(b) == TYPE_DICTIONARY else {}
	var ka: Array = sort_key_for_item(ia)
	var kb: Array = sort_key_for_item(ib)
	for i: int in range(min(ka.size(), kb.size())):
		if ka[i] == kb[i]:
			continue
		return ka[i] < kb[i]
	return false

static func safe_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(value)
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			return s.to_float() if s.is_valid_float() else fallback
		_:
			return fallback

static func _titleize_stat_key(key: String) -> String:
	var words: PackedStringArray = str(key).replace("-", "_").split("_")
	var out: Array[String] = []
	for word: String in words:
		if word == "":
			continue
		out.append(word.substr(0, 1).to_upper() + word.substr(1).to_lower())
	return " ".join(out)
