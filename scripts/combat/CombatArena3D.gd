class_name RVCombatArena3D
extends Node3D

const EnemyScene := preload("res://scenes/prefabs/enemies/Enemy3D.tscn")
const ProjectileScene := preload("res://scenes/prefabs/projectiles/Projectile3D.tscn")
const LootActorScene := preload("res://scenes/prefabs/loot/LootActor3D.tscn")
const LootSystemScript := preload("res://scripts/systems/LootSystem3D.gd") 
const RewardLoopSystemScript := preload("res://scripts/systems/RewardLoopSystem3D.gd") 
const SkillGameplaySystemScript := preload("res://scripts/systems/SkillGameplaySystem3D.gd")
const LootPickupSystemScript := preload("res://scripts/systems/LootPickupSystem3D.gd")
const MapLoopSystemScript := preload("res://scripts/systems/MapLoopSystem3D.gd") 
const MapDifficultySystemScript := preload("res://scripts/systems/MapDifficultySystem3D.gd")

var enemies_root: Node3D
var projectiles_root: Node3D
var decor_root: Node3D
var loot_root: Node3D
var active: bool = false
var room_clear: bool = false
var boss_reward_spawned: bool = false
var map_level: int = 1
var exit_pos: Vector3 = Vector3(0, 0, 8) 
var skill_runtime_effects: Array = []

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

	var map_activity: Dictionary = MapDifficultySystemScript.normalize_map_item(activity, state)
	if map_activity.is_empty():
		map_activity = MapDifficultySystemScript.normalize_map_item({
			"base_id":"ash_vault",
			"display_name":"Ash Vault",
			"tier":1,
			"map_level":max(1, int(state.get("level") if state != null else 1)),
			"layout":"box_blockers",
			"rarity":"normal",
			"entries":6,
			"mods":[],
		}, state)

	if state != null:
		state.set("current_map_activity", map_activity.duplicate(true))
		state.set("active_map_item", map_activity.duplicate(true))
		state.set("active_map_tier", int(map_activity.get("tier", 1)))
		state.set("active_map_rarity", str(map_activity.get("rarity", "normal")))

	active = true
	room_clear = false
	boss_reward_spawned = false
	map_level = MapDifficultySystemScript.map_level(map_activity, state)
	visible = true

	_clear_children(enemies_root)
	_clear_children(projectiles_root)
	_clear_children(decor_root)
	_clear_children(loot_root)

	_build_arena(str(map_activity.get("layout", "box_blockers")))

	var pack_bonus: int = MapDifficultySystemScript.pack_size_bonus(map_activity)
	var extra_packs: int = MapDifficultySystemScript.extra_pack_count(map_activity)

	_spawn_pack(Vector3(-5, 0, -4), 4 + pack_bonus, false)
	_spawn_pack(Vector3(5, 0, -2), 4 + max(0, int(pack_bonus / 2)), false)
	_spawn_pack(Vector3(-3, 0, 3), 3 + max(0, int(pack_bonus / 2)), true)

	for i: int in range(extra_packs):
		var angle: float = TAU * float(i) / float(max(1, extra_packs))
		var pos: Vector3 = Vector3(cos(angle), 0.0, sin(angle)) * 5.8
		_spawn_pack(pos, 2 + max(0, int(pack_bonus / 3)), i % 2 == 0)

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
	if cast_data.is_empty():
		return

	var cast: Dictionary = SkillGameplaySystemScript.enrich_cast_data(state, cast_data)
	var mana_cost: float = float(cast.get("mana_cost", 0.0))
	if not bool(state.call("spend_mana", mana_cost)):
		return

	SkillGameplaySystemScript.cast_xp(state, cast)

	var dir: Vector3 = aim_world - origin
	dir.y = 0.0
	if dir.length() < 0.05:
		dir = -global_transform.basis.z
	dir = dir.normalized()

	var active_id: String = str(cast.get("active_id", ""))
	match active_id:
		"fireball":
			_cast_fireball(origin, dir, cast)
		"storm_lance":
			_cast_storm_lance(origin, dir, cast, state)
		"arc_slash":
			_cast_arc_slash(origin, dir, cast, state)
		"void_rift":
			_cast_void_rift(aim_world, dir, cast, state)
		"ember_mine":
			_cast_ember_mine(origin, dir, cast)
		_:
			_spawn_projectile(origin + dir * 0.9 + Vector3.UP * 0.55, dir, cast)


func _cast_fireball(origin: Vector3, dir: Vector3, cast: Dictionary) -> void:
	var count: int = max(1, int(cast.get("projectile_count", 1)))
	var spread: float = float(cast.get("projectile_spread", 0.22))
	var start_index: float = -float(count - 1) * 0.5
	for i: int in range(count):
		var angle: float = (start_index + float(i)) * spread
		var projectile_dir: Vector3 = dir.rotated(Vector3.UP, angle)
		_spawn_projectile(origin + projectile_dir * 0.9 + Vector3.UP * 0.55, projectile_dir, cast)


func _cast_storm_lance(origin: Vector3, dir: Vector3, cast: Dictionary, state: Object) -> void:
	_damage_line(
		origin,
		dir,
		float(cast.get("line_length", 9.0)),
		float(cast.get("line_width", 0.72)),
		float(cast.get("damage", 1.0)),
		state,
		Array(cast.get("tags", [])),
		cast
	)

	var chain_count: int = int(cast.get("chain_count", cast.get("chain", 0)))
	if chain_count > 0:
		for i: int in range(chain_count):
			var side: float = -1.0 if i % 2 == 0 else 1.0
			var fork_dir: Vector3 = dir.rotated(Vector3.UP, 0.38 * side)
			_damage_line(origin + dir * 2.2, fork_dir, 4.2, 0.52, float(cast.get("damage", 1.0)) * 0.55, state, Array(cast.get("tags", [])), cast)


func _cast_arc_slash(origin: Vector3, dir: Vector3, cast: Dictionary, state: Object) -> void:
	_damage_cone(
		origin,
		dir,
		float(cast.get("cone_range", 2.75)),
		float(cast.get("cone_width", 1.55)),
		float(cast.get("damage", 1.0)),
		state,
		Array(cast.get("tags", [])),
		cast
	)


func _cast_void_rift(aim_world: Vector3, dir: Vector3, cast: Dictionary, state: Object) -> void:
	var center: Vector3 = Vector3(aim_world.x, 0.0, aim_world.z)
	_spawn_skill_zone(center, cast, state)

	var echo_count: int = int(cast.get("echo_count", 0))
	for i: int in range(echo_count):
		var echo_center: Vector3 = center + dir * (0.9 + float(i) * 0.75)
		var echo_cast: Dictionary = cast.duplicate(true)
		echo_cast["damage"] = float(cast.get("damage", 1.0)) * 0.48
		echo_cast["zone_duration"] = float(cast.get("zone_duration", 2.0)) * 0.65
		_spawn_skill_zone(echo_center, echo_cast, state)


func _cast_ember_mine(origin: Vector3, dir: Vector3, cast: Dictionary) -> void:
	var center: Vector3 = origin + dir * 2.4
	center.y = 0.0
	skill_runtime_effects.append({
		"kind": "mine",
		"center": center,
		"cast": cast.duplicate(true),
		"age": 0.0,
		"duration": float(cast.get("mine_duration", 8.0)),
		"armed": false,
	})


func _spawn_projectile(pos: Vector3, dir: Vector3, cast_data: Dictionary) -> void:
	var projectile: Node = ProjectileScene.instantiate()
	projectiles_root.add_child(projectile)

	var speed: float = float(cast_data.get("projectile_speed", 13.5))
	var radius: float = float(cast_data.get("projectile_radius", 0.42))
	projectile.call("setup", pos, dir.normalized() * speed, float(cast_data.get("damage", 1.0)), radius, Array(cast_data.get("tags", [])))
	projectile.set_meta("rv_cast_data", cast_data.duplicate(true))


