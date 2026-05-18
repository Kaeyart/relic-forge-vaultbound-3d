class_name RVPickupPet3D
extends Node3D

const PickupSystemScript := preload("res://scripts/systems/LootPickupSystem3D.gd")

var follow_speed: float = 8.0
var collect_radius: float = 1.35
var scan_radius: float = 7.5

func _ready() -> void:
	if get_child_count() == 0:
		var mesh := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.24
		sphere.height = 0.48
		mesh.mesh = sphere
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.95, 0.55, 0.18)
		mesh.material_override = mat
		add_child(mesh)

func update_pet(player: Node3D, combat: Node, state: Object, delta: float) -> void:
	if player == null or state == null:
		return
	var desired: Vector3 = player.global_position + Vector3(-0.9, 0.45, 0.75)
	global_position = global_position.lerp(desired, clampf(delta * follow_speed, 0.0, 1.0))
	if combat == null or not combat.has_method("loot_nodes"):
		return
	for loot_node: Node in Array(combat.call("loot_nodes")):
		if loot_node == null or not is_instance_valid(loot_node): continue
		var drop: Dictionary = Dictionary(loot_node.get("drop_data"))
		if not PickupSystemScript.pet_can_pick(drop): continue
		var dist: float = global_position.distance_to((loot_node as Node3D).global_position)
		if dist <= collect_radius:
			PickupSystemScript.apply_pickup(state, loot_node)
		elif dist <= scan_radius:
			(loot_node as Node3D).global_position = (loot_node as Node3D).global_position.lerp(global_position, clampf(delta * 5.0, 0.0, 1.0))
