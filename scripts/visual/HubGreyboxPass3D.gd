extends Node3D
class_name RVHubGreyboxPass3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")

var game_root: Node = null
var _built: bool = false
var _pulse_nodes: Array = []


func _ready() -> void:
	_build_once()
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root
	_hide_basic_096a_stations()


func _process(_delta: float) -> void:
	_hide_basic_096a_stations()
	visible = _mode() != "combat"
	_update_pulses()


func _build_once() -> void:
	if _built:
		return
	_built = true
	name = "HubGreyboxPass096B"

	_build_hub_floor()
	_build_paths()
	_build_outer_structure()
	_build_stash_vault(Vector3(-8.0, 0.0, 5.5))
	_build_forge(Vector3(8.0, 0.0, 5.5))
	_build_map_device(Vector3(0.0, 0.0, -8.0))
	_build_gem_altar(Vector3(-8.0, 0.0, -5.5))
	_build_character_shrine(Vector3(8.0, 0.0, -5.5))
	_build_descent_gate(Vector3(0.0, 0.0, 8.5))


func _build_hub_floor() -> void:
	var floor_mat: Material = VisualPaletteScript.material("Hub Raised Stone", Color(0.145, 0.135, 0.13, 1.0))
	var seal_mat: Material = VisualPaletteScript.material("Hub Seal", Color(0.20, 0.12, 0.08, 0.75), false, 0.0, 0.75)

	add_child(PrimitiveKitScript.ground_disc("HubMainPlatform096B", 6.5, Vector3(0.0, 0.03, 0.0), floor_mat))
	add_child(PrimitiveKitScript.ground_disc("HubInnerSeal096B", 3.2, Vector3(0.0, 0.065, 0.0), seal_mat))
	add_child(PrimitiveKitScript.ground_disc("HubBrassTrim096B", 6.72, Vector3(0.0, 0.02, 0.0), VisualPaletteScript.brass_mat()))

	var center: MeshInstance3D = PrimitiveKitScript.cylinder("HubCenterRelic096B", 0.62, 0.44, Vector3(0.0, 0.22, 0.0), VisualPaletteScript.brass_mat(), 32)
	add_child(center)

	var ember: MeshInstance3D = PrimitiveKitScript.sphere("HubCenterEmber096B", 0.24, Vector3(0.0, 0.62, 0.0), VisualPaletteScript.ember_mat(0.95))
	add_child(ember)
	_register_pulse(ember, 0.13, 2.4)


func _build_paths() -> void:
	var path_mat: Material = VisualPaletteScript.material("Hub Walk Path", Color(0.19, 0.17, 0.15, 1.0))
	var trim_mat: Material = VisualPaletteScript.material("Path Trim", Color(0.36, 0.27, 0.14, 1.0))
	var targets: Array[Vector3] = [
		Vector3(-8.0, 0.0, 5.5),
		Vector3(8.0, 0.0, 5.5),
		Vector3(0.0, 0.0, -8.0),
		Vector3(-8.0, 0.0, -5.5),
		Vector3(8.0, 0.0, -5.5),
		Vector3(0.0, 0.0, 8.5),
	]

	for target: Vector3 in targets:
		_add_path(Vector3.ZERO, target, 1.15, path_mat, 0.0)
		_add_path(Vector3.ZERO, target, 1.30, trim_mat, -0.012)


func _add_path(from_pos: Vector3, to_pos: Vector3, width: float, mat: Material, y_offset: float) -> void:
	var delta: Vector3 = to_pos - from_pos
	var length: float = Vector2(delta.x, delta.z).length()
	if length <= 0.01:
		return

	var center: Vector3 = from_pos + delta * 0.5
	var strip: MeshInstance3D = PrimitiveKitScript.box("HubPath096B", Vector3(width, 0.045, length), Vector3(center.x, 0.045 + y_offset, center.z), mat)
	strip.rotation.y = atan2(delta.x, delta.z)
	add_child(strip)


