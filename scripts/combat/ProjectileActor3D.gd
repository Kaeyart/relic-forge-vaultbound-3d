class_name RVProjectileActor3D
extends Node3D

var velocity: Vector3 = Vector3.ZERO
var damage: float = 18.0
var radius: float = 0.32
var lifetime: float = 2.0

func setup(pos: Vector3, vel: Vector3, dmg: float, hit_radius: float = 0.32) -> void:
	global_position = pos
	velocity = vel
	damage = dmg
	radius = hit_radius

func tick(delta: float) -> bool:
	global_position += velocity * delta
	lifetime -= delta
	return lifetime > 0.0
