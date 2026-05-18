class_name RVCombatArena3D
extends Node3D

const EnemyScene := preload("res://scenes/prefabs/enemies/Enemy3D.tscn")
const ProjectileScene := preload("res://scenes/prefabs/projectiles/Projectile3D.tscn")
const LootActorScene := preload("res://scenes/prefabs/loot/LootActor3D.tscn")
const LootSystemScript := preload("res://scripts/systems/LootSystem3D.gd")
const LootPickupSystemScript := preload("res://scripts/systems/LootPickupSystem3D.gd")
const MapLoopSystemScript := preload("res://scripts/systems/MapLoopSystem3D.gd")

var enemies_root: Node3D
var projectiles_root: Node3D
var decor_root: Node3D
var loot_root: Node3D
var active: bool = false
var room_clear: bool = false
var boss_reward_spawned: bool = false
var map_level: int = 1
var exit_pos: Vector3 = Vector3(0, 0, 8)

func _ready() -> void:
	_ensure_roots()
	visible = false

func _ensure_roots() -> void:
	decor_root = _root("DecorRoot")
	enemies_root = _root("EnemiesRoot")
	projectiles_root = _root("ProjectilesRoot")
	loot_root = _root("LootRoot")

func _root(node_name: String) -> Node3D:
	var found := get_node_or_null(node_name) as Node3D
	if found != null: return found
	var n := Node3D.new()
	n.name = node_name
	add_child(n)
	return n

func start_map(state: Object, activity: Dictionary = {}) -> void:
	_ensure_roots()
	active = true
	room_clear = false
	boss_reward_spawned = false
	map_level = max(1, int(activity.get("map_level", state.get("level") if state != null else 1)))
	visible = true
	_clear_children(enemies_root)
	_clear_children(projectiles_root)
	_clear_children(decor_root)
	_clear_children(loot_root)
	_build_arena(str(activity.get("layout", "box_blockers")))
	var pack_bonus: int = int(round(float(_map_stat(activity, "Pack Size")) * 10.0))
	_spawn_pack(Vector3(-5, 0, -4), 4 + pack_bonus, false)
	_spawn_pack(Vector3(5, 0, -2), 4, false)
	_spawn_pack(Vector3(-3, 0, 3), 3, true)
	_spawn_enemy(Vector3(0, 0, 6), true, true)

func stop_map() -> void:
	active = false
	visible = false
	_clear_children(enemies_root)
	_clear_children(projectiles_root)
	_clear_children(loot_root)

func update_combat(state: Object, player: Node3D, delta: float) -> void:
	if not active or state == null or player == null:
		return
	var player_pos: Vector3 = player.global_position
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node != null and enemy_node.has_method("update_ai"):
			enemy_node.call("update_ai", player_pos, delta)
			if bool(enemy_node.get("alive")) and (enemy_node as Node3D).global_position.distance_to(player_pos) < 0.9:
				var armor: float = float(state.get("armor"))
				var mitigation: float = armor / (armor + 160.0)
				var dmg: float = float(enemy_node.get("damage")) * (1.0 - mitigation)
				state.set("player_hp", max(0.0, float(state.get("player_hp")) - dmg * delta))
				if float(state.get("player_hp")) <= 0.0:
					state.set("deaths", int(state.get("deaths")) + 1)
					state.call("add_notice", "You died. Press T to return to hub.")
	for projectile_node: Node in projectiles_root.get_children():
		if projectile_node != null and projectile_node.has_method("update_projectile"):
			projectile_node.call("update_projectile", delta)
			_check_projectile_hits(projectile_node, state)
	for loot_node: Node in loot_root.get_children():
		if loot_node == null or not is_instance_valid(loot_node): continue
		var drop: Dictionary = Dictionary(loot_node.get("drop_data"))
		if LootPickupSystemScript.player_can_auto_pick(drop) and (loot_node as Node3D).global_position.distance_to(player_pos) < 1.2:
			LootPickupSystemScript.apply_pickup(state, loot_node)
	if _living_enemy_count() <= 0 and not room_clear:
		room_clear = true
		MapLoopSystemScript.complete_current_map(state)
		_spawn_boss_reward_pile(state, Vector3(0, 0, 5.2))
		state.call("add_notice", "Map clear. Press E to return or collect loot.")

