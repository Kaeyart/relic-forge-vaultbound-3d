extends Node3D

var _game_root: Node = null
var _built: bool = false

var _stone_floor: StandardMaterial3D
var _stone_mid: StandardMaterial3D
var _stone_dark: StandardMaterial3D
var _stone_wall: StandardMaterial3D
var _iron: StandardMaterial3D
var _iron_dark: StandardMaterial3D
var _brass: StandardMaterial3D
var _blue: StandardMaterial3D
var _blue_soft: StandardMaterial3D
var _ember: StandardMaterial3D
var _ember_soft: StandardMaterial3D
var _banner: StandardMaterial3D
var _shadow: StandardMaterial3D
var _rug: StandardMaterial3D

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
	_clear_children()
	_make_materials()
	_build_foundation()
	_build_walls_and_depth()
	_build_center_map_device()
	_build_forge_wing()
	_build_stash_wing()
	_build_north_shrine()
	_build_foreground_edge()
	_build_lighting()


func _clear_children() -> void:
	for child: Node in get_children():
		child.queue_free()


func _make_materials() -> void:
	_stone_floor = _mat("HubStoneFloor", Color(0.135, 0.125, 0.110, 1.0), 0.0, 0.0, 0.90)
	_stone_mid = _mat("HubStoneMid", Color(0.095, 0.087, 0.078, 1.0), 0.0, 0.0, 0.92)
	_stone_dark = _mat("HubStoneDark", Color(0.045, 0.041, 0.038, 1.0), 0.0, 0.0, 0.96)
	_stone_wall = _mat("HubStoneWall", Color(0.075, 0.068, 0.064, 1.0), 0.0, 0.0, 0.94)
	_iron = _mat("HubIron", Color(0.105, 0.095, 0.085, 1.0), 0.35, 0.0, 0.72)
	_iron_dark = _mat("HubIronDark", Color(0.032, 0.030, 0.029, 1.0), 0.45, 0.0, 0.78)
	_brass = _mat("HubBrass", Color(0.72, 0.48, 0.20, 1.0), 0.75, 0.0, 0.48)
	_blue = _mat("HubBlueArcane", Color(0.18, 0.48, 1.00, 1.0), 0.20, 1.85, 0.34)
	_blue_soft = _mat("HubBlueSoft", Color(0.07, 0.21, 0.55, 1.0), 0.15, 0.70, 0.52)
	_ember = _mat("HubEmber", Color(1.00, 0.26, 0.045, 1.0), 0.10, 2.35, 0.42)
	_ember_soft = _mat("HubEmberSoft", Color(0.62, 0.19, 0.05, 1.0), 0.15, 0.85, 0.58)
	_banner = _mat("HubBannerRed", Color(0.26, 0.035, 0.032, 1.0), 0.0, 0.0, 0.82)
	_shadow = _mat("HubVoidShadow", Color(0.006, 0.007, 0.010, 1.0), 0.0, 0.0, 1.0)
	_rug = _mat("HubRug", Color(0.23, 0.120, 0.035, 1.0), 0.0, 0.0, 0.88)


func _build_foundation() -> void:
	_add_box("OuterVoidPlate", Vector3(23.0, 0.08, 19.0), Vector3(0.0, -0.16, 0.0), _shadow)
	_add_box("MainSquareStoneFloor", Vector3(17.2, 0.16, 13.8), Vector3(0.0, -0.08, 0.0), _stone_floor)
	_add_box("SouthEntranceBridge", Vector3(5.2, 0.14, 3.8), Vector3(0.0, -0.06, 7.65), _stone_floor)
	_add_box("NorthRaisedFloor", Vector3(9.2, 0.20, 2.65), Vector3(0.0, 0.02, -6.05), _stone_mid)
	_add_box("ForgeRaisedFloor", Vector3(5.1, 0.18, 4.2), Vector3(-6.2, 0.00, -0.75), _stone_mid)
	_add_box("StashRaisedFloor", Vector3(5.1, 0.18, 4.2), Vector3(6.2, 0.00, -0.75), _stone_mid)
	_add_box("SouthLowerLanding", Vector3(8.0, 0.12, 2.2), Vector3(0.0, -0.02, 5.65), _stone_mid)
	_build_tile_grid()
	_build_floor_inlays()
	_build_stairs("NorthShrineStairs", Vector3(0.0, 0.07, -4.66), 6.0, 1.25, -1)
	_build_stairs("ForgeStairs", Vector3(-4.55, 0.04, -0.50), 2.2, 1.05, 1)
	_build_stairs("StashStairs", Vector3(4.55, 0.04, -0.50), 2.2, 1.05, -1)
	_build_stairs("SouthEntranceStairs", Vector3(0.0, 0.01, 6.45), 4.4, 1.20, 1)


