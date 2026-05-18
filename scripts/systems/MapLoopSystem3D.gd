class_name RVMapLoopSystem3D
extends RefCounted

static func start_run(map_item: Dictionary) -> Dictionary:
	var run: Dictionary = {
		"kind":"map_run",
		"map_item": map_item.duplicate(true),
		"map_id": str(map_item.get("map_id", "ash_vault_01")),
		"layout_id": str(map_item.get("layout_id", "layout_ruin_rect_01")),
		"area_level": int(map_item.get("area_level", 1)),
		"tier": int(map_item.get("tier", 1)),
		"entries_remaining": int(map_item.get("entries", 6)),
		"boss_alive": true,
		"completed": false,
		"failed": false,
		"killed_enemy_ids": [],
		"ground_loot": []
	}
	run["entries_remaining"] = max(0, int(run["entries_remaining"]) - 1)
	return run

static func consume_entry(run: Dictionary) -> Dictionary:
	var out: Dictionary = run.duplicate(true)
	out["entries_remaining"] = max(0, int(out.get("entries_remaining", 0)) - 1)
	if int(out.get("entries_remaining", 0)) <= 0 and not bool(out.get("completed", false)):
		out["failed"] = true
	return out

static func complete_run(state: RVGameState3D, run: Dictionary) -> void:
	if state == null:
		return
	var map_id: String = str(run.get("map_id", ""))
	if map_id != "":
		state.completed_map_ids[map_id] = true
	state.maps_completed += 1
	state.active_map_portal.clear()
	state.current_map_run.clear()
	state.add_notice("Map complete")
