extends RefCounted
class_name RVVerticalSliceSmokeTestSystem3D

const RuntimeDetectionSystemScript := preload("res://scripts/systems/RuntimeDetectionSystem3D.gd")

static func report(root: Node, game_state: Object = null) -> Dictionary:
	var scene_report: Dictionary = RuntimeDetectionSystemScript.scene_report(root)
	var warnings: Array = Array(scene_report.get("warnings", []))

	var mode: String = _state_string(game_state, "mode", "")
	var panel_mode: String = _state_string(game_state, "panel_mode", "")
	var selected_skill: String = _selected_skill(game_state)
	var active_map: String = _active_map_label(game_state)

	if mode == "":
		warnings.append("State mode is empty.")
	if selected_skill == "":
		warnings.append("No selected skill could be resolved.")
	if active_map == "" and mode == "combat":
		warnings.append("Combat mode has no active map label.")

	return {
		"mode": mode,
		"panel_mode": panel_mode,
		"selected_skill": selected_skill,
		"active_map": active_map,
		"enemy_count": int(scene_report.get("enemy_count", 0)),
		"loot_count": int(scene_report.get("loot_count", 0)),
		"generated_visual_count": int(scene_report.get("generated_visual_count", 0)),
		"warnings": warnings,
	}


static func one_line(root: Node, game_state: Object = null) -> String:
	var data: Dictionary = report(root, game_state)
	var parts: Array[String] = []
	parts.append("Mode " + str(data.get("mode", "")))
	parts.append("Map " + str(data.get("active_map", "")))
	parts.append("Skill " + str(data.get("selected_skill", "")))
	parts.append("Enemies " + str(data.get("enemy_count", 0)))
	parts.append("Loot " + str(data.get("loot_count", 0)))
	parts.append("Visuals " + str(data.get("generated_visual_count", 0)))
	return " · ".join(parts)


static func _selected_skill(state: Object) -> String:
	if state == null:
		return ""

	var slots_value: Variant = state.get("active_skill_slots")
	if typeof(slots_value) != TYPE_ARRAY:
		return ""

	var slots: Array = Array(slots_value)
	if slots.is_empty():
		return ""

	var selected: int = _state_int(state, "selected_skill_slot", 0)
	selected = clampi(selected, 0, slots.size() - 1)

	if typeof(slots[selected]) != TYPE_DICTIONARY:
		return ""

	var slot: Dictionary = Dictionary(slots[selected])
	return str(slot.get("active", slot.get("active_id", "")))


static func _active_map_label(state: Object) -> String:
	if state == null:
		return ""

	var value: Variant = state.get("active_map_item")
	if typeof(value) != TYPE_DICTIONARY:
		value = state.get("current_map_activity")
	if typeof(value) != TYPE_DICTIONARY:
		return ""

	var map_item: Dictionary = Dictionary(value)
	var name: String = str(map_item.get("display_name", "Map"))
	var tier: String = str(map_item.get("tier", map_item.get("map_tier", 1)))
	var rarity: String = str(map_item.get("rarity", "normal")).capitalize()
	return name + " T" + tier + " " + rarity


static func _state_string(state: Object, key: String, fallback: String) -> String:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return str(value)


static func _state_int(state: Object, key: String, fallback: int) -> int:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
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
