class_name RVUIMouseInteractionSystem3D
extends RefCounted

static func get_array(state: Object, key: String) -> Array:
	if state == null:
		return []
	var value: Variant = state.get(key)
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []

static func get_dict(state: Object, key: String) -> Dictionary:
	if state == null:
		return {}
	var value: Variant = state.get(key)
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}

static func notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)

static func selected_item(state: Object) -> Dictionary:
	var backpack: Array = get_array(state, "backpack")
	var cursor: int = int(state.get("inventory_cursor")) if state != null and state.get("inventory_cursor") != null else 0
	if cursor >= 0 and cursor < backpack.size() and typeof(backpack[cursor]) == TYPE_DICTIONARY:
		return Dictionary(backpack[cursor])
	return {}

static func mutate_selected_item(state: Object, key: String, value: Variant) -> bool:
	if state == null:
		return false
	var backpack: Array = get_array(state, "backpack")
	var cursor: int = int(state.get("inventory_cursor")) if state.get("inventory_cursor") != null else 0
	if cursor < 0 or cursor >= backpack.size() or typeof(backpack[cursor]) != TYPE_DICTIONARY:
		return false
	var item: Dictionary = Dictionary(backpack[cursor])
	item[key] = value
	backpack[cursor] = item
	state.set("backpack", backpack)
	return true

static func toggle_selected_flag(state: Object, key: String) -> bool:
	var item: Dictionary = selected_item(state)
	if item.is_empty():
		notice(state, "No inventory item selected.")
		return false
	var current: bool = bool(item.get(key, false))
	return mutate_selected_item(state, key, not current)

static func appraise_selected(state: Object) -> bool:
	var item: Dictionary = selected_item(state)
	if item.is_empty():
		notice(state, "No inventory item selected.")
		return false
	if bool(item.get("identified", true)):
		notice(state, "Item is already appraised.")
		return false
	mutate_selected_item(state, "identified", true)
	notice(state, "Item appraised.")
	return true

static func drop_selected(state: Object) -> bool:
	if state == null:
		return false
	var backpack: Array = get_array(state, "backpack")	
	var cursor: int = int(state.get("inventory_cursor")) if state.get("inventory_cursor") != null else 0
	if cursor < 0 or cursor >= backpack.size() or typeof(backpack[cursor]) != TYPE_DICTIONARY:
		notice(state, "No inventory item selected.")
		return false
	var item: Dictionary = Dictionary(backpack[cursor])
	if bool(item.get("locked", false)) or bool(item.get("favorite", false)):
		notice(state, "Cannot drop locked/favorite item.")
		return false
	backpack.remove_at(cursor)
	state.set("backpack", backpack)
	if backpack.is_empty():
		state.set("inventory_cursor", 0)
	else:
		state.set("inventory_cursor", clampi(cursor, 0, backpack.size() - 1))
	notice(state, "Dropped " + str(item.get("display_name", item.get("name", "item"))) + ".")
	return true

static func store_selected_to_stash(state: Object) -> bool:
	if state == null:
		return false
	var backpack: Array = get_array(state, "backpack")
	var cursor: int = int(state.get("inventory_cursor")) if state.get("inventory_cursor") != null else 0
	if cursor < 0 or cursor >= backpack.size() or typeof(backpack[cursor]) != TYPE_DICTIONARY:
		notice(state, "No inventory item selected.")
		return false
	var item: Dictionary = Dictionary(backpack[cursor])
	backpack.remove_at(cursor)
	var stash: Array = get_array(state, "stash")
	stash.append(item)
	state.set("backpack", backpack)
	state.set("stash", stash)
	if backpack.is_empty():
		state.set("inventory_cursor", 0)
	else:
		state.set("inventory_cursor", clampi(cursor, 0, backpack.size() - 1))
	notice(state, "Stored " + str(item.get("display_name", item.get("name", "item"))) + ".")
	return true

static func take_selected_from_stash(state: Object) -> bool:
	if state == null:
		return false
	var stash: Array = get_array(state, "stash")
	var cursor: int = int(state.get("stash_cursor")) if state.get("stash_cursor") != null else 0
	if cursor < 0 or cursor >= stash.size() or typeof(stash[cursor]) != TYPE_DICTIONARY:
		notice(state, "No stash item selected.")
		return false
	var item: Dictionary = Dictionary(stash[cursor])
	stash.remove_at(cursor)
	var backpack: Array = get_array(state, "backpack")
	backpack.append(item)
	state.set("stash", stash)
	state.set("backpack", backpack)
	if stash.is_empty():
		state.set("stash_cursor", 0)
	else:
		state.set("stash_cursor", clampi(cursor, 0, stash.size() - 1))
	state.set("inventory_cursor", backpack.size() - 1)
	notice(state, "Took " + str(item.get("display_name", item.get("name", "item"))) + ".")
	return true
