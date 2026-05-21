class_name RVUIAccessSystem3D
extends RefCounted

const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")

const GLOBAL_PANEL_MODES: Array[String] = ["inventory", "skills"]
const STATION_PANEL_MODES: Array[String] = ["maps", "crafting", "stash", "character"]

const STATION_NAMES: Dictionary = {
	"maps": "Map Device",
	"crafting": "Forge",
	"stash": "Stash",
	"character": "Character Shrine",
}

static func normalize_mode(mode: String) -> String:
	var m: String = str(mode).strip_edges().to_lower()
	match m:
		"forge":
			return "crafting"
		"skill", "gems", "gem", "skill_gems":
			return "skills"
		"map", "map_device":
			return "maps"
		"char", "stats":
			return "character"
		_:
			return m


static func request_panel(state: Object, mode: String, from_station: bool = false) -> bool:
	if state == null:
		return false

	var m: String = normalize_mode(mode)
	if m == "":
		close_panel(state)
		return true

	if not can_open_panel(state, m, from_station):
		_notice(state, _blocked_message(m))
		return false

	state.set("panel_mode", m)
	return true


static func toggle_panel(state: Object, mode: String, from_station: bool = false) -> bool:
	if state == null:
		return false

	var m: String = normalize_mode(mode)
	if str(_state_get(state, "panel_mode", "")) == m:
		close_panel(state)
		return true

	return request_panel(state, m, from_station)


static func close_panel(state: Object) -> void:
	if state != null:
		state.set("panel_mode", "")


static func can_open_panel(state: Object, mode: String, from_station: bool = false) -> bool:
	if state == null:
		return false

	var m: String = normalize_mode(mode)
	if GLOBAL_PANEL_MODES.has(m):
		return true

	if not STATION_PANEL_MODES.has(m):
		return true

	if str(_state_get(state, "mode", "hub")) != "hub":
		return false

	if from_station:
		return true

	return _near_station_allows(state, m)


static func panel_title(mode: String) -> String:
	var m: String = normalize_mode(mode)
	if UIFoundationSystemScript != null and UIFoundationSystemScript.has_method("panel_title"):
		return str(UIFoundationSystemScript.panel_title(m))
	match m:
		"inventory":
			return "Inventory"
		"skills":
			return "Skill Gems"
		"maps":
			return "Map Device"
		"crafting":
			return "Forge"
		"stash":
			return "Stash"
		"character":
			return "Character"
		_:
			return m.capitalize()


static func panel_hint(mode: String) -> String:
	var m: String = normalize_mode(mode)
	if STATION_PANEL_MODES.has(m):
		return "Station access only · walk to the " + str(STATION_NAMES.get(m, "station")) + " in the hub."
	if UIFoundationSystemScript != null and UIFoundationSystemScript.has_method("panel_hint"):
		return str(UIFoundationSystemScript.panel_hint(m))
	return "Mouse-first UI · click visible rows, slots, and actions."


static func _near_station_allows(state: Object, mode: String) -> bool:
	var m: String = normalize_mode(mode)

	var direct_keys: Array[String] = [
		"near_station_mode",
		"near_station_panel",
		"near_station_target",
		"near_station_panel_mode",
		"station_mode",
		"station_panel",
	]

	for key: String in direct_keys:
		var v: String = normalize_mode(str(_state_get(state, key, "")))
		if v == m:
			return true

	var id_text: String = str(_state_get(state, "near_station_id", "")).to_lower()
	var name_text: String = str(_state_get(state, "near_station_name", "")).to_lower()
	var combined: String = id_text + " " + name_text

	match m:
		"maps":
			return combined.find("map") >= 0 or combined.find("device") >= 0
		"crafting":
			return combined.find("forge") >= 0 or combined.find("craft") >= 0
		"stash":
			return combined.find("stash") >= 0
		"character":
			return combined.find("character") >= 0 or combined.find("shrine") >= 0
		_:
			return false


static func _blocked_message(mode: String) -> String:
	var m: String = normalize_mode(mode)
	if STATION_PANEL_MODES.has(m):
		return "Walk to the " + str(STATION_NAMES.get(m, "station")) + " in the hub to open this."
	return "That panel is not available right now."


static func _notice(state: Object, text: String) -> void:
	if state == null:
		return
	if state.has_method("add_notice"):
		state.call("add_notice", text)
	else:
		state.set("notice_text", text)
		state.set("notice_time", 2.0)


static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return value
