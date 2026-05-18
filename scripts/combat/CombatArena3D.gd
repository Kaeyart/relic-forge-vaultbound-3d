class_name RVCombatArena3D
extends Node3D

const EnemyScene := preload("res://scenes/prefabs/enemies/Enemy3D.tscn")
const ProjectileScene := preload("res://scenes/prefabs/projectiles/Projectile3D.tscn")
const LootSystemScript := preload("res://scripts/systems/LootSystem3D.gd")

var enemies_root: Node3D
var projectiles_root: Node3D
var decor_root: Node3D
var active: bool = false
var room_clear: bool = false
var map_level: int = 1
var exit_pos: Vector3 = Vector3(0, 0, 8)

func _ready() -> void:
	_ensure_roots()

func _ensure_roots() -> void:
	decor_root = get_node_or_null("DecorRoot") as Node3D
	if decor_root == null:
		decor_root = Node3D.new()
		decor_root.name = "DecorRoot"
		add_child(decor_root)
	enemies_root = get_node_or_null("EnemiesRoot") as Node3D
	if enemies_root == null:
		enemies_root = Node3D.new()
		enemies_root.name = "EnemiesRoot"
		add_child(enemies_root)
	projectiles_root = get_node_or_null("ProjectilesRoot") as Node3D
	if projectiles_root == null:
		projectiles_root = Node3D.new()
		projectiles_root.name = "ProjectilesRoot"
		add_child(projectiles_root)

func start_map(state: Object, activity: Dictionary = {}) -> void:
	_ensure_roots()
	active = true
	room_clear = false
	map_level = max(1, int(activity.get("map_level", state.get("level") if state != null else 1)))
	visible = true
	_clear_children(enemies_root)
	_clear_children(projectiles_root)
	_clear_children(decor_root)
	_build_arena()
	_spawn_pack(Vector3(-5, 0, -4), 4, false)
	_spawn_pack(Vector3(5, 0, -2), 4, false)
	_spawn_pack(Vector3(-3, 0, 3), 3, true)
	_spawn_enemy(Vector3(0, 0, 6), true, true)

func stop_map() -> void:
	active = false
	visible = false
	_clear_children(enemies_root)
	_clear_children(projectiles_root)

func update_combat(state: Object, player: Node3D, delta: float) -> void:
	if not active or state == null or player == null:
		return
	var player_pos: Vector3 = player.global_position
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D:
			var enemy: RVEnemyActor3D = enemy_node
			enemy.update_ai(player_pos, delta)
			if enemy.alive and enemy.global_position.distance_to(player_pos) < 0.85:
				state.set("player_hp", max(0.0, float(state.get("player_hp")) - enemy.damage * delta))
				if float(state.get("player_hp")) <= 0.0:
					state.set("deaths", int(state.get("deaths")) + 1)
					state.call("add_notice", "You died. Returning to hub.")
	for projectile_node: Node in projectiles_root.get_children():
		if projectile_node is RVProjectileActor3D:
			_check_projectile_hits(projectile_node as RVProjectileActor3D, state)
	if _living_enemy_count() <= 0 and not room_clear:
		room_clear = true
		state.call("add_notice", "Map clear. Press E to return.")

func cast_skill(state: Object, origin: Vector3, aim_world: Vector3, cast_data: Dictionary) -> void:
	if cast_data.is_empty():
		return
	var dir: Vector3 = aim_world - origin
	dir.y = 0.0
	if dir.length() < 0.05:
		dir = Vector3.FORWARD
	dir = dir.normalized()
	var active_id: String = str(cast_data.get("active_id", ""))
	match active_id:
		"fireball":
			_spawn_projectile(origin + dir * 0.9 + Vector3.UP * 0.45, dir, cast_data)
			var extra: int = int(cast_data.get("extra_projectiles", 0))
			var angles: Array[float] = [-0.22, 0.22, -0.38, 0.38]
			for i: int in range(min(extra, angles.size())):
				_spawn_projectile(origin + dir * 0.9 + Vector3.UP * 0.45, dir.rotated(Vector3.UP, angles[i]), cast_data)
		"storm_lance":
			_damage_line(origin, dir, 8.0, 0.7, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])))
		"arc_slash":
			_damage_cone(origin, dir, 2.4 * float(cast_data.get("area_mult", 1.0)), 1.4, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])))
		"void_rift":
			_damage_area(aim_world, 2.1 * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])))
			if int(cast_data.get("echo_count", 0)) > 0:
				_damage_area(aim_world + dir * 0.9, 1.6 * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)) * 0.45, state, Array(cast_data.get("tags", [])))
		"ember_mine":
			_damage_area(origin + dir * 2.2, 2.0 * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])))
		_:
			_spawn_projectile(origin + dir * 0.9 + Vector3.UP * 0.45, dir, cast_data)

func _spawn_projectile(pos: Vector3, dir: Vector3, cast_data: Dictionary) -> void:
	var projectile: RVProjectileActor3D = ProjectileScene.instantiate()
	projectiles_root.add_child(projectile)
	projectile.setup(pos, dir.normalized() * 13.0, float(cast_data.get("damage", 1.0)), 0.45, Array(cast_data.get("tags", [])))

func _check_projectile_hits(projectile: RVProjectileActor3D, state: Object) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if not (enemy_node is RVEnemyActor3D):
			continue
		var enemy: RVEnemyActor3D = enemy_node
		if not enemy.alive:
			continue
		if projectile.global_position.distance_to(enemy.global_position + Vector3.UP * 0.55) <= projectile.radius + enemy.radius:
			_damage_enemy(enemy, projectile.damage, state, projectile.tags)
			projectile.queue_free()
			return