func _build_tile_grid() -> void:
	var line_mat: StandardMaterial3D = _mat("HubTileLine", Color(0.070, 0.062, 0.052, 1.0), 0.0, 0.0, 0.96)
	for x: int in range(-8, 9):
		_add_box("TileLineX_" + str(x), Vector3(0.022, 0.025, 13.35), Vector3(float(x), 0.025, 0.0), line_mat)
	for z: int in range(-6, 8):
		_add_box("TileLineZ_" + str(z), Vector3(16.7, 0.025, 0.022), Vector3(0.0, 0.028, float(z)), line_mat)


func _build_floor_inlays() -> void:
	_add_ring_segments("OuterBrassCircle", 4.25, 56, 0.46, 0.050, 0.062, _brass)
	_add_ring_segments("MidBrassCircle", 3.20, 48, 0.38, 0.045, 0.067, _brass)
	_add_ring_segments("InnerBrassCircle", 2.15, 40, 0.30, 0.042, 0.072, _brass)
	_add_ring_segments("MapBlueGlowCircle", 1.35, 36, 0.20, 0.035, 0.082, _blue_soft)
	for i: int in range(8):
		var angle: float = TAU * float(i) / 8.0
		var pos: Vector3 = Vector3(cos(angle) * 2.85, 0.085, sin(angle) * 2.85)
		_add_box("RadialBrassSpoke_" + str(i), Vector3(1.15, 0.040, 0.055), pos, _brass, -angle)


func _build_walls_and_depth() -> void:
	_add_box("NorthCathedralWall", Vector3(17.7, 4.25, 0.52), Vector3(0.0, 2.05, -7.22), _stone_wall)
	_add_box("WestWall", Vector3(0.55, 3.10, 12.8), Vector3(-8.86, 1.47, -0.10), _stone_wall)
	_add_box("EastWall", Vector3(0.55, 3.10, 12.8), Vector3(8.86, 1.47, -0.10), _stone_wall)
	_add_box("NorthLeftReturn", Vector3(2.0, 3.4, 0.50), Vector3(-7.95, 1.55, -5.85), _stone_wall, 0.55)
	_add_box("NorthRightReturn", Vector3(2.0, 3.4, 0.50), Vector3(7.95, 1.55, -5.85), _stone_wall, -0.55)
	for i: int in range(6):
		var x: float = -7.2 + float(i) * 2.88
		_build_wall_pillar("NorthPillar_" + str(i), Vector3(x, 0.0, -6.82), 2.95)
	_build_wall_pillar("WestFrontPillar", Vector3(-8.55, 0.0, 5.25), 2.3)
	_build_wall_pillar("EastFrontPillar", Vector3(8.55, 0.0, 5.25), 2.3)
	_build_wall_pillar("WestMidPillar", Vector3(-8.55, 0.0, 0.45), 2.5)
	_build_wall_pillar("EastMidPillar", Vector3(8.55, 0.0, 0.45), 2.5)
	_build_wall_pillar("WestBackPillar", Vector3(-8.55, 0.0, -4.45), 2.7)
	_build_wall_pillar("EastBackPillar", Vector3(8.55, 0.0, -4.45), 2.7)
	_build_chains()


func _build_wall_pillar(label: String, pos: Vector3, height: float) -> void:
	_add_box(label + "Base", Vector3(0.54, 0.26, 0.54), pos + Vector3(0.0, 0.13, 0.0), _iron_dark)
	_add_cylinder(label + "Column", 0.20, height, pos + Vector3(0.0, height * 0.5 + 0.24, 0.0), _stone_dark, 10)
	_add_cylinder(label + "BrassCap", 0.27, 0.10, pos + Vector3(0.0, height + 0.80, 0.0), _brass, 12)
	_add_sphere(label + "TopOrb", 0.16, pos + Vector3(0.0, height + 0.98, 0.0), _brass)


