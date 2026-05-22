class_name RVPrecursorTabletSystem3D
extends RefCounted

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	var inventory: Array = _array(state.get("tablet_inventory"))
	if inventory.is_empty():
		inventory.append(make_tablet("gem", 5))
		inventory.append(make_tablet("forge", 5))
		inventory.append(make_tablet("boss", 3))
		state.set("tablet_inventory", inventory)
	if typeof(state.get("selected_tablet_uids")) != TYPE_ARRAY:
		state.set("selected_tablet_uids", [])


static func make_tablet(tablet_type: String, charges: int = 5) -> Dictionary:
	var data: Dictionary = tablet_data(tablet_type)
	return {
		"uid": "tablet_" + tablet_type + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000),
		"kind": "precursor_tablet",
		"tablet_type": tablet_type,
		"display_name": str(data.get("name", tablet_type.capitalize() + " Tablet")),
		"charges": maxi(1, charges),
		"mods": Array(data.get("mods", [])).duplicate(true),
		"description": str(data.get("description", "Applies extra content to a map.")),
	}


static func tablet_data(tablet_type: String) -> Dictionary:
	match tablet_type:
		"gem":
			return {"name": "Gem Precursor Tablet", "description": "Adds uncut gem pressure and extra monsters.", "mods": [{"id": "tablet_gem", "display_name": "+35% Uncut Gem Chance", "stats": {"Uncut Gem Chance": 0.35, "Pack Size": 0.10}, "danger": 1, "reward": 4}]}
		"forge":
			return {"name": "Forge Precursor Tablet", "description": "Adds forge material caches.", "mods": [{"id": "tablet_forge", "display_name": "+35% Forge Material Chance", "stats": {"Forge Material Chance": 0.35, "Item Quantity": 0.10}, "danger": 1, "reward": 3}]}
		"boss":
			return {"name": "Boss Precursor Tablet", "description": "Makes the boss more dangerous and more rewarding.", "mods": [{"id": "tablet_boss", "display_name": "+Boss Rewards / +Boss Danger", "stats": {"Boss Damage": 0.15, "Boss Life": 0.20, "Item Rarity": 0.25}, "danger": 3, "reward": 5}]}
		"breach":
			return {"name": "Breach Precursor Tablet", "description": "Adds a monster density breach event placeholder.", "mods": [{"id": "tablet_breach", "display_name": "+30% Pack Size", "stats": {"Pack Size": 0.30, "Item Quantity": 0.10}, "danger": 3, "reward": 4}]}
		_:
			return {"name": tablet_type.capitalize() + " Tablet", "description": "Unknown tablet.", "mods": []}


static func selected_tablets(state: Object) -> Array[Dictionary]:
	ensure_defaults(state)
	var selected_uids: Array = _array(state.get("selected_tablet_uids"))
	var out: Array[Dictionary] = []
	for value: Variant in _array(state.get("tablet_inventory")):
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var tablet: Dictionary = Dictionary(value)
		if selected_uids.has(str(tablet.get("uid", ""))):
			out.append(tablet)
	return out


static func toggle_tablet(state: Object, uid: String, max_slots: int) -> bool:
	ensure_defaults(state)
	var selected: Array = _array(state.get("selected_tablet_uids"))
	if selected.has(uid):
		selected.erase(uid)
		state.set("selected_tablet_uids", selected)
		return true
	if selected.size() >= max_slots:
		return false
	for value: Variant in _array(state.get("tablet_inventory")):
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("uid", "")) == uid:
			selected.append(uid)
			state.set("selected_tablet_uids", selected)
			return true
	return false


static func consume_selected_tablets(state: Object) -> Array[Dictionary]:
	ensure_defaults(state)
	var selected: Array = _array(state.get("selected_tablet_uids"))
	var inventory: Array = _array(state.get("tablet_inventory"))
	var used: Array[Dictionary] = []
	for i: int in range(inventory.size() - 1, -1, -1):
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue
		var tablet: Dictionary = Dictionary(inventory[i])
		var uid: String = str(tablet.get("uid", ""))
		if not selected.has(uid):
			continue
		used.append(tablet.duplicate(true))
		tablet["charges"] = int(tablet.get("charges", 1)) - 1
		if int(tablet.get("charges", 0)) <= 0:
			inventory.remove_at(i)
		else:
			inventory[i] = tablet
	state.set("tablet_inventory", inventory)
	state.set("selected_tablet_uids", [])
	return used


static func add_tablet(state: Object, tablet: Dictionary) -> void:
	if state == null or tablet.is_empty():
		return
	var inventory: Array = _array(state.get("tablet_inventory"))
	inventory.append(tablet.duplicate(true))
	state.set("tablet_inventory", inventory)


static func stat_total(tablets: Array, stat_name: String) -> float:
	var total: float = 0.0
	for tablet_value: Variant in tablets:
		if typeof(tablet_value) != TYPE_DICTIONARY:
			continue
		for mod_value: Variant in Array(Dictionary(tablet_value).get("mods", [])):
			if typeof(mod_value) == TYPE_DICTIONARY:
				total += float(Dictionary(Dictionary(mod_value).get("stats", {})).get(stat_name, 0.0))
	return total


static func danger_score(tablets: Array) -> int:
	var score: int = 0
	for tablet_value: Variant in tablets:
		if typeof(tablet_value) != TYPE_DICTIONARY:
			continue
		for mod_value: Variant in Array(Dictionary(tablet_value).get("mods", [])):
			if typeof(mod_value) == TYPE_DICTIONARY:
				score += int(Dictionary(mod_value).get("danger", 0))
	return score


static func reward_score(tablets: Array) -> int:
	var score: int = 0
	for tablet_value: Variant in tablets:
		if typeof(tablet_value) != TYPE_DICTIONARY:
			continue
		for mod_value: Variant in Array(Dictionary(tablet_value).get("mods", [])):
			if typeof(mod_value) == TYPE_DICTIONARY:
				score += int(Dictionary(mod_value).get("reward", 0))
	return score


static func _array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []
