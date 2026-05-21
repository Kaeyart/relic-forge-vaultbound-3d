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
var skill_ready_at_msec: Dictionary = {}
var pending_pulses: Array[Dictionary] = []

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
	if found != null:
		return found
	var n := Node3D.new()
	n.name = node_name
	add_child(n)
	return n

func start_map(state: Object, activity: Dictionary = {}) -> void:
	_ensure_roots()
	active = true
	room_clear = false
	boss_reward_spawned = false
	pending_pulses.clear()
	skill_ready_at_msec.clear()
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
	pending_pulses.clear()
	_clear_children(enemies_root)
	_clear_children(projectiles_root)
	_clear_children(loot_root)

func update_combat(state: Object, player: Node3D, delta: float) -> void:
	if not active or state == null or player == null:
		return
	_process_pending_pulses(state, delta)
	var player_pos: Vector3 = player.global_position
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not is_instance_valid(enemy_node):
			continue
		if enemy_node.has_method("update_ai"):
			enemy_node.call("update_ai", player_pos, delta)
		if not bool(enemy_node.get("alive")):
			if not bool(enemy_node.get("death_processed")):
				_on_enemy_died(enemy_node, state)
			continue
		if (enemy_node as Node3D).global_position.distance_to(player_pos) < 0.9:
			var armor: float = float(state.get("armor"))
			var mitigation: float = armor / (armor + 160.0)
			var dmg: float = float(enemy_node.get("damage")) * (1.0 - mitigation)
			state.set("player_hp", max(0.0, float(state.get("player_hp")) - dmg * delta))
			if float(state.get("player_hp")) <= 0.0:
				state.set("deaths", int(state.get("deaths")) + 1)
				state.call("add_notice", "You died.\nPress T to return to hub.")
	for projectile_node: Node in projectiles_root.get_children():
		if projectile_node != null and is_instance_valid(projectile_node) and projectile_node.has_method("update_projectile"):
			projectile_node.call("update_projectile", delta)
			_check_projectile_hits(projectile_node, state)
	for loot_node: Node in loot_root.get_children():
		if loot_node == null or not is_instance_valid(loot_node):
			continue
		var drop: Dictionary = Dictionary(loot_node.get("drop_data"))
		if LootPickupSystemScript.player_can_auto_pick(drop) and (loot_node as Node3D).global_position.distance_to(player_pos) < 1.2:
			LootPickupSystemScript.apply_pickup(state, loot_node)
	if _living_enemy_count() <= 0 and not room_clear:
		room_clear = true
		MapLoopSystemScript.complete_current_map(state)
		_spawn_boss_reward_pile(state, Vector3(0, 0, 5.2))
		state.call("add_notice", "Map clear.\nPress E to return or collect loot.")