func _build_outer_structure() -> void:
	var wall_mat: Material = VisualPaletteScript.wall_mat()
	var brass: Material = VisualPaletteScript.brass_mat()
	var positions: Array[Vector3] = [
		Vector3(-11.5, 0.0, -9.5),
		Vector3(11.5, 0.0, -9.5),
		Vector3(-11.5, 0.0, 9.5),
		Vector3(11.5, 0.0, 9.5),
	]

	for pos: Vector3 in positions:
		add_child(PrimitiveKitScript.cylinder("HubOuterPillar096B", 0.52, 2.65, pos + Vector3(0.0, 1.325, 0.0), wall_mat, 20))
		add_child(PrimitiveKitScript.cylinder("HubOuterPillarCap096B", 0.64, 0.20, pos + Vector3(0.0, 2.75, 0.0), brass, 20))

	add_child(PrimitiveKitScript.box("HubNorthBackWall096B", Vector3(9.0, 1.6, 0.34), Vector3(0.0, 0.8, -11.0), wall_mat))
	add_child(PrimitiveKitScript.box("HubSouthBackWall096B", Vector3(9.0, 1.6, 0.34), Vector3(0.0, 0.8, 11.0), wall_mat))


func _station_root(station_name: String, pos: Vector3) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = station_name + "GreyboxStation096B"
	root.position = pos
	add_child(root)
	return root


func _build_station_base(root: Node3D, label_text: String, accent: Material, label_color: Color) -> void:
	root.add_child(PrimitiveKitScript.ground_disc("InteractionRing", 1.45, Vector3.ZERO, accent))
	root.add_child(PrimitiveKitScript.cylinder("StationPlinth", 1.03, 0.24, Vector3(0.0, 0.12, 0.0), VisualPaletteScript.wall_mat(), 32))
	root.add_child(PrimitiveKitScript.cylinder("StationTrim", 1.13, 0.08, Vector3(0.0, 0.29, 0.0), VisualPaletteScript.brass_mat(), 32))
	root.add_child(PrimitiveKitScript.label_3d("StationLabel", label_text, Vector3(0.0, 2.65, 0.0), label_color))
	root.add_child(PrimitiveKitScript.add_light("StationLight", Vector3(0.0, 2.1, 0.0), label_color, 0.85, 5.0))


func _build_stash_vault(pos: Vector3) -> void:
	var root: Node3D = _station_root("Stash", pos)
	var accent: Material = VisualPaletteScript.blue_mat(0.9)
	_build_station_base(root, "STASH / VAULT", accent, Color(0.45, 0.68, 1.0, 1.0))
	root.add_child(PrimitiveKitScript.box("VaultBody", Vector3(1.8, 1.0, 1.0), Vector3(0.0, 0.82, 0.0), VisualPaletteScript.wall_mat()))
	root.add_child(PrimitiveKitScript.box("VaultLid", Vector3(1.95, 0.28, 1.1), Vector3(0.0, 1.47, 0.0), VisualPaletteScript.brass_mat()))
	root.add_child(PrimitiveKitScript.box("VaultGlowSeam", Vector3(2.02, 0.08, 1.16), Vector3(0.0, 1.18, 0.0), accent))
	root.add_child(PrimitiveKitScript.box("VaultLock", Vector3(0.36, 0.45, 0.12), Vector3(0.0, 0.98, -0.56), accent))
	var orb: MeshInstance3D = PrimitiveKitScript.sphere("VaultOrbPulse", 0.18, Vector3(0.0, 1.86, 0.0), accent)
	root.add_child(orb)
	_register_pulse(orb, 0.18, 2.1)


