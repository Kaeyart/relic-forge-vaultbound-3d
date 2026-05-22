extends RefCounted
class_name RVClassProgressionSystem3D

const ClassDBScript := preload("res://scripts/data/ClassDB3D.gd")
const PassiveTreeSystemScript := preload("res://scripts/systems/PassiveTreeSystem3D.gd")
const AscendancySystemScript := preload("res://scripts/systems/AscendancySystem3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	var class_id: String = str(_state_get(state, "class_id", "sorceress"))
	if not ClassDBScript.is_valid_class(class_id):
		_state_set(state, "class_id", "sorceress")
		class_id = "sorceress"
	_state_set(state, "class_display_name", ClassDBScript.display_name(class_id))
	if state.get("class_locked") == null:
		_state_set(state, "class_locked", false)
	if state.get("selected_build_lane_id") == null:
		var lanes: Array = ClassDBScript.recommended_lanes(class_id)
		_state_set(state, "selected_build_lane_id", str(Dictionary(lanes[0]).get("id", "")) if not lanes.is_empty() else "")
	PassiveTreeSystemScript.ensure_defaults(state)
	AscendancySystemScript.ensure_defaults(state)

static func switch_class_for_testing(state: Object, class_id: String) -> Dictionary:
	ensure_defaults(state)
	if not ClassDBScript.is_valid_class(class_id):
		return {"ok": false, "message": "Unknown class: " + class_id}
	_state_set(state, "class_id", class_id)
	_state_set(state, "class_display_name", ClassDBScript.display_name(class_id))	
	_state_set(state, "selected_ascendancy_id", "")
	_state_set(state, "allocated_ascendancy_nodes", {})
	_state_set(state, "allocated_passive_nodes", {})
	var lanes: Array = ClassDBScript.recommended_lanes(class_id)
	_state_set(state, "selected_build_lane_id", str(Dictionary(lanes[0]).get("id", "")) if not lanes.is_empty() else "")
	PassiveTreeSystemScript.ensure_defaults(state)
	AscendancySystemScript.ensure_defaults(state)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return {"ok": true, "message": "Switched prototype class to " + ClassDBScript.display_name(class_id)}

static func class_bundle(state: Object) -> Dictionary:
	ensure_defaults(state)
	var class_id: String = str(_state_get(state, "class_id", "sorceress"))
	var result: Dictionary = ClassDBScript.class_bundle(class_id)
	_merge_bundle(result, PassiveTreeSystemScript.bundle(state))
	_merge_bundle(result, AscendancySystemScript.bundle(state))
	return result

static func class_summary_text(state: Object) -> String:
	ensure_defaults(state)
	var class_id: String = str(_state_get(state, "class_id", "sorceress"))
	var data: Dictionary = ClassDBScript.class_data(class_id)
	var text: String = str(data.get("display_name", class_id)) + "\n"
	text += str(data.get("fantasy", "")) + "\n\n"
	text += "Recommended lanes:\n"
	for lane_value: Variant in ClassDBScript.recommended_lanes(class_id):
		var lane: Dictionary = Dictionary(lane_value)
		text += "- " + str(lane.get("name", lane.get("id", "Lane"))) + "\n"
	text += "\nAscendancies:\n"
	for asc_id: Variant in ClassDBScript.ascendancy_ids(class_id):
		text += "- " + str(asc_id).replace("_", " ").capitalize() + "\n"
	return text

static func _merge_bundle(target: Dictionary, source: Dictionary) -> void:
	if not target.has("stats") or typeof(target["stats"]) != TYPE_DICTIONARY:
		target["stats"] = {}
	if not target.has("rules") or typeof(target["rules"]) != TYPE_ARRAY:
		target["rules"] = []
	var stats: Dictionary = Dictionary(source.get("stats", {}))
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		Dictionary(target["stats"])[key] = float(Dictionary(target["stats"]).get(key, 0.0)) + float(stats[key_value])
	for rule_value: Variant in Array(source.get("rules", [])):
		var rule: String = str(rule_value)
		if rule != "" and not Array(target["rules"]).has(rule):
			Array(target["rules"]).append(rule)

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _state_set(state: Object, key: String, value: Variant) -> void:
	if state != null:
		state.set(key, value)
