class_name RVEnemyActor3D
extends Node3D

signal died(enemy: RVEnemyActor3D)

var hp: float = 42.0
var max_hp: float = 42.0
var damage: float = 10.0
var speed: float = 2.3
var radius: float = 0.45
var is_elite: bool = false
var is_boss: bool = false
var attack_cd: float = 0.0

@onready var body: MeshInstance3D = $Body

func setup(pos: Vector3, elite: bool = false, boss: bool = false) -> void:
	global_position = pos
	is_elite = elite
	is_boss = boss
	max_hp = 160.0 if boss else (82.0 if elite else 42.0)
	hp = max_hp
	damage = 22.0 if boss else (15.0 if elite else 9.0)
	speed = 1.65 if boss else (2.05 if elite else 2.45)
	_apply_visual()

func update_ai(target: Vector3, delta: float) -> void:
	attack_cd = max(0.0, attack_cd - delta)
	var to_target := target - global_position
	to_target.y = 0.0
	if to_target.length() > 0.75:
		global_position += to_target.normalized() * speed * delta
		look_at(global_position + to_target.normalized(), Vector3.UP)

func can_hit_player(player_pos: Vector3) -> bool:
	return attack_cd <= 0.0 and global_position.distance_to(player_pos) <= 1.05

func consume_attack_cd() -> void:
	attack_cd = 0.85 if not is_boss else 1.15

func take_damage(amount: float) -> void:
	hp -= max(0.0, amount)
	if hp <= 0.0:
		died.emit(self)
		queue_free()
	else:
		_apply_visual(true)

func _apply_visual(hit_flash: bool = false) -> void:
	if body == null:
		return
	var mat := StandardMaterial3D.new()
	if hit_flash:
		mat.albedo_color = Color(1.0, 0.35, 0.22)
	elif is_boss:
		mat.albedo_color = Color(0.55, 0.12, 0.08)
	elif is_elite:
		mat.albedo_color = Color(0.72, 0.36, 0.12)
	else:
		mat.albedo_color = Color(0.34, 0.26, 0.22)
	body.material_override = mat
