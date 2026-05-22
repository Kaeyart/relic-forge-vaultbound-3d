extends RefCounted
class_name RVVerticalSliceEncounterSystem3D

# Patch 36: Ash Foundry vertical-slice encounter helper.
# This script intentionally works as an external compatibility layer around
# CombatArena3D so it does not need to replace the whole arena script.

const ENEMY_ROLE_DATA: Dictionary = {
	"ash_thrall": {
		"name": "Ash Thrall",
		"color": Color(0.36, 0.32, 0.27),
		"hp_mult": 0.78,
		"damage_mult": 0.82,
		"speed_mult": 1.08,
	},
	"furnace_brute": {
		"name": "Furnace Brute",
		"color": Color(0.82, 0.32, 0.10),
		"hp_mult": 2.15,
		"damage_mult": 1.45,
		"speed_mult": 0.62,
	},
	"ember_spitter": {
		"name": "Ember Spitter",
		"color": Color(1.0, 0.45, 0.10),
		"hp_mult": 0.88,
		"damage_mult": 0.92,
		"speed_mult": 0.78,
	},
	"chain_warden": {
		"name": "Chain Warden",
		"color": Color(0.46, 0.58, 0.72),
		"hp_mult": 1.35,
		"damage_mult": 1.05,
		"speed_mult": 0.72,
	},
	"cinder_runner": {
		"name": "Cinder Runner",
		"color": Color(1.0, 0.16, 0.05),
		"hp_mult": 0.50,
		"damage_mult": 1.55,
		"speed_mult": 1.95,
	},
	"forge_acolyte": {
		"name": "Forge Acolyte",
		"color": Color(0.65, 0.20, 0.85),
		"hp_mult": 1.0,
		"damage_mult": 0.80,
		"speed_mult": 0.68,
	},
	"ash_warden": {
		"name": "The Ash Warden",
		"color": Color(0.95, 0.18, 0.08),
		"hp_mult": 7.5,
		"damage_mult": 1.85,
		"speed_mult": 0.55,
	},
}

static func try_start_map(arena: Node, state: Object, activity: Dictionary) -> bool:
	if arena == null:
		return false

	var layout: String = str(activity.get("layout", ""))
	var biome: String = str(activity.get("biome", ""))
	var node_name: String = str(activity.get("display_name", activity.get("node_name", "")))
	var force_foundry: bool = true
	if layout == "" and biome == "" and node_name == "":
		force_foundry = true

	if not force_foundry:
		return false

	arena.set_meta("rf36_vertical_slice_active", true)
	arena.set_meta("rf36_hazards", [])
	arena.set_meta("rf36_timer", 0.0)
	arena.set_meta("rf36_boss_intro", false)

	_build_ash_foundry(arena, activity)
	_spawn_ash_foundry_encounter(arena, activity)

	if state != null and state.has_method("add_notice"):
		state.call("add_notice", "Entered Ash Foundry. Kill The Ash Warden to complete the map.")

	return true


static func update_encounter(arena: Node, state: Object, player: Node3D, delta: float) -> void:
	if arena == null or player == null or state == null:
		return
	if not bool(arena.get_meta("rf36_vertical_slice_active", false)):
		return

	_update_hazards(arena, state, player, delta)
	_update_enemy_roles(arena, state, player, delta)
	_update_combat_labels(arena, delta)


static func _spawn_ash_foundry_encounter(arena: Node, activity: Dictionary) -> void:
	_spawn_role_pack(arena, "ash_thrall", Vector3(-5.5, 0.0, -5.2), 4, false)
	_spawn_role_pack(arena, "ember_spitter", Vector3(4.8, 0.0, -4.2), 2, false)
	_spawn_role_pack(arena, "cinder_runner", Vector3(0.0, 0.0, -1.8), 3, false)
	_spawn_role_pack(arena, "furnace_brute", Vector3(-4.8, 0.0, 2.2), 1, true)
	_spawn_role_pack(arena, "chain_warden", Vector3(4.8, 0.0, 2.8), 1, true)
	_spawn_role_pack(arena, "forge_acolyte", Vector3(0.0, 0.0, 4.5), 2, false)
	_spawn_role(arena, "ash_warden", Vector3(0.0, 0.0, 7.0), true, true)


