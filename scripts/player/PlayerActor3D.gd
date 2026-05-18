class_name RVPlayerActor3D
extends Node3D

var facing_dir: Vector3 = Vector3.FORWARD

func sync_from_state(state: Object) -> void:
	if state == null:
		return
	global_position = Vector3(state.get("player_pos"))

func set_facing(direction: Vector3) -> void:
	if direction.length() < 0.05:
		return
	facing_dir = direction.normalized()
	look_at(global_position + Vector3(facing_dir.x, 0.0, facing_dir.z), Vector3.UP)