func cast_skill(state: Object, origin: Vector3, aim_world: Vector3, cast_data: Dictionary) -> void:
	if cast_data.is_empty() or state == null:
		return
	var cooldown_key := str(cast_data.get("selected_slot", 0)) + ":" + str(cast_data.get("active_id", ""))
	var now := Time.get_ticks_msec()
	var ready_at := int(skill_ready_at_msec.get(cooldown_key, 0))
	if now < ready_at:
		return
	var mana_cost: float = float(cast_data.get("mana_cost", 0.0))
	if not bool(state.call("spend_mana", mana_cost)):
		return
	var life_cost: float = float(cast_data.get("life_cost", 0.0))
	if life_cost > 0.0:
		var hp := float(state.get("player_hp"))
		if hp <= life_cost + 1.0:
			state.call("add_notice", "Not enough life")
			return
		state.set("player_hp", max(1.0, hp - life_cost))
	skill_ready_at_msec[cooldown_key] = now + int(float(cast_data.get("cooldown", 0.2)) * 1000.0)
	var dir: Vector3 = aim_world - origin
	dir.y = 0.0
	if dir.length() < 0.05:
		dir = -global_transform.basis.z
	dir = dir.normalized()
	var active_id: String = str(cast_data.get("active_id", ""))
	match active_id:
		"fireball":
			_cast_projectile_fan(origin, dir, cast_data, 1.0)
		"storm_lance":
			_damage_line(origin, dir, float(cast_data.get("range", 10.0)), 0.75, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
			if int(cast_data.get("chain", 0)) > 0:
				_chain_from_point(origin + dir * 5.0, state, float(cast_data.get("damage", 1.0)) * 0.68, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})), int(cast_data.get("chain", 0)), [])
		"chain_spark":
			var first := _closest_enemy_to(origin, 8.5, [])
			if first != null:
				_damage_enemy(first, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})), origin)
				_chain_from_point((first as Node3D).global_position, state, float(cast_data.get("damage", 1.0)) * 0.78, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})), max(1, int(cast_data.get("chain", 0))), [first.get_instance_id()])
			else:
				_cast_projectile_fan(origin, dir, cast_data, 0.85)
		"arc_slash":
			_damage_cone(origin, dir, float(cast_data.get("range", 2.8)) * float(cast_data.get("area_mult", 1.0)), 1.4, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
		"blood_cleave":
			_damage_cone(origin, dir, float(cast_data.get("range", 3.2)) * float(cast_data.get("area_mult", 1.0)), 1.9, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
		"void_rift":
			var center := _clamped_target(origin, aim_world, float(cast_data.get("range", 8.0)))
			_damage_area(center, float(cast_data.get("base_area", 2.0)) * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
			_schedule_pulse(center + dir * 0.7, 0.22, float(cast_data.get("base_area", 2.0)) * 0.75 * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)) * 0.55, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
		"ember_mine":
			var mine_count := 1 + int(cast_data.get("extra_mines", 0))
			for i in range(mine_count):
				var angle := (float(i) - float(mine_count - 1) * 0.5) * 0.38
				var mine_pos := origin + dir.rotated(Vector3.UP, angle) * (2.5 + float(i) * 0.18)
				_schedule_pulse(mine_pos, 0.32 + float(i) * 0.07, float(cast_data.get("base_area", 1.8)) * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)), Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
		"bone_spear":
			_cast_projectile_fan(origin, dir, cast_data, 1.08)
		"ash_nova":
			_damage_area(origin, float(cast_data.get("base_area", 2.7)) * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
		"shield_burst":
			_damage_cone(origin, dir, 2.8 * float(cast_data.get("area_mult", 1.0)), 2.2, float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
		"infernal_step":
			var end_pos := origin + dir * float(cast_data.get("range", 4.5))
			_damage_line(origin, dir, float(cast_data.get("range", 4.5)), 0.65 * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)) * 0.55, state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
			_damage_area(end_pos, float(cast_data.get("base_area", 1.55)) * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)), state, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
		"furnace_totem":
			var totem_pos := _clamped_target(origin, aim_world, float(cast_data.get("range", 6.0)))
			var pulses := 1 + int(cast_data.get("extra_pulses", 0))
			for p in range(pulses):
				_schedule_pulse(totem_pos, 0.05 + float(p) * 0.32, float(cast_data.get("base_area", 1.75)) * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)) * (0.85 if p > 0 else 1.0), Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))
		_:
			_cast_projectile_fan(origin, dir, cast_data, 1.0)
	var echo_count := int(cast_data.get("echo_count", 0))
	for e in range(echo_count):
		_schedule_echo(origin, aim_world, dir, cast_data, 0.24 + float(e) * 0.18)

func _cast_projectile_fan(origin: Vector3, dir: Vector3, cast_data: Dictionary, damage_scale: float) -> void:
	var count: int = maxi(1, int(cast_data.get("projectile_count", 1)))
	var spread: float = float(cast_data.get("spread", 0.0))

	if count > 1 and spread <= 0.0:
		spread = 0.22

	for i: int in range(count):
		var offset_index: float = float(i) - float(count - 1) * 0.5
		var shot_dir: Vector3 = dir.rotated(Vector3.UP, offset_index * spread).normalized()
		var spawn_pos: Vector3 = origin + shot_dir * 0.9 + Vector3.UP * 0.55

		_spawn_projectile(spawn_pos, shot_dir, cast_data, damage_scale)

func _spawn_projectile(pos: Vector3, dir: Vector3, cast_data: Dictionary, damage_scale: float = 1.0) -> void:
	var projectile: Node = ProjectileScene.instantiate()
	projectiles_root.add_child(projectile)
	var speed := float(cast_data.get("projectile_speed", 13.0))
	projectile.call("setup", pos, dir.normalized() * speed, float(cast_data.get("damage", 1.0)) * damage_scale, float(cast_data.get("radius", 0.4)), Array(cast_data.get("tags", [])), int(cast_data.get("pierce", 0)), int(cast_data.get("chain", 0)), Dictionary(cast_data.get("rules", {})))

func _check_projectile_hits(projectile: Node, state: Object) -> void:
	if projectile == null or not is_instance_valid(projectile):
		return
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not is_instance_valid(enemy_node) or not bool(enemy_node.get("alive")):
			continue
		var enemy_id := enemy_node.get_instance_id()
		var hit_ids: Array = Array(projectile.get("hit_instance_ids"))
		if hit_ids.has(enemy_id):
			continue
		var enemy_pos: Vector3 = (enemy_node as Node3D).global_position + Vector3.UP * 0.55
		if (projectile as Node3D).global_position.distance_to(enemy_pos) <= float(projectile.get("radius")) + float(enemy_node.get("radius")):
			hit_ids.append(enemy_id)
			projectile.set("hit_instance_ids", hit_ids)
			_damage_enemy(enemy_node, float(projectile.get("damage")), state, Array(projectile.get("tags")), Dictionary(projectile.get("rules")), (projectile as Node3D).global_position)
			if int(projectile.get("chain_remaining")) > 0:
				_chain_from_point((enemy_node as Node3D).global_position, state, float(projectile.get("damage")) * 0.68, Array(projectile.get("tags")), Dictionary(projectile.get("rules")), int(projectile.get("chain_remaining")), hit_ids)
			if int(projectile.get("pierce_remaining")) > 0:
				projectile.set("pierce_remaining", int(projectile.get("pierce_remaining")) - 1)
				return
			projectile.queue_free()
			return

