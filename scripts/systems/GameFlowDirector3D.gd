extends Node
class_name RVGameFlowDirector3D

const RuntimeFeatureFlagsScript := preload("res://scripts/systems/RuntimeFeatureFlags3D.gd")
const SliceChecklistSystemScript := preload("res://scripts/systems/SliceChecklistSystem3D.gd")

var game_root: Node = null
var _ready_done: bool = false


func _ready() -> void:
	name = "GameFlowDirector099A"
	call_deferred("_late_ready")


func bind_game(root: Node) -> void:
	game_root = root
	call_deferred("_late_ready")


func _late_ready() -> void:
	if _ready_done:
		return
	_ready_done = true
	_ensure_slice_defaults()
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F4:
			force_return_to_hub()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F5:
			start_ash_vault_slice()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F6:
			print_slice_report()
			get_viewport().set_input_as_handled()


func force_return_to_hub() -> void:
	var state: Object = _state()
	if state != null:
		state.set("mode", "hub")
		state.set("panel_mode", "")
		state.set("last_slice_action", "Returned to hub")
		_add_notice(state, "Returned to hub")

	var arena: Node = _find_node_with_method(_root(), "stop_map", "combat")
	if arena != null:
		arena.call("stop_map")

	_update_ui()


func start_ash_vault_slice() -> void:
	var state: Object = _state()
	if state == null:
		return

	_ensure_slice_defaults()

	var map_item: Dictionary = _ash_vault_map()
	state.set("current_map_activity", map_item.duplicate(true))
	state.set("active_map_item", map_item.duplicate(true))
	state.set("active_map_tier", 1)
	state.set("active_map_rarity", "normal")
	state.set("active_map_entries", 5)
	state.set("panel_mode", "")
	state.set("mode", "combat")
	state.set("last_slice_action", "Started Ash Vault test map")

	var arena: Node = _find_node_with_method(_root(), "start_map", "combat")
	if arena != null:
		arena.call("start_map", state, map_item)
		_add_notice(state, "Started Ash Vault test map")
	else:
		_add_notice(state, "No combat arena found for F5 start")

	_update_ui()


func print_slice_report() -> void:
	print(SliceChecklistSystemScript.report_text(_root(), _state()))


func _ensure_slice_defaults() -> void:
	var state: Object = _state()
	if state == null:
		return

	RuntimeFeatureFlagsScript.ensure_defaults(state)

	if state.get("mode") == null:
		state.set("mode", "hub")
	if state.get("panel_mode") == null:
		state.set("panel_mode", "")

	var maps_value: Variant = state.get("map_stash")
	var maps: Array = []
	if typeof(maps_value) == TYPE_ARRAY:
		maps = Array(maps_value)

	if maps.is_empty():
		maps.append(_ash_vault_map())
		state.set("map_stash", maps)
		state.set("map_cursor", 0)

	if state.get("slice_milestone") == null:
		state.set("slice_milestone", "0.1")


func _ash_vault_map() -> Dictionary:
	return {
		"uid": "slice_ash_vault",
		"base_id": "ash_vault",
		"display_name": "Ash Vault",
		"tier": 1,
		"map_tier": 1,
		"map_level": 1,
		"layout": "box_blockers",
		"rarity": "normal",
		"mods": [],
		"entries": 6,
		"kind": "map",
		"item_kind": "map",
		"category": "map",
		"slot": "map",
		"tags": ["map", "slice"],
	}


func _root() -> Node:
	if game_root != null:
		return game_root
	return get_tree().current_scene


func _state() -> Object:
	var root: Node = _root()
	if root == null:
		return null

	var value: Variant = root.get("state")
	if value != null and value is Object:
		return value as Object

	return null


func _find_node_with_method(root: Node, method_name: String, name_hint: String = "") -> Node:
	if root == null:
		return null

	var lower_name: String = str(root.name).to_lower()
	if root.has_method(method_name):
		if name_hint == "" or lower_name.find(name_hint) >= 0:
			return root

	for child: Node in root.get_children():
		var found: Node = _find_node_with_method(child, method_name, name_hint)
		if found != null:
			return found

	if name_hint != "" and root.has_method(method_name):
		return root

	return null


func _update_ui() -> void:
	var ui: Node = _find_node_with_method(_root(), "update_from_state", "panel")
	var state: Object = _state()
	if ui != null and state != null:
		ui.call("update_from_state", state)


func _add_notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)
