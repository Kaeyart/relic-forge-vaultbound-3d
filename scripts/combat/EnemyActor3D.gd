class_name RVEnemyActor3D
extends CharacterBody3D

var alive: bool = true
var death_processed: bool = false
var enemy_level: int = 1
var is_elite: bool = false
var is_boss: bool = false
var max_hp: float = 40.0
var hp: float = 40.0
var damage: float = 8.0
var speed: float = 2.1
var radius: float = 0.45
var ignite_time: float = 0.0
var ignite_dps: float = 0.0
var bleed_time: float = 0.0
var bleed_dps: float = 0.0
var shock_time: float = 0.0
var shock_taken_more: float = 0.0

func _ready() -> void:
	if get_child_count() == 0:
		var shape := CollisionShape3D.new()
		var capsule := CapsuleShape3D.new()
		capsule.radius = radius
		capsule.height = 1.2
		shape.shape = capsule
		shape.position.y = 0.6
		add_child(shape)
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.8, 1.1, 0.8)
		mesh.mesh = box
		mesh.position.y = 0.55
		add_child(mesh)
	_update_color()

func setup(level: int, elite: bool, boss: bool) -> void:
	enemy_level = max(1, level)
	is_elite = elite
	is_boss = boss
	max_hp = 38.0 + float(enemy_level) * 9.0
	damage = 7.0 + float(enemy_level) * 1.8
	speed = 2.0 + min(1.2, float(enemy_level) * 0.04)
	if elite:
		max_hp *= 2.1
		damage *= 1.35
	if boss:
		max_hp *= 5.0
		damage *= 1.65
		speed *= 0.82
	hp = max_hp
	alive = true
	death_processed = false
	ignite_time = 0.0
	bleed_time = 0.0
	shock_time = 0.0
	_update_color()

func _update_color() -> void:
	for child: Node in get_children():
		if child is MeshInstance3D:
			var mat := StandardMaterial3D.new()
			if is_boss:
				mat.albedo_color = Color(0.85, 0.18, 0.12)
			elif is_elite:
				mat.albedo_color = Color(0.82, 0.45, 0.12)
			elif ignite_time > 0.0:
				mat.albedo_color = Color(1.0, 0.32, 0.08)
			elif shock_time > 0.0:
				mat.albedo_color = Color(0.25, 0.55, 1.0)
			elif bleed_time > 0.0:
				mat.albedo_color = Color(0.78, 0.05, 0.04)
			else:
				mat.albedo_color = Color(0.32, 0.30, 0.28)
			(child as MeshInstance3D).material_override = mat

func update_ai(player_pos: Vector3, delta: float) -> void:
	if not alive:
		return
	_tick_status(delta)
	if not alive:
		return
	var dir: Vector3 = player_pos - global_position
	dir.y = 0.0
	if dir.length() > 0.75:
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		velocity.y = 0.0
		move_and_slide()
		look_at(global_position + dir, Vector3.UP)
	else:
		velocity = Vector3.ZERO

func _tick_status(delta: float) -> void:
	var dot_damage: float = 0.0
	if ignite_time > 0.0:
		ignite_time = max(0.0, ignite_time - delta)
		dot_damage += ignite_dps * delta
	if bleed_time > 0.0:
		bleed_time = max(0.0, bleed_time - delta)
		dot_damage += bleed_dps * delta
	if shock_time > 0.0:
		shock_time = max(0.0, shock_time - delta)
		if shock_time <= 0.0:
			shock_taken_more = 0.0
	if dot_damage > 0.0:
		take_damage(dot_damage)
	_update_color()

func apply_status(kind: String, source_damage: float) -> void:
	match kind:
		"ignite":
			ignite_time = max(ignite_time, 3.0)
			ignite_dps = max(ignite_dps, max(1.0, source_damage * 0.18))
		"bleed":
			bleed_time = max(bleed_time, 4.0)
			bleed_dps = max(bleed_dps, max(1.0, source_damage * 0.14))
		"shock":
			shock_time = max(shock_time, 3.0)
			shock_taken_more = max(shock_taken_more, 0.18)
	_update_color()

func take_damage(amount: float) -> bool:
	if not alive:
		return false

	var safe_amount: float = maxf(0.0, amount)
	var shock_multiplier: float = 1.0 + shock_taken_more
	var final_amount: float = safe_amount * shock_multiplier

	hp -= final_amount

	if hp <= 0.0:
		alive = false

	return true

func health_ratio() -> float:
	if max_hp <= 0.0:
		return 0.0
	return clampf(hp / max_hp, 0.0, 1.0)
