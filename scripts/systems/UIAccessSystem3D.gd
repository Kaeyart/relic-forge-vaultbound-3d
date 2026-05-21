extends RefCounted

const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")

static func request_panel(state: Object, mode: String) -> bool:
	if state == null:
		return false
	state.set("panel_mode", mode)
	return true

static func toggle_panel(state: Object, mode: String) -> bool:
	if state == null:
		return false
	var current: String = str(state.get("panel_mode"))
	if current == mode:
		state.set("panel_mode", "")
	else:
		state.set("panel_mode", mode)
	return true

static func close_panel(state: Object) -> void:
	if state != null:
		state.set("panel_mode", "")

static func panel_title(mode: String) -> String:
	return UIFoundationSystemScript.panel_title(mode)

static func panel_hint(mode: String) -> String:
	return UIFoundationSystemScript.panel_hint(mode)
