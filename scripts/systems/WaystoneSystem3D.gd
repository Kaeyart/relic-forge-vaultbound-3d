class_name RVWaystoneSystem3D
extends RefCounted

const MOD_POOL: Array[Dictionary] = [
	{"id": "monster_damage", "display_name": "+15% Monster Damage", "stats": {"Monster Damage": 0.15}, "danger": 2, "reward": 1},
	{"id": "monster_life", "display_name": "+20% Monster Life", "stats": {"Monster Life": 0.20}, "danger": 2, "reward": 1},
	{"id": "pack_size", "display_name": "+20% Monster Pack Size", "stats": {"Pack Size": 0.20}, "danger": 1, "reward": 2},
	{"id": "rare_chance", "display_name": "+15% Rare Monster Chance", "stats": {"Rare Monster Chance": 0.15}, "danger": 2, "reward": 2},
	{"id": "boss_damage", "display_name": "+20% Boss Damage", "stats": {"Boss Damage": 0.20}, "danger": 2, "reward": 2},
	{"id": "boss_life", "display_name": "+25% Boss Life", "stats": {"Boss Life": 0.25}, "danger": 2, "reward": 2},
	{"id": "item_quantity", "display_name": "+20% Item Quantity", "stats": {"Item Quantity": 0.20}, "danger": 1, "reward": 3},
	{"id": "item_rarity", "display_name": "+30% Item Rarity", "stats": {"Item Rarity": 0.30}, "danger": 1, "reward": 3},
	{"id": "uncut_gems", "display_name": "+25% Uncut Gem Chance", "stats": {"Uncut Gem Chance": 0.25}, "danger": 1, "reward": 3},
	{"id": "forge_materials", "display_name": "+25% Forge Material Chance", "stats": {"Forge Material Chance": 0.25}, "danger": 1, "reward": 2},
]

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	var inventory: Array = _array(state.get("waystone_inventory"))
	if inventory.is_empty():
		inventory.append(make_waystone(1, "normal", []))
		inventory.append(make_waystone(1, "normal", []))
		inventory.append(make_waystone(1, "normal", []))
		inventory.append(make_waystone(1, "magic", ["pack_size", "uncut_gems"]))
		state.set("waystone_inventory", inventory)
	if str(state.get("selected_waystone_uid")) == "" and not inventory.is_empty():
		state.set("selected_waystone_uid", str(Dictionary(inventory[0]).get("uid", "")))


static func make_waystone(tier: int = 1, rarity: String = "normal", mod_ids: Array = []) -> Dictionary:
	var clean_tier: int = clampi(tier, 1, 16)
	var mods: Array[Dictionary] = []
	for id_value: Variant in mod_ids:
		var mod: Dictionary = mod_by_id(str(id_value))
		if not mod.is_empty():
			mods.append(mod)
	return {
		"uid": "waystone_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000),
		"kind": "waystone",
		"display_name": rarity.capitalize() + " Waystone T" + str(clean_tier),
		"tier": clean_tier,
		"area_level": 64 + clean_tier,
		"rarity": rarity,
		"mods": mods,
		"corrupted": false,
	}


static func make_random_waystone(rng: RandomNumberGenerator, tier: int = 1, force_magic: bool = false) -> Dictionary:
	var rarity: String = "normal"
	var mod_count: int = 0
	var roll: float = rng.randf()
	if force_magic or roll < 0.55:
		rarity = "magic"
		mod_count = rng.randi_range(1, 2)
	elif roll < 0.75:
		rarity = "rare"
		mod_count = rng.randi_range(3, 6)
	var ids: Array = []
	var pool: Array = MOD_POOL.duplicate(true)
	for i: int in range(mod_count):
		if pool.is_empty():
			break
		var idx: int = rng.randi_range(0, pool.size() - 1)
		ids.append(str(Dictionary(pool[idx]).get("id", "")))
		pool.remove_at(idx)
	return make_waystone(tier, rarity, ids)


