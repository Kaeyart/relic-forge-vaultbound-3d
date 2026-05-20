extends Node3D
class_name RVHubStationLayer3D

const RuntimeDetectionSystemScript := preload("res://scripts/systems/RuntimeDetectionSystem3D.gd")
const HubStationSystemScript := preload("res://scripts/systems/HubStationSystem3D.gd")

var game_root: Node = null
var _station_root: Node3D = null
var _prompt_layer: CanvasLayer = null
var _prompt_label: RichTextLabel = null
var _stations: Array[Node3D] = []
var _nearest: Node3D = null
var _scan_timer: float = 0.0
var _time: float = 0.0


func _ready() -> void:
	name = "HubStationLayer098C"
	RuntimeDetectionSystemScript.mark_generated_visual(self, "hub_station")
	_ensure_station_root()
	_build_stations()
	_ensure_prompt()
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if _nearest != null and is_instance_valid(_nearest):
				_open_station(_nearest)
				get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	_time += delta
	_update_visibility()
	if not visible:
		_set_prompt("")
		return

	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.08
		_update_nearest_station()

	_update_station_highlights()


func _ensure_station_root() -> void:
	if _station_root != null and is_instance_valid(_station_root):
		return

	_station_root = get_node_or_null("HubStations098C") as Node3D
	if _station_root == null:
		_station_root = Node3D.new()
		_station_root.name = "HubStations098C"
		add_child(_station_root)

	RuntimeDetectionSystemScript.mark_generated_visual(_station_root, "hub_station")


func _build_stations() -> void:
	_ensure_station_root()

	for child: Node in _station_root.get_children():
		child.queue_free()

	_stations.clear()

	_create_floor_grid()

	for spec: Dictionary in HubStationSystemScript.station_specs():
		var station: Node3D = _make_station(spec)
		_station_root.add_child(station)
		_stations.append(station)
		RuntimeDetectionSystemScript.mark_generated_visual(station, "hub_station")


func _create_floor_grid() -> void:
	var floor_mat: StandardMaterial3D = _mat("HubWhiteboxFloor", Color(0.20, 0.21, 0.23, 0.92))
	var floor: MeshInstance3D = _box("HubWhiteboxFloor098C", Vector3(11.0, 0.06, 10.0), Vector3(0.0, -0.04, -0.2), floor_mat)
	_station_root.add_child(floor)

	for x: int in range(-5, 6):
		var line_mat: StandardMaterial3D = _mat("HubGridLine", Color(0.36, 0.36, 0.38, 0.50))
		var line: MeshInstance3D = _box("HubGridLineX", Vector3(0.025, 0.025, 10.0), Vector3(float(x), 0.02, -0.2), line_mat)
		_station_root.add_child(line)

	for z: int in range(-5, 6):
		var line_mat_z: StandardMaterial3D = _mat("HubGridLine", Color(0.36, 0.36, 0.38, 0.50))
		var line_z: MeshInstance3D = _box("HubGridLineZ", Vector3(11.0, 0.025, 0.025), Vector3(0.0, 0.025, float(z) - 0.2), line_mat_z)
		_station_root.add_child(line_z)


