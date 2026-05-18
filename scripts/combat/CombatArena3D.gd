class_name RVCombatArena3D
extends Node3D

const EnemyScene := preload("res://scenes/prefabs/enemies/Enemy3D.tscn")
const ProjectileScene := preload("res://scenes/prefabs/projectiles/Projectile3D.tscn")
const SkillDBScript := preload("res://scripts/data/SkillDB3D.gd")
const LootSystemScript := preload("res://scripts/systems/LootSystem3D.gd")
const ProgressionSystemScript := preload("res://scripts/systems/ProgressionSystem3D.gd")
const MapLoopSystemScript := preload("res://scripts/systems/MapLoopSystem3D.gd")

var enemies_root: Node3D
var projectiles_root: Node3D
var loot_root: Node3D
var layout_root: Node3D
var blockers: Array = []
var active: bool = false
var map_item: Dictionary = {}
var room_clear: bool = false

func _ready() -> void:
	_ensure_roots()
	visible = false

func start_map(state: Object, map_data: Dictionary) -> void:
	_ensure_roots()
	clear_arena()
	active = true
	visible = true
	room_clear = false
	map_item = map_data.duplicate(true)
	_build_layout()
	_spawn_encounter(state)

func stop_map() -> void:
	active = false
	visible = false
	clear_arena()

func clear_arena() -> void:
	_ensure_roots()
	for root: Node in [enemies_root, projectiles_root, loot_root, layout_root]:
		for child: Node in root.get_children():
			child.queue_free()
	blockers.clear()

func update_combat(state: Object, player_node: Node3D, delta: float) -> void:
	if not active or state == null or player_node == null:
		return
	var player_pos: Vector3 = Vector3(state.get("player_pos"))
	for enemy_node: Node in enemies_root.get_children():
		if not is_instance_valid(enemy_node):
			continue
		if enemy_node.has_method("update_enemy"):
			enemy_node.call("update_enemy", state, player_pos, delta, blockers)
	for projectile_node: Node in projectiles_root.get_children():
		if not is_instance_valid(projectile_node):
			continue
		if projectile_node.has_method("update_projectile"):
			projectile_node.call("update_projectile", delta)
		_check_projectile_hits(projectile_node, state)
	_check_loot_pickups(state, player_pos)
	if state != null:
		state.set("prompt_text", "Clear the map." if not room_clear else "Map clear. Press E to return to hub.")
	if enemies_root.get_child_count() == 0 and not room_clear:
		room_clear = true
		MapLoopSystemScript.complete_current_map(state)
		_spawn_exit_marker()

func cast_selected_skill(state: Object, origin: Vector3, aim: Vector3) -> bool:
	if not active or state == null:
		return false
	var skill_id: String = str(state.call("get_selected_skill"))
	if skill_id == "":
		return false
	var skill: Dictionary = SkillDBScript.compute_skill(state, skill_id)
	var cooldowns: Dictionary = Dictionary(state.get("skill_cooldowns"))
	if float(cooldowns.get(skill_id, 0.0)) > 0.0:
		return false
	var cost: float = float(skill.get("cost", 0.0))
	if float(state.get("player_mana")) < cost:
		state.call("add_notice", "Not enough mana")
		return false
	state.set("player_mana", float(state.get("player_mana")) - cost)
	cooldowns[skill_id] = float(skill.get("cooldown", 0.25))
	state.set("skill_cooldowns", cooldowns)
	var dir: Vector3 = aim - origin
	dir.y = 0.0
	if dir.length() < 0.05:
		dir = Vector3.FORWARD
	else:
		dir = dir.normalized()
	match str(skill.get("kind", "projectile")):
		"projectile":
			_spawn_projectile(origin + dir * 0.8 + Vector3(0, 0.55, 0), dir * float(skill.get("speed", 14.0)), float(skill.get("damage", 1.0)), float(skill.get("radius", 0.3)), Array(skill.get("tags", [])))
			var extra: int = int(skill.get("extra_projectiles", 0))
			if extra > 0:
				for angle: float in [-0.22, 0.22, -0.38, 0.38].slice(0, min(extra, 4)):
					var side: Vector3 = dir.rotated(Vector3.UP, angle)
					_spawn_projectile(origin + side * 0.8 + Vector3(0, 0.55, 0), side * float(skill.get("speed", 14.0)), float(skill.get("damage", 1.0)) * 0.65, float(skill.get("radius", 0.3)), Array(skill.get("tags", [])))
		"lance":
			_damage_line(origin, dir, float(skill.get("range", 10.0)), float(skill.get("radius", 0.6)), float(skill.get("damage", 1.0)), Array(skill.get("tags", [])))
		"area", "area_target":
			var center: Vector3 = origin + dir * float(skill.get("range", 2.2))
			if str(skill.get("kind", "")) == "area_target":
				center = aim
			_damage_radius(center, float(skill.get("radius", 2.0)), float(skill.get("damage", 1.0)), Array(skill.get("tags", [])))
		_:
			_spawn_projectile(origin + dir * 0.8 + Vector3(0, 0.55, 0), dir * 14.0, float(skill.get("damage", 1.0)), 0.3, Array(skill.get("tags", [])))
	return true

