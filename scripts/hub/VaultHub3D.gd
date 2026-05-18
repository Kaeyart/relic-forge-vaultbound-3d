class_name RVVaultHub3D
extends Node3D

var map_device_pos: Vector3 = Vector3(0.0, 0.0, -4.0)
var stash_pos: Vector3 = Vector3(-4.5, 0.0, 1.0)
var forge_pos: Vector3 = Vector3(4.5, 0.0, 1.0)
var _built: bool = false

func _ready() -> void:
	_build_once()

func update_focus(state: Object, player_pos: Vector3) -> void:
	if state == null:
		return
	var nearest_name: String = ""
	var nearest_dist: float = 999.0
	for entry: Dictionary in [
		{"name": "Map Device", "pos": map_device_pos, "prompt": "E: open Ash Vault map"},
		{"name": "Stash", "pos": stash_pos, "prompt": "Stash placeholder"},
		{"name": "Forge", "pos": forge_pos, "prompt": "Forge placeholder"}
	]:
		var d: float = player_pos.distance_to(Vector3(entry["pos"]))
		if d < nearest_dist:
			nearest_dist = d
			nearest_name = str(entry.get("prompt", ""))
	if nearest_dist <= 2.2:
		state.set("prompt_text", nearest_name)
	else:
		state.set("prompt_text", "Approach the map device and press E, or press T to run a test map.")

func player_near_map_device(player_pos: Vector3) -> bool:
	return player_pos.distance_to(map_device_pos) <= 2.2

func _build_once() -> void:
	if _built:
		return
	_built = true
	_add_box("HubFloor", Vector3(0, -0.06, 0), Vector3(18, 0.1, 14), Color(0.12, 0.10, 0.085))
	_add_box("MapDevice", map_device_pos + Vector3(0, 0.45, 0), Vector3(1.7, 0.9, 1.7), Color(0.85, 0.42, 0.16))
	_add_box("Stash", stash_pos + Vector3(0, 0.45, 0), Vector3(1.5, 0.9, 1.1), Color(0.35, 0.23, 0.12))
	_add_box("Forge", forge_pos + Vector3(0, 0.45, 0), Vector3(1.5, 0.9, 1.1), Color(0.7, 0.16, 0.08))
	for i: int in range(8):
		var x: float = -8.5 + float(i) * 2.4
		_add_box("Pillar" + str(i), Vector3(x, 0.8, 6.7), Vector3(0.45, 1.6, 0.45), Color(0.24, 0.21, 0.18))

func _add_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	var inst := MeshInstance3D.new()
	inst.name = node_name
	inst.mesh = mesh
	inst.set_surface_override_material(0, mat)
	inst.position = pos
	add_child(inst)
	return inst
