class_name RVStationAccessSystem3D
extends RefCounted

const UIAccessSystemScript: GDScript = preload("res://scripts/systems/UIAccessSystem3D.gd")

const CONTAINER_NAME: String = "HubStationAccessLayout028"
const LEGACY_CONTAINER_NAMES: Array[String] = [
	"HubStationAccessLayout013",
	"HubStationAccessLayout018",
	"HubStationLayer098C",
	"HubStations",
	"HubStationAccessLayout028",
]
const INTERACT_RADIUS: float = 3.05

const STATIONS: Array[Dictionary] = [
	{"id": "map_device", "display_name": "Map Device", "panel_mode": "maps", "position": Vector3(0.0, 0.0, 0.0), "accent": Color(0.20, 0.50, 1.0, 1.0)},
	{"id": "forge", "display_name": "Forge", "panel_mode": "crafting", "position": Vector3(-6.2, 0.0, -0.45), "accent": Color(1.0, 0.32, 0.06, 1.0)},
	{"id": "stash", "display_name": "Stash", "panel_mode": "stash", "position": Vector3(6.3, 0.0, -0.45), "accent": Color(0.88, 0.66, 0.28, 1.0)},
]

static func ensure_physical_stations(game_root: Node) -> void:
	if game_root == null:
		return

	var hub: Node3D = _hub_node(game_root)
	if hub == null:
		return

	_remove_legacy_station_nodes(game_root, hub)

	var container: Node3D = hub.get_node_or_null(CONTAINER_NAME) as Node3D
	if container == null:
		container = Node3D.new()
		container.name = CONTAINER_NAME
		hub.add_child(container)

	if container.get_child_count() == 0:
		_build_layout(container)


static func update_access(game_root: Node, state: Object, player: Node3D) -> void:
	if game_root == null or state == null:
		return

	ensure_physical_stations(game_root)

	if str(_state_get(state, "mode", "hub")) != "hub":
		_clear_station_state(state)
		_update_station_visuals(game_root, "")
		return

	if player == null:
		_clear_station_state(state)
		_update_station_visuals(game_root, "")
		return

	var closest: Dictionary = {}
	var closest_distance: float = 999999.0
	var player_pos: Vector3 = player.global_position

	for station: Dictionary in STATIONS:
		var pos: Vector3 = _station_position(station)
		var distance: float = Vector2(player_pos.x - pos.x, player_pos.z - pos.z).length()
		if distance < closest_distance:
			closest_distance = distance
			closest = station

	if closest.is_empty() or closest_distance > INTERACT_RADIUS:
		_clear_station_state(state)
		_update_station_visuals(game_root, "")
		return

	var station_id: String = str(closest.get("id", ""))
	state.set("near_station_id", station_id)
	state.set("near_station_name", str(closest.get("display_name", "")))
	state.set("near_station_panel", str(closest.get("panel_mode", "")))
	state.set("near_station_distance", closest_distance)
	_update_station_visuals(game_root, station_id)


static func handle_station_input(event: InputEvent, game_root: Node, state: Object, player: Node3D) -> bool:
	if event == null or game_root == null or state == null:
		return false
	if not (event is InputEventKey):
		return false

	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return false
	if key_event.keycode != KEY_E:
		return false
	if str(_state_get(state, "mode", "hub")) != "hub":
		return false
	if str(_state_get(state, "panel_mode", "")) != "":
		return false

	update_access(game_root, state, player)

	var station_id: String = str(_state_get(state, "near_station_id", ""))
	if station_id == "":
		return true

	return _activate_station(state, station_id)


static func station_prompt(_state: Object) -> String:
	return ""


static func _activate_station(state: Object, station_id: String) -> bool:
	var station: Dictionary = _station_by_id(station_id)
	if station.is_empty():
		return false

	var mode: String = str(station.get("panel_mode", ""))
	if mode == "":
		return true

	return UIAccessSystemScript.request_panel(state, mode, true)


static func _build_layout(container: Node3D) -> void:
	for child: Node in container.get_children():
		child.queue_free()

	for station: Dictionary in STATIONS:
		_build_station(container, station)