func _check_projectile_hits(projectile: Node, state: Object) -> void:
	if projectile == null or not is_instance_valid(projectile):
		return

	var cast: Dictionary = {}
	if projectile.has_meta("rv_cast_data"):
		var cast_value: Variant = projectile.get_meta("rv_cast_data")
		if typeof(cast_value) == TYPE_DICTIONARY:
			cast = Dictionary(cast_value)

	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")):
			continue
		var enemy_pos: Vector3 = (enemy_node as Node3D).global_position + Vector3.UP * 0.55
		if (projectile as Node3D).global_position.distance_to(enemy_pos) <= float(projectile.get("radius")) + float(enemy_node.get("radius")):
			_damage_enemy(enemy_node, float(projectile.get("damage")), state, Array(projectile.get("tags")), cast)

			var impact_radius: float = float(cast.get("impact_radius", 0.0))
			if impact_radius > 0.05:
				_damage_area((projectile as Node3D).global_position, impact_radius, float(projectile.get("damage")) * float(cast.get("impact_damage_mult", 0.45)), state, Array(projectile.get("tags")), cast, enemy_node)

			projectile.queue_free()
			return


func _damage_line(origin: Vector3, dir: Vector3, length: float, width: float, damage: float, state: Object, tags: Array, cast: Dictionary = {}) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")):
			continue
		var rel: Vector3 = (enemy_node as Node3D).global_position - origin
		rel.y = 0.0
		var along: float = rel.dot(dir)
		if along >= 0.0 and along <= length:
			var closest: Vector3 = origin + dir * along
			if closest.distance_to((enemy_node as Node3D).global_position) <= width:
				_damage_enemy(enemy_node, damage, state, tags, cast)


func _damage_cone(origin: Vector3, dir: Vector3, radius: float, half_width: float, damage: float, state: Object, tags: Array, cast: Dictionary = {}) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")):
			continue
		var rel: Vector3 = (enemy_node as Node3D).global_position - origin
		rel.y = 0.0
		if rel.length() <= radius and rel.normalized().dot(dir) > 0.28:
			var falloff: float = clampf(1.0 - (rel.length() / max(0.01, radius)) * 0.18, 0.72, 1.0)
			_damage_enemy(enemy_node, damage * falloff, state, tags, cast)


func _damage_area(center: Vector3, radius: float, damage: float, state: Object, tags: Array, cast: Dictionary = {}, ignore_enemy: Node = null) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or enemy_node == ignore_enemy or not bool(enemy_node.get("alive")):
			continue
		var flat_center: Vector3 = Vector3(center.x, (enemy_node as Node3D).global_position.y, center.z)
		if (enemy_node as Node3D).global_position.distance_to(flat_center) <= radius:
			_damage_enemy(enemy_node, damage, state, tags, cast)


func _damage_enemy(enemy: Node, damage: float, state: Object, tags: Array, cast: Dictionary = {}) -> void:
	if enemy == null or not bool(enemy.get("alive")):
		return

	var hit: Dictionary = SkillGameplaySystemScript.resolve_hit_damage(enemy, damage, state, tags, cast)
	var final_damage: float = float(hit.get("damage", damage))
	var killed: bool = bool(enemy.call("take_damage", final_damage))

	SkillGameplaySystemScript.apply_on_hit_status(enemy, state, cast, final_damage)
	SkillGameplaySystemScript.hit_xp(state, cast)

	if killed:
		SkillGameplaySystemScript.kill_xp(state, cast)
		_on_enemy_died(enemy, state)


func _spawn_skill_zone(center: Vector3, cast: Dictionary, state: Object) -> void:
	skill_runtime_effects.append({
		"kind": "zone",
		"center": Vector3(center.x, 0.0, center.z),
		"cast": cast.duplicate(true),
		"age": 0.0,
		"duration": float(cast.get("zone_duration", 2.0)),
		"tick_timer": 0.01,
	})


