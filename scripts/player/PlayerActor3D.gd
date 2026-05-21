class_name RVPlayerActor3D
extends CharacterBody3D

const DEFAULT_HEIGHT: float = 1.45
const DEFAULT_RADIUS: float = 0.36
const DASH_MULT: float = 2.35
const DASH_TIME: float = 0.16
const DASH_COOLDOWN: float = 0.58

var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _dash_dir: Vector3 = Vector3.ZERO
var _visual_root: Node3D = null
var _body_mesh: MeshInstance3D = null
var _accent_mesh: MeshInstance3D = null

func _ready() -> void:
	_build_actor_if_needed()

func move_world(input_dir: Vector3, speed: float, delta: float) -> void:
	_build_actor_if_needed()
	_dash_cooldown_timer = maxf(0.0, _dash_cooldown_timer - delta)

	var dir: Vector3 = input_dir
	dir.y = 0.0
	if dir.length() > 1.0:
		dir = dir.normalized()

	if _dash_timer <= 0.0 and dir.length() > 0.05 and (Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL)) and _dash_cooldown_timer <= 0.0:
		_dash_timer = DASH_TIME
		_dash_cooldown_timer = DASH_COOLDOWN
		_dash_dir = dir.normalized()

	var move_dir: Vector3 = dir
	var move_speed: float = speed
	if _dash_timer > 0.0:
		_dash_timer = maxf(0.0, _dash_timer - delta)
		move_dir = _dash_dir
		move_speed = speed * DASH_MULT
		_set_dash_visual(true)
	else:
		_set_dash_visual(false)

	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed
	velocity.y = 0.0
	move_and_slide()

	if move_dir.length() > 0.05:
		look_at(global_position + move_dir, Vector3.UP)

func is_dashing() -> bool:
	return _dash_timer > 0.0

func _build_actor_if_needed() -> void:
	if _visual_root != null and is_instance_valid(_visual_root):
		return

	for child: Node in get_children():
		child.queue_free()

	var shape := CollisionShape3D.new()
	shape.name = "PlayerCollision"
	var capsule := CapsuleShape3D.new()
	capsule.radius = DEFAULT_RADIUS
	capsule.height = DEFAULT_HEIGHT
	shape.shape = capsule
	shape.position.y = DEFAULT_HEIGHT * 0.5
	add_child(shape)

	_visual_root = Node3D.new()
	_visual_root.name = "PlayerVisualRoot"
	add_child(_visual_root)

	_body_mesh = MeshInstance3D.new()
	_body_mesh.name = "SorceressBody"
	var cap_mesh := CapsuleMesh.new()
	cap_mesh.radius = DEFAULT_RADIUS
	cap_mesh.height = DEFAULT_HEIGHT
	_body_mesh.mesh = cap_mesh
	_body_mesh.position.y = DEFAULT_HEIGHT * 0.5
	_body_mesh.material_override = _material(Color(0.78, 0.58, 0.96))
	_visual_root.add_child(_body_mesh)

	_accent_mesh = MeshInstance3D.new()
	_accent_mesh.name = "CombatReadabilityHalo"
	var halo := TorusMesh.new()
	halo.inner_radius = 0.44
	halo.outer_radius = 0.50
	_accent_mesh.mesh = halo
	_accent_mesh.position.y = 0.04
	_accent_mesh.scale = Vector3(1.0, 0.04, 1.0)
	_accent_mesh.material_override = _material(Color(0.24, 0.75, 1.0, 0.65))
	_visual_root.add_child(_accent_mesh)

func _set_dash_visual(active: bool) -> void:
	if _body_mesh == null or not is_instance_valid(_body_mesh):
		return
	if active:
		_body_mesh.scale = _body_mesh.scale.lerp(Vector3(0.82, 1.05, 1.22), 0.35)
	else:
		_body_mesh.scale = _body_mesh.scale.lerp(Vector3.ONE, 0.22)

func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.75
	return mat
