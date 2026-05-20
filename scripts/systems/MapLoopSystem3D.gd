class_name RVMapLoopSystem3D
extends RefCounted

const MapDBScript := preload("res://scripts/data/MapDB3D.gd")
const MapDifficultySystemScript := preload("res://scripts/systems/MapDifficultySystem3D.gd")

static func selected_or_default_map(state: Object) -> Dictionary:
	if state == null:
		return {}

	var maps: Array = _as_array(state.get("map_stash"))
	if maps.is_empty():
		var rng: RandomNumberGenerator = state.get("rng") as RandomNumberGenerator
		maps.append(MapDBScript.make_map_item("ash_vault", 1, rng))
		state.set("map_stash", maps)

	var cursor: int = clampi(_to_int(state.get("map_cursor"), 0), 0, max(0, maps.size() - 1))
	return MapDifficultySystemScript.normalize_map_item(Dictionary(maps[cursor]).duplicate(true), state)


static func start_selected_map(state: Object) -> Dictionary:
	if state == null:
		return {}

	var map_item: Dictionary = selected_or_default_map(state)
	if map_item.is_empty():
		return {}

	map_item = MapDifficultySystemScript.normalize_map_item(map_item, state)
	map_item["entries"] = max(0, _to_int(map_item.get("entries", 6), 6) - 1)

	state.set("active_map_entries", _to_int(map_item.get("entries", 0), 0))
	state.set("current_map_activity", map_item.duplicate(true))
	state.set("active_map_item", map_item.duplicate(true))
	state.set("active_map_tier", _to_int(map_item.get("tier", 1), 1))
	state.set("active_map_rarity", str(map_item.get("rarity", "normal")))

	var maps: Array = _as_array(state.get("map_stash"))
	var cursor: int = clampi(_to_int(state.get("map_cursor"), 0), 0, max(0, maps.size() - 1))
	if not maps.is_empty():
		if _to_int(map_item.get("entries", 0), 0) <= 0:
			maps.remove_at(cursor)
			state.set("map_cursor", clampi(cursor, 0, max(0, maps.size() - 1)))
		else:
			maps[cursor] = map_item
	state.set("map_stash", maps)

	if state.has_method("add_notice"):
		state.call("add_notice", "Opened " + str(map_item.get("display_name", "Map")) + " · " + str(map_item.get("rarity", "normal")).capitalize())

	return map_item


static func complete_current_map(state: Object) -> void:
	if state == null:
		return

	var result: Dictionary = MapDifficultySystemScript.complete_current_map_state(state)
	if bool(result.get("completed", false)) and state.has_method("add_notice"):
		var msg: String = "Map complete"
		if bool(result.get("bonus", false)):
			msg += " + bonus"
		state.call("add_notice", msg)


static func panel_text(state: Object) -> String:
	if state == null:
		return "Maps unavailable."

	var maps: Array = _as_array(state.get("map_stash"))
	var cursor: int = _to_int(state.get("map_cursor"), 0)
	var completed: Dictionary = _as_dict(state.get("completed_maps"))
	var bonus_completed: Dictionary = _as_dict(state.get("bonus_completed_maps"))

	var text: String = "MAP DEVICE\n[ / ] Select Map · T Start Map\n\n"
	text += "Completed: " + str(completed.size()) + " · Bonus: " + str(bonus_completed.size()) + "\n\n"

	if maps.is_empty():
		return text + "No maps.\nKill bosses or rare enemies to find more."

	for i: int in range(maps.size()):
		if typeof(maps[i]) != TYPE_DICTIONARY:
			continue
		var map_item: Dictionary = MapDifficultySystemScript.normalize_map_item(Dictionary(maps[i]), state)
		var marker: String = "> " if i == cursor else "  "
		var base_id: String = str(map_item.get("base_id", "ash_vault"))
		var flags: String = ""
		if bool(completed.get(base_id, false)):
			flags += " ✓"
		if bool(bonus_completed.get(base_id, false)):
			flags += " ★"

		text += marker + str(map_item.get("display_name", "Map")) + flags + " · " + str(map_item.get("rarity", "normal")).capitalize() + " · T" + str(map_item.get("tier", 1)) + " · Lv " + str(map_item.get("map_level", 1)) + "\n"
		text += "   " + MapDifficultySystemScript.bonus_requirement_text(map_item) + "\n"

		var mods: Array = _as_array(map_item.get("mods", []))
		if mods.is_empty():
			text += "   No modifiers\n"
		else:
			var mod_names: Array[String] = []
			for value: Variant in mods:
				if typeof(value) == TYPE_DICTIONARY:
					mod_names.append(str(Dictionary(value).get("name", "Map Mod")))
			text += "   " + ", ".join(mod_names) + "\n"

	return text


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
