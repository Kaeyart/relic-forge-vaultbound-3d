class_name RVCombatArena3D
extends Node3D

@export var enemy_scene: PackedScene
@export var projectile_scene: PackedScene

var active: bool = false
var room_clear: bool = false
var objective: String = ""

@onready var enemies_root: Node3D = $Enemies
@onready var projectiles_root: Node3D = $Projectiles
@onready var exit_portal: Area3D = $ExitPortal
@onready var floor_mesh: MeshInstance3D = $ArenaFloor

func start_activity(state: RVGameState3D, activity: Dictionary = {}) -> void:
	active = true
	visible = true
	room_clear = false
	objective = "Clear the vault field"
	_clear_children(enemies_root)
	_clear_children(projectiles_root)
	state.mode = "combat"
	state.current_activity = activity.duplicate(true)
	state.player_pos = Vector3(0, 0, 0)
	_spawn_pack()
	if exit_portal != null:
		exit_portal.visible = false

func stop_activity() -> void:
	active = false
	visible = false
	_clear_children(projectiles_root)

func update_combat(state: RVGameState3D, player: RVPlayerActor3D, delta: float) -> void:
	if not active or state == null or player == null:
		return
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D:
			var enemy := enemy_node as RVEnemyActor3D
			enemy.update_ai(state.player_pos, delta)
			enemy.global_position = _clamp_to_arena(enemy.global_position)
			if enemy.can_hit_player(state.player_pos):
				enemy.consume_attack_cd()
				_damage_player(state, enemy.damage)
	for projectile_node: Node in projectiles_root.get_children():
		if projectile_node is RVProjectileActor3D:
			var projectile := projectile_node as RVProjectileActor3D
			if not projectile.tick(delta):
				projectile.queue_free()
				continue
			_check_projectile_hits(projectile, state)
	if enemies_root.get_child_count() == 0 and not room_clear:
		room_clear = true
		state.add_notice("Map cleared")
		_spawn_reward(state)
		if exit_portal != null:
			exit_portal.visible = true

func constrain_player_position(pos: Vector3) -> Vector3:
	return _clamp_to_arena(pos)

func cast_selected_skill(state: RVGameState3D, from_pos: Vector3, aim_world: Vector3) -> void:
	if state == null:
		return
	var skill := state.get_selected_skill()
	var direction := aim_world - from_pos
	direction.y = 0.0
	if direction.length() < 0.05:
		direction = Vector3.FORWARD
	direction = direction.normalized()
	var base_damage := 22.0 + float(state.level) * 3.0
	match skill:
		"Cleave":
			_damage_enemies_in_radius(from_pos + direction * 1.05, 1.55, base_damage * 1.35)
		"Frost Nova":
			_damage_enemies_in_radius(from_pos, 2.3, base_damage * 0.95)
		"Void Rift":
			_damage_enemies_in_radius(aim_world, 1.65, base_damage * 1.15)
		"Blade Trap":
			_damage_enemies_in_radius(aim_world, 1.25, base_damage * 1.05)
		"Storm Lance":
			_damage_enemies_along_line(from_pos, from_pos + direction * 9.0, 0.62, base_damage * 1.12)
		_:
			_spawn_projectile(from_pos + direction * 0.75 + Vector3.UP * 0.6, direction * 12.0, base_damage, 0.38)

func interact(state: RVGameState3D) -> bool:
	if state == null:
		return false
	if room_clear and state.player_pos.distance_to(exit_portal.global_position) <= 2.25:
		return true
	return false

func _spawn_pack() -> void:
	var positions: Array[Vector3] = [
		Vector3(-7, 0, -5), Vector3(-4, 0, -7), Vector3(0, 0, -8), Vector3(5, 0, -5),
		Vector3(7, 0, 1), Vector3(-7, 0, 3), Vector3(-2, 0, 6), Vector3(4, 0, 6),
	]
	for i: int in range(positions.size()):
		_spawn_enemy(positions[i], i == 2 or i == 5, false)
	_spawn_enemy(Vector3(0, 0, 8), false, true)

func _spawn_enemy(pos: Vector3, elite: bool, boss: bool) -> void:
	if enemy_scene == null:
		return
	var enemy := enemy_scene.instantiate() as RVEnemyActor3D
	enemies_root.add_child(enemy)
	enemy.setup(pos, elite, boss)
	enemy.died.connect(_on_enemy_died)

func _spawn_projectile(pos: Vector3, vel: Vector3, damage: float, radius: float) -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as RVProjectileActor3D
	projectiles_root.add_child(projectile)
	projectile.setup(pos, vel, damage, radius)

func _check_projectile_hits(projectile: RVProjectileActor3D, state: RVGameState3D) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D:
			var enemy := enemy_node as RVEnemyActor3D
			if projectile.global_position.distance_to(enemy.global_position + Vector3.UP * 0.5) <= projectile.radius + enemy.radius:
				enemy.take_damage(projectile.damage)
				projectile.queue_free()
				return

func _damage_enemies_in_radius(center: Vector3, radius: float, damage: float) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D:
			var enemy := enemy_node as RVEnemyActor3D
			if enemy.global_position.distance_to(center) <= radius + enemy.radius:
				enemy.take_damage(damage)

func _damage_enemies_along_line(a: Vector3, b: Vector3, width: float, damage: float) -> void:
	var ab := b - a
	var ab_len_sq := max(0.001, ab.length_squared())
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D:
			var enemy := enemy_node as RVEnemyActor3D
			var ap := enemy.global_position - a
			var t := clamp(ap.dot(ab) / ab_len_sq, 0.0, 1.0)
			var closest := a + ab * t
			if closest.distance_to(enemy.global_position) <= width + enemy.radius:
				enemy.take_damage(damage)

func _damage_player(state: RVGameState3D, damage: float) -> void:
	state.player_hp -= damage
	if state.player_hp <= 0.0:
		state.deaths += 1
		state.player_hp = state.max_hp
		state.player_pos = Vector3.ZERO
		state.add_notice("Death test: restored at entrance")

func _on_enemy_died(enemy: RVEnemyActor3D) -> void:
	var root := get_tree().current_scene
	if root != null and root.has_method("on_enemy_killed_3d"):
		root.call("on_enemy_killed_3d", enemy.is_elite, enemy.is_boss)

func _spawn_reward(state: RVGameState3D) -> void:
	state.backpack.append({"name": "Vault-Test Rare", "type": "weapon", "rarity": "Rare", "item_level": max(1, state.level), "forge_potential": 18})
	state.gold += 35

func _clear_children(root: Node) -> void:
	for child: Node in root.get_children():
		child.queue_free()

func _clamp_to_arena(pos: Vector3) -> Vector3:
	return Vector3(clamp(pos.x, -11.5, 11.5), pos.y, clamp(pos.z, -9.5, 9.5))
