extends RefCounted

const STATION_LOCKED_MODES: Array[String] = ["stash", "crafting"]

static func can_open_panel(state: Object, mode: String) -> bool:
	if state == null:
		return false
	if mode == "":
		return true
	if not STATION_LOCKED_MODES.has(mode):
		return true
	var near: String = str(state.get("near_station_mode"))
	if near == mode:
		return true
	if state.has_method("add_notice"):
		if mode == "stash":
			state.call("add_notice", "Use the physical Stash in the hub.")
		else:
			state.call("add_notice", "Use the physical Forge table in the hub.")
	return false

static func request_panel(state: Object, mode: String) -> bool:
	if state == null:
		return false
	if mode == "":
		state.set("panel_mode", "")
		return true
	if not can_open_panel(state, mode):
		return false
	state.set("panel_mode", mode)
	return true

static func toggle_panel(state: Object, mode: String) -> bool:
	if state == null:
		return false
	if str(state.get("panel_mode")) == mode:
		state.set("panel_mode", "")
		return true
	return request_panel(state, mode)

static func close_panel(state: Object) -> void:
	if state != null:
		state.set("panel_mode", "")

static func panel_title(mode: String) -> String:
	match mode:
		"inventory": return "Inventory & Equipment"
		"stash": return "Stash"
		"crafting": return "Forge"
		"skills": return "Skill Gems"
		"maps": return "Map Device"
		"character": return "Character"
		"help": return "Help"
		_: return ""
