extends Node3D
class_name RVCombatArenaGreyboxPass3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")

var game_root: Node = null
var _built: bool = false
var _pulse_nodes: Array = []
var _last_mode: String = ""


func _ready() -> void:
	_build_once()
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root
	_update_visibility(true)


func _process(_delta: float) -> void:
	_update_visibility(false)
	_update_pulses()


func _build_once() -> void:
	if _built:
		return
	_built = true
	name = "CombatArenaGreyboxPass096C"
	_build_floor()
	_build_boundaries()
	_build_lanes()
	_build_blockers()
	_build_spawn_and_exit()
	_build_reward_dais()
	_build_telegraph_samples()
	visible = false


func _build_floor() -> void:
	var floor_mat: Material = VisualPaletteScript.material("Combat Arena Plate", Color(0.105, 0.105, 0.112, 1.0))
	var trim_mat: Material = VisualPaletteScript.material("Combat Edge Trim", Color(0.36, 0.24, 0.12, 1.0))
	var seal_mat: Material = VisualPaletteScript.material("Combat Seal", Color(0.28, 0.10, 0.06, 0.68), true, 0.25, 0.68)

	add_child(PrimitiveKitScript.box("CombatFloor096C", Vector3(31.0, 0.09, 25.0), Vector3(0.0, 0.012, 0.0), floor_mat))
	add_child(PrimitiveKitScript.box("CombatNorthTrim096C", Vector3(31.5, 0.06, 0.20), Vector3(0.0, 0.08, -12.6), trim_mat))
	add_child(PrimitiveKitScript.box("CombatSouthTrim096C", Vector3(31.5, 0.06, 0.20), Vector3(0.0, 0.08, 12.6), trim_mat))
	add_child(PrimitiveKitScript.box("CombatWestTrim096C", Vector3(0.20, 0.06, 25.3), Vector3(-15.8, 0.08, 0.0), trim_mat))
	add_child(PrimitiveKitScript.box("CombatEastTrim096C", Vector3(0.20, 0.06, 25.3), Vector3(15.8, 0.08, 0.0), trim_mat))

	var center_seal: MeshInstance3D = PrimitiveKitScript.ground_disc("CombatCenterSeal096C", 3.0, Vector3(0.0, 0.10, 0.0), seal_mat)
	add_child(center_seal)
	_register_pulse(center_seal, 0.035, 1.3)


func _build_boundaries() -> void:
	var wall: Material = VisualPaletteScript.wall_mat()
	var brass: Material = VisualPaletteScript.brass_mat()

	add_child(PrimitiveKitScript.box("CombatNorthWall096C", Vector3(30.5, 1.45, 0.55), Vector3(0.0, 0.78, -13.2), wall))
	add_child(PrimitiveKitScript.box("CombatSouthWall096C", Vector3(30.5, 1.45, 0.55), Vector3(0.0, 0.78, 13.2), wall))
	add_child(PrimitiveKitScript.box("CombatWestWall096C", Vector3(0.55, 1.45, 24.5), Vector3(-16.4, 0.78, 0.0), wall))
	add_child(PrimitiveKitScript.box("CombatEastWall096C", Vector3(0.55, 1.45, 24.5), Vector3(16.4, 0.78, 0.0), wall))

	var corners: Array[Vector3] = [
		Vector3(-16.0, 0.0, -12.8),
		Vector3(16.0, 0.0, -12.8),
		Vector3(-16.0, 0.0, 12.8),
		Vector3(16.0, 0.0, 12.8),
	]
	for pos: Vector3 in corners:
		add_child(PrimitiveKitScript.cylinder("CombatCornerPillar096C", 0.62, 2.3, pos + Vector3(0.0, 1.15, 0.0), wall, 22))
		add_child(PrimitiveKitScript.cylinder("CombatCornerCap096C", 0.76, 0.22, pos + Vector3(0.0, 2.38, 0.0), brass, 22))


func _build_lanes() -> void:
	var lane_mat: Material = VisualPaletteScript.material("Combat Lane Marking", Color(0.44, 0.25, 0.12, 0.42), true, 0.15, 0.42)
	var danger_mat: Material = VisualPaletteScript.material("Combat Hazard Strip", Color(1.0, 0.18, 0.06, 0.36), true, 0.55, 0.36)

	add_child(PrimitiveKitScript.box("CombatMidLaneX096C", Vector3(29.0, 0.035, 0.10), Vector3(0.0, 0.12, 0.0), lane_mat))
	add_child(PrimitiveKitScript.box("CombatMidLaneZ096C", Vector3(0.10, 0.035, 23.0), Vector3(0.0, 0.121, 0.0), lane_mat))

	var diag_a: MeshInstance3D = PrimitiveKitScript.box("CombatDiagonalLaneA096C", Vector3(0.10, 0.035, 25.0), Vector3(0.0, 0.122, 0.0), lane_mat)
	diag_a.rotation.y = deg_to_rad(43.0)
	add_child(diag_a)

	var diag_b: MeshInstance3D = PrimitiveKitScript.box("CombatDiagonalLaneB096C", Vector3(0.10, 0.035, 25.0), Vector3(0.0, 0.123, 0.0), lane_mat)
	diag_b.rotation.y = deg_to_rad(-43.0)
	add_child(diag_b)

	var hazard_positions: Array[Vector3] = [
		Vector3(-8.0, 0.0, -6.2),
		Vector3(8.0, 0.0, -6.2),
		Vector3(-8.0, 0.0, 6.2),
		Vector3(8.0, 0.0, 6.2),
	]
	for pos: Vector3 in hazard_positions:
		add_child(PrimitiveKitScript.box("CombatHazardStrip096C", Vector3(3.2, 0.04, 0.16), pos + Vector3(0.0, 0.14, 0.0), danger_mat))


func _build_blockers() -> void:
	var wall: Material = VisualPaletteScript.wall_mat()
	var brass: Material = VisualPaletteScript.brass_mat()

	var pillar_positions: Array[Vector3] = [
		Vector3(-6.0, 0.0, -3.5),
		Vector3(6.0, 0.0, -3.5),
		Vector3(-6.0, 0.0, 3.5),
		Vector3(6.0, 0.0, 3.5),
	]
	for pos: Vector3 in pillar_positions:
		add_child(PrimitiveKitScript.cylinder("CombatMidPillar096C", 0.42, 1.6, pos + Vector3(0.0, 0.8, 0.0), wall, 18))
		add_child(PrimitiveKitScript.cylinder("CombatMidPillarGlowRing096C", 0.49, 0.055, pos + Vector3(0.0, 1.62, 0.0), brass, 18))

	var low_blocks: Array[Vector3] = [
		Vector3(-10.5, 0.0, 0.0),
		Vector3(10.5, 0.0, 0.0),
		Vector3(0.0, 0.0, -8.0),
		Vector3(0.0, 0.0, 8.0),
	]
	for block_pos: Vector3 in low_blocks:
		add_child(PrimitiveKitScript.box("CombatLowBlocker096C", Vector3(2.2, 0.65, 0.85), block_pos + Vector3(0.0, 0.325, 0.0), wall))


func _build_spawn_and_exit() -> void:
	var player_mat: Material = VisualPaletteScript.green_mat(0.45)
	var gate_mat: Material = VisualPaletteScript.ember_mat(0.9)
	var blue_mat: Material = VisualPaletteScript.blue_mat(0.8)

	var spawn_ring: MeshInstance3D = PrimitiveKitScript.ground_disc("PlayerSpawnRing096C", 1.4, Vector3(0.0, 0.16, 9.5), player_mat)
	add_child(spawn_ring)
	_register_pulse(spawn_ring, 0.05, 2.0)

	var gate_root: Node3D = Node3D.new()
	gate_root.name = "CombatExitGate096C"
	gate_root.position = Vector3(0.0, 0.0, -12.0)
	add_child(gate_root)

	gate_root.add_child(PrimitiveKitScript.box("ExitGateLeft", Vector3(0.34, 2.2, 0.42), Vector3(-1.15, 1.1, 0.0), VisualPaletteScript.wall_mat()))
	gate_root.add_child(PrimitiveKitScript.box("ExitGateRight", Vector3(0.34, 2.2, 0.42), Vector3(1.15, 1.1, 0.0), VisualPaletteScript.wall_mat()))
	gate_root.add_child(PrimitiveKitScript.box("ExitGateTop", Vector3(2.65, 0.34, 0.42), Vector3(0.0, 2.18, 0.0), VisualPaletteScript.brass_mat()))

	var core: MeshInstance3D = PrimitiveKitScript.cylinder("ExitGateCorePulse", 0.72, 0.055, Vector3(0.0, 1.18, 0.02), gate_mat, 48)
	core.rotation_degrees.x = 90.0
	gate_root.add_child(core)
	_register_pulse(core, 0.18, 2.5)

	gate_root.add_child(PrimitiveKitScript.label_3d("CombatGateLabel096C", "EXIT / NEXT", Vector3(0.0, 2.72, 0.0), Color(1.0, 0.64, 0.35, 1.0)))
	gate_root.add_child(PrimitiveKitScript.add_light("ExitBlueFillA", Vector3(-2.6, 2.1, 0.2), Color(0.35, 0.55, 1.0, 1.0), 0.7, 5.5))
	gate_root.add_child(PrimitiveKitScript.add_light("ExitBlueFillB", Vector3(2.6, 2.1, 0.2), Color(0.35, 0.55, 1.0, 1.0), 0.7, 5.5))

	var locked_strip: MeshInstance3D = PrimitiveKitScript.box("ExitLockedThreshold096C", Vector3(3.6, 0.055, 0.18), Vector3(0.0, 0.18, 0.65), blue_mat)
	gate_root.add_child(locked_strip)
	_register_pulse(locked_strip, 0.08, 4.0)


func _build_reward_dais() -> void:
	var reward_root: Node3D = Node3D.new()
	reward_root.name = "CombatRewardDais096C"
	reward_root.position = Vector3(0.0, 0.0, 6.8)
	add_child(reward_root)

	var rare_mat: Material = VisualPaletteScript.rarity_mat("rare", 0.72)
	var brass: Material = VisualPaletteScript.brass_mat()

	reward_root.add_child(PrimitiveKitScript.cylinder("RewardBase", 0.9, 0.18, Vector3(0.0, 0.09, 0.0), brass, 32))
	reward_root.add_child(PrimitiveKitScript.ground_disc("RewardGlow", 0.74, Vector3(0.0, 0.21, 0.0), rare_mat))
	reward_root.add_child(PrimitiveKitScript.label_3d("RewardLabel", "REWARD SPAWN", Vector3(0.0, 1.1, 0.0), Color(1.0, 0.86, 0.28, 1.0)))

	var reward_orb: MeshInstance3D = PrimitiveKitScript.sphere("RewardOrbPulse096C", 0.22, Vector3(0.0, 0.72, 0.0), rare_mat)
	reward_root.add_child(reward_orb)
	_register_pulse(reward_orb, 0.20, 3.2)


func _build_telegraph_samples() -> void:
	var danger_mat: Material = VisualPaletteScript.material("Telegraph Sample", Color(1.0, 0.12, 0.04, 0.28), true, 0.55, 0.28)
	var warning_mat: Material = VisualPaletteScript.material("Warning Sample", Color(1.0, 0.55, 0.08, 0.22), true, 0.35, 0.22)

	var circle_a: MeshInstance3D = PrimitiveKitScript.ground_disc("TelegraphSampleCircleA096C", 1.2, Vector3(-11.0, 0.18, -8.5), danger_mat)
	add_child(circle_a)
	_register_pulse(circle_a, 0.06, 2.8)

	var circle_b: MeshInstance3D = PrimitiveKitScript.ground_disc("TelegraphSampleCircleB096C", 0.85, Vector3(11.0, 0.18, -8.5), warning_mat)
	add_child(circle_b)
	_register_pulse(circle_b, 0.06, 3.1)

	var line: MeshInstance3D = PrimitiveKitScript.box("TelegraphSampleLine096C", Vector3(0.72, 0.04, 5.8), Vector3(0.0, 0.18, -5.5), danger_mat)
	line.rotation.y = deg_to_rad(20.0)
	add_child(line)
	_register_pulse(line, 0.04, 2.5)


func _register_pulse(node: Node3D, amp: float, speed: float) -> void:
	_pulse_nodes.append({
		"node": node,
		"base": node.scale,
		"amp": amp,
		"speed": speed,
	})


func _update_visibility(force: bool) -> void:
	var mode: String = _mode()
	if force or mode != _last_mode:
		_last_mode = mode
		visible = mode == "combat"


func _mode() -> String:
	if game_root != null:
		var state_value: Variant = game_root.get("state")
		if state_value != null and state_value is Object:
			var state_obj: Object = state_value as Object
			return str(state_obj.get("mode"))
	return "hub"


func _update_pulses() -> void:
	if not visible:
		return

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
