class_name RVMapLoopSystem3D
extends RefCounted

const MapDBScript := preload("res://scripts/data/MapDB3D.gd")

static func selected_or_default_map(state: Object) -> Dictionary:
	if state == null: return {}
	var maps: Array = Array(state.get("map_stash"))
	if maps.is_empty():
		var new_map: Dictionary = MapDBScript.make_map_item("ash_vault", 1, state.get("rng"))
		maps.append(new_map)
		state.set("map_stash", maps)
	var cursor: int = clampi(int(state.get("map_cursor")), 0, max(0, maps.size() - 1))
	return Dictionary(maps[cursor]).duplicate(true)

static func start_selected_map(state: Object) -> Dictionary:
	var map_item: Dictionary = selected_or_default_map(state)
	if map_item.is_empty(): return {}
	map_item["entries"] = max(0, int(map_item.get("entries", 6)) - 1)
	state.set("active_map_entries", int(map_item.get("entries", 0)))
	state.set("current_map_activity", map_item.duplicate(true))
	var maps: Array = Array(state.get("map_stash"))
	var cursor: int = clampi(int(state.get("map_cursor")), 0, max(0, maps.size() - 1))
	if not maps.is_empty():
		if int(map_item.get("entries", 0)) <= 0:
			maps.remove_at(cursor)
		else:
			maps[cursor] = map_item
		state.set("map_stash", maps)
	return map_item

static func complete_current_map(state: Object) -> void:
	if state == null: return
	var activity: Dictionary = Dictionary(state.get("current_map_activity"))
	if activity.is_empty(): return
	var completed: Dictionary = Dictionary(state.get("completed_maps"))
	completed[str(activity.get("base_id", "ash_vault"))] = true
	state.set("completed_maps", completed)
	state.set("maps_completed", int(state.get("maps_completed")) + 1)
	state.call("add_notice", "Map complete")

static func panel_text(state: Object) -> String:
	if state == null: return "Maps unavailable."
	var maps: Array = Array(state.get("map_stash"))
	var cursor: int = int(state.get("map_cursor"))
	var text: String = "MAP DEVICE\n[ / ] Select Map · T Start Map\n\n"
	if maps.is_empty():
		return text + "No maps. Kill bosses to find more."
	for i: int in range(maps.size()):
		var marker: String = "> " if i == cursor else "  "
		text += marker + MapDBScript.describe(Dictionary(maps[i])) + "\n"
	return text
