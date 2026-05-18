class_name RVEnemyActor3D
extends CharacterBody3D

var enemy_level: int = 1
var max_hp: float = 50.0
var hp: float = 50.0
var damage: float = 8.0
var speed: float = 2.3
var radius: float = 0.55
var is_elite: bool = false
var is_boss: bool = false
var alive: bool = true

func setup(level: int, elite: bool = false, boss: bool = false) -> void:
	enemy_level = level
	is_elite = elite
	is_boss = boss
	max_hp = (58.0 + float(level) * 12.0) * (3.0 if boss else (1.8 if elite else 1.0))
	hp = max_hp
	damage = (8.0 + float(level) * 2.0) * (1.8 if boss else (1.35 if elite else 1.0))
	speed = 1.6 if boss else (2.05 if elite else 2.35)
	_refresh_visual()

func update_ai(player_pos: Vector3, delta: float) -> void:
	if not alive:
		return
	var diff: Vector3 = player_pos - global_position
	diff.y = 0.0
	if diff.length() > 0.05:
		velocity = diff.normalized() * speed
		move_and_slide()

func take_damage(amount: float) -> bool:
	if not alive:
		return false
	hp -= max(0.0, amount)
	_refresh_visual()
	if hp <= 0.0:
		alive = false
		return true
	return false

func _refresh_visual() -> void:
	var mesh_node: MeshInstance3D = get_node_or_null("Body") as MeshInstance3D
	if mesh_node == null:
		return
	var mat := StandardMaterial3D.new()
	if is_boss:
		mat.albedo_color = Color(0.65, 0.08, 0.06)
	elif is_elite:
		mat.albedo_color = Color(0.8, 0.42, 0.12)
	else:
		mat.albedo_color = Color(0.45, 0.12, 0.08)
	mesh_node.material_override = mat
