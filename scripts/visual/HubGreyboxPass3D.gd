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
			visible = str(state.get("mode")) == "hub"

func _build_once() -> void:
	if _built:
		return
	_built = true
	name = "HubGreyboxPass096B"
	var floor_mat := _mat(Color(0.12, 0.115, 0.105, 1.0), 0.0)
	var line_mat := _mat(Color(0.78, 0.43, 0.18, 1.0), 0.25)
	var dark_mat := _mat(Color(0.045, 0.045, 0.05, 1.0), 0.0)
	_add_box("MainHubFloor", Vector3(12.0, 0.12, 10.5), Vector3(0, -0.08, 0), floor_mat)
	_add_box("NorthStep", Vector3(7.0, 0.22, 1.2), Vector3(0, 0.02, -5.1), dark_mat)
	_add_box("SouthTrainingPad", Vector3(4.8, 0.08, 2.3), Vector3(0, 0.0, 3.7), dark_mat)
	_add_box("CenterMapRing", Vector3(3.3, 0.08, 2.35), Vector3(0, 0.04, -3.35), line_mat)
	_add_box("LeftUtilityZone", Vector3(3.2, 0.06, 2.6), Vector3(-4.2, 0.02, 0.8), line_mat)
	_add_box("RightUtilityZone", Vector3(3.2, 0.06, 2.6), Vector3(4.2, 0.02, 0.8), line_mat)
	_add_box("GemZone", Vector3(2.8, 0.06, 2.2), Vector3(-3.9, 0.02, -4.2), line_mat)
	_add_box("ShrineZone", Vector3(2.8, 0.06, 2.2), Vector3(3.9, 0.02, -4.2), line_mat)
	_add_label("VAULT HUB", Vector3(0, 1.6, -5.1), 50)
	_add_label("Map Device", Vector3(0, 1.15, -2.0), 32)
	_add_label("Training", Vector3(0, 1.1, 4.9), 30)
	_add_rail("WestRail", -6.2)
	_add_rail("EastRail", 6.2)

func _add_rail(node_name: String, x: float) -> void:
	var mat := _mat(Color(0.20, 0.18, 0.16, 1.0), 0.0)
	_add_box(node_name + "A", Vector3(0.18, 0.7, 9.8), Vector3(x, 0.28, 0), mat)
	_add_box(node_name + "B", Vector3(0.35, 0.95, 0.35), Vector3(x, 0.4, -4.8), mat)
	_add_box(node_name + "C", Vector3(0.35, 0.95, 0.35), Vector3(x, 0.4, 4.8), mat)

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
	label.modulate = Color(1.0, 0.82, 0.38, 1.0)
	add_child(label)

func _mat(color: Color, emission: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.86
	if emission > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission
	return mat