static func _build_station(container: Node3D, station: Dictionary) -> void:
	var id: String = str(station.get("id", "station"))
	var display_name: String = str(station.get("display_name", id))
	var pos: Vector3 = _station_position(station)
	var accent: Color = station.get("accent", Color(0.95, 0.65, 0.25, 1.0)) as Color
	var ring_mat: StandardMaterial3D = _mat("StationRing_" + id, Color(accent.r * 0.35, accent.g * 0.35, accent.b * 0.35, 0.72), true)
	var label_color: Color = Color(0.96, 0.84, 0.55, 1.0)

	var anchor: Node3D = Node3D.new()
	anchor.name = "Station_" + id
	anchor.position = pos
	anchor.set_meta("station_id", id)
	anchor.set_meta("station_name", display_name)
	anchor.set_meta("station_panel", str(station.get("panel_mode", "")))
	container.add_child(anchor)

	var ring: MeshInstance3D = _disc("StationInteractionRing", 1.42, 0.035, Vector3(0.0, 0.11, 0.0), ring_mat)
	anchor.add_child(ring)

	var label_height: float = 2.72
	if id == "forge":
		label_height = 1.95
	elif id == "stash":
		label_height = 2.10
	var label: Label3D = _label("StationLabel", display_name, Vector3(0.0, label_height, 0.18), label_color, 28)
	anchor.add_child(label)


static func _update_station_visuals(game_root: Node, active_id: String) -> void:
	var hub: Node3D = _hub_node(game_root)
	if hub == null:
		return

	var container: Node3D = hub.get_node_or_null(CONTAINER_NAME) as Node3D
	if container == null:
		return

	for child: Node in container.get_children():
		if not str(child.name).begins_with("Station_"):
			continue
		var station_id: String = str(child.get_meta("station_id", ""))
		var is_active: bool = station_id == active_id
		var anchor: Node3D = child as Node3D
		if anchor == null:
			continue
		var ring: MeshInstance3D = anchor.get_node_or_null("StationInteractionRing") as MeshInstance3D
		if ring != null:
			ring.scale = Vector3.ONE * (1.22 if is_active else 1.0)
			if ring.material_override is StandardMaterial3D:
				var mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
				mat.emission_energy_multiplier = 1.45 if is_active else 0.38


static func _remove_legacy_station_nodes(game_root: Node, hub: Node3D) -> void:
	for node: Node in [game_root, hub]:
		if node == null:
			continue
		for legacy_name: String in LEGACY_CONTAINER_NAMES:
			var legacy: Node = node.get_node_or_null(legacy_name)
			if legacy != null and legacy.name != CONTAINER_NAME:
				legacy.queue_free()
		for child: Node in node.get_children():
			var n: String = str(child.name)
			if n == "HubStationLayer098C" or n.begins_with("Station_") or n == "HubInstructionLabel":
				child.queue_free()


static func _clear_station_state(state: Object) -> void:
	state.set("near_station_id", "")
	state.set("near_station_name", "")
	state.set("near_station_panel", "")
	state.set("near_station_distance", 999999.0)


static func _hub_node(game_root: Node) -> Node3D:
	if game_root == null:
		return null
	return game_root.get_node_or_null("Hub") as Node3D


static func _station_by_id(station_id: String) -> Dictionary:
	for station: Dictionary in STATIONS:
		if str(station.get("id", "")) == station_id:
			return station
	return {}


static func _station_position(station: Dictionary) -> Vector3:
	var value: Variant = station.get("position", Vector3.ZERO)
	if typeof(value) == TYPE_VECTOR3:
		return value as Vector3
	return Vector3.ZERO


static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return value


static func _mat(label: String, color: Color, emissive: bool = false) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.resource_name = label
	mat.albedo_color = color
	mat.roughness = 0.82
	mat.metallic = 0.20
	if emissive:
		mat.emission_enabled = true
		mat.emission = Color(color.r, color.g, color.b, 1.0)
		mat.emission_energy_multiplier = 0.38
	return mat


static func _disc(label: String, radius: float, height: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 48
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	return node


static func _label(label_name: String, text: String, pos: Vector3, color: Color, size: int) -> Label3D:
	var label: Label3D = Label3D.new()
	label.name = label_name
	label.text = text
	label.position = pos
	label.font_size = size
	label.modulate = color
	label.outline_size = 8
	label.outline_modulate = Color(0.0, 0.0, 0.0, 0.96)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	return label