func _build_chains() -> void:
	for i: int in range(7):
		var x: float = -7.2 + float(i) * 2.4
		_add_box("NorthChainLink_" + str(i), Vector3(0.08, 0.08, 1.35), Vector3(x, 3.45, -6.73), _iron, 0.42)
	for i: int in range(5):
		var z: float = -4.7 + float(i) * 2.3
		_add_box("WestHangingChain_" + str(i), Vector3(0.06, 1.4, 0.06), Vector3(-8.35, 2.75, z), _iron)
		_add_box("EastHangingChain_" + str(i), Vector3(0.06, 1.4, 0.06), Vector3(8.35, 2.75, z), _iron)


func _build_center_map_device() -> void:
	_add_cylinder("MapDeviceLowerDais", 2.30, 0.34, Vector3(0.0, 0.18, 0.0), _stone_mid, 96)
	_add_cylinder("MapDeviceMidDais", 1.74, 0.30, Vector3(0.0, 0.50, 0.0), _stone_dark, 96)
	_add_cylinder("MapDeviceUpperDais", 1.12, 0.24, Vector3(0.0, 0.78, 0.0), _iron_dark, 64)
	_add_ring_segments("DeviceBrassOuterTrim", 2.36, 64, 0.23, 0.045, 0.39, _brass)
	_add_ring_segments("DeviceBrassMiddleTrim", 1.78, 56, 0.19, 0.040, 0.68, _brass)
	_add_ring_segments("DeviceBlueTrim", 1.10, 44, 0.14, 0.035, 0.93, _blue)
	for i: int in range(4):
		var angle: float = TAU * float(i) / 4.0 + PI * 0.25
		var pos: Vector3 = Vector3(cos(angle) * 1.35, 0.0, sin(angle) * 1.35)
		_add_cylinder("MapDevicePylon_" + str(i), 0.16, 1.08, pos + Vector3(0.0, 1.12, 0.0), _iron_dark, 12)
		_add_sphere("MapDevicePylonLight_" + str(i), 0.18, pos + Vector3(0.0, 1.78, 0.0), _blue)
	_add_cylinder("MapDeviceCoreWell", 0.54, 0.16, Vector3(0.0, 1.02, 0.0), _blue_soft, 48)
	_add_sphere("MapDeviceCore", 0.34, Vector3(0.0, 1.36, 0.0), _blue)
	_add_box("MapDeviceBeam", Vector3(0.11, 1.75, 0.11), Vector3(0.0, 2.20, 0.0), _blue)
	_add_label("MapDeviceWorldLabel", "Map Device", Vector3(0.0, 2.55, 0.65), 30, Color(0.96, 0.84, 0.55, 1.0))


func _build_forge_wing() -> void:
	_add_box("ForgeBackWallPlate", Vector3(4.7, 2.4, 0.32), Vector3(-6.2, 1.22, -2.90), _stone_wall)
	_add_box("ForgeFurnaceFrame", Vector3(2.0, 1.55, 0.52), Vector3(-7.0, 0.94, -2.45), _iron_dark)
	_add_box("ForgeFireMouth", Vector3(1.18, 0.86, 0.18), Vector3(-7.0, 0.88, -2.73), _ember)
	_add_box("ForgeAnvilBlock", Vector3(1.12, 0.34, 0.58), Vector3(-5.55, 0.52, -0.82), _iron)
	_add_box("ForgeAnvilTop", Vector3(1.46, 0.16, 0.38), Vector3(-5.55, 0.80, -0.82), _iron)
	_add_box("ForgeWorkbench", Vector3(2.35, 0.25, 0.86), Vector3(-6.75, 0.60, 1.08), _iron_dark)
	_add_box("ForgeWorkbenchTop", Vector3(2.55, 0.08, 0.98), Vector3(-6.75, 0.78, 1.08), _brass)
	for i: int in range(6):
		var x: float = -7.82 + float(i) * 0.42
		_add_box("ForgeTool_" + str(i), Vector3(0.05, 0.82, 0.05), Vector3(x, 1.30, -2.63), _brass, 0.2 * float(i))
	for i: int in range(5):
		_add_sphere("ForgeCoalGlow_" + str(i), 0.08, Vector3(-7.45 + float(i) * 0.23, 0.92, -2.93), _ember)
	_add_cylinder("ForgeBrazierLeft", 0.24, 0.45, Vector3(-8.02, 0.55, 0.70), _iron_dark, 16)
	_add_sphere("ForgeBrazierFlameLeft", 0.19, Vector3(-8.02, 0.92, 0.70), _ember)
	_add_cylinder("ForgeBrazierRight", 0.24, 0.45, Vector3(-4.38, 0.55, 0.75), _iron_dark, 16)
	_add_sphere("ForgeBrazierFlameRight", 0.19, Vector3(-4.38, 0.92, 0.75), _ember)
	_add_label("ForgeWorldLabel", "Forge", Vector3(-6.2, 1.78, 0.25), 30, Color(1.0, 0.70, 0.36, 1.0))