static func _spawn_role_pack(arena: Node, role_id: String, center: Vector3, count: int, elite: bool) -> void:
	for i: int in range(count):
		var angle: float = float(i) * TAU / maxf(1.0, float(count))
		var offset: Vector3 = Vector3(cos(angle), 0.0, sin(angle)) * (0.7 + 0.22 * float(i % 3))
		_spawn_role(arena, role_id, center + offset, elite and i == 0, false)


static func _spawn_role(arena: Node, role_id: String, position: Vector3, elite: bool, boss: bool) -> Node:
	var enemies_root: Node = arena.get("enemies_root") as Node
	if enemies_root == null:
		return null
	var before_count: int = enemies_root.get_child_count()
	arena.call("_spawn_enemy", position, elite, boss)
	if enemies_root.get_child_count() <= before_count:
		return null
	var enemy: Node = enemies_root.get_child(enemies_root.get_child_count() - 1)
	_configure_enemy_role(enemy, role_id, elite, boss)
	return enemy


static func _configure_enemy_role(enemy: Node, role_id: String, elite: bool, boss: bool) -> void:
	if enemy == null:
		return
	var data: Dictionary = Dictionary(ENEMY_ROLE_DATA.get(role_id, ENEMY_ROLE_DATA["ash_thrall"]))
	enemy.set_meta("rf36_role", role_id)
	enemy.set_meta("rf36_role_name", str(data.get("name", role_id)))
	enemy.set_meta("rf36_attack_cd", randf_range(0.35, 1.2))
	enemy.set_meta("rf36_phase", 1)

	var max_hp: float = float(enemy.get("max_hp")) * float(data.get("hp_mult", 1.0))
	if elite:
		max_hp *= 1.15
	if boss:
		max_hp *= 1.25
	enemy.set("max_hp", max_hp)
	enemy.set("hp", max_hp)
	enemy.set("damage", float(enemy.get("damage")) * float(data.get("damage_mult", 1.0)))
	enemy.set("speed", float(enemy.get("speed")) * float(data.get("speed_mult", 1.0)))
	enemy.set("radius", 0.75 if boss else float(enemy.get("radius")))
	_set_enemy_color(enemy, Color(data.get("color", Color.WHITE)), boss)
	_add_enemy_label(enemy, str(data.get("name", role_id)), boss)


static func _set_enemy_color(enemy: Node, color: Color, boss: bool) -> void:
	for child: Node in enemy.get_children():
		if child is MeshInstance3D:
			var mat: StandardMaterial3D = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.emission_enabled = true
			mat.emission = color * (0.18 if boss else 0.06)
			(child as MeshInstance3D).material_override = mat
			if boss:
				(child as MeshInstance3D).scale = Vector3(1.8, 1.65, 1.8)


static func _add_enemy_label(enemy: Node, label_text: String, boss: bool) -> void:
	var label: Label3D = Label3D.new()
	label.name = "RF36RoleLabel"
	label.text = label_text
	label.position = Vector3(0.0, 2.1 if boss else 1.45, 0.0)
	label.pixel_size = 0.018 if boss else 0.012
	label.modulate = Color(1.0, 0.86, 0.62) if boss else Color(0.85, 0.82, 0.72)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	enemy.add_child(label)


