class_name RVEnemyActor3D
extends Node3D

var data: Dictionary = {}
var hp: float = 20.0
var max_hp: float = 20.0
var damage: float = 8.0
var speed: float = 2.4
var radius: float = 0.45
var attack_cd: float = 0.0
var alive: bool = true
var is_boss: bool = false
var is_elite: bool = false

func setup(enemy_data: Dictionary) -> void:
	data = enemy_data.duplicate(true)
	max_hp = float(data.get("hp", 20.0))
	hp = max_hp
	damage = float(data.get("damage", 8.0))
	speed = float(data.get("speed", 2.4))
	radius = float(data.get("radius", 0.45))
	is_boss = bool(data.get("boss", false))
	is_elite = bool(data.get("elite", false))
	_make_visual()

func update_enemy(state: Object, player_pos: Vector3, delta: float, blockers: Array) -> void:
	if not alive:
		return
	attack_cd = max(0.0, attack_cd - delta)
	var to_player: Vector3 = player_pos - global_position
	to_player.y = 0.0
	var dist: float = to_player.length()
	if dist > 1.25:
		var dir: Vector3 = to_player.normalized()
		var old_pos: Vector3 = global_position
		var target: Vector3 = global_position + dir * speed * delta
		global_position = _constrain(target, old_pos, blockers)
		if dir.length() > 0.05:
			look_at(global_position + dir, Vector3.UP)
	elif attack_cd <= 0.0:
		attack_cd = 1.0 if not is_boss else 0.75
		if state != null and float(state.get("invuln")) <= 0.0:
			state.set("player_hp", max(0.0, float(state.get("player_hp")) - damage))
			state.set("invuln", 0.25)

func take_damage(amount: float) -> bool:
	if not alive:
		return false
	hp -= max(0.0, amount)
	_flash_hit()
	if hp <= 0.0:
		alive = false
		return true
	return false

func death_data() -> Dictionary:
	var out: Dictionary = data.duplicate(true)
	out["boss"] = is_boss
	out["elite"] = is_elite
	return out

func _constrain(target: Vector3, old_pos: Vector3, blockers: Array) -> Vector3:
	for blocker_value: Variant in blockers:
		if typeof(blocker_value) != TYPE_DICTIONARY:
			continue
		var b: Dictionary = blocker_value
		var min_v: Vector3 = Vector3(b.get("min", Vector3.ZERO))
		var max_v: Vector3 = Vector3(b.get("max", Vector3.ZERO))
		if target.x > min_v.x - radius and target.x < max_v.x + radius and target.z > min_v.z - radius and target.z < max_v.z + radius:
			return old_pos
	return target

func _make_visual() -> void:
	if has_node("Mesh"):
		return
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = 1.35 if not is_boss else 2.2
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.65, 0.18, 0.12) if not is_elite else Color(0.95, 0.45, 0.12)
	if is_boss:
		mat.albedo_color = Color(0.45, 0.06, 0.05)
	var inst := MeshInstance3D.new()
	inst.name = "Mesh"
	inst.mesh = mesh
	inst.set_surface_override_material(0, mat)
	inst.position = Vector3(0, mesh.height * 0.5, 0)
	add_child(inst)

func _flash_hit() -> void:
	var mesh: MeshInstance3D = get_node_or_null("Mesh") as MeshInstance3D
	if mesh == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.82, 0.42)
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.35, 0.05)
	mesh.set_surface_override_material(0, mat)