func _damage_line(origin: Vector3, dir: Vector3, length: float, width: float, damage: float, state: Object, tags: Array, rules: Dictionary) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")):
			continue
		var rel: Vector3 = (enemy_node as Node3D).global_position - origin
		rel.y = 0.0
		var along: float = rel.dot(dir)
		if along >= 0.0 and along <= length:
			var closest: Vector3 = origin + dir * along
			if closest.distance_to((enemy_node as Node3D).global_position) <= width:
				_damage_enemy(enemy_node, damage, state, tags, rules, closest)

func _damage_cone(origin: Vector3, dir: Vector3, radius_value: float, half_width: float, damage: float, state: Object, tags: Array, rules: Dictionary) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")):
			continue
		var rel: Vector3 = (enemy_node as Node3D).global_position - origin
		rel.y = 0.0
		if rel.length() <= radius_value and rel.length() > 0.05 and rel.normalized().dot(dir) > 0.22:
			_damage_enemy(enemy_node, damage, state, tags, rules, origin)

func _damage_area(center: Vector3, radius_value: float, damage: float, state: Object, tags: Array, rules: Dictionary) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not bool(enemy_node.get("alive")):
			continue
		var flat_center: Vector3 = Vector3(center.x, (enemy_node as Node3D).global_position.y, center.z)
		if (enemy_node as Node3D).global_position.distance_to(flat_center) <= radius_value:
			_damage_enemy(enemy_node, damage, state, tags, rules, center)

func _damage_enemy(enemy: Node, damage: float, state: Object, tags: Array, rules: Dictionary, source_pos: Vector3) -> void:
	if enemy == null or not is_instance_valid(enemy) or not bool(enemy.get("alive")):
		return
	var final_damage := damage
	if float(rules.get("execute_more", 0.0)) > 0.0 and enemy.has_method("health_ratio") and float(enemy.call("health_ratio")) <= 0.35:
		final_damage *= 1.0 + float(rules.get("execute_more", 0.0))
	if bool(enemy.call("take_damage", final_damage)):
		_apply_on_hit_rules(enemy, final_damage, state, tags, rules, source_pos)
	if not bool(enemy.get("alive")):
		_on_enemy_died(enemy, state)

func _apply_on_hit_rules(enemy: Node, damage: float, state: Object, tags: Array, rules: Dictionary, source_pos: Vector3) -> void:
	if enemy != null and enemy.has_method("apply_status"):
		if tags.has("fire") and randf() < float(rules.get("ignite_chance", 0.0)):
			enemy.call("apply_status", "ignite", damage)
		if tags.has("lightning") and randf() < float(rules.get("shock_chance", 0.0)):
			enemy.call("apply_status", "shock", damage)
		if (tags.has("attack") or tags.has("physical")) and randf() < float(rules.get("bleed_chance", 0.0)):
			enemy.call("apply_status", "bleed", damage)
	if bool(rules.get("on_hit_burst", false)):
		_damage_area((enemy as Node3D).global_position, 1.05, damage * 0.28, state, tags, {"ignite_chance": float(rules.get("ignite_chance", 0.0)) * 0.5})
	var life_leech := float(rules.get("life_leech", 0.0))
	if life_leech > 0.0:
		state.set("player_hp", min(float(state.get("max_hp")), float(state.get("player_hp")) + damage * life_leech))
	var mana_leech := float(rules.get("mana_leech", 0.0))
	if mana_leech > 0.0:
		state.set("player_mana", min(float(state.get("max_mana")), float(state.get("player_mana")) + damage * mana_leech))

func _chain_from_point(point: Vector3, state: Object, damage: float, tags: Array, rules: Dictionary, remaining: int, already_hit: Array) -> void:
	if remaining <= 0:
		return
	var target := _closest_enemy_to(point, 6.0, already_hit)
	if target == null:
		return
	already_hit.append(target.get_instance_id())
	_damage_enemy(target, damage, state, tags, rules, point)
	_chain_from_point((target as Node3D).global_position, state, damage * 0.72, tags, rules, remaining - 1, already_hit)