static func _update_enemy_roles(arena: Node, state: Object, player: Node3D, delta: float) -> void:
	var enemies_root: Node = arena.get("enemies_root") as Node
	if enemies_root == null:
		return
	for enemy_node: Node in enemies_root.get_children():
		if enemy_node == null or not is_instance_valid(enemy_node):
			continue
		if not bool(enemy_node.get("alive")):
			continue
		var role_id: String = str(enemy_node.get_meta("rf36_role", ""))
		if role_id == "":
			continue
		var cd: float = float(enemy_node.get_meta("rf36_attack_cd", 0.0)) - delta
		enemy_node.set_meta("rf36_attack_cd", cd)
		if cd > 0.0:
			continue
		match role_id:
			"ember_spitter":
				_spitter_attack(arena, state, player, enemy_node)
				enemy_node.set_meta("rf36_attack_cd", randf_range(1.25, 1.85))
			"furnace_brute":
				_brute_attack(arena, state, player, enemy_node)
				enemy_node.set_meta("rf36_attack_cd", randf_range(1.75, 2.45))
			"chain_warden":
				_warden_attack(arena, state, player, enemy_node)
				enemy_node.set_meta("rf36_attack_cd", randf_range(1.65, 2.2))
			"cinder_runner":
				_runner_attack(arena, state, player, enemy_node)
				enemy_node.set_meta("rf36_attack_cd", randf_range(0.45, 0.75))
			"forge_acolyte":
				_acolyte_attack(arena, state, player, enemy_node)
				enemy_node.set_meta("rf36_attack_cd", randf_range(2.0, 3.0))
			"ash_warden":
				_boss_attack(arena, state, player, enemy_node)
				enemy_node.set_meta("rf36_attack_cd", _boss_cooldown(enemy_node))
			_:
				enemy_node.set_meta("rf36_attack_cd", randf_range(0.9, 1.6))


static func _spitter_attack(arena: Node, state: Object, player: Node3D, enemy: Node) -> void:
	var enemy_pos: Vector3 = (enemy as Node3D).global_position
	var target: Vector3 = player.global_position
	_add_hazard(arena, target, 0.62, 0.52, float(enemy.get("damage")) * 1.05, Color(1.0, 0.36, 0.05), "ember bolt")
	_add_line_marker(arena, enemy_pos, target, Color(1.0, 0.30, 0.05), 0.52)


static func _brute_attack(arena: Node, state: Object, player: Node3D, enemy: Node) -> void:
	var target: Vector3 = (enemy as Node3D).global_position.lerp(player.global_position, 0.72)
	_add_hazard(arena, target, 1.35, 0.85, float(enemy.get("damage")) * 1.45, Color(1.0, 0.18, 0.04), "molten slam")


static func _warden_attack(arena: Node, state: Object, player: Node3D, enemy: Node) -> void:
	var enemy_pos: Vector3 = (enemy as Node3D).global_position
	var player_pos: Vector3 = player.global_position
	_add_hazard(arena, player_pos, 0.95, 0.70, float(enemy.get("damage")) * 0.85, Color(0.25, 0.55, 1.0), "chain snare")
	_add_line_marker(arena, enemy_pos, player_pos, Color(0.25, 0.55, 1.0), 0.70)
	state.set("move_speed", maxf(3.6, float(state.get("move_speed")) * 0.985))


static func _runner_attack(arena: Node, state: Object, player: Node3D, enemy: Node) -> void:
	var enemy_pos: Vector3 = (enemy as Node3D).global_position
	if enemy_pos.distance_to(player.global_position) <= 1.55:
		_add_hazard(arena, enemy_pos, 1.45, 0.20, float(enemy.get("damage")) * 2.0, Color(1.0, 0.08, 0.02), "cinder detonation")
		if enemy.has_method("take_damage"):
			enemy.call("take_damage", 99999.0)
	else:
		enemy.set_meta("rf36_attack_cd", 0.15)


static func _acolyte_attack(arena: Node, state: Object, player: Node3D, enemy: Node) -> void:
	var center: Vector3 = (enemy as Node3D).global_position
	_add_hazard(arena, center, 1.75, 1.15, float(enemy.get("damage")) * 0.70, Color(0.74, 0.10, 0.90), "forge rite")
	var enemies_root: Node = arena.get("enemies_root") as Node
	if enemies_root == null:
		return
	for other: Node in enemies_root.get_children():
		if other != null and other != enemy and bool(other.get("alive")):
			if (other as Node3D).global_position.distance_to(center) <= 3.2:
				other.set("damage", float(other.get("damage")) * 1.015)


