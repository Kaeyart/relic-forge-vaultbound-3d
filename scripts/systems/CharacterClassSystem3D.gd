class_name RVCharacterClassSystem3D
extends RefCounted

const ClassDBScript: GDScript = preload("res://scripts/data/ClassDB3D.gd")

static func classes() -> Dictionary:
	return ClassDBScript.classes()

static func class_ids() -> Array[String]:
	return ClassDBScript.class_ids()

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	var id: String = str(state.get("class_id"))
	if id == "" or not ClassDBScript.has_class(id):
		id = "sorceress"
		state.set("class_id", id)
	var data: Dictionary = ClassDBScript.class_data(id)
	state.set("class_display_name", str(data.get("display_name", id.capitalize())))
	state.set("class_tags", Array(data.get("tags", [])).duplicate(true))
	state.set("class_rules", Array(data.get("rules", [])).duplicate(true))
	if state.get("selected_ascendancy_id") == null:
		state.set("selected_ascendancy_id", "")

static func class_bundle(state: Object) -> Dictionary:
	if state == null:
		return {}
	var id: String = str(state.get("class_id"))
	return ClassDBScript.class_bundle(id)

static func set_class(state: Object, class_id: String) -> String:
	if state == null:
		return "No state."
	if not ClassDBScript.has_class(class_id):
		return "Unknown class: " + class_id
	state.set("class_id", class_id)
	state.set("selected_ascendancy_id", "")
	state.set("allocated_ascendancy_nodes", {})
	ensure_defaults(state)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	var data: Dictionary = ClassDBScript.class_data(class_id)
	return "Class set to " + str(data.get("display_name", class_id.capitalize())) + "."

static func class_summary_text(state: Object) -> String:
	if state == null:
		return "No class."
	ensure_defaults(state)
	var id: String = str(state.get("class_id"))
	var data: Dictionary = ClassDBScript.class_data(id)
	var text: String = "[color=#c59b4a][b]" + str(data.get("display_name", id.capitalize())) + "[/b][/color]\n"
	text += str(data.get("description", "")) + "\n"
	text += "Tags: " + ", ".join(Array(data.get("tags", []))) + "\n"
	text += "Ascendancies: " + ", ".join(Array(data.get("ascendancies", [])))
	return text