func _closest_enemy_to(point: Vector3, max_distance: float, excluded_ids: Array) -> Node:
	var best: Node = null
	var best_dist := max_distance
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not is_instance_valid(enemy_node) or not bool(enemy_node.get("alive")):
			continue
		if excluded_ids.has(enemy_node.get_instance_id()):
			continue
		var dist := (enemy_node as Node3D).global_position.distance_to(point)
		if dist < best_dist:
			best = enemy_node
			best_dist = dist
	return best

func _schedule_echo(origin: Vector3, aim_world: Vector3, dir: Vector3, cast_data: Dictionary, delay: float) -> void:
	var active_id := str(cast_data.get("active_id", ""))
	var center := _clamped_target(origin, aim_world, float(cast_data.get("range", 8.0)))
	match active_id:
		"fireball", "storm_lance", "chain_spark", "bone_spear":
			pending_pulses.append({"time": delay, "type": "projectile", "origin": origin, "dir": dir, "cast": cast_data.duplicate(true), "scale": 0.55})
		"arc_slash", "blood_cleave", "shield_burst":
			pending_pulses.append({"time": delay, "type": "cone", "origin": origin, "dir": dir, "radius": float(cast_data.get("range", 3.0)) * float(cast_data.get("area_mult", 1.0)), "damage": float(cast_data.get("damage", 1.0)) * 0.50, "tags": Array(cast_data.get("tags", [])), "rules": Dictionary(cast_data.get("rules", {}))})
		_:
			_schedule_pulse(center, delay, float(cast_data.get("base_area", 1.0)) * float(cast_data.get("area_mult", 1.0)), float(cast_data.get("damage", 1.0)) * 0.55, Array(cast_data.get("tags", [])), Dictionary(cast_data.get("rules", {})))

func _schedule_pulse(center: Vector3, delay: float, radius_value: float, damage: float, tags: Array, rules: Dictionary) -> void:
	pending_pulses.append({"time": max(0.0, delay), "type": "area", "center": center, "radius": radius_value, "damage": damage, "tags": tags.duplicate(true), "rules": rules.duplicate(true)})

func _process_pending_pulses(state: Object, delta: float) -> void:
	for i in range(pending_pulses.size() - 1, -1, -1):
		var pulse := Dictionary(pending_pulses[i])
		pulse["time"] = float(pulse.get("time", 0.0)) - delta
		if float(pulse.get("time", 0.0)) > 0.0:
			pending_pulses[i] = pulse
			continue
		match str(pulse.get("type", "area")):
			"projectile":
				var cast := Dictionary(pulse.get("cast", {}))
				var pulse_origin: Vector3 = pulse.get("origin", Vector3.ZERO)
				var pulse_dir: Vector3 = pulse.get("dir", Vector3.FORWARD)
				_cast_projectile_fan(pulse_origin, pulse_dir.normalized(), cast, float(pulse.get("scale", 0.55)))
			"cone":
				var cone_origin: Vector3 = pulse.get("origin", Vector3.ZERO)
				var cone_dir: Vector3 = pulse.get("dir", Vector3.FORWARD)
				_damage_cone(cone_origin, cone_dir.normalized(), float(pulse.get("radius", 2.5)), 1.6, float(pulse.get("damage", 1.0)), state, Array(pulse.get("tags", [])), Dictionary(pulse.get("rules", {})))
			_:
				var area_center: Vector3 = pulse.get("center", Vector3.ZERO)
				_damage_area(area_center, float(pulse.get("radius", 1.0)), float(pulse.get("damage", 1.0)), state, Array(pulse.get("tags", [])), Dictionary(pulse.get("rules", {})))
		pending_pulses.remove_at(i)

func _clamped_target(origin: Vector3, target: Vector3, max_range: float) -> Vector3:
	var rel := target - origin
	rel.y = 0.0
	if rel.length() > max_range:
		rel = rel.normalized() * max_range
	return origin + rel

func _on_enemy_died(enemy: Node, state: Object) -> void:
	if enemy == null or not is_instance_valid(enemy) or bool(enemy.get("death_processed")):
		return
	enemy.set("death_processed", true)
	state.call("on_enemy_killed", int(enemy.get("enemy_level")), bool(enemy.get("is_elite")), bool(enemy.get("is_boss")))
	var drops: Array[Dictionary] = LootSystemScript.enemy_drop_bundle(state, int(enemy.get("enemy_level")), bool(enemy.get("is_elite")), bool(enemy.get("is_boss")))
	_spawn_drops(drops, (enemy as Node3D).global_position)
	enemy.queue_free()

func _spawn_boss_reward_pile(state: Object, pos: Vector3) -> void:
	if boss_reward_spawned:
		return
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
		if loot_node == null or not is_instance_valid(loot_node):
			continue
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
	if root == null:
		return
	for child: Node in root.get_children():
		child.queue_free()
