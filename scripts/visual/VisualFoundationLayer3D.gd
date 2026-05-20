extends Node3D
class_name RVVisualFoundationLayer3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")

var game_root: Node = null
var player_ref: Node3D = null

var _player_ring: MeshInstance3D = null
var _facing_marker: MeshInstance3D = null
var _built: bool = false


func _ready() -> void:
	_build_once()
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root
	_refresh_refs()


func _process(_delta: float) -> void:
	_refresh_refs()
	_update_player_markers()


func _build_once() -> void:
	if _built:
		return
	_built = true

	name = "VisualFoundationLayer096A"
	_build_environment()
	_build_floor()
	_build_arena_frame()
	_build_hub_landmarks()
	_build_player_markers()


func _build_environment() -> void:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.name = "WorldEnvironment096A"
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.035, 0.033, 0.036, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.19, 0.17, 0.15, 1.0)
	env.ambient_light_energy = 0.8
	env.fog_enabled = true
	env.fog_light_color = Color(0.14, 0.12, 0.10, 1.0)
	env.fog_density = 0.012
	world_env.environment = env
	add_child(world_env)

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "KeyLight096A"
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.light_energy = 1.25
	sun.light_color = Color(1.0, 0.78, 0.56, 1.0)
	add_child(sun)

	var fill: OmniLight3D = PrimitiveKitScript.add_light("ColdFillLight096A", Vector3(-8.0, 6.0, 8.0), Color(0.28, 0.44, 1.0, 1.0), 0.55, 18.0)
	add_child(fill)


func _build_floor() -> void:
	var floor: MeshInstance3D = PrimitiveKitScript.box("AshFloor096A", Vector3(42.0, 0.10, 42.0), Vector3(0.0, -0.06, 0.0), VisualPaletteScript.floor_mat())
	add_child(floor)

	for i: int in range(-10, 11):
		var zline: MeshInstance3D = PrimitiveKitScript.box("GridZ_" + str(i), Vector3(42.0, 0.012, 0.028), Vector3(0.0, 0.005, float(i) * 2.0), VisualPaletteScript.grid_mat())
		add_child(zline)

		var xline: MeshInstance3D = PrimitiveKitScript.box("GridX_" + str(i), Vector3(0.028, 0.012, 42.0), Vector3(float(i) * 2.0, 0.006, 0.0), VisualPaletteScript.grid_mat())
		add_child(xline)


func _build_arena_frame() -> void:
	var wall_mat: Material = VisualPaletteScript.wall_mat()
	add_child(PrimitiveKitScript.box("NorthFrameWall096A", Vector3(36.0, 1.2, 0.6), Vector3(0.0, 0.6, -18.0), wall_mat))
	add_child(PrimitiveKitScript.box("SouthFrameWall096A", Vector3(36.0, 1.2, 0.6), Vector3(0.0, 0.6, 18.0), wall_mat))
	add_child(PrimitiveKitScript.box("WestFrameWall096A", Vector3(0.6, 1.2, 36.0), Vector3(-18.0, 0.6, 0.0), wall_mat))
	add_child(PrimitiveKitScript.box("EastFrameWall096A", Vector3(0.6, 1.2, 36.0), Vector3(18.0, 0.6, 0.0), wall_mat))

	var pillar_positions: Array[Vector3] = [
		Vector3(-12.0, 0.0, -10.0),
		Vector3(12.0, 0.0, -10.0),
		Vector3(-12.0, 0.0, 10.0),
		Vector3(12.0, 0.0, 10.0),
	]
	for pos: Vector3 in pillar_positions:
		add_child(PrimitiveKitScript.cylinder("ArenaPillar096A", 0.48, 2.1, pos + Vector3(0.0, 1.05, 0.0), wall_mat, 18))


func _build_hub_landmarks() -> void:
	_build_station("Stash", Vector3(-7.0, 0.0, 5.0), VisualPaletteScript.blue_mat(0.9), "STASH")
	_build_station("Forge", Vector3(7.0, 0.0, 5.0), VisualPaletteScript.ember_mat(0.92), "FORGE")
	_build_station("Maps", Vector3(0.0, 0.0, -7.0), VisualPaletteScript.violet_mat(0.9), "MAPS")
	_build_station("Gems", Vector3(-7.0, 0.0, -5.0), VisualPaletteScript.green_mat(0.9), "GEMS")
	_build_station("Character", Vector3(7.0, 0.0, -5.0), VisualPaletteScript.brass_mat(), "CHAR")


func _build_station(station_name: String, pos: Vector3, accent: Material, label_text: String) -> void:
	var station_root: Node3D = Node3D.new()
	station_root.name = station_name + "Station096A"
	station_root.position = pos
	add_child(station_root)

	station_root.add_child(PrimitiveKitScript.ground_disc("InteractionDisc", 1.15, Vector3.ZERO, accent))
	station_root.add_child(PrimitiveKitScript.cylinder("Base", 0.72, 0.24, Vector3(0.0, 0.12, 0.0), VisualPaletteScript.wall_mat(), 24))
	station_root.add_child(PrimitiveKitScript.box("Body", Vector3(1.25, 0.95, 0.75), Vector3(0.0, 0.72, 0.0), VisualPaletteScript.wall_mat()))
	station_root.add_child(PrimitiveKitScript.box("AccentBar", Vector3(1.42, 0.10, 0.86), Vector3(0.0, 1.25, 0.0), accent))
	station_root.add_child(PrimitiveKitScript.sphere("IconOrb", 0.23, Vector3(0.0, 1.55, 0.0), accent))
	station_root.add_child(PrimitiveKitScript.label_3d("Label", label_text, Vector3(0.0, 2.12, 0.0), Color(1, 1, 1, 1)))
	station_root.add_child(PrimitiveKitScript.add_light("StationLight", Vector3(0.0, 2.2, 0.0), _material_color(accent), 0.8, 5.0))


func _build_player_markers() -> void:
	_player_ring = PrimitiveKitScript.ground_disc("PlayerSelectionRing096A", 0.72, Vector3.ZERO, VisualPaletteScript.green_mat(0.35))
	add_child(_player_ring)

	_facing_marker = PrimitiveKitScript.box("PlayerFacingMarker096A", Vector3(0.18, 0.035, 0.78), Vector3(0.0, 0.03, -0.82), VisualPaletteScript.green_mat(0.45))
	add_child(_facing_marker)


func _refresh_refs() -> void:
	if player_ref != null and is_instance_valid(player_ref):
		return

	if game_root != null:
		var found: Node = game_root.get_node_or_null("Player")
		if found != null and found is Node3D:
			player_ref = found as Node3D
			return

	var root_node: Node = get_tree().current_scene
	if root_node != null:
		var player_node: Node = root_node.get_node_or_null("Player")
		if player_node != null and player_node is Node3D:
			player_ref = player_node as Node3D


func _update_player_markers() -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		if _player_ring != null:
			_player_ring.visible = false
		if _facing_marker != null:
			_facing_marker.visible = false
		return

	var p: Vector3 = player_ref.global_position
	if _player_ring != null:
		_player_ring.visible = true
		_player_ring.global_position = Vector3(p.x, 0.04, p.z)

	if _facing_marker != null:
		_facing_marker.visible = true
		_facing_marker.global_position = Vector3(p.x, 0.06, p.z)
		_facing_marker.global_rotation = Vector3(0.0, player_ref.global_rotation.y, 0.0)


func _material_color(mat: Material) -> Color:
	if mat != null and mat is StandardMaterial3D:
		var sm: StandardMaterial3D = mat as StandardMaterial3D
		return sm.albedo_color
	return Color(1, 1, 1, 1)
