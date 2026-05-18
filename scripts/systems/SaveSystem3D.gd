# PATCH_087L: class_name removed to avoid Godot global-class collision. Use preload aliases.
extends RefCounted

const SAVE_PATH: String = "user://relic_forge_3d_save.json"

static func save(state: Object) -> void:
	if state == null: return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null: return
	file.store_string(JSON.stringify(state.call("to_save_dict"), "\t"))

static func load_into(state: Object) -> void:
	if state == null: return
	if not FileAccess.file_exists(SAVE_PATH):
		state.call("init_new")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		state.call("init_new")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		state.call("apply_save_dict", Dictionary(parsed))
	else:
		state.call("init_new")
