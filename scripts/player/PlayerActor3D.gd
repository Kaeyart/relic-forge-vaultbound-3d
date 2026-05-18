class_name RVPlayerActor3D
extends CharacterBody3D

@onready var body: MeshInstance3D = $Body

func _ready() -> void:
	if body == null:
		var mesh := CapsuleMesh.new()
		mesh.radius = 0.35
		mesh.height = 1.3
		body = MeshInstance3D.new()
		body.name = "Body"
		body.mesh = mesh
		add_child(body)

func sync_from_state(state: Object) -> void:
	if state == null:
		return
	global_position = Vector3(state.get("player_pos"))

func apply_to_state(state: Object) -> void:
	if state == null:
		return
	state.set("player_pos", global_position)
