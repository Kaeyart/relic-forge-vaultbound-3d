class_name RVSaveSystem3D
extends RefCounted

const SAVE_PATH: String = "user://relic_forge_3d_save.json"

static func load_into(state: Object) -> void:
	if state == null:
		return
	if not FileAccess.file_exists(SAVE_PATH):
		if state.has_method("init_new"):
			state.call("init_new")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		state.call("init_new")
		return
	var text: String = file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		state.call("apply_save_dict", Dictionary(parsed))
	else:
		state.call("init_new")

static func save(state: Object) -> void:
	if state == null or not state.has_method("to_save_dict"):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(state.call("to_save_dict"), "\t"))
