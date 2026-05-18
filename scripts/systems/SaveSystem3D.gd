class_name RVSaveSystem3D
extends RefCounted

const SAVE_PATH: String = "user://relic_forge_vaultbound_3d.save"

static func save(state: Object) -> void:
	if state == null or not state.has_method("to_save_dict"):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(state.call("to_save_dict"), "\t"))

static func load_into(state: Object) -> bool:
	if state == null or not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	if state.has_method("apply_save_dict"):
		state.call("apply_save_dict", Dictionary(parsed))
		return true
	return false