func _build_forge(pos: Vector3) -> void:
	var root: Node3D = _station_root("Forge", pos)
	var accent: Material = VisualPaletteScript.ember_mat(0.95)
	_build_station_base(root, "FORGE", accent, Color(1.0, 0.42, 0.16, 1.0))
	root.add_child(PrimitiveKitScript.box("ForgeAnvilBase", Vector3(1.5, 0.35, 0.8), Vector3(0.0, 0.58, 0.0), VisualPaletteScript.wall_mat()))
	root.add_child(PrimitiveKitScript.box("ForgeAnvilTop", Vector3(1.95, 0.20, 0.62), Vector3(0.0, 0.88, 0.0), VisualPaletteScript.brass_mat()))
	root.add_child(PrimitiveKitScript.box("ForgeFurnace", Vector3(1.0, 1.35, 0.9), Vector3(0.0, 1.18, 0.78), VisualPaletteScript.wall_mat()))
	root.add_child(PrimitiveKitScript.box("ForgeMouth", Vector3(0.72, 0.42, 0.08), Vector3(0.0, 1.08, 0.31), accent))
	root.add_child(PrimitiveKitScript.cylinder("ForgeChimney", 0.24, 1.1, Vector3(0.0, 2.1, 0.78), VisualPaletteScript.wall_mat(), 16))
	var fire: MeshInstance3D = PrimitiveKitScript.sphere("ForgeFirePulse", 0.28, Vector3(0.0, 1.08, 0.26), accent)
	root.add_child(fire)
	_register_pulse(fire, 0.22, 5.0)


func _build_map_device(pos: Vector3) -> void:
	var root: Node3D = _station_root("Map", pos)
	var accent: Material = VisualPaletteScript.violet_mat(0.9)
	_build_station_base(root, "MAP DEVICE", accent, Color(0.72, 0.42, 1.0, 1.0))
	root.add_child(PrimitiveKitScript.cylinder("MapTable", 0.82, 0.34, Vector3(0.0, 0.58, 0.0), VisualPaletteScript.wall_mat(), 32))
	root.add_child(PrimitiveKitScript.ground_disc("MapTableGlow", 0.72, Vector3(0.0, 0.78, 0.0), accent))
	root.add_child(PrimitiveKitScript.box("PortalLeftPillar", Vector3(0.25, 1.9, 0.25), Vector3(-0.92, 1.4, -0.2), VisualPaletteScript.wall_mat()))
	root.add_child(PrimitiveKitScript.box("PortalRightPillar", Vector3(0.25, 1.9, 0.25), Vector3(0.92, 1.4, -0.2), VisualPaletteScript.wall_mat()))
	root.add_child(PrimitiveKitScript.box("PortalLintel", Vector3(2.1, 0.25, 0.25), Vector3(0.0, 2.28, -0.2), VisualPaletteScript.brass_mat()))
	var portal: MeshInstance3D = PrimitiveKitScript.cylinder("PortalCorePulse", 0.72, 0.055, Vector3(0.0, 1.48, -0.22), accent, 48)
	portal.rotation_degrees.x = 90.0
	root.add_child(portal)
	_register_pulse(portal, 0.16, 2.7)


func _build_gem_altar(pos: Vector3) -> void:
	var root: Node3D = _station_root("Gem", pos)
	var accent: Material = VisualPaletteScript.green_mat(0.9)
	_build_station_base(root, "GEM ALTAR", accent, Color(0.36, 1.0, 0.55, 1.0))
	root.add_child(PrimitiveKitScript.cylinder("GemAltar", 0.72, 0.68, Vector3(0.0, 0.64, 0.0), VisualPaletteScript.wall_mat(), 28))
	root.add_child(PrimitiveKitScript.box("GemPrismA", Vector3(0.24, 0.75, 0.24), Vector3(-0.32, 1.28, 0.0), accent))
	root.add_child(PrimitiveKitScript.box("GemPrismB", Vector3(0.20, 1.05, 0.20), Vector3(0.0, 1.45, 0.0), VisualPaletteScript.blue_mat(0.9)))
	root.add_child(PrimitiveKitScript.box("GemPrismC", Vector3(0.24, 0.75, 0.24), Vector3(0.32, 1.28, 0.0), VisualPaletteScript.ember_mat(0.9)))
	var gem_orb: MeshInstance3D = PrimitiveKitScript.sphere("GemPulse", 0.20, Vector3(0.0, 2.04, 0.0), accent)
	root.add_child(gem_orb)
	_register_pulse(gem_orb, 0.20, 3.4)


