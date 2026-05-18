class_name RVMapLoopSystem3D
extends RefCounted

const MapDBScript := preload("res://scripts/data/MapDB3D.gd")

static func map_to_run(state: Object) -> Dictionary:
	if state == null:
		return MapDBScript.make_test_map(1)
	var stash: Array = Array(state.get("map_stash"))
	if stash.is_empty():
		return MapDBScript.make_test_map(max(1, int(state.get("level"))))
	return Dictionary(stash[0]).duplicate(true)

static func consume_map_for_run(state: Object, map_item: Dictionary) -> void:
	if state == null:
		return
	var stash: Array = Array(state.get("map_stash"))
	for i: int in range(stash.size()):
		if typeof(stash[i]) == TYPE_DICTIONARY and str(Dictionary(stash[i]).get("id", "")) == str(map_item.get("id", "")):
			stash.remove_at(i)
			break
	state.set("map_stash", stash)
	state.set("current_map", map_item.duplicate(true))
	state.set("map_entries_remaining", int(state.get("map_entries_max")))

static func consume_entry(state: Object) -> bool:
	if state == null:
		return false
	var entries: int = int(state.get("map_entries_remaining"))
	if entries <= 0:
		return false
	state.set("map_entries_remaining", entries - 1)
	return true

static func complete_current_map(state: Object) -> void:
	if state == null:
		return
	state.set("map_completed", true)
	state.set("map_entries_remaining", 0)
	state.set("active_map_snapshot", {})
	if state.has_method("add_notice"):
		state.call("add_notice", "Map complete")