func constrain_player_position(old_pos: Vector3, target: Vector3, radius: float) -> Vector3:
	if not active:
		return target
	target.x = clampf(target.x, -14.0, 14.0)
	target.z = clampf(target.z, -16.0, 16.0)
	for blocker_value: Variant in blockers:
		if typeof(blocker_value) != TYPE_DICTIONARY:
			continue
		var b: Dictionary = blocker_value
		var min_v: Vector3 = Vector3(b.get("min", Vector3.ZERO))
		var max_v: Vector3 = Vector3(b.get("max", Vector3.ZERO))
		if target.x > min_v.x - radius and target.x < max_v.x + radius and target.z > min_v.z - radius and target.z < max_v.z + radius:
			return old_pos
	return target

func interact(state: Object) -> Dictionary:
	if room_clear:
		return {"action": "return_hub"}
	return {}

func _check_projectile_hits(projectile_node: Node, state: Object) -> void:
	if projectile_node == null or not is_instance_valid(projectile_node):
		return
	if projectile_node.get("alive") == false:
		return
	var p_pos: Vector3 = projectile_node.global_position
	for enemy_node: Node in enemies_root.get_children():
		if not is_instance_valid(enemy_node):
			continue
		var e_pos: Vector3 = (enemy_node as Node3D).global_position
		var hit_radius: float = float(projectile_node.get("radius")) + float(enemy_node.get("radius"))
		if p_pos.distance_to(e_pos) <= hit_radius:
			var died: bool = bool(enemy_node.call("take_damage", float(projectile_node.get("damage"))))
			projectile_node.set("alive", false)
			projectile_node.queue_free()
			if died:
				_on_enemy_died(enemy_node, state)
			return

func _damage_radius(center: Vector3, radius: float, damage: float, tags: Array) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if not is_instance_valid(enemy_node):
			continue
		var enemy: Node3D = enemy_node as Node3D
		if enemy.global_position.distance_to(center) <= radius + float(enemy_node.get("radius")):
			var died: bool = bool(enemy_node.call("take_damage", damage))
			if died:
				_on_enemy_died(enemy_node, get_parent().get("state") if get_parent() != null else null)

func _damage_line(origin: Vector3, dir: Vector3, length: float, width: float, damage: float, tags: Array) -> void:
	for enemy_node: Node in enemies_root.get_children():
		if not is_instance_valid(enemy_node):
			continue
		var to_enemy: Vector3 = (enemy_node as Node3D).global_position - origin
		to_enemy.y = 0.0
		var along: float = to_enemy.dot(dir)
		if along < 0.0 or along > length:
			continue
		var closest: Vector3 = origin + dir * along
		var lateral: float = closest.distance_to((enemy_node as Node3D).global_position)
		if lateral <= width + float(enemy_node.get("radius")):
			var died: bool = bool(enemy_node.call("take_damage", damage))
			if died:
				_on_enemy_died(enemy_node, get_parent().get("state") if get_parent() != null else null)

func _on_enemy_died(enemy_node: Node, state: Object) -> void:
	if enemy_node == null or not is_instance_valid(enemy_node):
		return
	var enemy_data: Dictionary = enemy_node.call("death_data") if enemy_node.has_method("death_data") else {}
	if state != null:
		ProgressionSystemScript.award_enemy_kill(state, enemy_data)
		for drop: Dictionary in LootSystemScript.roll_enemy_loot(state, enemy_data, map_item):
			_spawn_loot(enemy_node.global_position, drop)
	enemy_node.queue_free()

func _check_loot_pickups(state: Object, player_pos: Vector3) -> void:
	if state == null:
		return
	for loot_node: Node in loot_root.get_children():
		if not is_instance_valid(loot_node):
			continue
		var n3: Node3D = loot_node as Node3D
		if n3.global_position.distance_to(player_pos) <= 1.15:
			var drop: Dictionary = Dictionary(loot_node.get_meta("drop", {}))
			LootSystemScript.apply_pickup(state, drop)
			loot_node.queue_free()

func _spawn_projectile(pos: Vector3, vel: Vector3, damage: float, radius: float, tags: Array) -> void:
	var projectile: Node = ProjectileScene.instantiate()
	projectiles_root.add_child(projectile)
	projectile.call("setup", pos, vel, damage, radius, tags)

