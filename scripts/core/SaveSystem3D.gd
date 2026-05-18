class_name RVSaveSystem3D
extends RefCounted

const SAVE_PATH := "user://relic_forge_3d_save.json"

static func save(state: RVGameState3D) -> void:
	if state == null:
		return
	var data := {
		"mode": state.mode,
		"level": state.level,
		"xp": state.xp,
		"gold": state.gold,
		"kills": state.kills,
		"deaths": state.deaths,
		"active_skills": state.active_skills,
		"selected_skill_index": state.selected_skill_index,
		"backpack": state.backpack,
		"materials": state.materials,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))

static func load_into(state: RVGameState3D) -> void:
	if state == null or not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	state.level = int(data.get("level", state.level))
	state.xp = float(data.get("xp", state.xp))
	state.gold = int(data.get("gold", state.gold))
	state.kills = int(data.get("kills", state.kills))
	state.deaths = int(data.get("deaths", state.deaths))
	if typeof(data.get("active_skills", [])) == TYPE_ARRAY:
		state.active_skills.clear()
		for value: Variant in Array(data.get("active_skills", [])):
			state.active_skills.append(str(value))
	state.selected_skill_index = int(data.get("selected_skill_index", state.selected_skill_index))
	if typeof(data.get("backpack", [])) == TYPE_ARRAY:
		state.backpack = Array(data.get("backpack", [])).duplicate(true)
	if typeof(data.get("materials", {})) == TYPE_DICTIONARY:
		state.materials = Dictionary(data.get("materials", {})).duplicate(true)
	state.mode = "hub"
	state.full_restore()