static func _boss_attack(arena: Node, state: Object, player: Node3D, boss: Node) -> void:
	if boss == null or not boss.has_method("health_ratio"):
		return
	var ratio: float = float(boss.call("health_ratio"))
	var phase: int = 1
	if ratio <= 0.35:
		phase = 3
	elif ratio <= 0.68:
		phase = 2
	var previous_phase: int = int(boss.get_meta("rf36_phase", 1))
	if phase != previous_phase:
		boss.set_meta("rf36_phase", phase)
		if state.has_method("add_notice"):
			state.call("add_notice", "The Ash Warden enters phase " + str(phase) + ".")
		if phase == 2:
			_spawn_role_pack(arena, "ash_thrall", (boss as Node3D).global_position + Vector3(-2.2, 0.0, -1.5), 2, false)
			_spawn_role_pack(arena, "ember_spitter", (boss as Node3D).global_position + Vector3(2.2, 0.0, -1.5), 1, false)
		elif phase == 3:
			_spawn_role_pack(arena, "cinder_runner", (boss as Node3D).global_position + Vector3(0.0, 0.0, -2.4), 2, false)

	var boss_pos: Vector3 = (boss as Node3D).global_position
	var target: Vector3 = player.global_position
	match phase:
		1:
			_add_hazard(arena, target, 1.55, 0.95, float(boss.get("damage")) * 1.15, Color(1.0, 0.20, 0.05), "warden slam")
		2:
			_add_hazard(arena, target, 1.15, 0.65, float(boss.get("damage")) * 0.85, Color(1.0, 0.32, 0.05), "anvil drop")
			_add_line_hazard(arena, boss_pos, target, 0.42, 0.72, float(boss.get("damage")) * 0.75, Color(1.0, 0.45, 0.05), "forge line")
		_:
			_add_hazard(arena, target, 1.35, 0.48, float(boss.get("damage")) * 0.95, Color(1.0, 0.12, 0.04), "final bell")
			_add_hazard(arena, boss_pos + (target - boss_pos).normalized() * 2.0, 2.0, 0.72, float(boss.get("damage")) * 0.70, Color(1.0, 0.25, 0.05), "aftershock")


static func _boss_cooldown(boss: Node) -> float:
	var phase: int = int(boss.get_meta("rf36_phase", 1))
	if phase == 3:
		return randf_range(0.95, 1.25)
	if phase == 2:
		return randf_range(1.15, 1.55)
	return randf_range(1.35, 1.85)


static func _add_hazard(arena: Node, center: Vector3, radius: float, delay: float, damage: float, color: Color, label: String) -> void:
	var hazards: Array = Array(arena.get_meta("rf36_hazards", []))
	hazards.append({
		"time": maxf(0.05, delay),
		"center": Vector3(center.x, 0.0, center.z),
		"radius": radius,
		"damage": damage,
		"label": label,
	})
	arena.set_meta("rf36_hazards", hazards)
	_add_disc_marker(arena, Vector3(center.x, 0.03, center.z), radius, color, delay)


static func _add_line_hazard(arena: Node, start: Vector3, end: Vector3, width: float, delay: float, damage: float, color: Color, label: String) -> void:
	var midpoint: Vector3 = start.lerp(end, 0.5)
	var length: float = start.distance_to(end)
	var hazards: Array = Array(arena.get_meta("rf36_hazards", []))
	hazards.append({
		"time": maxf(0.05, delay),
		"center": Vector3(midpoint.x, 0.0, midpoint.z),
		"radius": maxf(width, length * 0.18),
		"damage": damage,
		"label": label,
	})
	arena.set_meta("rf36_hazards", hazards)
	_add_line_marker(arena, start, end, color, delay)


static func _update_hazards(arena: Node, state: Object, player: Node3D, delta: float) -> void:
	var hazards: Array = Array(arena.get_meta("rf36_hazards", []))
	for i: int in range(hazards.size() - 1, -1, -1):
		var hazard: Dictionary = Dictionary(hazards[i])
		hazard["time"] = float(hazard.get("time", 0.0)) - delta
		if float(hazard.get("time", 0.0)) > 0.0:
			hazards[i] = hazard
			continue
		var center: Vector3 = Vector3(hazard.get("center", Vector3.ZERO))
		var radius: float = float(hazard.get("radius", 1.0))
		if player.global_position.distance_to(center) <= radius:
			_deal_player_damage(state, float(hazard.get("damage", 1.0)), str(hazard.get("label", "hazard")))
		hazards.remove_at(i)
	arena.set_meta("rf36_hazards", hazards)


