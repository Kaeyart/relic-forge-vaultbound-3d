extends RefCounted

const STASH_MODE: String = "stash"
const FORGE_MODE: String = "crafting"
const ACCESS_RADIUS: float = 3.0

static func ensure_physical_stations(root: Node) -> void:
	if root == null:
		return
	if root.get_node_or_null("PhysicalStations091A") != null:
		return

	var station_root := Node3D.new()
	station_root.name = "PhysicalStations091A"
	root.add_child(station_root)

	var origin := Vector3.ZERO
	var hub := root.get_node_or_null("Hub") as Node3D
	if hub != null:
		origin = hub.global_position

	_create_station(station_root, "PhysicalStashStation091A", "STASH", STASH_MODE, origin + Vector3(-3.2, 0.55, 2.4), Color(0.55, 0.68, 1.0, 1.0))
	_create_station(station_root, "PhysicalForgeStation091A", "FORGE", FORGE_MODE, origin + Vector3(3.2, 0.55, 2.4), Color(1.0, 0.58, 0.25, 1.0))

static func _create_station(parent: Node3D, node_name: String, label_text: String, mode: String, pos: Vector3, color: Color) -> void:
	var station := Node3D.new()
	station.name = node_name
	station.global_position = pos
	station.set_meta("station_mode", mode)
	station.set_meta("station_name", label_text)
	parent.add_child(station)

	var body := CSGBox3D.new()
	body.name = "GreyboxBody"
	body.size = Vector3(1.6, 1.1, 1.2)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.75
	body.material = material
	station.add_child(body)

	var top := CSGBox3D.new()
	top.name = "StationTop"
	top.size = Vector3(1.9, 0.18, 1.4)
	top.position = Vector3(0, 0.65, 0)
	top.material = material
	station.add_child(top)

	var label := Label3D.new()
	label.name = "StationLabel"
	label.text = label_text + "\n[E]"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 1.45, 0)
	label.font_size = 42
	station.add_child(label)

static func update_access(root: Node, state: Object, player: Node3D) -> void:
	if root == null or state == null:
		return
	ensure_physical_stations(root)

	if player == null:
		player = root.get_node_or_null("Player") as Node3D

	var nearest_mode: String = ""
	var nearest_name: String = ""
	var nearest_distance: float = 999999.0

	var station_root := root.get_node_or_null("PhysicalStations091A")
	if station_root != null and player != null:
		for child: Node in station_root.get_children():
			var station := child as Node3D
			if station == null:
				continue
			var dist: float = player.global_position.distance_to(station.global_position)
			if dist <= ACCESS_RADIUS and dist < nearest_distance:
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
	if mode == "":
		return false

	state.set("panel_mode", mode)
	if state.has_method("add_notice"):
		state.call("add_notice", "Opened " + str(state.get("near_station_name")))
	return true

static func request_station_panel(state: Object, mode: String) -> bool:
	if mode != STASH_MODE and mode != FORGE_MODE:
		return true
	if state == null:
		return false

	var allowed: String = str(state.get("near_station_mode"))
	if allowed == mode:
		return true

	if state.has_method("add_notice"):
		if mode == STASH_MODE:
			state.call("add_notice", "Use the physical Stash in the hub.")
		else:
			state.call("add_notice", "Use the physical Forge table in the hub.")
	return false

static func _is_interact_pressed(event: InputEvent) -> bool:
	if event == null:
		return false
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		return true
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo and key_event.keycode == KEY_E
	return false