func _make_station(spec: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "HubStation_" + str(spec.get("id", "station"))
	root.position = spec.get("position", Vector3.ZERO)
	root.set_meta("station_id", str(spec.get("id", "")))
	root.set_meta("station_name", str(spec.get("name", "Station")))
	root.set_meta("panel_mode", str(spec.get("panel_mode", "")))
	root.set_meta("station_hint", str(spec.get("hint", "")))

	var color: Color = spec.get("color", Color.WHITE)
	var size: Vector3 = spec.get("size", Vector3.ONE)

	var base_mat: StandardMaterial3D = _mat("StationBase_" + str(spec.get("id", "")), color)
	var dark_mat: StandardMaterial3D = _mat("StationPedestal_" + str(spec.get("id", "")), Color(color.r * 0.35, color.g * 0.35, color.b * 0.35, 0.92))

	var pedestal: MeshInstance3D = _box("HubStationPedestal", Vector3(size.x + 0.35, 0.22, size.z + 0.35), Vector3(0.0, 0.11, 0.0), dark_mat)
	root.add_child(pedestal)

	var body: MeshInstance3D = _box("HubStationBody", size, Vector3(0.0, 0.22 + size.y * 0.5, 0.0), base_mat)
	root.add_child(body)

	var ring: MeshInstance3D = _disc("HubStationInteractionRing", 1.15, Color(color.r, color.g, color.b, 0.28))
	ring.position = Vector3(0.0, 0.035, 0.0)
	root.add_child(ring)

	var label: Label3D = Label3D.new()
	label.name = "HubStationLabel"
	label.text = str(spec.get("name", "Station"))
	label.font_size = 24
	label.modulate = Color(0.95, 0.92, 0.82, 1.0)
	label.position = Vector3(0.0, size.y + 0.75, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)

	var hint: Label3D = Label3D.new()
	hint.name = "HubStationHint"
	hint.text = "E"
	hint.font_size = 30
	hint.modulate = Color(color.r, color.g, color.b, 1.0)
	hint.position = Vector3(0.0, size.y + 1.25, 0.0)
	hint.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hint.visible = false
	root.add_child(hint)

	return root


func _ensure_prompt() -> void:
	if _prompt_layer != null and is_instance_valid(_prompt_layer):
		return

	_prompt_layer = CanvasLayer.new()
	_prompt_layer.name = "HubStationPromptLayer098C"
	_prompt_layer.layer = 75
	add_child(_prompt_layer)

	var panel: PanelContainer = PanelContainer.new()
	panel.name = "HubStationPromptPanel"
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 220.0
	panel.offset_right = -220.0
	panel.offset_top = -104.0
	panel.offset_bottom = -28.0

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.035, 0.045, 0.82)
	style.border_color = Color(0.75, 0.58, 0.28, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	_prompt_layer.add_child(panel)

	_prompt_label = RichTextLabel.new()
	_prompt_label.name = "HubStationPromptText"
	_prompt_label.bbcode_enabled = true
	_prompt_label.fit_content = true
	_prompt_label.scroll_active = false
	_prompt_label.custom_minimum_size = Vector2(680.0, 54.0)
	panel.add_child(_prompt_label)

	RuntimeDetectionSystemScript.mark_generated_visual(_prompt_layer, "hub_station")


func _update_visibility() -> void:
	visible = HubStationSystemScript.should_show_hub_stations(_state())


func _update_nearest_station() -> void:
	var player: Node3D = _find_player()
	if player == null:
		_nearest = null
		_set_prompt("")
		return

	_nearest = HubStationSystemScript.nearest_station(player.global_position, _stations, 2.35)
	if _nearest == null:
		_set_prompt("")
	else:
		_set_prompt(HubStationSystemScript.station_prompt(_nearest))


func _update_station_highlights() -> void:
	for station: Node3D in _stations:
		if station == null or not is_instance_valid(station):
			continue

		var active: bool = station == _nearest
		var ring: MeshInstance3D = station.get_node_or_null("HubStationInteractionRing") as MeshInstance3D
		if ring != null:
			var pulse: float = (sin(_time * 5.5) + 1.0) * 0.5 if active else 0.0
			var s: float = 1.0 + pulse * 0.16
			ring.scale = Vector3(s, 1.0, s)
			ring.visible = true

		var hint: Label3D = station.get_node_or_null("HubStationHint") as Label3D
		if hint != null:
			hint.visible = active


func _open_station(station: Node) -> void:
	var mode: String = HubStationSystemScript.station_panel_mode(station)
	if mode == "":
		return

	var state: Object = _state()
	if state != null:
		state.set("panel_mode", mode)

	var ui: Node = _find_ui_root()
	if ui != null and ui.has_method("_set_mode"):
		ui.call("_set_mode", mode)
	elif ui != null and ui.has_method("set_mode"):
		ui.call("set_mode", mode)

	_set_prompt(HubStationSystemScript.station_prompt(station))


func _find_ui_root() -> Node:
	var scene: Node = get_tree().current_scene
	if scene == null:
		scene = game_root
	if scene == null:
		return null

	var direct_names: Array[String] = ["UIPanelRoot3D", "FinalUIPanelRoot3D", "FinalUIPanelRoot", "PanelRoot"]
	for node_name: String in direct_names:
		var found: Node = scene.get_node_or_null(node_name)
		if found != null:
			return found

	return _find_ui_root_recursive(scene)


func _find_ui_root_recursive(root: Node) -> Node:
	if root == null:
		return null

	if root.has_method("_set_mode") or root.has_method("set_mode"):
		var n: String = str(root.name).to_lower()
		if n.find("ui") >= 0 or n.find("panel") >= 0:
			return root

	for child: Node in root.get_children():
		var found: Node = _find_ui_root_recursive(child)
		if found != null:
			return found

	return null


func _find_player() -> Node3D:
	var groups: Array[String] = ["player", "players", "hero"]
	for group_name: String in groups:
		var nodes: Array = get_tree().get_nodes_in_group(group_name)
		for value: Variant in nodes:
			if value is Node3D and is_instance_valid(value):
				return value as Node3D

	var scene: Node = get_tree().current_scene
	if scene == null:
		scene = game_root
	return _find_player_recursive(scene)


func _find_player_recursive(root: Node) -> Node3D:
	if root == null:
		return null

	if root is Node3D and not RuntimeDetectionSystemScript.is_generated_visual(root, true):
		var lower_name: String = str(root.name).to_lower()
		if lower_name.find("player") >= 0 or lower_name.find("hero") >= 0 or lower_name.find("character") >= 0:
			return root as Node3D

	for child: Node in root.get_children():
		var found: Node3D = _find_player_recursive(child)
		if found != null:
			return found

	return null


func _state() -> Object:
	if game_root == null:
		return null
	var value: Variant = game_root.get("state")
	if value != null and value is Object:
		return value as Object
	return null


func _set_prompt(text: String) -> void:
	_ensure_prompt()
	if _prompt_label == null:
		return

	_prompt_layer.visible = text != ""
	if text == "":
		_prompt_label.text = ""
	else:
		_prompt_label.text = "[center][b]" + text + "[/b][/center]"


func _box(node_name: String, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size

	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.material_override = mat
	return node


func _disc(node_name: String, radius: float, color: Color) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.025
	mesh.radial_segments = 64

	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.material_override = _mat(node_name, color)
	return node


func _mat(label: String, color: Color) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.resource_name = label
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat
