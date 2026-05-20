extends RefCounted
class_name RVUIStateSummarySystem3D

static func summary_for_mode(state: Object, mode: String) -> String:
	if state == null:
		return ""

	match mode:
		"inventory":
			return inventory_summary(state)
		"stash":
			return stash_summary(state)
		"crafting":
			return forge_summary(state)
		"skills":
			return skills_summary(state)
		"maps":
			return maps_summary(state)
		"character":
			return character_summary(state)
		_:
			return ""


static func inventory_summary(state: Object) -> String:
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var equipped: Dictionary = _as_dict(_state_get(state, "equipped", {}))
	var selected: int = _to_int(_state_get(state, "inventory_cursor", 0), 0)
	var item_text: String = "none"
	if selected >= 0 and selected < backpack.size() and typeof(backpack[selected]) == TYPE_DICTIONARY:
		item_text = _item_name(Dictionary(backpack[selected]))
	return "Backpack " + str(backpack.size()) + " · Equipped " + str(equipped.size()) + " · Selected " + item_text


static func stash_summary(state: Object) -> String:
	var tabs: Array = _as_array(_state_get(state, "stash_tabs", []))
	var categories: Array = _as_array(_state_get(state, "stash_categories", []))
	var total_items: int = 0
	for value: Variant in tabs:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		total_items += _as_array(Dictionary(value).get("items", [])).size()
	var query: String = str(_state_get(state, "stash_search_query", "")).strip_edges()
	var search_text: String = " · Search: " + query if query != "" else ""
	return "Categories " + str(categories.size()) + " · Tabs " + str(tabs.size()) + " · Stored " + str(total_items) + search_text


static func forge_summary(state: Object) -> String:
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var selected_uid: String = str(_state_get(state, "crafting_selected_item_uid", ""))
	var selected_name: String = "none"
	for value: Variant in backpack:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(value)
		if selected_uid != "" and str(item.get("uid", "")) == selected_uid:
			selected_name = _item_name(item) + " · FP " + str(item.get("forge_potential", 0))
			break
	if selected_name == "none" and not backpack.is_empty() and typeof(backpack[0]) == TYPE_DICTIONARY:
		var fallback_item: Dictionary = Dictionary(backpack[0])
		selected_name = _item_name(fallback_item) + " · FP " + str(fallback_item.get("forge_potential", 0))
	return "Forge item: " + selected_name + " · Materials " + _wallet_summary(state)


static func skills_summary(state: Object) -> String:
	var active_slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	var selected: int = _to_int(_state_get(state, "selected_skill_slot", 0), 0)
	var spirit_reserved: int = _to_int(_state_get(state, "spirit_reserved", 0), 0)
	var spirit_max: int = _to_int(_state_get(state, "spirit_max", 0), 0)
	var selected_text: String = "none"
	if selected >= 0 and selected < active_slots.size() and typeof(active_slots[selected]) == TYPE_DICTIONARY:
		var slot: Dictionary = Dictionary(active_slots[selected])
		selected_text = str(slot.get("active", slot.get("active_id", "empty")))
	return "Active slots " + str(active_slots.size()) + " · Selected " + selected_text + " · Spirit " + str(spirit_reserved) + "/" + str(spirit_max)


static func maps_summary(state: Object) -> String:
	var maps: Array = _as_array(_state_get(state, "map_stash", []))
	var cursor: int = _to_int(_state_get(state, "map_cursor", 0), 0)
	var completed: Dictionary = _as_dict(_state_get(state, "completed_maps", {}))
	var bonus: Dictionary = _as_dict(_state_get(state, "bonus_completed_maps", {}))
	var selected: String = "none"
	if cursor >= 0 and cursor < maps.size() and typeof(maps[cursor]) == TYPE_DICTIONARY:
		var map_item: Dictionary = Dictionary(maps[cursor])
		selected = str(map_item.get("display_name", "Map")) + " T" + str(map_item.get("tier", map_item.get("map_tier", 1))) + " " + str(map_item.get("rarity", "normal")).capitalize()
	return "Maps " + str(maps.size()) + " · Selected " + selected + " · Complete " + str(completed.size()) + " · Bonus " + str(bonus.size())


static func character_summary(state: Object) -> String:
	var level: int = _to_int(_state_get(state, "level", 1), 1)
	var hp: int = _to_int(_state_get(state, "player_hp", _state_get(state, "hp", 0)), 0)
	var max_hp: int = _to_int(_state_get(state, "max_hp", _state_get(state, "maximum_life", 0)), 0)
	var mana: int = _to_int(_state_get(state, "player_mana", _state_get(state, "mana", 0)), 0)
	var max_mana: int = _to_int(_state_get(state, "max_mana", _state_get(state, "maximum_mana", 0)), 0)
	var stats: Dictionary = _as_dict(_state_get(state, "build_stats", {}))
	return "Level " + str(level) + " · HP " + str(hp) + "/" + str(max_hp) + " · Mana " + str(mana) + "/" + str(max_mana) + " · Stats " + str(stats.size())


static func _item_name(item: Dictionary) -> String:
	return str(item.get("display_name", item.get("name", item.get("base_name", "Item"))))


static func _wallet_summary(state: Object) -> String:
	var wallet: Dictionary = {}
	var materials: Variant = _state_get(state, "materials", {})
	var currency: Variant = _state_get(state, "currency", {})
	if typeof(materials) == TYPE_DICTIONARY:
		wallet = Dictionary(materials)
	elif typeof(currency) == TYPE_DICTIONARY:
		wallet = Dictionary(currency)
	if wallet.is_empty():
		return "{}"
	var parts: Array[String] = []
	for key_value: Variant in wallet.keys():
		parts.append(str(key_value) + ":" + str(wallet[key_value]))
	return ", ".join(parts)


static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback

	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return value


static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value
	return []


static func _as_dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
