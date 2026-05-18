class_name RVVaultHub3D
extends Node3D

func setup() -> void:
	if get_node_or_null("Floor") == null:
		var floor := MeshInstance3D.new()
		floor.name = "Floor"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(18, 0.15, 18)
		floor.mesh = mesh
		floor.position.y = -0.08
		add_child(floor)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.10, 0.085, 0.07)
		floor.material_override = mat
	if get_node_or_null("MapDevice") == null:
		var device := MeshInstance3D.new()
		device.name = "MapDevice"
		var mesh2 := CylinderMesh.new()
		mesh2.top_radius = 1.1
		mesh2.bottom_radius = 1.3
		mesh2.height = 0.7
		device.mesh = mesh2
		device.position = Vector3(0, 0.35, -3.2)
		add_child(device)
		var mat2 := StandardMaterial3D.new()
		mat2.albedo_color = Color(0.42, 0.25, 0.12)
		device.material_override = mat2

func prompt_for_player(player_pos: Vector3) -> String:
	if player_pos.distance_to(Vector3(0, 0, -3.2)) < 2.3:
		return "E/T: open map device and start a test map"
	return "Hub: run maps, manage loot, tune gems"
