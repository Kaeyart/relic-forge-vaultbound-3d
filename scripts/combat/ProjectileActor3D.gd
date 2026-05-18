class_name RVProjectileActor3D
extends Node3D

var velocity: Vector3 = Vector3.ZERO
var damage: float = 1.0
var radius: float = 0.25
var tags: Array = []
var lifetime: float = 2.0
var alive: bool = true

func setup(pos: Vector3, vel: Vector3, hit_damage: float, hit_radius: float, skill_tags: Array) -> void:
	global_position = pos
	velocity = vel
	damage = hit_damage
	radius = hit_radius
	tags = skill_tags.duplicate(true)
	_make_visual()

func update_projectile(delta: float) -> void:
	if not alive:
		return
	lifetime -= delta
	if lifetime <= 0.0:
		alive = false
		queue_free()
		return
	global_position += velocity * delta

func _make_visual() -> void:
	if has_node("Mesh"):
		return
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.42, 0.12)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.22, 0.04)
	var inst := MeshInstance3D.new()
	inst.name = "Mesh"
	inst.mesh = mesh
	inst.set_surface_override_material(0, mat)
	add_child(inst)
