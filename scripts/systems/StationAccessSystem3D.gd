class_name RVStationAccessSystem3D
extends RefCounted

# Patch 26: hard-stabilized station access.
# Only the real hub stations remain: Map Device, Forge, Stash.
# Inventory and Skill Gems stay global through their own keys/UI; character/gem/extra stations are removed.

const CONTAINER_NAME: String = "HubStationAccessLayout026"
const INTERACT_RADIUS: float = 2.75
const FORGIVING_E_RADIUS: float = 6.25

const LEGACY_CONTAINER_NAMES: Array[String] = [
	"HubStationAccessLayout013",
	"HubStationAccessLayout018",
	"HubStationAccessLayout026",
	"HubStationLayer098C",
	"HubStations",
]

const STATIONS: Array[Dictionary] = [
	{
		"id": "map_device",
		"display_name": "Map Device",
		"panel_mode": "maps",
		"position": Vector3(0.0, 0.0, -4.3),
		"accent": Color(0.95, 0.50, 0.16, 1.0),
	},
	{
		"id": "forge",
		"display_name": "Forge",
		"panel_mode": "crafting",
		"position": Vector3(-4.1, 0.0, 1.8),
		"accent": Color(0.95, 0.25, 0.08, 1.0),
	},
	{
		"id": "stash",
		"display_name": "Stash",
		"panel_mode": "stash",
		"position": Vector3(4.1, 0.0, 1.8),
		"accent": Color(0.38, 0.68, 0.96, 1.0),
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
	# Clean screen rule: no HUD prompt spam. Station names live above stations.
	return ""


static func _activate_station(state: Object, station_id: String) -> bool:
	var station: Dictionary = _station_by_id(station_id)
	if station.is_empty():
		return false

	var mode: String = str(station.get("panel_mode", ""))
	if mode == "":
		return false

	# Direct station activation. This intentionally bypasses older station-gating
	# compatibility paths that have caused false negatives.
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
	var accent: Color = station.get("accent", Color(0.95, 0.65, 0.25, 1.0)) as Color

	var base_mat: Material = _mat("StationBase_" + id, Color(0.08, 0.065, 0.050, 1.0), false)
	var accent_mat: Material = _mat("StationAccent_" + id, accent, true)
	var muted_mat: Material = _mat("StationMuted_" + id, Color(accent.r * 0.32, accent.g * 0.32, accent.b * 0.32, 0.78), true)

	var anchor: Node3D = Node3D.new()
	anchor.name = "Station_" + id
	anchor.position = pos
	anchor.set_meta("station_id", id)
	anchor.set_meta("station_name", display_name)
	anchor.set_meta("station_panel", str(station.get("panel_mode", "")))
	container.add_child(anchor)

	var ring: MeshInstance3D = _disc("StationRing", 1.18, 0.045, Vector3.ZERO, muted_mat)
	anchor.add_child(ring)

	var pedestal: MeshInstance3D = _box("StationPedestal", Vector3(1.05, 0.30, 0.82), Vector3(0.0, 0.18, 0.0), base_mat)
	anchor.add_child(pedestal)

	_build_station_icon(anchor, id, accent_mat, base_mat)

	var label: Label3D = _label("StationLabel", display_name.to_upper(), Vector3(0.0, 1.52, 0.0), Color(0.96, 0.84, 0.55, 1.0), 24)
	anchor.add_child(label)


static func _build_station_icon(anchor: Node3D, id: String, accent_mat: Material, base_mat: Material) -> void:
	match id:
		"map_device":
			anchor.add_child(_disc("MapDevicePortal", 0.66, 0.12, Vector3(0.0, 0.46, 0.0), accent_mat))
			anchor.add_child(_sphere("MapDeviceCore", 0.27, Vector3(0.0, 0.76, 0.0), accent_mat))
		"forge":
			anchor.add_child(_box("ForgeAnvil", Vector3(1.12, 0.26, 0.48), Vector3(0.0, 0.56, 0.0), base_mat))
			anchor.add_child(_box("ForgeFire", Vector3(0.42, 0.45, 0.42), Vector3(0.0, 0.86, 0.0), accent_mat))
		"stash":
			anchor.add_child(_box("StashChest", Vector3(1.08, 0.52, 0.72), Vector3(0.0, 0.58, 0.0), base_mat))
			anchor.add_child(_box("StashLock", Vector3(0.25, 0.28, 0.08), Vector3(0.0, 0.58, -0.38), accent_mat))
		_:
			anchor.add_child(_sphere("StationMarker", 0.32, Vector3(0.0, 0.72, 0.0), accent_mat))


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
		var ring: MeshInstance3D = anchor.get_node_or_null("StationRing") as MeshInstance3D
		if ring != null:
			ring.scale = Vector3.ONE * (1.20 if is_active else 1.0)
			if ring.material_override is StandardMaterial3D:
				var mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
				mat.emission_energy_multiplier = 1.45 if is_active else 0.42


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
	mat.metallic = 0.25
	if emissive:
		mat.emission_enabled = true
		mat.emission = Color(color.r, color.g, color.b, 1.0)
		mat.emission_energy_multiplier = 0.50
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
	label.outline_size = 8
	label.outline_modulate = Color(0.0, 0.0, 0.0, 0.92)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	return label
