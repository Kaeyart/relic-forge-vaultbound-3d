class_name RVProjectileActor3D
extends Area3D

var velocity: Vector3 = Vector3.ZERO
var damage: float = 1.0
var radius: float = 0.35
var tags: Array = []
var lifetime: float = 2.0

func _ready() -> void:
	if get_child_count() == 0:
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = radius
		shape.shape = sphere
		add_child(shape)
		var mesh := MeshInstance3D.new()
		var smesh := SphereMesh.new()
		smesh.radius = radius
		smesh.height = radius * 2.0
		mesh.mesh = smesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.38, 0.12)
		mesh.material_override = mat
		add_child(mesh)

func setup(pos: Vector3, vel: Vector3, dmg: float, rad: float, skill_tags: Array) -> void:
	global_position = pos
	velocity = vel
	damage = dmg
	radius = rad
	tags = skill_tags.duplicate(true)

func update_projectile(delta: float) -> void:
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
