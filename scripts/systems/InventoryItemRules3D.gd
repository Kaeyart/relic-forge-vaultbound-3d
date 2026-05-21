extends RefCounted

const UNIQUE_RARITY: String = "unique"

const STAT_DISPLAY_NAMES: Dictionary = {
	"maximum life": "Maximum Life",
	"maximum mana": "Maximum Mana",
	"maximum spirit": "Maximum Spirit",
	"armor": "Armor",
	"armour": "Armor",
	"ward": "Ward",
	"block chance": "Block Chance",
	"fire resistance": "Fire Resistance",
	"cold resistance": "Cold Resistance",
	"lightning resistance": "Lightning Resistance",
	"void resistance": "Void Resistance",
	"attack damage": "Attack Damage",
	"spell damage": "Spell Damage",
	"fire damage": "Fire Damage",
	"lightning damage": "Lightning Damage",
	"void damage": "Void Damage",
	"projectile damage": "Projectile Damage",
	"critical chance": "Critical Chance",
	"critical damage": "Critical Damage",
	"attack speed": "Attack Speed",
	"cast speed": "Cast Speed",
	"cooldown recovery": "Cooldown Recovery",
	"movement speed": "Movement Speed",
	"ignite chance": "Ignite Chance",
	"shock chance": "Shock Chance",
	"bleed chance": "Bleed Chance",
	"extra projectiles": "Extra Projectiles",
	"chain count": "Chain Count",
	"area size": "Area Size",
}

const PERCENT_STATS: Array[String] = [
	"block chance", "fire resistance", "cold resistance", "lightning resistance", "void resistance",
	"attack damage", "spell damage", "fire damage", "lightning damage", "void damage", "projectile damage",
	"critical chance", "critical damage", "attack speed", "cast speed", "cooldown recovery", "movement speed",
	"ignite chance", "shock chance", "bleed chance", "area size",
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
	"map": 10,
	"": 99,
}

const RARITY_ORDER: Dictionary = {
	"unique": 0,
	"rare": 1,
	"magic": 2,
	"normal": 3,
	"currency": 4,
	"": 9,
}

const UNIVERSAL_STATS: Array[String] = [
	"maximum life", "maximum mana", "maximum spirit", "fire resistance", "cold resistance", "lightning resistance", "void resistance",
]
const WEAPON_STATS: Array[String] = [
	"attack damage", "spell damage", "fire damage", "lightning damage", "void damage", "projectile damage",
	"critical chance", "critical damage", "attack speed", "cast speed", "cooldown recovery", "ignite chance", "shock chance", "bleed chance", "extra projectiles", "chain count", "area size",
]
const OFFHAND_STATS: Array[String] = [
	"armor", "ward", "block chance", "spell damage", "fire damage", "lightning damage", "void damage", "cast speed", "cooldown recovery", "critical chance", "chain count", "area size",
]
const ARMOR_STATS: Array[String] = [
	"armor", "ward", "movement speed", "cooldown recovery", "attack speed", "cast speed", "ignite chance", "shock chance", "bleed chance",
]
const JEWELRY_STATS: Array[String] = [
	"attack damage", "spell damage", "fire damage", "lightning damage", "void damage", "projectile damage", "critical chance", "critical damage",
	"attack speed", "cast speed", "cooldown recovery", "movement speed", "ignite chance", "shock chance", "bleed chance", "extra projectiles", "chain count", "area size",
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
	# Unique items intentionally bypass slot policing because their job is to break normal rules.
	if str(item.get("rarity", "normal")).to_lower() == UNIQUE_RARITY:
		_normalize_total_stats(item)
		return false
	var changed: bool = false
	for stat_container_key: String in ["total_stats", "stats", "implicit_stats", "unique_stats"]:
		if typeof(item.get(stat_container_key, {})) != TYPE_DICTIONARY:
			continue
		var stats: Dictionary = Dictionary(item.get(stat_container_key, {}))
		var clean: Dictionary = {}
		for key_value: Variant in stats.keys():
			var key: String = str(key_value)
			if is_stat_allowed_on_slot(key, normalized_slot(item)):
				clean[key] = _clean_numeric_value(key, stats[key_value])
			else:
				changed = true
		if clean != stats:
			item[stat_container_key] = clean
			changed = true
	return changed

static func _normalize_total_stats(item: Dictionary) -> void:
	for stat_container_key: String in ["total_stats", "stats", "implicit_stats", "unique_stats"]:
		if typeof(item.get(stat_container_key, {})) != TYPE_DICTIONARY:
			continue
		var stats: Dictionary = Dictionary(item.get(stat_container_key, {}))
		for key_value: Variant in stats.keys():
			stats[key_value] = _clean_numeric_value(str(key_value), stats[key_value])
		item[stat_container_key] = stats

static func _clean_numeric_value(key: String, value: Variant) -> float:
	var v: float = safe_float(value)
	if is_percent_stat(key):
		return snappedf(v, 0.001)
	return snappedf(v, 0.1)

static func is_stat_allowed_on_slot(stat_key: String, slot: String) -> bool:
	var key: String = _norm_stat(stat_key)
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
	var slot: String = str(item.get("slot", "")).to_lower().strip_edges()
	match slot:
		"helm":
			return "head"
		"ring":
			return "ring1"
		_:
			return slot

static func display_stat_line(stat_key: String, raw_value: Variant) -> String:
	var key: String = _norm_stat(stat_key)
	var label: String = str(STAT_DISPLAY_NAMES.get(key, _titleize_stat_key(key)))
	var value: float = safe_float(raw_value)
	var prefix: String = "+" if value >= 0.0 else ""
	if is_percent_stat(key):
		return prefix + str(snappedf(value * 100.0, 0.1)) + "% " + label
	return prefix + str(int(round(value))) + " " + label

static func display_stat_delta(stat_key: String, current_value: Variant, next_value: Variant) -> String:
	var key: String = _norm_stat(stat_key)
	var label: String = str(STAT_DISPLAY_NAMES.get(key, _titleize_stat_key(key)))
	var cur: float = safe_float(current_value)
	var nxt: float = safe_float(next_value)
	var diff: float = nxt - cur
	var sign: String = "+" if diff >= 0.0 else ""
	if is_percent_stat(key):
		return label + ": " + str(snappedf(cur * 100.0, 0.1)) + "% → " + str(snappedf(nxt * 100.0, 0.1)) + "% (" + sign + str(snappedf(diff * 100.0, 0.1)) + "%)"
	return label + ": " + str(int(round(cur))) + " → " + str(int(round(nxt))) + " (" + sign + str(int(round(diff))) + ")"

static func is_percent_stat(stat_key: String) -> bool:
	return PERCENT_STATS.has(_norm_stat(stat_key))

static func sort_key_for_item(item: Dictionary) -> Array:
	var slot: String = normalized_slot(item)
	var rarity: String = str(item.get("rarity", "normal")).to_lower()
	return [
		int(SLOT_ORDER.get(slot, 99)),
		int(RARITY_ORDER.get(rarity, 99)),
		-int(round(safe_float(item.get("item_level", 1)))),
		str(item.get("display_name", item.get("name", "Item"))).to_lower(),
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

static func _norm_stat(key: String) -> String:
	return str(key).strip_edges().to_lower().replace("_", " ").replace("-", " ")

static func _titleize_stat_key(key: String) -> String:
	var words: PackedStringArray = str(key).replace("-", " ").replace("_", " ").split(" ", false)
	var out: Array[String] = []
	for word: String in words:
		if word == "":
			continue
		out.append(word.substr(0, 1).to_upper() + word.substr(1).to_lower())
	return " ".join(out)