func _damage_line(origin: Vector3, dir: Vector3, length: float, width: float, damage: float, state: Object, tags: Array) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D:
			var enemy: RVEnemyActor3D = enemy_node
			var rel: Vector3 = enemy.global_position - origin
			rel.y = 0.0
			var along: float = rel.dot(dir)
			if along >= 0.0 and along <= length:
				var closest: Vector3 = origin + dir * along
				if closest.distance_to(enemy.global_position) <= width:
					_damage_enemy(enemy, damage, state, tags)

func _damage_cone(origin: Vector3, dir: Vector3, radius: float, half_width: float, damage: float, state: Object, tags: Array) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D:
			var enemy: RVEnemyActor3D = enemy_node
			var rel: Vector3 = enemy.global_position - origin
			rel.y = 0.0
			if rel.length() <= radius and rel.normalized().dot(dir) > 0.35:
				_damage_enemy(enemy, damage, state, tags)

func _damage_area(center: Vector3, radius: float, damage: float, state: Object, tags: Array) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D:
			var enemy: RVEnemyActor3D = enemy_node
			if enemy.global_position.distance_to(Vector3(center.x, enemy.global_position.y, center.z)) <= radius:
				_damage_enemy(enemy, damage, state, tags)

func _damage_enemy(enemy: RVEnemyActor3D, damage: float, state: Object, tags: Array) -> void:
	if enemy.take_damage(damage):
		_on_enemy_died(enemy, state)

func _on_enemy_died(enemy: RVEnemyActor3D, state: Object) -> void:
	state.call("on_enemy_killed", enemy.enemy_level, enemy.is_elite, enemy.is_boss)
	var drops: Array[Dictionary] = LootSystemScript.enemy_drop_bundle(state, enemy.enemy_level, enemy.is_elite, enemy.is_boss)
	for drop: Dictionary in drops:
		LootSystemScript.apply_drop_to_state(state, drop)
	if enemy.is_boss:
		var completed: Dictionary = Dictionary(state.get("completed_maps"))
		completed["ash_vault"] = true
		state.set("completed_maps", completed)
	enemy.queue_free()

func constrain_player_position(pos: Vector3) -> Vector3:
	return Vector3(clampf(pos.x, -8.5, 8.5), 0.0, clampf(pos.z, -8.5, 8.5))

func _living_enemy_count() -> int:
	var count: int = 0
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node is RVEnemyActor3D and (enemy_node as RVEnemyActor3D).alive:
			count += 1
	return count

func _spawn_pack(center: Vector3, count: int, elite: bool) -> void:
	for i: int in range(count):
		_spawn_enemy(center + Vector3(randf_range(-1.6, 1.6), 0, randf_range(-1.6, 1.6)), elite and i == 0, false)

func _spawn_enemy(pos: Vector3, elite: bool, boss: bool) -> void:
	var enemy: RVEnemyActor3D = EnemyScene.instantiate()
	enemies_root.add_child(enemy)
	enemy.global_position = pos
	enemy.setup(map_level, elite, boss)

func _build_arena() -> void:
	# Patch 087I: build arena props with valid Node3D data and real static bodies.
	# The previous version accidentally read `w.z` from a MeshInstance3D instead of
	# reading the loop Vector3, causing a runtime crash when starting maps.
	_make_box_prop("ArenaFloor", Vector3(0.0, -0.08, 0.0), Vector3(20.0, 0.15, 20.0), Color(0.12, 0.10, 0.085), true)
	_make_box_prop("NorthWall", Vector3(0.0, 0.8, -10.0), Vector3(20.0, 1.8, 0.4), Color(0.18, 0.14, 0.11), true)
	_make_box_prop("SouthWall", Vector3(0.0, 0.8, 10.0), Vector3(20.0, 1.8, 0.4), Color(0.18, 0.14, 0.11), true)
	_make_box_prop("WestWall", Vector3(-10.0, 0.8, 0.0), Vector3(0.4, 1.8, 20.0), Color(0.18, 0.14, 0.11), true)
	_make_box_prop("EastWall", Vector3(10.0, 0.8, 0.0), Vector3(0.4, 1.8, 20.0), Color(0.18, 0.14, 0.11), true)

	# A few simple internal blockers so the 3D arena starts feeling less like an empty box.
	_make_box_prop("VaultBlockerA", Vector3(-3.0, 0.45, 1.2), Vector3(2.0, 0.9, 1.4), Color(0.20, 0.16, 0.12), true)
	_make_box_prop("VaultBlockerB", Vector3(3.2, 0.45, -1.8), Vector3(1.6, 0.9, 2.2), Color(0.20, 0.16, 0.12), true)
	_make_box_prop("EmberMarkerA", Vector3(-6.5, 0.08, -6.5), Vector3(0.9, 0.16, 0.9), Color(0.85, 0.28, 0.08), false)
	_make_box_prop("EmberMarkerB", Vector3(6.5, 0.08, 6.5), Vector3(0.9, 0.16, 0.9), Color(0.85, 0.28, 0.08), false)

func _make_box_prop(prop_name: String, prop_position: Vector3, prop_size: Vector3, color: Color, solid: bool) -> Node3D:
	var root: Node3D
	if solid:
		var body := StaticBody3D.new()
		root = body
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = prop_size
		collision.shape = shape
		body.add_child(collision)
	else:
		root = Node3D.new()
	root.name = prop_name
	root.position = prop_position
	decor_root.add_child(root)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = prop_name + "Mesh"
	var mesh := BoxMesh.new()
	mesh.size = prop_size
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_instance.material_override = mat
	root.add_child(mesh_instance)
	return root

func _clear_children(root: Node) -> void:
	for child: Node in root.get_children():
		child.queue_free()