static func _deal_player_damage(state: Object, raw_damage: float, source_name: String) -> void:
	var armor: float = float(state.get("armor"))
	var mitigation: float = armor / (armor + 220.0)
	var damage: float = maxf(0.0, raw_damage * (1.0 - mitigation))
	var hp: float = float(state.get("player_hp"))
	state.set("player_hp", maxf(0.0, hp - damage))
	if float(state.get("player_hp")) <= 0.0:
		state.set("deaths", int(state.get("deaths")) + 1)
		if state.has_method("add_notice"):
			state.call("add_notice", "You were killed by " + source_name + ". Press E if the map is clear, or return from the hub loop.")


static func _build_ash_foundry(arena: Node, activity: Dictionary) -> void:
	var decor_root: Node3D = arena.get("decor_root") as Node3D
	if decor_root == null:
		return
	_add_box(decor_root, "FoundryFloor", Vector3(0, -0.08, 0), Vector3(22, 0.16, 24), Color(0.105, 0.09, 0.075), false)
	_add_box(decor_root, "NorthForgeWall", Vector3(0, 1.15, -10.8), Vector3(22, 2.3, 0.55), Color(0.18, 0.13, 0.10), true)
	_add_box(decor_root, "SouthEntryWall", Vector3(0, 1.15, 11.0), Vector3(22, 2.3, 0.55), Color(0.18, 0.13, 0.10), true)
	_add_box(decor_root, "WestWall", Vector3(-10.8, 1.15, 0), Vector3(0.55, 2.3, 24), Color(0.18, 0.13, 0.10), true)
	_add_box(decor_root, "EastWall", Vector3(10.8, 1.15, 0), Vector3(0.55, 2.3, 24), Color(0.18, 0.13, 0.10), true)

	# Route structure: entry, side chambers, bridge, boss dais.
	_add_box(decor_root, "EntryThreshold", Vector3(0, 0.05, 8.8), Vector3(5.5, 0.14, 2.0), Color(0.16, 0.12, 0.09), false)
	_add_box(decor_root, "LeftFoundryWing", Vector3(-6.5, 0.02, 0.5), Vector3(5.5, 0.12, 8.5), Color(0.125, 0.095, 0.075), false)
	_add_box(decor_root, "RightFoundryWing", Vector3(6.5, 0.02, 0.5), Vector3(5.5, 0.12, 8.5), Color(0.125, 0.095, 0.075), false)
	_add_box(decor_root, "BossDais", Vector3(0, 0.05, -7.2), Vector3(7.0, 0.18, 4.2), Color(0.20, 0.12, 0.08), false)

	_add_box(decor_root, "LeftFurnace", Vector3(-8.5, 1.0, -4.9), Vector3(2.3, 2.0, 2.0), Color(0.25, 0.10, 0.045), true)
	_add_box(decor_root, "LeftFurnaceGlow", Vector3(-8.45, 0.75, -4.0), Vector3(1.5, 0.95, 0.18), Color(1.0, 0.28, 0.04), false)
	_add_box(decor_root, "RightFurnace", Vector3(8.5, 1.0, -4.9), Vector3(2.3, 2.0, 2.0), Color(0.25, 0.10, 0.045), true)
	_add_box(decor_root, "RightFurnaceGlow", Vector3(8.45, 0.75, -4.0), Vector3(1.5, 0.95, 0.18), Color(1.0, 0.28, 0.04), false)

	for i: int in range(5):
		var z: float = -6.8 + float(i) * 3.1
		_add_box(decor_root, "WestPillar" + str(i), Vector3(-9.2, 1.1, z), Vector3(0.7, 2.2, 0.7), Color(0.23, 0.17, 0.13), true)
		_add_box(decor_root, "EastPillar" + str(i), Vector3(9.2, 1.1, z), Vector3(0.7, 2.2, 0.7), Color(0.23, 0.17, 0.13), true)

	# Low blockers create readable combat lanes.
	_add_box(decor_root, "LowBlockA", Vector3(-2.7, 0.45, 1.0), Vector3(1.2, 0.9, 3.4), Color(0.22, 0.15, 0.11), true)
	_add_box(decor_root, "LowBlockB", Vector3(2.7, 0.45, -1.2), Vector3(1.2, 0.9, 3.4), Color(0.22, 0.15, 0.11), true)
	_add_box(decor_root, "AnvilLeft", Vector3(-5.7, 0.35, 4.8), Vector3(1.0, 0.7, 0.7), Color(0.16, 0.16, 0.16), true)
	_add_box(decor_root, "AnvilRight", Vector3(5.7, 0.35, 4.8), Vector3(1.0, 0.7, 0.7), Color(0.16, 0.16, 0.16), true)

	_add_light(decor_root, "FoundryBlueCore", Vector3(0, 4.2, -6.8), Color(0.25, 0.55, 1.0), 5.0, 10.0)
	_add_light(decor_root, "FoundryFireLeft", Vector3(-8.3, 2.4, -4.2), Color(1.0, 0.34, 0.05), 7.0, 9.0)
	_add_light(decor_root, "FoundryFireRight", Vector3(8.3, 2.4, -4.2), Color(1.0, 0.34, 0.05), 7.0, 9.0)
	_add_label(decor_root, "AshFoundryTitle", "ASH FOUNDRY", Vector3(0, 2.2, 9.2), Color(1.0, 0.72, 0.42), 0.026)


