class_name RVLootActor3D
extends Area3D

const LootSystemScript := preload("res://scripts/systems/LootSystem3D.gd") const RewardLoopSystemScript := preload("res://scripts/systems/RewardLoopSystem3D.gd")

var drop_data: Dictionary = {}
var collected: bool = false
var pickup_radius: float = 1.35
var label: Label3D = null
var body: MeshInstance3D = null

func _ready() -> void:
	monitoring = true
	_ensure_visuals()

func setup(drop: Dictionary, pos: Vector3) -> void:
	drop_data = drop.duplicate(true)
	global_position = pos
	_ensure_visuals()
	_update_visuals()

func _ensure_visuals() -> void:
	if get_child_count() == 0:
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = pickup_radius
		shape.shape = sphere
		add_child(shape)
		body = MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.18
		mesh.height = 0.36
		body.mesh = mesh
		body.position.y = 0.22
		add_child(body)
		label = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position = Vector3(0, 0.75, 0)
		label.font_size = 24
		add_child(label)
	else:
		for child: Node in get_children():
			if child is MeshInstance3D: body = child as MeshInstance3D
			if child is Label3D: label = child as Label3D

func _update_visuals() -> void:
	if label != null:
		label.text = RewardLoopSystemScript.label_for_drop(drop_data)
	if body != null:
		var mat := StandardMaterial3D.new()
		var kind: String = str(drop_data.get("kind", ""))
		if kind == "item": mat.albedo_color = Color(0.95, 0.72, 0.34)
		elif kind == "map": mat.albedo_color = Color(0.34, 0.72, 1.0)
		elif kind.ends_with("gem"): mat.albedo_color = Color(0.75, 0.42, 1.0)
		elif kind == "gold": mat.albedo_color = Color(1.0, 0.84, 0.22)
		else: mat.albedo_color = Color(0.55, 0.95, 0.72)
		body.material_override = mat

func collect() -> void:
	if collected: return
	collected = true
	queue_free()
