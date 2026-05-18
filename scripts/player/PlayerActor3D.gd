class_name RVPlayerActor3D
extends Node3D

@onready var body: MeshInstance3D = $Body

func sync_from_state(state: RVGameState3D) -> void:
	if state == null:
		return
	global_position = state.player_pos

func face_direction(direction: Vector3) -> void:
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length() < 0.01:
		return
	look_at(global_position + flat.normalized(), Vector3.UP)

func set_combat_flash(active: bool) -> void:
	if body == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.74, 0.42) if active else Color(0.82, 0.74, 0.58)
	body.material_override = mat