static func selected_waystone(state: Object) -> Dictionary:
	ensure_defaults(state)
	var inventory: Array = _array(state.get("waystone_inventory"))
	var uid: String = str(state.get("selected_waystone_uid"))
	for value: Variant in inventory:
		if typeof(value) == TYPE_DICTIONARY:
			var w: Dictionary = normalize(Dictionary(value))
			if str(w.get("uid", "")) == uid:
				return w
	if not inventory.is_empty() and typeof(inventory[0]) == TYPE_DICTIONARY:
		var fallback: Dictionary = normalize(Dictionary(inventory[0]))
		state.set("selected_waystone_uid", str(fallback.get("uid", "")))
		return fallback
	return {}


static func select_waystone(state: Object, uid: String) -> bool:
	ensure_defaults(state)
	for value: Variant in _array(state.get("waystone_inventory")):
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("uid", "")) == uid:
			state.set("selected_waystone_uid", uid)
			return true
	return false


static func consume_selected_waystone(state: Object) -> Dictionary:
	ensure_defaults(state)
	var uid: String = str(state.get("selected_waystone_uid"))
	var inventory: Array = _array(state.get("waystone_inventory"))
	for i: int in range(inventory.size()):
		if typeof(inventory[i]) == TYPE_DICTIONARY and str(Dictionary(inventory[i]).get("uid", "")) == uid:
			var out: Dictionary = normalize(Dictionary(inventory[i]))
			inventory.remove_at(i)
			state.set("waystone_inventory", inventory)
			if not inventory.is_empty() and typeof(inventory[0]) == TYPE_DICTIONARY:
				state.set("selected_waystone_uid", str(Dictionary(inventory[0]).get("uid", "")))
			else:
				state.set("selected_waystone_uid", "")
			return out
	return {}


static func add_waystone(state: Object, waystone: Dictionary) -> void:
	if state == null or waystone.is_empty():
		return
	var inventory: Array = _array(state.get("waystone_inventory"))
	inventory.append(normalize(waystone))
	state.set("waystone_inventory", inventory)
	if str(state.get("selected_waystone_uid")) == "":
		state.set("selected_waystone_uid", str(Dictionary(inventory[0]).get("uid", "")))


static func normalize(waystone: Dictionary) -> Dictionary:
	var out: Dictionary = waystone.duplicate(true)
	if str(out.get("uid", "")) == "":
		out["uid"] = "waystone_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000)
	var tier: int = clampi(int(out.get("tier", 1)), 1, 16)
	out["tier"] = tier
	out["area_level"] = int(out.get("area_level", 64 + tier))
	out["kind"] = "waystone"
	if str(out.get("rarity", "")) == "":
		out["rarity"] = "normal"
	if typeof(out.get("mods", [])) != TYPE_ARRAY:
		out["mods"] = []
	out["display_name"] = str(out.get("display_name", str(out.get("rarity", "normal")).capitalize() + " Waystone T" + str(tier)))
	return out


static func tablet_slots_for_waystone(waystone: Dictionary) -> int:
	var mod_count: int = _array(waystone.get("mods", [])).size()
	if mod_count >= 6:
		return 3
	if mod_count >= 3:
		return 2
	return 1


static func stat_total(waystone: Dictionary, stat_name: String) -> float:
	var total: float = 0.0
	for value: Variant in _array(waystone.get("mods", [])):
		if typeof(value) == TYPE_DICTIONARY:
			total += float(Dictionary(Dictionary(value).get("stats", {})).get(stat_name, 0.0))
	return total


static func danger_score(waystone: Dictionary) -> int:
	var score: int = int(waystone.get("tier", 1))
	for value: Variant in _array(waystone.get("mods", [])):
		if typeof(value) == TYPE_DICTIONARY:
			score += int(Dictionary(value).get("danger", 0))
	return score


static func reward_score(waystone: Dictionary) -> int:
	var score: int = 1
	for value: Variant in _array(waystone.get("mods", [])):
		if typeof(value) == TYPE_DICTIONARY:
			score += int(Dictionary(value).get("reward", 0))
	return score


static func mod_by_id(id: String) -> Dictionary:
	for mod: Dictionary in MOD_POOL:
		if str(mod.get("id", "")) == id:
			return mod.duplicate(true)
	return {}


static func _array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []
