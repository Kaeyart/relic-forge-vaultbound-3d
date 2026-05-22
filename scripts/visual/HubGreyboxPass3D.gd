extends Node3D

# Patch 27: concept-hub layout rebuild.
# Builds the reference image as a playable primitive 3D hub:
# central blue Map Device, left Forge, right Stash, top shrine, gothic circular chamber.

var _game_root: Node = null
var _built: bool = false

var _mat_stone: StandardMaterial3D
var _mat_stone_dark: StandardMaterial3D
var _mat_floor: StandardMaterial3D
var _mat_iron: StandardMaterial3D
var _mat_brass: StandardMaterial3D
var _mat_blue: StandardMaterial3D
var _mat_fire: StandardMaterial3D
var _mat_red: StandardMaterial3D
var _mat_shadow: StandardMaterial3D
var _mat_label: StandardMaterial3D

func bind_game(root: Node) -> void:
	_game_root = root
	_build_once()


func _ready() -> void:
	_build_once()


func _process(_delta: float) -> void:
	if _game_root == null:
		return
	var state: Object = _game_root.get("state") as Object
	if state != null:
		visible = str(state.get("mode")) == "hub"


func _build_once() -> void:
	if _built:
		return
	_built = true
	name = "HubGreyboxPass096B"

	_make_materials()
	_build_room_floor()
	_build_perimeter_architecture()
	_build_center_map_device()
	_build_forge_left()
	_build_stash_right()
	_build_shrine_north()
	_build_foreground_braziers()
	_build_lighting()


func _make_materials() -> void:
	_mat_stone = _mat("HubStone", Color(0.105, 0.095, 0.082, 1.0), 0.0, 0.0)
	_mat_stone_dark = _mat("HubDarkStone", Color(0.045, 0.043, 0.044, 1.0), 0.0, 0.0)
	_mat_floor = _mat("HubFloorStone", Color(0.135, 0.122, 0.105, 1.0), 0.0, 0.0)
	_mat_iron = _mat("HubBlackIron", Color(0.055, 0.050, 0.045, 1.0), 0.12, 0.0)
	_mat_brass = _mat("HubDullBrass", Color(0.62, 0.43, 0.19, 1.0), 0.35, 0.0)
	_mat_blue = _mat("HubArcaneBlue", Color(0.18, 0.48, 1.0, 1.0), 0.10, 1.70)
	_mat_fire = _mat("HubForgeFire", Color(1.0, 0.32, 0.07, 1.0), 0.0, 2.00)
	_mat_red = _mat("HubRedBanner", Color(0.24, 0.035, 0.028, 1.0), 0.0, 0.0)
	_mat_shadow = _mat("HubBlackVoid", Color(0.012, 0.014, 0.018, 1.0), 0.0, 0.0)
	_mat_label = _mat("HubLabelPlate", Color(0.015, 0.012, 0.009, 1.0), 0.05, 0.0)


func _build_room_floor() -> void:
	_add_box("MainOctagonFloor", Vector3(16.5, 0.16, 13.2), Vector3(0.0, -0.12, 0.15), _mat_floor)
	_add_box("NorthRaisedFloor", Vector3(9.5, 0.22, 2.6), Vector3(0.0, 0.00, -5.35), _mat_stone)
	_add_box("LeftForgePlatform", Vector3(5.2, 0.18, 4.25), Vector3(-5.35, -0.01, -1.15), _mat_stone)
	_add_box("RightStashPlatform", Vector3(5.2, 0.18, 4.25), Vector3(5.35, -0.01, -1.15), _mat_stone)

	# Central engraved circular paving: stacked disks create brass ring lines.
	_add_disc("CentralOuterBrassRing", 4.95, 0.035, Vector3(0.0, 0.015, 0.0), _mat_brass, 96)
	_add_disc("CentralOuterStoneFill", 4.78, 0.045, Vector3(0.0, 0.035, 0.0), _mat_floor, 96)
	_add_disc("CentralMiddleBrassRing", 3.85, 0.035, Vector3(0.0, 0.055, 0.0), _mat_brass, 96)
	_add_disc("CentralMiddleStoneFill", 3.70, 0.045, Vector3(0.0, 0.075, 0.0), _mat_floor, 96)
	_add_disc("CentralInnerBrassRing", 2.35, 0.035, Vector3(0.0, 0.095, 0.0), _mat_brass, 96)
	_add_disc("CentralInnerStoneFill", 2.18, 0.055, Vector3(0.0, 0.115, 0.0), _mat_stone_dark, 96)

	# Brass floor spokes / paths.
	_add_box("NorthSouthBrassPath", Vector3(0.10, 0.035, 10.6), Vector3(0.0, 0.13, 0.0), _mat_brass)
	_add_box("EastWestBrassPath", Vector3(11.5, 0.035, 0.10), Vector3(0.0, 0.135, 0.0), _mat_brass)
	_add_box("ForgeApproachLine", Vector3(2.9, 0.035, 0.08), Vector3(-3.55, 0.14, -0.92), _mat_brass)
	_add_box("StashApproachLine", Vector3(2.9, 0.035, 0.08), Vector3(3.55, 0.14, -0.92), _mat_brass)

	# South entrance stairs.
	_add_step_set("SouthEntranceSteps", Vector3(0.0, 0.0, 5.55), 5.6, 0.35, 4, 1.0)


func _build_perimeter_architecture() -> void:
	# Back gothic walls.
	_add_box("NorthBackWall", Vector3(15.8, 3.4, 0.45), Vector3(0.0, 1.55, -7.0), _mat_stone_dark)
	_add_box("WestBackWall", Vector3(0.45, 3.0, 11.2), Vector3(-8.45, 1.40, -0.95), _mat_stone_dark)
	_add_box("EastBackWall", Vector3(0.45, 3.0, 11.2), Vector3(8.45, 1.40, -0.95), _mat_stone_dark)

	# Pillars around room.
	var pillar_positions: Array[Vector3] = [
		Vector3(-7.65, 0.0, -5.75), Vector3(-4.20, 0.0, -6.15), Vector3(4.20, 0.0, -6.15), Vector3(7.65, 0.0, -5.75),
		Vector3(-7.85, 0.0, -1.55), Vector3(7.85, 0.0, -1.55), Vector3(-7.50, 0.0, 3.55), Vector3(7.50, 0.0, 3.55),
	]
	for i: int in range(pillar_positions.size()):
		var p: Vector3 = pillar_positions[i]
		_add_box("GothicPillar" + str(i), Vector3(0.55, 2.55, 0.55), Vector3(p.x, 1.18, p.z), _mat_stone)
		_add_box("PillarBrassCap" + str(i), Vector3(0.72, 0.12, 0.72), Vector3(p.x, 2.45, p.z), _mat_brass)
		_add_sphere("PillarCandle" + str(i), 0.15, Vector3(p.x, 2.68, p.z), _mat_fire)

	# Red banners at top wall.
	_add_box("LeftCrimsonBanner", Vector3(0.72, 1.85, 0.05), Vector3(-2.95, 1.90, -6.74), _mat_red)
	_add_box("RightCrimsonBanner", Vector3(0.72, 1.85, 0.05), Vector3(2.95, 1.90, -6.74), _mat_red)
	_add_box("LeftBannerTrim", Vector3(0.82, 0.08, 0.06), Vector3(-2.95, 2.88, -6.70), _mat_brass)
	_add_box("RightBannerTrim", Vector3(0.82, 0.08, 0.06), Vector3(2.95, 2.88, -6.70), _mat_brass)

	# Low front rails / void boundary.
	_add_box("SouthVoidRailA", Vector3(5.8, 0.85, 0.34), Vector3(-4.95, 0.35, 6.38), _mat_iron)
	_add_box("SouthVoidRailB", Vector3(5.8, 0.85, 0.34), Vector3(4.95, 0.35, 6.38), _mat_iron)
	_add_box("WestVoidSide", Vector3(0.34, 0.92, 5.0), Vector3(-8.10, 0.38, 3.35), _mat_iron)
	_add_box("EastVoidSide", Vector3(0.34, 0.92, 5.0), Vector3(8.10, 0.38, 3.35), _mat_iron)


func _build_center_map_device() -> void:
	# Raised central platform.
	_add_disc("MapDeviceBaseStepLarge", 2.80, 0.32, Vector3(0.0, 0.24, 0.0), _mat_stone_dark, 96)
	_add_disc("MapDeviceBaseBrassRim", 2.68, 0.08, Vector3(0.0, 0.45, 0.0), _mat_brass, 96)
	_add_disc("MapDeviceBaseStepSmall", 2.05, 0.34, Vector3(0.0, 0.57, 0.0), _mat_stone, 96)
	_add_disc("MapDeviceBluePool", 1.28, 0.08, Vector3(0.0, 0.82, 0.0), _mat_blue, 96)
	_add_sphere("MapDeviceCore", 0.34, Vector3(0.0, 1.10, 0.0), _mat_blue)
	_add_box("MapDeviceVerticalBeam", Vector3(0.14, 1.25, 0.14), Vector3(0.0, 1.72, 0.0), _mat_blue)

	# Four blue pylons around the device.
	var pylons: Array[Vector3] = [Vector3(1.45, 0.0, 1.45), Vector3(-1.45, 0.0, 1.45), Vector3(1.45, 0.0, -1.45), Vector3(-1.45, 0.0, -1.45)]
	for i: int in range(pylons.size()):
		var p: Vector3 = pylons[i]
		_add_box("MapPylon" + str(i), Vector3(0.24, 1.10, 0.24), Vector3(p.x, 0.86, p.z), _mat_iron)
		_add_sphere("MapPylonLight" + str(i), 0.18, Vector3(p.x, 1.48, p.z), _mat_blue)


func _build_forge_left() -> void:
	# Forge is the warm orange production area on left, matching the reference.
	_add_box("ForgeBackWall", Vector3(3.70, 2.25, 0.38), Vector3(-5.92, 1.05, -2.95), _mat_stone_dark)
	_add_box("ForgeFurnaceFrame", Vector3(2.15, 1.85, 0.50), Vector3(-6.10, 0.92, -2.70), _mat_iron)
	_add_box("ForgeFurnaceMouth", Vector3(1.30, 0.95, 0.18), Vector3(-6.10, 0.72, -2.39), _mat_fire)
	_add_sphere("ForgeFireBallA", 0.36, Vector3(-6.32, 0.82, -2.18), _mat_fire)
	_add_sphere("ForgeFireBallB", 0.26, Vector3(-5.88, 0.96, -2.12), _mat_fire)
	_add_box("ForgeAnvil", Vector3(1.05, 0.35, 0.60), Vector3(-5.15, 0.38, -0.55), _mat_iron)
	_add_box("ForgeAnvilTop", Vector3(1.35, 0.20, 0.78), Vector3(-5.15, 0.68, -0.55), _mat_brass)
	_add_box("ForgeWorkbench", Vector3(2.20, 0.35, 0.82), Vector3(-6.45, 0.34, 0.78), _mat_iron)
	_add_box("ForgeToolRack", Vector3(0.24, 1.40, 1.60), Vector3(-4.25, 0.85, -2.05), _mat_iron)
	_add_box("ForgeHammerA", Vector3(0.16, 0.95, 0.10), Vector3(-4.05, 0.95, -2.20), _mat_brass)
	_add_box("ForgeHammerB", Vector3(0.16, 0.95, 0.10), Vector3(-4.45, 0.95, -2.05), _mat_brass)
	_add_step_set("ForgePlatformSteps", Vector3(-3.65, 0.0, 0.78), 2.4, 0.25, 3, 0.65)


func _build_stash_right() -> void:
	# Stash is the right treasury/storage zone from the concept.
	_add_box("StashBackWall", Vector3(3.75, 2.20, 0.38), Vector3(5.98, 1.05, -2.95), _mat_stone_dark)
	_add_box("StashVaultBody", Vector3(2.25, 1.65, 1.35), Vector3(5.65, 0.82, -1.58), _mat_iron)
	_add_box("StashVaultLid", Vector3(2.45, 0.22, 1.52), Vector3(5.65, 1.78, -1.58), _mat_brass)
	_add_box("StashVaultFace", Vector3(1.75, 0.92, 0.12), Vector3(5.65, 0.90, -2.30), _mat_stone_dark)
	_add_box("StashLockPlate", Vector3(0.45, 0.36, 0.14), Vector3(5.65, 0.88, -2.40), _mat_brass)
	_add_box("StashShelfLeft", Vector3(0.50, 1.40, 1.25), Vector3(3.95, 0.82, -0.82), _mat_iron)
	_add_box("StashShelfRight", Vector3(0.50, 1.40, 1.25), Vector3(7.20, 0.82, -0.78), _mat_iron)
	_add_box("StashChestA", Vector3(1.05, 0.56, 0.72), Vector3(4.20, 0.34, 0.85), _mat_iron)
	_add_box("StashChestB", Vector3(0.92, 0.45, 0.68), Vector3(6.95, 0.30, 0.95), _mat_iron)
	_add_box("StashCarpet", Vector3(2.80, 0.03, 1.25), Vector3(5.65, 0.14, 0.33), _mat_red)
	_add_box("StashCarpetTrim", Vector3(2.95, 0.04, 0.10), Vector3(5.65, 0.16, -0.25), _mat_brass)
	_add_step_set("StashPlatformSteps", Vector3(3.65, 0.0, 0.78), 2.4, 0.25, 3, 0.65)


func _build_shrine_north() -> void:
	# North altar/doorway anchors the vertical composition like the concept.
	_add_step_set("NorthShrineSteps", Vector3(0.0, 0.0, -4.35), 5.4, 0.34, 4, -0.62)
	_add_box("ShrineDoorFrame", Vector3(2.00, 2.75, 0.42), Vector3(0.0, 1.35, -6.63), _mat_iron)
	_add_box("ShrineDoorGlow", Vector3(1.20, 1.95, 0.12), Vector3(0.0, 1.35, -6.38), _mat_brass)
	_add_box("ShrineAltar", Vector3(2.40, 0.65, 0.92), Vector3(0.0, 0.36, -5.52), _mat_stone_dark)
	_add_box("ShrineLeftStatue", Vector3(0.48, 1.85, 0.48), Vector3(-1.75, 1.02, -6.14), _mat_stone)
	_add_box("ShrineRightStatue", Vector3(0.48, 1.85, 0.48), Vector3(1.75, 1.02, -6.14), _mat_stone)
	_add_sphere("ShrineLeftCandle", 0.18, Vector3(-2.45, 1.36, -5.62), _mat_fire)
	_add_sphere("ShrineRightCandle", 0.18, Vector3(2.45, 1.36, -5.62), _mat_fire)


func _build_foreground_braziers() -> void:
	var brazier_positions: Array[Vector3] = [
		Vector3(-5.75, 0.0, 4.78), Vector3(5.75, 0.0, 4.78), Vector3(-7.05, 0.0, 1.90), Vector3(7.05, 0.0, 1.90)
	]
	for i: int in range(brazier_positions.size()):
		var p: Vector3 = brazier_positions[i]
		_add_disc("BrazierBase" + str(i), 0.48, 0.32, Vector3(p.x, 0.24, p.z), _mat_iron, 32)
		_add_sphere("BrazierFire" + str(i), 0.28, Vector3(p.x, 0.70, p.z), _mat_fire)


func _build_lighting() -> void:
	_add_omni("BlueMapDeviceLight", Vector3(0.0, 1.75, 0.0), Color(0.20, 0.50, 1.0, 1.0), 4.0, 8.0)
	_add_omni("ForgeWarmLight", Vector3(-6.05, 1.35, -2.15), Color(1.0, 0.37, 0.08, 1.0), 5.5, 7.0)
	_add_omni("StashWarmLight", Vector3(5.70, 1.40, -1.30), Color(1.0, 0.70, 0.32, 1.0), 2.0, 5.0)
	_add_omni("ShrineCandleLight", Vector3(0.0, 2.10, -5.85), Color(1.0, 0.66, 0.36, 1.0), 2.3, 6.0)


func _add_step_set(prefix: String, center: Vector3, width: float, step_depth: float, count: int, z_dir: float) -> void:
	var dir: float = 1.0 if z_dir >= 0.0 else -1.0
	for i: int in range(count):
		var w: float = width - float(i) * 0.40
		var pos: Vector3 = center + Vector3(0.0, 0.035 + float(i) * 0.055, dir * step_depth * float(i))
		_add_box(prefix + "_" + str(i), Vector3(w, 0.10, step_depth), pos, _mat_stone_dark)


func _add_box(node_name: String, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	add_child(node)
	return node


func _add_disc(node_name: String, radius: float, height: float, pos: Vector3, material: Material, segments: int = 64) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	add_child(node)
	return node


func _add_sphere(node_name: String, radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	add_child(node)
	return node


func _add_omni(node_name: String, pos: Vector3, color: Color, energy: float, range_value: float) -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.name = node_name
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	add_child(light)


func _mat(label: String, color: Color, metallic: float, emission: float) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.resource_name = label
	mat.albedo_color = color
	mat.roughness = 0.82
	mat.metallic = metallic
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	return mat
