extends Node
class_name RVRuntimeLayerManager3D

var game_root: Node = null
var _last_report: Dictionary = {}

var layer_specs: Array[Dictionary] = [
	{"name": "VisualFoundationLayer096A", "path": "res://scripts/visual/VisualFoundationLayer3D.gd", "required": false},
	{"name": "HubGreyboxPass096B", "path": "res://scripts/visual/HubGreyboxPass3D.gd", "required": false},
	{"name": "CombatArenaGreyboxPass096C", "path": "res://scripts/visual/CombatArenaGreyboxPass3D.gd", "required": false},
	{"name": "SkillVFXLayer096D", "path": "res://scripts/visual/SkillVFXLayer3D.gd", "required": false},
	{"name": "EnemyReadabilityLayer096E", "path": "res://scripts/visual/EnemyReadabilityLayer3D.gd", "required": false},
	{"name": "LootPresentationLayer096F", "path": "res://scripts/visual/LootPresentationLayer3D.gd", "required": false},
	{"name": "CombatFeedbackLayer096G", "path": "res://scripts/visual/CombatFeedbackLayer3D.gd", "required": false},
	{"name": "CombatDirectorLayer097A", "path": "res://scripts/visual/CombatDirectorLayer3D.gd", "required": false},
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

	var report: Dictionary = {
		"created": [],
		"existing": [],
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

	if node_name == "" or script_path == "":
		return

	_remove_duplicate_children_named(node_name, report)

	var existing: Node = game_root.get_node_or_null(node_name)
	if existing != null:
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

	var node: Node = null
	if loaded is Script:
		node = (loaded as Script).new()
	else:
		var failed_list_2: Array = report.get("failed", [])
		failed_list_2.append(node_name + " :: resource is not a Script")
		report["failed"] = failed_list_2
		return

	if node == null:
		var failed_list_3: Array = report.get("failed", [])
		failed_list_3.append(node_name + " :: instantiate failed")
		report["failed"] = failed_list_3
		return

	node.name = node_name
	game_root.add_child(node)

	if node.has_method("bind_game"):
		node.call("bind_game", game_root)

	var created_list: Array = report.get("created", [])
	created_list.append(node_name)
	report["created"] = created_list


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