func _build_stash_wing() -> void:
	_add_box("StashBackWallPlate", Vector3(4.7, 2.4, 0.32), Vector3(6.2, 1.22, -2.90), _stone_wall)
	_add_box("StashVaultBody", Vector3(2.25, 1.45, 1.25), Vector3(6.65, 0.92, -1.55), _iron_dark)
	_add_box("StashVaultDoor", Vector3(2.02, 1.23, 0.12), Vector3(6.65, 0.95, -2.20), _iron)
	_add_box("StashVaultTrimTop", Vector3(2.35, 0.11, 1.36), Vector3(6.65, 1.68, -1.55), _brass)
	_add_box("StashVaultLock", Vector3(0.34, 0.34, 0.10), Vector3(6.65, 0.90, -2.31), _brass)
	_add_box("StashRug", Vector3(2.4, 0.035, 1.55), Vector3(6.65, 0.15, 0.20), _rug)
	for i: int in range(3):
		_add_box("StashShelf_" + str(i), Vector3(0.34, 1.36, 1.08), Vector3(8.0, 0.85, -1.85 + float(i) * 1.05), _iron_dark)
	for i: int in range(6):
		_add_box("StashCrate_" + str(i), Vector3(0.54, 0.40, 0.48), Vector3(4.55 + float(i % 3) * 0.62, 0.30, 0.92 + float(i / 3) * 0.55), _stone_dark)
	_add_cylinder("StashBrazierLeft", 0.22, 0.42, Vector3(4.46, 0.55, -0.45), _iron_dark, 16)
	_add_sphere("StashBrazierFlameLeft", 0.16, Vector3(4.46, 0.88, -0.45), _ember_soft)
	_add_cylinder("StashBrazierRight", 0.22, 0.42, Vector3(8.02, 0.55, -0.45), _iron_dark, 16)
	_add_sphere("StashBrazierFlameRight", 0.16, Vector3(8.02, 0.88, -0.45), _ember_soft)
	_add_label("StashWorldLabel", "Stash", Vector3(6.55, 1.95, 0.20), 30, Color(0.96, 0.84, 0.55, 1.0))


func _build_north_shrine() -> void:
	_add_box("ShrineDoorFrame", Vector3(2.45, 2.65, 0.40), Vector3(0.0, 1.65, -7.00), _iron_dark)
	_add_box("ShrineDoorGoldPanel", Vector3(1.50, 2.05, 0.10), Vector3(0.0, 1.50, -7.24), _brass)
	_add_box("ShrineDoorDarkInset", Vector3(1.18, 1.72, 0.08), Vector3(0.0, 1.45, -7.31), _stone_dark)
	_add_box("ShrineAltar", Vector3(2.35, 0.55, 0.82), Vector3(0.0, 0.42, -5.70), _iron_dark)
	_add_box("ShrineAltarTop", Vector3(2.70, 0.10, 0.96), Vector3(0.0, 0.76, -5.70), _brass)
	for side: int in [-1, 1]:
		var sx: float = float(side)
		_add_box("ShrineStatueBase_" + str(side), Vector3(0.58, 0.22, 0.58), Vector3(sx * 2.15, 0.20, -6.18), _iron_dark)
		_add_box("ShrineStatueBody_" + str(side), Vector3(0.36, 1.15, 0.34), Vector3(sx * 2.15, 0.88, -6.18), _stone_dark)
		_add_sphere("ShrineStatueHead_" + str(side), 0.18, Vector3(sx * 2.15, 1.55, -6.18), _stone_dark)
		_add_cylinder("ShrineCandle_" + str(side), 0.12, 0.36, Vector3(sx * 3.20, 0.50, -5.72), _iron_dark, 12)
		_add_sphere("ShrineCandleFlame_" + str(side), 0.09, Vector3(sx * 3.20, 0.78, -5.72), _ember_soft)
		_add_box("ShrineBanner_" + str(side), Vector3(0.52, 1.70, 0.045), Vector3(sx * 3.65, 2.15, -6.93), _banner)
		_add_box("ShrineBannerTrim_" + str(side), Vector3(0.62, 0.06, 0.055), Vector3(sx * 3.65, 3.02, -6.90), _brass)
	_add_label("ShrineHeaderLabel", "Vault Reliquary", Vector3(0.0, 3.02, -6.55), 28, Color(0.95, 0.72, 0.38, 1.0))