func _spawn_loot(pos: Vector3, drop: Dictionary) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.45, 0.18, 0.45)
	var mat := StandardMaterial3D.new()
	match str(drop.get("kind", "")):
		"gold": mat.albedo_color = Color(0.95, 0.72, 0.18)
		"material": mat.albedo_color = Color(0.9, 0.25, 0.08)
		"map": mat.albedo_color = Color(0.25, 0.65, 1.0)
		_: mat.albedo_color = Color(0.65, 0.85, 0.55)
	var inst := MeshInstance3D.new()
	inst.mesh = mesh
	inst.set_surface_override_material(0, mat)
	inst.position = pos + Vector3(randf_range(-0.5, 0.5), 0.18, randf_range(-0.5, 0.5))
	inst.set_meta("drop", drop.duplicate(true))
	loot_root.add_child(inst)

func _spawn_encounter(state: Object) -> void:
	var level: int = max(1, int(map_item.get("level", 1)))
	var positions: Array[Vector3] = [
		Vector3(-7, 0, -6), Vector3(-4, 0, -2), Vector3(4, 0, -3), Vector3(7, 0, -7),
		Vector3(-6, 0, 4), Vector3(4, 0, 5), Vector3(8, 0, 1)
	]
	for i: int in range(positions.size()):
		var elite: bool = i == 2 or i == 5
		_spawn_enemy(positions[i], {"name": "Ash Wretch", "level": level, "hp": 34.0 + level * 8.0 + (26.0 if elite else 0.0), "damage": 8.0 + level * 1.6, "speed": 2.3, "radius": 0.45, "elite": elite})
	_spawn_enemy(Vector3(0, 0, 10), {"name": "Vault Keeper", "level": level + 1, "hp": 180.0 + level * 35.0, "damage": 18.0 + level * 2.0, "speed": 1.9, "radius": 0.8, "boss": true, "elite": true})

func _spawn_enemy(pos: Vector3, enemy_data: Dictionary) -> void:
	var enemy: Node = EnemyScene.instantiate()
	enemies_root.add_child(enemy)
	(enemy as Node3D).global_position = pos
	enemy.call("setup", enemy_data)

func _build_layout() -> void:
	_add_box(layout_root, "MapFloor", Vector3(0, -0.08, 0), Vector3(30, 0.12, 34), Color(0.10, 0.09, 0.08))
	_add_wall(Vector3(0, 0.9, -17), Vector3(30, 1.8, 0.7))
	_add_wall(Vector3(0, 0.9, 17), Vector3(30, 1.8, 0.7))
	_add_wall(Vector3(-15, 0.9, 0), Vector3(0.7, 1.8, 34))
	_add_wall(Vector3(15, 0.9, 0), Vector3(0.7, 1.8, 34))
	_add_wall(Vector3(-4.5, 0.8, 0.5), Vector3(1.0, 1.6, 8.0))
	_add_wall(Vector3(4.5, 0.8, -0.5), Vector3(1.0, 1.6, 8.0))
	_add_wall(Vector3(0, 0.8, 4.2), Vector3(4.5, 1.6, 1.0))
	_add_wall(Vector3(0, 0.8, -7.8), Vector3(5.5, 1.6, 1.0))
	_add_box(layout_root, "BossSeal", Vector3(0, 0.03, 10), Vector3(5.0, 0.04, 5.0), Color(0.38, 0.07, 0.04))

func _spawn_exit_marker() -> void:
	_add_box(layout_root, "ExitPortal", Vector3(0, 0.45, -13.5), Vector3(1.2, 0.9, 1.2), Color(0.3, 0.75, 1.0))

func _add_wall(pos: Vector3, size: Vector3) -> void:
	_add_box(layout_root, "Wall", pos, size, Color(0.22, 0.19, 0.16))
	blockers.append({"min": pos - size * 0.5, "max": pos + size * 0.5})

func _add_box(parent: Node, node_name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	var inst := MeshInstance3D.new()
	inst.name = node_name
	inst.mesh = mesh
	inst.set_surface_override_material(0, mat)
	inst.position = pos
	parent.add_child(inst)
	return inst

func _ensure_roots() -> void:
	if enemies_root == null:
		enemies_root = Node3D.new()
		enemies_root.name = "Enemies"
		add_child(enemies_root)
	if projectiles_root == null:
		projectiles_root = Node3D.new()
		projectiles_root.name = "Projectiles"
		add_child(projectiles_root)
	if loot_root == null:
		loot_root = Node3D.new()
		loot_root.name = "Loot"
		add_child(loot_root)
	if layout_root == null:
		layout_root = Node3D.new()
		layout_root.name = "Layout"
		add_child(layout_root)