func _build_character_shrine(pos: Vector3) -> void:
	var root: Node3D = _station_root("Character", pos)
	var accent: Material = VisualPaletteScript.brass_mat()
	_build_station_base(root, "CHARACTER", accent, Color(0.95, 0.78, 0.42, 1.0))
	root.add_child(PrimitiveKitScript.cylinder("ShrineBase", 0.76, 0.48, Vector3(0.0, 0.50, 0.0), VisualPaletteScript.wall_mat(), 30))
	root.add_child(PrimitiveKitScript.box("StatObelisk", Vector3(0.72, 1.55, 0.34), Vector3(0.0, 1.35, 0.0), VisualPaletteScript.wall_mat()))
	root.add_child(PrimitiveKitScript.box("StatFaceGlow", Vector3(0.54, 0.82, 0.035), Vector3(0.0, 1.42, -0.19), VisualPaletteScript.blue_mat(0.55)))
	root.add_child(PrimitiveKitScript.box("TrainingDummy", Vector3(0.28, 1.2, 0.28), Vector3(0.88, 1.0, 0.2), VisualPaletteScript.brass_mat()))


func _build_descent_gate(pos: Vector3) -> void:
	var root: Node3D = _station_root("Descent", pos)
	var accent: Material = VisualPaletteScript.ember_mat(0.95)
	_build_station_base(root, "DESCENT", accent, Color(1.0, 0.34, 0.12, 1.0))
	root.add_child(PrimitiveKitScript.box("GateLeft", Vector3(0.36, 2.5, 0.45), Vector3(-0.95, 1.45, 0.0), VisualPaletteScript.wall_mat()))
	root.add_child(PrimitiveKitScript.box("GateRight", Vector3(0.36, 2.5, 0.45), Vector3(0.95, 1.45, 0.0), VisualPaletteScript.wall_mat()))
	root.add_child(PrimitiveKitScript.box("GateTop", Vector3(2.35, 0.36, 0.45), Vector3(0.0, 2.65, 0.0), VisualPaletteScript.brass_mat()))
	var gate_core: MeshInstance3D = PrimitiveKitScript.cylinder("GateCorePulse", 0.78, 0.055, Vector3(0.0, 1.52, -0.02), accent, 48)
	gate_core.rotation_degrees.x = 90.0
	root.add_child(gate_core)
	_register_pulse(gate_core, 0.18, 2.9)


func _register_pulse(node: Node3D, amp: float, speed: float) -> void:
	_pulse_nodes.append({"node": node, "base": node.scale, "amp": amp, "speed": speed})


func _hide_basic_096a_stations() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	var visual: Node = scene.get_node_or_null("VisualFoundationLayer096A")
	if visual == null:
		return
	for child: Node in visual.get_children():
		if child.name.ends_with("Station096A"):
			child.visible = false


func _mode() -> String:
	if game_root != null:
		var state_value: Variant = game_root.get("state")
		if state_value != null and state_value is Object:
			var state_obj: Object = state_value as Object
			return str(state_obj.get("mode"))
	return "hub"


func _update_pulses() -> void:
	var t: float = float(Time.get_ticks_msec()) / 1000.0
	for value: Variant in _pulse_nodes:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(value)
		var node_value: Variant = data.get("node", null)
		if node_value == null or not is_instance_valid(node_value):
			continue
		var mesh_node: Node3D = node_value as Node3D
		if mesh_node == null:
			continue

		var base_scale: Vector3 = Vector3.ONE
		var base_value: Variant = data.get("base", Vector3.ONE)
		if typeof(base_value) == TYPE_VECTOR3:
			base_scale = base_value

		var amp: float = _to_float(data.get("amp", 0.1), 0.1)
		var speed: float = _to_float(data.get("speed", 2.0), 2.0)
		var pulse: float = 1.0 + sin(t * speed) * amp
		mesh_node.scale = base_scale * pulse


func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(int(value))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		_:
			return fallback
