class_name RVStationAccessSystem3D
extends RefCounted

const UIAccessSystemScript: GDScript = preload("res://scripts/systems/UIAccessSystem3D.gd")

const CONTAINER_NAME: String = "HubStationAccessLayout013"
const INTERACT_RADIUS: float = 2.75

const STATIONS: Array[Dictionary] = [
	{
		"id": "map_device",
		"display_name": "Map Device",
		"panel_mode": "maps",
		"position": Vector3(0.0, 0.0, -5.2),
		"accent": Color(0.95, 0.48, 0.18, 1.0),
		"description": "Launch maps and continue the run loop."
	},
	{
		"id": "forge",
		"display_name": "Forge",
		"panel_mode": "crafting",
		"position": Vector3(-6.0, 0.0, -0.8),
		"accent": Color(0.95, 0.28, 0.12, 1.0),
		"description": "Improve gear through controlled crafting."
	},
	{
		"id": "stash",
		"display_name": "Stash",
		"panel_mode": "stash",
		"position": Vector3(6.0, 0.0, -0.8),
		"accent": Color(0.45, 0.72, 0.95, 1.0),
		"description": "Store gear, maps, gems, materials, and uniques."
	},
	{
		"id": "gem_bench",
		"display_name": "Gem Bench",
		"panel_mode": "skills",
		"position": Vector3(-4.8, 0.0, 4.0),
		"accent": Color(0.55, 0.38, 1.0, 1.0),
		"description": "Edit active gems, supports, and spirit reservations."
	},
	{
		"id": "character_shrine",
		"display_name": "Character Shrine",
		"panel_mode": "character",
		"position": Vector3(4.8, 0.0, 4.0),
		"accent": Color(0.95, 0.78, 0.28, 1.0),
		"description": "Review offense, defense, resources, and build rules."
	},
	{
		"id": "training_dummy",
		"display_name": "Training Dummy",
		"panel_mode": "",
		"position": Vector3(0.0, 0.0, 6.2),
		"accent": Color(0.72, 0.55, 0.34, 1.0),
		"description": "Combat testing placeholder."
	}
]


static func ensure_physical_stations(game_root: Node) -> void:
	if game_root == null:
		return

	var hub: Node3D = _hub_node(game_root)
	if hub == null:
		return

	var container: Node3D = hub.get_node_or_null(CONTAINER_NAME) as Node3D
	if container == null:
		container = Node3D.new()
		container.name = CONTAINER_NAME
		hub.add_child(container)

	_build_layout(container)


static func update_access(game_root: Node, state: Object, player: Node3D) -> void:
	if game_root == null or state == null:
		return

	ensure_physical_stations(game_root)

	if str(_state_get(state, "mode", "hub")) != "hub":
		_clear_station_state(state)
		return

	if player == null:
		_clear_station_state(state)
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
	state.set("near_station_description", str(closest.get("description", "")))
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
		return false

	return _activate_station(game_root, state, station_id)


static func station_prompt(state: Object) -> String:
	if state == null:
		return ""

	var station_name: String = str(_state_get(state, "near_station_name", ""))
	if station_name == "":
		return ""

	return "[E] Open " + station_name


static func _activate_station(game_root: Node, state: Object, station_id: String) -> bool:
	var station: Dictionary = _station_by_id(station_id)
	if station.is_empty():
		return false

	var mode: String = str(station.get("panel_mode", ""))
	if mode != "":
		UIAccessSystemScript.request_panel(state, mode)
		_add_notice(state, "Opened " + str(station.get("display_name", "Station")) + ".")
		return true

	match station_id:
		"training_dummy":
			_add_notice(state, "Training Dummy is ready. Combat practice hook comes later.")
			return true
		_:
			_add_notice(state, str(station.get("display_name", "Station")) + " is not wired yet.")
			return true


static func _build_layout(container: Node3D) -> void:
	for child: Node in container.get_children():
		child.queue_free()

	_add_floor_frame(container)

	for station: Dictionary in STATIONS:
		_build_station(container, station)


static func _add_floor_frame(container: Node3D) -> void:
	var mat_path: Material = _mat("Hub Path Iron", Color(0.18, 0.14, 0.10, 0.86), false)
	var mat_center: Material = _mat("Hub Center Ember", Color(0.45, 0.22, 0.08, 0.72), false)

	var main_path: MeshInstance3D = _box("MainPathNorthSouth", Vector3(1.25, 0.035, 12.5), Vector3(0.0, 0.018, 0.5), mat_path)
	container.add_child(main_path)

	var cross_path: MeshInstance3D = _box("MainPathEastWest", Vector3(12.8, 0.034, 1.2), Vector3(0.0, 0.019, -0.9), mat_path)
	container.add_child(cross_path)

	var center: MeshInstance3D = _disc("CentralHubRitualDisc", 2.0, 0.045, Vector3(0.0, 0.045, -0.9), mat_center)
	container.add_child(center)

	var center_label: Label3D = _label("HubInstructionLabel", "VAULT HUB\n[E] near station · [M] maps · [I] inventory", Vector3(0.0, 1.55, -0.9), Color(0.92, 0.80, 0.55, 1.0), 26)
	container.add_child(center_label)


