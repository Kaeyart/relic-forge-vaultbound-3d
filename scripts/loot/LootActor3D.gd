class_name RVLootActor3D
extends Area3D

const LootSystemScript := preload("res://scripts/systems/LootSystem3D.gd") 
const RewardLoopSystemScript := preload("res://scripts/systems/RewardLoopSystem3D.gd")
const LootFilterScript: GDScript = preload("res://scripts/systems/LootFilterSystem3D.gd")

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
		label.text = LootFilterScript.drop_label(drop_data)
	if body != null:
		var mat := StandardMaterial3D.new()
		var kind: String = str(drop_data.get("kind", ""))
		var priority: int = 20
		if kind == "item" and typeof(drop_data.get("item", {})) == TYPE_DICTIONARY:
			priority = LootFilterScript.priority_for_item(Dictionary(drop_data.get("item", {})))
		elif kind == "map" or kind.find("waystone") >= 0:
			priority = 80
		elif kind.ends_with("gem") or kind.find("gem") >= 0:
			priority = 85
		elif kind == "material" or kind == "gold":
			priority = 70
		if priority >= 95:
			mat.albedo_color = Color(1.0, 0.63, 0.12)
		elif priority >= 85:
			mat.albedo_color = Color(0.72, 0.36, 1.0)
		elif priority >= 70:
			mat.albedo_color = Color(0.34, 0.72, 1.0)
		elif priority >= 35:
			mat.albedo_color = Color(0.95, 0.72, 0.34)
		else:
			mat.albedo_color = Color(0.42, 0.42, 0.42)
		body.material_override = mat

func collect() -> void:
	if collected: return
	collected = true
	queue_free()