func cast_skill(state: Object, origin: Vector3, aim_world: Vector3, cast_data: Dictionary) -> void:
	if cast_data.is_empty(): return
	var mana_cost: float = float(cast_data.get("mana_cost", 0.0))
	if not bool(state.call("spend_mana", mana_cost)): return
	var dir: Vector3 = aim_world - origin
	dir.y = 0.0
	if dir.length() < 0.05: dir = -global_transform.basis.z
	dir = dir.normalized()
	var active_id: String = str(cast_data.get("active_id", ""))
	match active_id:
		"fireball":
			_spawn_projectile(origin + dir * 0.9 + Vector3.UP * 0.55, dir, cast_data)
			var extra: int = int(cast_data.get("extra_projectiles", 0))
			var angles: Array[float] = [-0.22, 0.22, -0.38, 0.38]
			for i: int in range(min(extra, angles.size())):
				_spawn_projectile(origin + dir * 0.9 + Vector3.UP * 0.55, dir.rotated(Vector3.UP, angles[i]), cast_data)
		"storm_lance":
			_damage_line(origin, dir, 9.0, 0.75, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])))
		"arc_slash":
			_damage_cone(origin, dir, 2.6 * float(cast_data.get("area_mult", 1.0)), 1.4, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])))
		"void_rift":
			_damage_area(aim_world, 2.2 * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])))
			if int(cast_data.get("echo_count", 0)) > 0:
				_damage_area(aim_world + dir * 0.9, 1.6 * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)) * 0.48, state, Array(cast_data.get("tags", [])))
		"ember_mine":
			_damage_area(origin + dir * 2.4, 2.0 * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])))
		_:
			_spawn_projectile(origin + dir * 0.9 + Vector3.UP * 0.55, dir, cast_data)

func _spawn_projectile(pos: Vector3, dir: Vector3, cast_data: Dictionary) -> void:
	var projectile: Node = ProjectileScene.instantiate()
	projectiles_root.add_child(projectile)
	projectile.call("setup", pos, dir.normalized() * 13.5, float(cast_data.get("damage", 1.0)), 0.42, Array(cast_data.get("tags", [])))

func _check_projectile_hits(projectile: Node, state: Object) -> void:
	if projectile == null or not is_instance_valid(projectile): return
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")): continue
		var enemy_pos: Vector3 = (enemy_node as Node3D).global_position + Vector3.UP * 0.55
		if (projectile as Node3D).global_position.distance_to(enemy_pos) <= float(projectile.get("radius")) + float(enemy_node.get("radius")):
			_damage_enemy(enemy_node, float(projectile.get("damage")), state, Array(projectile.get("tags")))
			projectile.queue_free()
			return

func _damage_line(origin: Vector3, dir: Vector3, length: float, width: float, damage: float, state: Object, tags: Array) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")): continue
		var rel: Vector3 = (enemy_node as Node3D).global_position - origin
		rel.y = 0.0
		var along: float = rel.dot(dir)
		if along >= 0.0 and along <= length:
			var closest: Vector3 = origin + dir * along
			if closest.distance_to((enemy_node as Node3D).global_position) <= width:
				_damage_enemy(enemy_node, damage, state, tags)

func _damage_cone(origin: Vector3, dir: Vector3, radius: float, half_width: float, damage: float, state: Object, tags: Array) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")): continue
		var rel: Vector3 = (enemy_node as Node3D).global_position - origin
		rel.y = 0.0
		if rel.length() <= radius and rel.normalized().dot(dir) > 0.28:
			_damage_enemy(enemy_node, damage, state, tags)

func _damage_area(center: Vector3, radius: float, damage: float, state: Object, tags: Array) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")): continue
		var flat_center: Vector3 = Vector3(center.x, (enemy_node as Node3D).global_position.y, center.z)
		if (enemy_node as Node3D).global_position.distance_to(flat_center) <= radius:
			_damage_enemy(enemy_node, damage, state, tags)

func _damage_enemy(enemy: Node, damage: float, state: Object, tags: Array) -> void:
	if bool(enemy.call("take_damage", damage)):
		_on_enemy_died(enemy, state)

func _on_enemy_died(enemy: Node, state: Object) -> void:
	state.call("on_enemy_killed", int(enemy.get("enemy_level")), bool(enemy.get("is_elite")), bool(enemy.get("is_boss")))
	var drops: Array[Dictionary] = LootSystemScript.enemy_drop_bundle(state, int(enemy.get("enemy_level")), bool(enemy.get("is_elite")), bool(enemy.get("is_boss")))
	_spawn_drops(drops, (enemy as Node3D).global_position)
	enemy.queue_free()