func _update_skill_runtime_effects(state: Object, delta: float) -> void:
	_update_enemy_status_effects(state, delta)

	for i: int in range(skill_runtime_effects.size() - 1, -1, -1):
		var value: Variant = skill_runtime_effects[i]
		if typeof(value) != TYPE_DICTIONARY:
			skill_runtime_effects.remove_at(i)
			continue

		var effect: Dictionary = Dictionary(value)
		var kind: String = str(effect.get("kind", ""))
		var age: float = float(effect.get("age", 0.0)) + delta
		var duration: float = max(0.01, float(effect.get("duration", 0.01)))
		var cast: Dictionary = Dictionary(effect.get("cast", {}))
		var center: Vector3 = Vector3(effect.get("center", Vector3.ZERO))

		if kind == "zone":
			var tick_timer: float = float(effect.get("tick_timer", 0.0)) - delta
			if tick_timer <= 0.0:
				tick_timer += max(0.05, float(cast.get("zone_tick_rate", 0.45)))
				_damage_area(center, float(cast.get("zone_radius", 2.0)), float(cast.get("damage", 1.0)) * float(cast.get("zone_tick_damage_mult", 0.42)), state, Array(cast.get("tags", [])), cast)
			effect["tick_timer"] = tick_timer

		elif kind == "mine":
			var armed: bool = bool(effect.get("armed", false))
			if not armed and age >= float(cast.get("mine_arm_time", 0.42)):
				armed = true
				effect["armed"] = true

			if armed and _enemy_within(center, float(cast.get("mine_trigger_radius", 2.35))):
				_damage_area(center, float(cast.get("mine_explosion_radius", 2.05)), float(cast.get("damage", 1.0)), state, Array(cast.get("tags", [])), cast)
				skill_runtime_effects.remove_at(i)
				continue

		effect["age"] = age
		skill_runtime_effects[i] = effect

		if age >= duration:
			skill_runtime_effects.remove_at(i)


func _update_enemy_status_effects(state: Object, delta: float) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not is_instance_valid(enemy_node):
			continue
		if not bool(enemy_node.get("alive")):
			continue
		if SkillGameplaySystemScript.update_enemy_statuses(enemy_node, state, delta):
			_on_enemy_died(enemy_node, state)


func _enemy_within(center: Vector3, radius: float) -> bool:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")):
			continue
		var flat_center: Vector3 = Vector3(center.x, (enemy_node as Node3D).global_position.y, center.z)
		if (enemy_node as Node3D).global_position.distance_to(flat_center) <= radius:
			return true
	return false


func _on_enemy_died(enemy: Node, state: Object) -> void:
	state.call("on_enemy_killed", int(enemy.get("enemy_level")), bool(enemy.get("is_elite")), bool(enemy.get("is_boss")))

	var drops: Array = RewardLoopSystemScript.enemy_reward_bundle(state, enemy)
	_spawn_drops(drops, (enemy as Node3D).global_position)

	enemy.queue_free()


func _spawn_boss_reward_pile(state: Object, pos: Vector3) -> void:
	if boss_reward_spawned:
		return
	boss_reward_spawned = true

	var drops: Array = RewardLoopSystemScript.clear_reward_bundle(state, map_level)
	_spawn_drops(drops, pos)


func _spawn_drops(drops: Array, center: Vector3) -> void:
	if drops.is_empty():
		return

	_spawn_reward_burst_visual(center, drops)

	var i: int = 0
	var count: int = max(1, drops.size())
	for value: Variant in drops:
		if typeof(value) != TYPE_DICTIONARY:
			continue

		var drop: Dictionary = RewardLoopSystemScript.normalize_drop(Dictionary(value), null, map_level)
		if drop.is_empty():
			continue

		var loot: Node = LootActorScene.instantiate()
		loot_root.add_child(loot)

		var angle: float = float(i) * TAU / float(count)
		var ring: float = 0.75 + 0.22 * float(i % 5)
		if count >= 6:
			ring += 0.25
		var offset: Vector3 = Vector3(cos(angle), 0.0, sin(angle)) * ring
		var pos: Vector3 = center + offset + Vector3.UP * 0.15

		loot.set_meta("item_data", RewardLoopSystemScript.presentation_data_for_drop(drop))
		loot.add_to_group("loot")
		loot.call("setup", drop, pos)

		i += 1


func _spawn_reward_burst_visual(center: Vector3, drops: Array) -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return

	var layer: Node = scene.get_node_or_null("LootPresentationLayer096F")
	if layer == null:
		layer = get_node_or_null("/root/GameRoot3D/LootPresentationLayer096F")
	if layer == null or not layer.has_method("spawn_reward_burst"):
		return

	var best_rarity: String = "normal"
	for value: Variant in drops:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var rarity: String = RewardLoopSystemScript.rarity_for_drop(Dictionary(value))
		if rarity == "unique":
			best_rarity = "unique"
			break
		if rarity == "rare":
			best_rarity = "rare"
		elif rarity == "magic" and best_rarity == "normal":
			best_rarity = "magic"

	layer.call("spawn_reward_burst", center + Vector3.UP * 0.2, best_rarity)


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
	MapDifficultySystemScript.apply_map_mods_to_enemy(enemy, null)

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
