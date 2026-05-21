extends Node3D

var _game_root: Node = null
var _built: bool = false

func bind_game(root: Node) -> void:
	_game_root = root
	_build_once()

func _ready() -> void:
	_build_once()

func _process(_delta: float) -> void:
	if _game_root != null:
		var state: Object = _game_root.get("state") as Object
		if state != null:
			visible = str(state.get("mode")) == "combat"

func _build_once() -> void:
	if _built:
		return
	_built = true
	name = "CombatArenaGreyboxPass096C"
	var floor_mat := _mat(Color(0.075, 0.070, 0.065, 1.0), 0.0)
	var lane_mat := _mat(Color(0.42, 0.19, 0.10, 1.0), 0.18)
	var wall_mat := _mat(Color(0.13, 0.12, 0.115, 1.0), 0.0)
	_add_box("ArenaFloor", Vector3(18.0, 0.08, 14.0), Vector3(0, -0.11, 0), floor_mat)
	_add_box("NorthWall", Vector3(18.6, 1.2, 0.45), Vector3(0, 0.5, -7.2), wall_mat)
	_add_box("SouthWall", Vector3(18.6, 0.8, 0.35), Vector3(0, 0.3, 7.2), wall_mat)
	_add_box("WestWall", Vector3(0.45, 1.0, 14.0), Vector3(-9.2, 0.45, 0), wall_mat)
	_add_box("EastWall", Vector3(0.45, 1.0, 14.0), Vector3(9.2, 0.45, 0), wall_mat)
	_add_box("CenterKillLane", Vector3(2.0, 0.05, 12.0), Vector3(0, 0.0, 0), lane_mat)
	_add_box("CrossLane", Vector3(13.0, 0.05, 1.4), Vector3(0, 0.01, -1.0), lane_mat)
	_add_box("PlayerEntryPad", Vector3(3.2, 0.08, 1.6), Vector3(0, 0.02, 5.8), lane_mat)
	_add_box("BossDais", Vector3(4.0, 0.16, 2.0), Vector3(0, 0.04, -5.4), lane_mat)
	_add_label("ENTRY", Vector3(0, 0.9, 5.8), 30)
	_add_label("BOSS / CHEST", Vector3(0, 1.1, -5.4), 30)

func _add_box(node_name: String, size: Vector3, pos: Vector3, mat: Material) -> void:
	var box := CSGBox3D.new()
	box.name = node_name
	box.size = size
	box.position = pos
	box.material = mat
	add_child(box)

func _add_label(text: String, pos: Vector3, size: int) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = size
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 0.74, 0.34, 1.0)
	add_child(label)

func _mat(color: Color, emission: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	return mat