func _spawn_boss_reward_pile(state: Object, pos: Vector3) -> void:
	if boss_reward_spawned: return
	boss_reward_spawned = true
	_spawn_drops(LootSystemScript.boss_reward_bundle(state, map_level), pos)

func _spawn_drops(drops: Array, center: Vector3) -> void:
	var i: int = 0
	for drop: Dictionary in drops:
		var loot: Node = LootActorScene.instantiate()
		loot_root.add_child(loot)
		var angle: float = float(i) * 1.37
		var offset: Vector3 = Vector3(cos(angle), 0, sin(angle)) * (0.7 + 0.18 * float(i))
		loot.call("setup", drop, center + offset + Vector3.UP * 0.15)
		i += 1

func manual_pickup_near(state: Object, player_pos: Vector3) -> bool:
	var best: Node = null
	var best_dist: float = 9999.0
	for loot_node: Node in loot_root.get_children():
		if loot_node == null or not is_instance_valid(loot_node): continue
		var dist: float = (loot_node as Node3D).global_position.distance_to(player_pos)
		if dist < best_dist and dist <= 2.1:
			best = loot_node
			best_dist = dist
	if best != null:
		LootPickupSystemScript.apply_pickup(state, best)
		return true
	return false

func loot_nodes() -> Array:
	return loot_root.get_children() if loot_root != null else []

func constrain_player_position(pos: Vector3) -> Vector3:
	return Vector3(clampf(pos.x, -8.7, 8.7), 0.0, clampf(pos.z, -8.7, 8.7))

func _living_enemy_count() -> int:
	var count: int = 0
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node != null and bool(enemy_node.get("alive")):
			count += 1
	return count

func _spawn_pack(center: Vector3, count: int, elite: bool) -> void:
	for i: int in range(count):
		_spawn_enemy(center + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5)), elite and i == 0, false)

func _spawn_enemy(pos: Vector3, elite: bool, boss: bool) -> void:
	var enemy: Node = EnemyScene.instantiate()
	enemies_root.add_child(enemy)
	(enemy as Node3D).global_position = pos
	enemy.call("setup", map_level, elite, boss)

func _map_stat(activity: Dictionary, stat_name: String) -> float:
	var total: float = 0.0
	for mod: Dictionary in Array(activity.get("mods", [])):
		total += float(Dictionary(mod.get("stats", {})).get(stat_name, 0.0))
	return total

func _build_arena(layout: String) -> void:
	_make_box_prop("ArenaFloor", Vector3(0, -0.08, 0), Vector3(20, 0.15, 20), Color(0.12, 0.10, 0.085), false)
	_make_box_prop("WallNorth", Vector3(0, 0.8, -10), Vector3(20, 1.8, 0.4), Color(0.18, 0.14, 0.11), true)
	_make_box_prop("WallSouth", Vector3(0, 0.8, 10), Vector3(20, 1.8, 0.4), Color(0.18, 0.14, 0.11), true)
	_make_box_prop("WallWest", Vector3(-10, 0.8, 0), Vector3(0.4, 1.8, 20), Color(0.18, 0.14, 0.11), true)
	_make_box_prop("WallEast", Vector3(10, 0.8, 0), Vector3(0.4, 1.8, 20), Color(0.18, 0.14, 0.11), true)
	_make_box_prop("BlockerA", Vector3(-2.5, 0.45, 0.5), Vector3(1.2, 0.9, 4.0), Color(0.23, 0.17, 0.13), true)
	_make_box_prop("BlockerB", Vector3(3.2, 0.45, -1.8), Vector3(1.2, 0.9, 3.2), Color(0.23, 0.17, 0.13), true)
	if layout == "ring":
		_make_box_prop("CenterBlock", Vector3(0, 0.5, 0), Vector3(2.4, 1.0, 2.4), Color(0.28, 0.18, 0.12), true)

func _make_box_prop(prop_name: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> void:
	var root: Node3D
	if solid:
		var body := StaticBody3D.new()
		root = body
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
	else:
		root = Node3D.new()
	root.name = prop_name
	root.position = pos
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_instance.material_override = mat
	root.add_child(mesh_instance)
	decor_root.add_child(root)

func _clear_children(root: Node) -> void:
	if root == null: return
	for child: Node in root.get_children():
		child.queue_free()
