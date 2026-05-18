class_name RVPlayerActor3D
extends CharacterBody3D

func _ready() -> void:
	if get_child_count() == 0:
		var shape := CollisionShape3D.new()
		var capsule := CapsuleShape3D.new()
		capsule.radius = 0.35
		capsule.height = 1.4
		shape.shape = capsule
		shape.position.y = 0.7
		add_child(shape)
		var mesh := MeshInstance3D.new()
		var cap_mesh := CapsuleMesh.new()
		cap_mesh.radius = 0.35
		cap_mesh.height = 1.4
		mesh.mesh = cap_mesh
		mesh.position.y = 0.7
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.86, 0.72, 0.48)
		mesh.material_override = mat
		add_child(mesh)

func move_world(input_dir: Vector3, speed: float, delta: float) -> void:
	var dir: Vector3 = input_dir
	dir.y = 0.0
	if dir.length() > 1.0:
		dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	velocity.y = 0.0
	move_and_slide()
	if dir.length() > 0.05:
		look_at(global_position + dir, Vector3.UP)
