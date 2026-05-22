class_name RVStationAccessSystem3D
extends RefCounted

# Patch 27: station access aligned to the concept hub.
# Only the three physical hub stations are interactive: Map Device, Forge, Stash.
# Labels sit above the matching environment props; no HUD prompt spam.

const CONTAINER_NAME: String = "HubStationAccessLayout027"
const INTERACT_RADIUS: float = 2.55
const FORGIVING_E_RADIUS: float = 4.10

const LEGACY_CONTAINER_NAMES: Array[String] = [
	"HubStationAccessLayout013",
	"HubStationAccessLayout018",
	"HubStationAccessLayout026",
	"HubStationAccessLayout027",
	"HubStationLayer098C",
	"HubStations",
]

const STATIONS: Array[Dictionary] = [
	{
		"id": "map_device",
		"display_name": "Map Device",
		"panel_mode": "maps",
		"position": Vector3(0.0, 0.0, 0.0),
		"label_position": Vector3(0.0, 2.18, 1.15),
		"accent": Color(0.18, 0.50, 1.0, 1.0),
	},
	{
		"id": "forge",
		"display_name": "Forge",
		"panel_mode": "crafting",
		"position": Vector3(-5.35, 0.0, -1.05),
		"label_position": Vector3(-5.35, 1.85, 0.42),
		"accent": Color(1.0, 0.34, 0.08, 1.0),
	},
	{
		"id": "stash",
		"display_name": "Stash",
		"panel_mode": "stash",
		"position": Vector3(5.35, 0.0, -1.05),
		"label_position": Vector3(5.35, 1.85, 0.42),
		"accent": Color(0.95, 0.72, 0.34, 1.0),
	},
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

	if _needs_rebuild(container):
		_build_layout(container)


static func update_access(game_root: Node, state: Object, player: Node3D) -> void:
	if game_root == null or state == null:
		return

	ensure_physical_stations(game_root)

	if str(_state_get(state, "mode", "hub")) != "hub":
		_clear_station_state(state)
		_update_station_visuals(game_root, "")
		return

	var player_pos: Vector3 = _player_position(state, player)
	var closest: Dictionary = _closest_station(player_pos)
	if closest.is_empty():
		_clear_station_state(state)
		_update_station_visuals(game_root, "")
		return

	var distance: float = float(closest.get("distance", 999999.0))
	if distance > INTERACT_RADIUS:
		_clear_station_state(state)
		_update_station_visuals(game_root, "")
		return

	_apply_station_state(state, closest)
	_update_station_visuals(game_root, str(closest.get("id", "")))


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

	ensure_physical_stations(game_root)

	var player_pos: Vector3 = _player_position(state, player)
	var closest: Dictionary = _closest_station(player_pos)
	if closest.is_empty():
		return false

	var distance: float = float(closest.get("distance", 999999.0))
	if distance > FORGIVING_E_RADIUS:
		_clear_station_state(state)
		_update_station_visuals(game_root, "")
		return false

	_apply_station_state(state, closest)
	_update_station_visuals(game_root, str(closest.get("id", "")))
	return _activate_station(state, str(closest.get("id", "")))


static func station_prompt(_state: Object) -> String:
	return ""


static func _activate_station(state: Object, station_id: String) -> bool:
	var station: Dictionary = _station_by_id(station_id)
	if station.is_empty():
		return false

	var mode: String = str(station.get("panel_mode", ""))
	if mode == "":
		return false

	_safe_set(state, "panel_mode", mode)
	_safe_set(state, "near_station_mode", mode)
	_safe_set(state, "near_station_name", str(station.get("display_name", "")))
	_safe_set(state, "near_station_id", station_id)
	_safe_set(state, "near_station_panel", mode)
	_safe_set(state, "station_access_message", "Opened " + str(station.get("display_name", "station")))
	return true


static func _needs_rebuild(container: Node3D) -> bool:
	if container == null:
		return true
	if container.get_child_count() != STATIONS.size():
		return true
	for station: Dictionary in STATIONS:
		var id: String = str(station.get("id", ""))
		if container.get_node_or_null("Station_" + id) == null:
			return true
	return false


static func _build_layout(container: Node3D) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()

	for station: Dictionary in STATIONS:
		_build_station(container, station)


static func _build_station(container: Node3D, station: Dictionary) -> void:
	var id: String = str(station.get("id", "station"))
	var display_name: String = str(station.get("display_name", id))
	var pos: Vector3 = _station_position(station)
	var label_pos: Vector3 = _station_label_position(station)
	var accent: Color = station.get("accent", Color(0.95, 0.65, 0.25, 1.0)) as Color

	var accent_mat: Material = _mat("StationAccent_" + id, accent, true)
	var plate_mat: Material = _mat("StationLabelPlate_" + id, Color(0.015, 0.012, 0.009, 1.0), false)
	var ring_mat: Material = _mat("StationRing_" + id, Color(accent.r * 0.35, accent.g * 0.35, accent.b * 0.35, 0.88), true)

	var anchor: Node3D = Node3D.new()
	anchor.name = "Station_" + id
	anchor.position = pos
	anchor.set_meta("station_id", id)
	anchor.set_meta("station_name", display_name)
	anchor.set_meta("station_panel", str(station.get("panel_mode", "")))
	container.add_child(anchor)

	# Thin interaction halo only. Environment props are built by HubGreyboxPass3D.
	var ring: MeshInstance3D = _disc("InteractionHalo", 1.12, 0.025, Vector3(0.0, 0.04, 0.0), ring_mat)
	anchor.add_child(ring)
	var pin: MeshInstance3D = _sphere("InteractionPin", 0.13, Vector3(0.0, 0.36, 0.0), accent_mat)
	anchor.add_child(pin)

	# Concept-style station name plate above the station.
	var label_anchor: Node3D = Node3D.new()
	label_anchor.name = "LabelAnchor"
	label_anchor.position = label_pos - pos
	anchor.add_child(label_anchor)

	var plate: MeshInstance3D = _box("StationLabelPlate", Vector3(2.25, 0.055, 0.48), Vector3(0.0, -0.06, 0.03), plate_mat)
	label_anchor.add_child(plate)

	var label: Label3D = _label("StationLabel", display_name, Vector3(0.0, 0.02, 0.0), Color(0.96, 0.84, 0.55, 1.0), 26)
	label_anchor.add_child(label)


static func _update_station_visuals(game_root: Node, active_id: String) -> void:
	var hub: Node3D = _hub_node(game_root)
	if hub == null:
		return

	var container: Node3D = hub.get_node_or_null(CONTAINER_NAME) as Node3D
	if container == null:
		return

	for child: Node in container.get_children():
		if not child.name.begins_with("Station_"):
			continue
		var station_id: String = str(child.get_meta("station_id", ""))
		var is_active: bool = station_id == active_id
		var anchor: Node3D = child as Node3D
		if anchor == null:
			continue
		var ring: MeshInstance3D = anchor.get_node_or_null("InteractionHalo") as MeshInstance3D
		if ring != null:
			ring.scale = Vector3.ONE * (1.20 if is_active else 1.0)
			if ring.material_override is StandardMaterial3D:
				var mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
				mat.emission_energy_multiplier = 1.10 if is_active else 0.28


static func _remove_legacy_station_nodes(game_root: Node, hub: Node3D) -> void:
	for node: Node in [game_root, hub]:
		if node == null:
			continue
		for legacy_name: String in LEGACY_CONTAINER_NAMES:
			var legacy: Node = node.get_node_or_null(legacy_name)
			if legacy != null and legacy.name != CONTAINER_NAME:
				node.remove_child(legacy)
				legacy.queue_free()
		for child: Node in node.get_children():
			var n: String = str(child.name)
			if n.begins_with("Station_") or n == "HubInstructionLabel" or n == "HubStationLayer098C":
				node.remove_child(child)
				child.queue_free()


static func _apply_station_state(state: Object, station: Dictionary) -> void:
	var station_id: String = str(station.get("id", ""))
	var mode: String = str(station.get("panel_mode", ""))
	_safe_set(state, "near_station_id", station_id)
	_safe_set(state, "near_station_name", str(station.get("display_name", "")))
	_safe_set(state, "near_station_panel", mode)
	_safe_set(state, "near_station_mode", mode)
	_safe_set(state, "near_station_distance", float(station.get("distance", 0.0)))


static func _clear_station_state(state: Object) -> void:
	_safe_set(state, "near_station_id", "")
	_safe_set(state, "near_station_name", "")
	_safe_set(state, "near_station_panel", "")
	_safe_set(state, "near_station_mode", "")
	_safe_set(state, "near_station_distance", 999999.0)


static func _closest_station(player_pos: Vector3) -> Dictionary:
	var best: Dictionary = {}
	var best_distance: float = 999999.0
	for station: Dictionary in STATIONS:
		var pos: Vector3 = _station_position(station)
		var distance: float = Vector2(player_pos.x - pos.x, player_pos.z - pos.z).length()
		if distance < best_distance:
			best_distance = distance
			best = station.duplicate(true)
			best["distance"] = distance
	return best


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


static func _station_label_position(station: Dictionary) -> Vector3:
	var value: Variant = station.get("label_position", _station_position(station) + Vector3(0.0, 1.6, 0.0))
	if typeof(value) == TYPE_VECTOR3:
		return value as Vector3
	return _station_position(station) + Vector3(0.0, 1.6, 0.0)


static func _player_position(state: Object, player: Node3D) -> Vector3:
	if player != null:
		return player.global_position
	var value: Variant = _state_get(state, "player_pos", Vector3.ZERO)
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


static func _safe_set(state: Object, key: String, value: Variant) -> void:
	if state == null:
		return
	state.set(key, value)


static func _mat(label: String, color: Color, emissive: bool = false) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.resource_name = label
	mat.albedo_color = color
	mat.roughness = 0.82
	mat.metallic = 0.28
	if emissive:
		mat.emission_enabled = true
		mat.emission = Color(color.r, color.g, color.b, 1.0)
		mat.emission_energy_multiplier = 0.38
	return mat


static func _box(label: String, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	return node


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


static func _sphere(label: String, radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12
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
	label.outline_size = 10
	label.outline_modulate = Color(0.0, 0.0, 0.0, 0.96)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	return label
