class_name RVStationAccessSystem3D
extends RefCounted

const UIAccessSystemScript: GDScript = preload("res://scripts/systems/UIAccessSystem3D.gd")

const CONTAINER_NAME: String = "HubStationAccessLayout018"
const LEGACY_CONTAINER_NAMES: Array[String] = [
	"HubStationAccessLayout013",
	"HubStationAccessLayout018",
	"HubStationLayer098C",
	"HubStations",
]
const INTERACT_RADIUS: float = 2.85

const STATIONS: Array[Dictionary] = [
	{"id": "map_device", "display_name": "Map Device", "panel_mode": "maps", "position": Vector3(0.0, 0.0, -5.4), "accent": Color(0.95, 0.48, 0.18, 1.0)},
	{"id": "forge", "display_name": "Forge", "panel_mode": "crafting", "position": Vector3(-6.0, 0.0, -0.6), "accent": Color(0.95, 0.26, 0.10, 1.0)},
	{"id": "stash", "display_name": "Stash", "panel_mode": "stash", "position": Vector3(6.0, 0.0, -0.6), "accent": Color(0.45, 0.72, 0.95, 1.0)},
	{"id": "gem_bench", "display_name": "Gem Bench", "panel_mode": "skills", "position": Vector3(-4.8, 0.0, 4.1), "accent": Color(0.55, 0.38, 1.0, 1.0)},
	{"id": "character_shrine", "display_name": "Character Shrine", "panel_mode": "character", "position": Vector3(4.8, 0.0, 4.1), "accent": Color(0.95, 0.78, 0.28, 1.0)},
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
	# Patch 18: no screen prompt spam. Station names are world labels only.
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
	var base_mat: Material = _mat("StationBase_" + id, Color(0.10, 0.085, 0.065, 1.0), false)
	var accent_mat: Material = _mat("StationAccent_" + id, accent, true)
	var muted_mat: Material = _mat("StationMuted_" + id, Color(accent.r * 0.38, accent.g * 0.38, accent.b * 0.38, 0.72), true)

	var anchor: Node3D = Node3D.new()
	anchor.name = "Station_" + id
	anchor.position = pos
	anchor.set_meta("station_id", id)
	anchor.set_meta("station_name", display_name)
	anchor.set_meta("station_panel", str(station.get("panel_mode", "")))
	container.add_child(anchor)

	var ring: MeshInstance3D = _disc("StationRing", 1.26, 0.045, Vector3.ZERO, muted_mat)
	anchor.add_child(ring)

	var pedestal: MeshInstance3D = _box("StationPedestal", Vector3(1.05, 0.32, 0.82), Vector3(0.0, 0.18, 0.0), base_mat)
	anchor.add_child(pedestal)

	_build_station_icon(anchor, id, accent_mat, base_mat)

	var label: Label3D = _label("StationLabel", display_name.to_upper(), Vector3(0.0, 1.48, 0.0), Color(0.96, 0.84, 0.55, 1.0), 24)
	anchor.add_child(label)

static func _build_station_icon(anchor: Node3D, id: String, accent_mat: Material, base_mat: Material) -> void:
	match id:
		"map_device":
			anchor.add_child(_disc("MapDevicePortal", 0.72, 0.12, Vector3(0.0, 0.46, 0.0), accent_mat))
			anchor.add_child(_sphere("MapDeviceCore", 0.30, Vector3(0.0, 0.75, 0.0), accent_mat))
		"forge":
			anchor.add_child(_box("ForgeAnvil", Vector3(1.10, 0.26, 0.48), Vector3(0.0, 0.56, 0.0), base_mat))
			anchor.add_child(_box("ForgeFire", Vector3(0.42, 0.45, 0.42), Vector3(0.0, 0.86, 0.0), accent_mat))
		"stash":
			anchor.add_child(_box("StashChest", Vector3(1.05, 0.52, 0.70), Vector3(0.0, 0.58, 0.0), base_mat))
			anchor.add_child(_box("StashLock", Vector3(0.25, 0.28, 0.08), Vector3(0.0, 0.58, -0.38), accent_mat))
		"gem_bench":
			anchor.add_child(_box("GemBenchTable", Vector3(1.16, 0.20, 0.72), Vector3(0.0, 0.55, 0.0), base_mat))
			anchor.add_child(_sphere("GemBenchCrystal", 0.28, Vector3(0.0, 0.88, 0.0), accent_mat))
		"character_shrine":
			anchor.add_child(_box("CharacterShrineObelisk", Vector3(0.44, 1.05, 0.44), Vector3(0.0, 0.78, 0.0), accent_mat))
			anchor.add_child(_box("CharacterShrineBase", Vector3(0.95, 0.18, 0.95), Vector3(0.0, 0.42, 0.0), base_mat))
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
			ring.scale = Vector3.ONE * (1.18 if is_active else 1.0)
			if ring.material_override is StandardMaterial3D:
				var mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
				mat.emission_energy_multiplier = 1.4 if is_active else 0.45

static func _remove_legacy_station_nodes(game_root: Node, hub: Node3D) -> void:
	# Remove old station containers that lived outside Hub and caused stations to appear inside maps.
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