static func _add_box(parent: Node3D, name_value: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> Node3D:
	var root: Node3D
	if solid:
		var body: StaticBody3D = StaticBody3D.new()
		root = body
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
	else:
		root = Node3D.new()
	root.name = name_value
	root.position = pos
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color * 0.10
	mesh_instance.material_override = mat
	root.add_child(mesh_instance)
	parent.add_child(root)
	return root


static func _add_disc_marker(arena: Node, pos: Vector3, radius: float, color: Color, lifetime: float) -> void:
	var decor_root: Node3D = arena.get("decor_root") as Node3D
	if decor_root == null:
		return
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "RF36TelegraphDisc"
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.025
	mesh.radial_segments = 36
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, 0.35)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = color * 0.65
	mesh_instance.material_override = mat
	mesh_instance.set_meta("rf36_life", maxf(0.08, lifetime))
	decor_root.add_child(mesh_instance)


static func _add_line_marker(arena: Node, start: Vector3, end: Vector3, color: Color, lifetime: float) -> void:
	var decor_root: Node3D = arena.get("decor_root") as Node3D
	if decor_root == null:
		return
	var midpoint: Vector3 = start.lerp(end, 0.5)
	var length: float = start.distance_to(end)
	var marker: Node3D = _add_box(decor_root, "RF36TelegraphLine", Vector3(midpoint.x, 0.05, midpoint.z), Vector3(0.16, 0.035, length), color, false)
	var dir: Vector3 = end - start
	dir.y = 0.0
	if dir.length() > 0.01:
		marker.look_at(marker.global_position + dir.normalized(), Vector3.UP)
	marker.set_meta("rf36_life", maxf(0.08, lifetime))


static func _update_combat_labels(arena: Node, delta: float) -> void:
	var decor_root: Node3D = arena.get("decor_root") as Node3D
	if decor_root == null:
		return
	for child: Node in decor_root.get_children():
		if child == null or not child.has_meta("rf36_life"):
			continue
		var life: float = float(child.get_meta("rf36_life")) - delta
		child.set_meta("rf36_life", life)
		if life <= 0.0:
			child.queue_free()


static func _add_light(parent: Node3D, name_value: String, pos: Vector3, color: Color, energy: float, range_value: float) -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.name = name_value
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	parent.add_child(light)


static func _add_label(parent: Node3D, name_value: String, text_value: String, pos: Vector3, color: Color, pixel_size: float) -> void:
	var label: Label3D = Label3D.new()
	label.name = name_value
	label.text = text_value
	label.position = pos
	label.modulate = color
	label.pixel_size = pixel_size
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	parent.add_child(label)