static func _build_station(container: Node3D, station: Dictionary) -> void:
	var id: String = str(station.get("id", "station"))
	var display_name: String = str(station.get("display_name", id))
	var pos: Vector3 = _station_position(station)
	var accent: Color = station.get("accent", Color(0.95, 0.65, 0.25, 1.0)) as Color
	var base_mat: Material = _mat("StationBase_" + id, Color(0.12, 0.10, 0.08, 1.0), false)
	var accent_mat: Material = _mat("StationAccent_" + id, accent, true)
	var muted_mat: Material = _mat("StationMuted_" + id, Color(accent.r * 0.42, accent.g * 0.42, accent.b * 0.42, 0.68), true)

	var anchor: Node3D = Node3D.new()
	anchor.name = "Station_" + id
	anchor.position = pos
	anchor.set_meta("station_id", id)
	anchor.set_meta("station_name", display_name)
	anchor.set_meta("station_panel", str(station.get("panel_mode", "")))
	container.add_child(anchor)

	var ring: MeshInstance3D = _disc("StationRing", 1.28, 0.055, Vector3.ZERO, muted_mat)
	anchor.add_child(ring)

	var pedestal: MeshInstance3D = _box("StationPedestal", Vector3(1.05, 0.34, 0.82), Vector3(0.0, 0.19, 0.0), base_mat)
	anchor.add_child(pedestal)

	_build_station_icon(anchor, id, accent_mat, base_mat)

	var label: Label3D = _label("StationLabel", display_name.to_upper(), Vector3(0.0, 1.28, 0.0), Color(0.96, 0.84, 0.55, 1.0), 24)
	anchor.add_child(label)

	var hint: Label3D = _label("StationHint", "[E]", Vector3(0.0, 0.88, 0.0), accent, 30)
	hint.name = "StationInteractHint"
	anchor.add_child(hint)

	var desc: Label3D = _label("StationDescription", str(station.get("description", "")), Vector3(0.0, -0.08, 1.1), Color(0.72, 0.67, 0.56, 1.0), 16)
	desc.name = "StationDescription"
	anchor.add_child(desc)


static func _build_station_icon(anchor: Node3D, id: String, accent_mat: Material, base_mat: Material) -> void:
	match id:
		"map_device":
			var disc: MeshInstance3D = _disc("MapDevicePortal", 0.72, 0.12, Vector3(0.0, 0.46, 0.0), accent_mat)
			anchor.add_child(disc)
			var core: MeshInstance3D = _sphere("MapDeviceCore", 0.30, Vector3(0.0, 0.75, 0.0), accent_mat)
			anchor.add_child(core)
		"forge":
			var anvil: MeshInstance3D = _box("ForgeAnvil", Vector3(1.10, 0.26, 0.48), Vector3(0.0, 0.56, 0.0), base_mat)
			anchor.add_child(anvil)
			var fire: MeshInstance3D = _box("ForgeFire", Vector3(0.42, 0.45, 0.42), Vector3(0.0, 0.86, 0.0), accent_mat)
			anchor.add_child(fire)
		"stash":
			var chest: MeshInstance3D = _box("StashChest", Vector3(1.05, 0.52, 0.70), Vector3(0.0, 0.58, 0.0), base_mat)
			anchor.add_child(chest)
			var lock: MeshInstance3D = _box("StashLock", Vector3(0.25, 0.28, 0.08), Vector3(0.0, 0.58, -0.38), accent_mat)
			anchor.add_child(lock)
		"gem_bench":
			var bench: MeshInstance3D = _box("GemBenchTable", Vector3(1.16, 0.20, 0.72), Vector3(0.0, 0.55, 0.0), base_mat)
			anchor.add_child(bench)
			var gem: MeshInstance3D = _sphere("GemBenchCrystal", 0.28, Vector3(0.0, 0.88, 0.0), accent_mat)
			anchor.add_child(gem)
		"character_shrine":
			var shrine: MeshInstance3D = _box("CharacterShrineObelisk", Vector3(0.44, 1.05, 0.44), Vector3(0.0, 0.78, 0.0), accent_mat)
			anchor.add_child(shrine)
			var base: MeshInstance3D = _box("CharacterShrineBase", Vector3(0.95, 0.18, 0.95), Vector3(0.0, 0.42, 0.0), base_mat)
			anchor.add_child(base)
		"training_dummy":
			var post: MeshInstance3D = _box("TrainingDummyPost", Vector3(0.24, 1.05, 0.24), Vector3(0.0, 0.78, 0.0), base_mat)
			anchor.add_child(post)
			var head: MeshInstance3D = _sphere("TrainingDummyHead", 0.25, Vector3(0.0, 1.38, 0.0), accent_mat)
			anchor.add_child(head)
		_:
			var marker: MeshInstance3D = _sphere("StationMarker", 0.32, Vector3(0.0, 0.72, 0.0), accent_mat)
			anchor.add_child(marker)


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

		var hint: Label3D = anchor.get_node_or_null("StationInteractHint") as Label3D
		if hint != null:
			hint.visible = is_active

		var desc: Label3D = anchor.get_node_or_null("StationDescription") as Label3D
		if desc != null:
			desc.visible = is_active

		var ring: MeshInstance3D = anchor.get_node_or_null("StationRing") as MeshInstance3D
		if ring != null:
			ring.scale = Vector3.ONE * (1.15 if is_active else 1.0)


static func _clear_station_state(state: Object) -> void:
	state.set("near_station_id", "")
	state.set("near_station_name", "")
	state.set("near_station_panel", "")
	state.set("near_station_distance", 999999.0)
	state.set("near_station_description", "")


static func _hub_node(game_root: Node) -> Node3D:
	if game_root == null:
		return null

	var hub: Node3D = game_root.get_node_or_null("Hub") as Node3D
	if hub != null:
		return hub

	if game_root is Node3D:
		return game_root as Node3D

	return null


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


static func _add_notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)


static func _mat(label: String, color: Color, emissive: bool = false) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.resource_name = label
	mat.albedo_color = color
	mat.roughness = 0.82
	mat.metallic = 0.25
	if emissive:
		mat.emission_enabled = true
		mat.emission = Color(color.r, color.g, color.b, 1.0)
		mat.emission_energy_multiplier = 0.65
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