func _build_foreground_edge() -> void:
	_add_box("SouthLeftParapet", Vector3(5.4, 0.95, 0.42), Vector3(-5.2, 0.45, 6.85), _stone_wall, -0.20)
	_add_box("SouthRightParapet", Vector3(5.4, 0.95, 0.42), Vector3(5.2, 0.45, 6.85), _stone_wall, 0.20)
	for i: int in range(4):
		var x: float = -7.4 + float(i) * 4.95
		_add_cylinder("ForegroundBrazier_" + str(i), 0.28, 0.55, Vector3(x, 0.62, 6.28), _iron_dark, 16)
		_add_sphere("ForegroundBrazierFlame_" + str(i), 0.20, Vector3(x, 1.04, 6.28), _ember)


func _build_lighting() -> void:
	var world: WorldEnvironment = WorldEnvironment.new()
	world.name = "HubWorldEnvironment"
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.004, 0.005, 0.008, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.05, 0.055, 0.065, 1.0)
	env.ambient_light_energy = 0.55
	world.environment = env
	add_child(world)
	_add_omni("CenterBlueLight", Vector3(0.0, 2.25, 0.0), Color(0.25, 0.55, 1.0, 1.0), 2.8, 8.5)
	_add_omni("ForgeFireLight", Vector3(-7.05, 1.25, -2.25), Color(1.0, 0.34, 0.06, 1.0), 3.2, 7.0)
	_add_omni("StashWarmLight", Vector3(6.85, 1.55, -1.10), Color(1.0, 0.64, 0.22, 1.0), 1.6, 5.0)
	_add_omni("ShrineCandleLight", Vector3(0.0, 2.2, -5.85), Color(1.0, 0.72, 0.35, 1.0), 1.5, 5.5)
	_add_omni("SouthBrazierLight", Vector3(0.0, 1.5, 6.35), Color(1.0, 0.32, 0.08, 1.0), 1.1, 6.0)


func _build_stairs(label: String, center: Vector3, width: float, depth: float, z_dir: int) -> void:
	for i: int in range(4):
		var step_depth: float = depth / 4.0
		var y: float = center.y + float(i) * 0.055
		var z: float = center.z + float(z_dir) * (float(i) - 1.5) * step_depth
		_add_box(label + "_Step_" + str(i), Vector3(width - float(i) * 0.20, 0.10, step_depth * 0.95), Vector3(center.x, y, z), _stone_dark)


func _add_ring_segments(label: String, radius: float, count: int, segment_len: float, thickness: float, y: float, mat: Material) -> void:
	for i: int in range(count):
		var angle: float = TAU * float(i) / float(count)
		var pos: Vector3 = Vector3(cos(angle) * radius, y, sin(angle) * radius)
		_add_box(label + "_" + str(i), Vector3(segment_len, 0.030, thickness), pos, mat, -angle)


func _add_box(label: String, size: Vector3, pos: Vector3, mat: Material, rot_y: float = 0.0) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = pos
	node.rotation.y = rot_y
	node.material_override = mat
	add_child(node)
	return node


func _add_cylinder(label: String, radius: float, height: float, pos: Vector3, mat: Material, segments: int = 32) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = maxi(8, segments)
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = pos
	node.material_override = mat
	add_child(node)
	return node


func _add_sphere(label: String, radius: float, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = pos
	node.material_override = mat
	add_child(node)
	return node


func _add_label(label_name: String, text: String, pos: Vector3, size: int, color: Color) -> Label3D:
	var label: Label3D = Label3D.new()
	label.name = label_name
	label.text = text
	label.position = pos
	label.font_size = size
	label.modulate = color
	label.outline_size = 8
	label.outline_modulate = Color(0.0, 0.0, 0.0, 0.96)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	return label


func _add_omni(label: String, pos: Vector3, color: Color, energy: float, range_value: float) -> OmniLight3D:
	var light: OmniLight3D = OmniLight3D.new()
	light.name = label
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	add_child(light)
	return light


func _mat(label: String, color: Color, metallic: float, emission: float, roughness: float) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.resource_name = label
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	return mat
