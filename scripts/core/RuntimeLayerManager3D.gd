extends Node
class_name RVRuntimeLayerManager3D

const RuntimeFeatureFlagsScript := preload("res://scripts/systems/RuntimeFeatureFlags3D.gd")

var game_root: Node = null
var _last_report: Dictionary = {}

var layer_specs: Array[Dictionary] = [
	{"name": "VisualFoundationLayer096A", "path": "res://scripts/visual/VisualFoundationLayer3D.gd", "required": false, "flag": "visual_foundation_layer"},
	{"name": "HubGreyboxPass096B", "path": "res://scripts/visual/HubGreyboxPass3D.gd", "required": false, "flag": "hub_greybox_layer"},
	{"name": "CombatArenaGreyboxPass096C", "path": "res://scripts/visual/CombatArenaGreyboxPass3D.gd", "required": false, "flag": "combat_arena_greybox_layer"},
	{"name": "SkillVFXLayer096D", "path": "res://scripts/visual/SkillVFXLayer3D.gd", "required": false, "flag": "skill_vfx_layer"},
	{"name": "EnemyReadabilityLayer096E", "path": "res://scripts/visual/EnemyReadabilityLayer3D.gd", "required": false, "flag": "enemy_readability_layer"},
	{"name": "LootPresentationLayer096F", "path": "res://scripts/visual/LootPresentationLayer3D.gd", "required": false, "flag": "loot_presentation_layer"},
	{"name": "CombatFeedbackLayer096G", "path": "res://scripts/visual/CombatFeedbackLayer3D.gd", "required": false, "flag": "combat_feedback_layer"},
	{"name": "CombatDirectorLayer097A", "path": "res://scripts/visual/CombatDirectorLayer3D.gd", "required": false, "flag": "combat_director_layer"},
	{"name": "VerticalSliceDebugOverlay098A", "path": "res://scripts/visual/VerticalSliceDebugOverlay3D.gd", "required": false, "flag": "vertical_slice_debug_overlay"},
	{"name": "CombatFeelLayer098B", "path": "res://scripts/visual/CombatFeelLayer3D.gd", "required": false, "flag": "combat_feel_layer"},
	{"name": "HubStationLayer098C", "path": "res://scripts/visual/HubStationLayer3D.gd", "required": false, "flag": "hub_station_layer"},
	{"name": "GameFlowDirector099A", "path": "res://scripts/systems/GameFlowDirector3D.gd", "required": false, "flag": "game_flow_director"},
	{"name": "FinalUIPanelRoot100A", "path": "res://scripts/ui/FinalUIPanelRoot3D.gd", "required": true, "flag": "final_ui_shell"},
]


func _ready() -> void:
	name = "RuntimeLayerManager097B"
	call_deferred("_ensure_layers")


func bind_game(root: Node) -> void:
	game_root = root
	call_deferred("_ensure_layers")


func health_report() -> Dictionary:
	return _last_report.duplicate(true)


func refresh_layers() -> Dictionary:
	_ensure_layers()
	return health_report()


func _ensure_layers() -> void:
	if game_root == null:
		game_root = get_parent()
	if game_root == null:
		return

	var state: Object = _state()
	if state != null:
		RuntimeFeatureFlagsScript.ensure_defaults(state)

	var report: Dictionary = {
		"created": [],
		"existing": [],
		"disabled": [],
		"missing_optional": [],
		"missing_required": [],
		"failed": [],
		"duplicates_removed": [],
	}

	for spec: Dictionary in layer_specs:
		_ensure_single_layer(spec, report)

	_last_report = report
	set_meta("rv_runtime_layer_report", report)


func _ensure_single_layer(spec: Dictionary, report: Dictionary) -> void:
	var node_name: String = str(spec.get("name", ""))
	var script_path: String = str(spec.get("path", ""))
	var required: bool = bool(spec.get("required", false))
	var flag_name: String = str(spec.get("flag", RuntimeFeatureFlagsScript.layer_flag_for_name(node_name)))

	if node_name == "" or script_path == "":
		return

	_remove_duplicate_children_named(node_name, report)

	var existing: Node = game_root.get_node_or_null(node_name)
	var enabled: bool = RuntimeFeatureFlagsScript.is_enabled(_state(), flag_name, true)

	if not enabled:
		if existing != null:
			_apply_layer_runtime_state(existing, false)
		var disabled_list: Array = report.get("disabled", [])
		disabled_list.append(node_name)
		report["disabled"] = disabled_list
		return

	if existing != null:
		_apply_layer_runtime_state(existing, true)
		if existing.has_method("bind_game"):
			existing.call("bind_game", game_root)
		var existing_list: Array = report.get("existing", [])
		existing_list.append(node_name)
		report["existing"] = existing_list
		return

	if not ResourceLoader.exists(script_path):
		var key: String = "missing_required" if required else "missing_optional"
		var missing_list: Array = report.get(key, [])
		missing_list.append(node_name + " :: " + script_path)
		report[key] = missing_list
		return

	var loaded: Resource = ResourceLoader.load(script_path)
	if loaded == null:
		var failed_list: Array = report.get("failed", [])
		failed_list.append(node_name + " :: load failed")
		report["failed"] = failed_list
		return

	if not (loaded is Script):
		var failed_list_2: Array = report.get("failed", [])
		failed_list_2.append(node_name + " :: resource is not a Script")
		report["failed"] = failed_list_2
		return

	var node: Node = (loaded as Script).new()
	if node == null:
		var failed_list_3: Array = report.get("failed", [])
		failed_list_3.append(node_name + " :: instantiate failed")
		report["failed"] = failed_list_3
		return

	node.name = node_name
	game_root.add_child(node)
	_apply_layer_runtime_state(node, true)

	if node.has_method("bind_game"):
		node.call("bind_game", game_root)

	var created_list: Array = report.get("created", [])
	created_list.append(node_name)
	report["created"] = created_list


func _apply_layer_runtime_state(node: Node, enabled: bool) -> void:
	if node == null:
		return

	node.set_process(enabled)
	node.set_physics_process(enabled)
	node.set_process_unhandled_input(enabled)
	node.set_process_input(enabled)

	if node is CanvasItem:
		(node as CanvasItem).visible = enabled
	elif node is Node3D:
		(node as Node3D).visible = enabled


func _remove_duplicate_children_named(node_name: String, report: Dictionary) -> void:
	if game_root == null:
		return

	var matches: Array[Node] = []
	for child: Node in game_root.get_children():
		if child.name == node_name:
			matches.append(child)

	if matches.size() <= 1:
		return

	for i: int in range(1, matches.size()):
		var duplicate: Node = matches[i]
		game_root.remove_child(duplicate)
		duplicate.queue_free()

	var dupes: Array = report.get("duplicates_removed", [])
	dupes.append(node_name + " x" + str(matches.size() - 1))
	report["duplicates_removed"] = dupes


func _state() -> Object:
	if game_root == null:
		return null

	var value: Variant = game_root.get("state")
	if value != null and value is Object:
		return value as Object

	return null
