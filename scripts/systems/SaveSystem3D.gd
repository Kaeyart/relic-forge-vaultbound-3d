class_name RVSaveSystem3D
extends RefCounted

const SAVE_PATH: String = "user://relic_forge_vaultbound_3d_save.json"

static func save(state: RVGameState3D) -> bool:
	if state == null:
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(state.to_save_dict(), "\t"))
	return true

static func load_into(state: RVGameState3D) -> bool:
	if state == null or not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	state.apply_save_dict(Dictionary(parsed))
	return true
