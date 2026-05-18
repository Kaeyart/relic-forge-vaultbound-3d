class_name RVProjectileActor3D
extends Area3D

var velocity: Vector3 = Vector3.ZERO
var damage: float = 10.0
var radius: float = 0.35
var lifetime: float = 2.6
var tags: Array = []
var pierce_remaining: int = 0

func setup(pos: Vector3, vel: Vector3, dmg: float, hit_radius: float, tag_list: Array) -> void:
	global_position = pos
	velocity = vel
	damage = dmg
	radius = hit_radius
	tags = tag_list.duplicate(true)

func _process(delta: float) -> void:
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
