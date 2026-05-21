extends RefCounted

const ACCESS_RADIUS: float = 3.1

const STATIONS: Array[Dictionary] = [
	{"node": "StationMapDevice04", "name": "MAP DEVICE", "mode": "maps", "pos": Vector3(0.0, 0.52, -3.35), "color": Color(0.86, 0.48, 0.16, 1.0), "size": Vector3(2.2, 1.05, 1.6)},
	{"node": "StationStash04", "name": "STASH", "mode": "stash", "pos": Vector3(-4.2, 0.52, 0.8), "color": Color(0.38, 0.53, 0.90, 1.0), "size": Vector3(1.8, 1.15, 1.35)},
	{"node": "StationForge04", "name": "FORGE", "mode": "crafting", "pos": Vector3(4.2, 0.52, 0.8), "color": Color(1.0, 0.35, 0.12, 1.0), "size": Vector3(2.0, 1.05, 1.45)},
	{"node": "StationGemBench04", "name": "GEM BENCH", "mode": "skills", "pos": Vector3(-3.9, 0.52, -4.2), "color": Color(0.50, 0.85, 0.95, 1.0), "size": Vector3(1.85, 1.0, 1.35)},
	{"node": "StationShrine04", "name": "CHARACTER", "mode": "character", "pos": Vector3(3.9, 0.52, -4.2), "color": Color(0.78, 0.64, 1.0, 1.0), "size": Vector3(1.7, 1.3, 1.25)},
	{"node": "StationTraining04", "name": "TRAINING", "mode": "training", "pos": Vector3(0.0, 0.52, 3.6), "color": Color(0.72, 0.72, 0.66, 1.0), "size": Vector3(1.7, 1.2, 1.2)},
]

static func ensure_physical_stations(root: Node) -> void:
	if root == null:
		return
	var station_root := root.get_node_or_null("PhysicalStations091A") as Node3D
	if station_root == null:
		station_root = Node3D.new()
		station_root.name = "PhysicalStations091A"
		root.add_child(station_root)
	for spec: Dictionary in STATIONS:
		if station_root.get_node_or_null(str(spec.get("node", ""))) == null:
			_create_station(station_root, spec)

static func update_access(root: Node, state: Object, player: Node3D) -> void:
	if root == null or state == null:
		return
	ensure_physical_stations(root)
	var station_root := root.get_node_or_null("PhysicalStations091A") as Node3D
	if station_root == null:
		return
	station_root.visible = str(state.get("mode")) == "hub"
	if player == null:
		player = root.get_node_or_null("Player") as Node3D
	var nearest_mode: String = ""
	var nearest_name: String = ""
	var nearest_distance: float = 999999.0
	if player != null and station_root.visible:
		for child: Node in station_root.get_children():
			var station := child as Node3D
			if station == null:
				continue
			var dist: float = player.global_position.distance_to(station.global_position)
			var active: bool = dist <= ACCESS_RADIUS
			_station_highlight(station, active)
			if active and dist < nearest_distance:
				nearest_distance = dist
				nearest_mode = str(station.get_meta("station_mode", ""))
				nearest_name = str(station.get_meta("station_name", ""))
	state.set("near_station_mode", nearest_mode)
	state.set("near_station_name", nearest_name)

static func handle_station_input(event: InputEvent, root: Node, state: Object, player: Node3D) -> bool:
	if state == null:
		return false
	if not _is_interact_pressed(event):
		return false
	update_access(root, state, player)
	var mode: String = str(state.get("near_station_mode"))
	var station_name: String = str(state.get("near_station_name"))
	if mode == "":
		return false
	if mode == "training":
		if state.has_method("add_notice"):
			state.call("add_notice", "Training dummy: test skills here, then open Map Device.")
		return true
	state.set("panel_mode", mode)
	if state.has_method("add_notice"):
		state.call("add_notice", "Opened " + station_name)
	return true

static func request_station_panel(state: Object, mode: String) -> bool:
	if state == null:
		return false
	state.set("panel_mode", mode)
	return true

static func _create_station(parent: Node3D, spec: Dictionary) -> void:
	var station := Node3D.new()
	station.name = str(spec.get("node", "Station"))
	station.position = spec.get("pos", Vector3.ZERO)
	station.set_meta("station_mode", str(spec.get("mode", "")))
	station.set_meta("station_name", str(spec.get("name", "STATION")))
	parent.add_child(station)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = spec.get("color", Color.WHITE)
	mat.roughness = 0.82
	mat.metallic = 0.12

	var body := CSGBox3D.new()
	body.name = "Body"
	body.size = spec.get("size", Vector3(1.6, 1.0, 1.2))
	body.material = mat
	station.add_child(body)

	var plinth := CSGBox3D.new()
	plinth.name = "Plinth"
	plinth.size = Vector3(2.35, 0.15, 1.85)
	plinth.position = Vector3(0, -0.6, 0)
	plinth.material = mat
	station.add_child(plinth)

	var beacon_mat := StandardMaterial3D.new()
	beacon_mat.albedo_color = Color(1.0, 0.74, 0.30, 1.0)
	beacon_mat.emission_enabled = true
	beacon_mat.emission = Color(1.0, 0.45, 0.12, 1.0)
	beacon_mat.emission_energy_multiplier = 0.7
	var beacon := CSGCylinder3D.new()
	beacon.name = "InteractBeacon"
	beacon.radius = 0.16
	beacon.height = 0.18
	beacon.position = Vector3(0, 0.75, 0)
	beacon.material = beacon_mat
	station.add_child(beacon)

	var label := Label3D.new()
	label.name = "StationLabel"
	label.text = str(spec.get("name", "STATION")) + "\n[E]"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 1.35, 0)
	label.font_size = 38
	label.modulate = Color(1.0, 0.86, 0.48, 1.0)
	station.add_child(label)

static func _station_highlight(station: Node3D, active: bool) -> void:
	var label := station.get_node_or_null("StationLabel") as Label3D
	if label != null:
		label.modulate = Color(1.0, 0.92, 0.25, 1.0) if active else Color(1.0, 0.86, 0.48, 1.0)
	var beacon := station.get_node_or_null("InteractBeacon") as CSGCylinder3D
	if beacon != null:
		beacon.scale = Vector3.ONE * (1.45 if active else 1.0)

static func _is_interact_pressed(event: InputEvent) -> bool:
	if event == null:
		return false
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		return true
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo and key_event.keycode == KEY_E
	return false
