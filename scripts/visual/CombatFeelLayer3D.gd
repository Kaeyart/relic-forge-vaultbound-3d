extends Node3D
class_name RVCombatFeelLayer3D

const RuntimeDetectionSystemScript := preload("res://scripts/systems/RuntimeDetectionSystem3D.gd")
const CombatFeelSystemScript := preload("res://scripts/systems/CombatFeelSystem3D.gd")

var game_root: Node = null
var _enemy_hp_cache: Dictionary = {}
var _pulse_root: Node3D = null
var _player_ring: MeshInstance3D = null
var _time: float = 0.0
var _scan_timer: float = 0.0
var _known_enemies: Array[Node] = []


func _ready() -> void:
	name = "CombatFeelLayer098B"
	RuntimeDetectionSystemScript.mark_generated_visual(self, "combat_feel")
	_ensure_roots()
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root


func _process(delta: float) -> void:
	_time += delta
	_ensure_roots()
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.10
		_scan_enemies()
		_update_player_focus()
	_update_enemy_rings()
	_update_pulses(delta)


func _ensure_roots() -> void:
	if _pulse_root == null or not is_instance_valid(_pulse_root):
		_pulse_root = get_node_or_null("CombatFeelPulses098B") as Node3D
		if _pulse_root == null:
			_pulse_root = Node3D.new()
			_pulse_root.name = "CombatFeelPulses098B"
			add_child(_pulse_root)
			RuntimeDetectionSystemScript.mark_generated_visual(_pulse_root, "combat_feel")


func _scan_enemies() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		scene = game_root
	if scene == null:
		return
	var enemies: Array = []
	RuntimeDetectionSystemScript.collect_enemy_candidates(scene, enemies)
	_known_enemies.clear()
	for value: Variant in enemies:
		if value is Node:
			var enemy: Node = value
			if not is_instance_valid(enemy):
				continue
			_known_enemies.append(enemy)
			_track_enemy_hp(enemy)
			_ensure_enemy_ring(enemy)


func _track_enemy_hp(enemy: Node) -> void:
	var id: int = enemy.get_instance_id()
	var hp: float = CombatFeelSystemScript.enemy_hp(enemy)
	if hp < 0.0:
		return
	if not _enemy_hp_cache.has(id):
		_enemy_hp_cache[id] = hp
		return
	var previous: float = float(_enemy_hp_cache[id])
	if hp < previous:
		_spawn_hit_pulse(enemy, previous - hp)
	_enemy_hp_cache[id] = hp


func _ensure_enemy_ring(enemy: Node) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	var enemy_3d: Node3D = enemy as Node3D
	if enemy_3d == null:
		return
	var ring: MeshInstance3D = enemy_3d.get_node_or_null("CombatFeelThreatRing098B") as MeshInstance3D
	if ring == null:
		ring = _make_disc("CombatFeelThreatRing098B", 1.0, Color(1.0, 1.0, 1.0, 0.25), 48)
		ring.position = Vector3(0.0, 0.035, 0.0)
		enemy_3d.add_child(ring)
		RuntimeDetectionSystemScript.mark_generated_visual(ring, "combat_feel")
	_update_enemy_ring_material(enemy, ring)


func _update_enemy_rings() -> void:
	for enemy: Node in _known_enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if not CombatFeelSystemScript.enemy_alive(enemy):
			continue
		var enemy_3d: Node3D = enemy as Node3D
		if enemy_3d == null:
			continue
		var ring: MeshInstance3D = enemy_3d.get_node_or_null("CombatFeelThreatRing098B") as MeshInstance3D
		if ring == null:
			continue
		var radius: float = CombatFeelSystemScript.threat_ring_radius(enemy)
		var pulse: float = (sin(_time * 5.5) + 1.0) * 0.5
		if CombatFeelSystemScript.enemy_rarity(enemy) == "normal":
			pulse = 0.0
		ring.scale = Vector3(radius, 1.0, radius) * (1.0 + pulse * 0.04)
		_update_enemy_ring_material(enemy, ring, pulse)


func _update_enemy_ring_material(enemy: Node, ring: MeshInstance3D, pulse: float = 0.0) -> void:
	var color: Color = CombatFeelSystemScript.rarity_color(CombatFeelSystemScript.enemy_rarity(enemy))
	color.a = CombatFeelSystemScript.threat_ring_alpha(enemy, pulse)
	ring.material_override = _mat("CombatFeelThreat", color)


func _spawn_hit_pulse(enemy: Node, damage: float) -> void:
	if _pulse_root == null:
		return
	if enemy == null or not is_instance_valid(enemy):
		return
	var enemy_3d: Node3D = enemy as Node3D
	if enemy_3d == null:
		return
	var root: Node3D = Node3D.new()
	root.name = "CombatFeelHitPulse098B"
	root.global_position = enemy_3d.global_position + Vector3(0.0, 0.07, 0.0)
	root.set_meta("life", 0.42)
	root.set_meta("max_life", 0.42)
	root.set_meta("base_radius", CombatFeelSystemScript.threat_ring_radius(enemy) * 0.7)
	_pulse_root.add_child(root)
	var color: Color = CombatFeelSystemScript.hit_color(damage, enemy)
	var disc: MeshInstance3D = _make_disc("CombatFeelHitRing", 1.0, Color(color.r, color.g, color.b, 0.58), 48)
	root.add_child(disc)
	var label: Label3D = Label3D.new()
	label.name = "CombatFeelDamageLabel"
	label.text = CombatFeelSystemScript.hit_label(damage)
	label.font_size = 22
	label.modulate = color
	label.position = Vector3(0.0, 1.15, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(label)
	RuntimeDetectionSystemScript.mark_generated_visual(root, "combat_feel")


func _update_pulses(delta: float) -> void:
	if _pulse_root == null:
		return
	for child: Node in _pulse_root.get_children():
		if not (child is Node3D):
			child.queue_free()
			continue
		var node: Node3D = child as Node3D
		var life: float = float(node.get_meta("life", 0.0)) - delta
		var max_life: float = max(0.01, float(node.get_meta("max_life", 0.42)))
		var base_radius: float = float(node.get_meta("base_radius", 0.7))
		if life <= 0.0:
			node.queue_free()
			continue
		node.set_meta("life", life)
		var t: float = 1.0 - life / max_life
		var scale_value: float = base_radius * (0.7 + t * 1.15)
		node.scale = Vector3(scale_value, 1.0, scale_value)
		node.position.y += delta * 0.55
		for sub: Node in node.get_children():
			if sub is Label3D:
				var label: Label3D = sub as Label3D
				var c: Color = label.modulate
				c.a = clampf(1.0 - t, 0.0, 1.0)
				label.modulate = c
			elif sub is MeshInstance3D:
				var mesh_node: MeshInstance3D = sub as MeshInstance3D
				if mesh_node.material_override is StandardMaterial3D:
					var mat: StandardMaterial3D = mesh_node.material_override as StandardMaterial3D
					var c2: Color = mat.albedo_color
					c2.a = clampf(0.55 * (1.0 - t), 0.0, 0.55)
					mat.albedo_color = c2


func _update_player_focus() -> void:
	var player: Node3D = _find_player()
	if player == null:
		return
	if _player_ring == null or not is_instance_valid(_player_ring):
		_player_ring = _make_disc("CombatFeelPlayerFocusRing098B", 1.15, CombatFeelSystemScript.player_focus_color(), 64)
		_player_ring.position = Vector3(0.0, 0.028, 0.0)
		player.add_child(_player_ring)
		RuntimeDetectionSystemScript.mark_generated_visual(_player_ring, "combat_feel")
	var pulse: float = (sin(_time * 3.0) + 1.0) * 0.5
	_player_ring.scale = Vector3.ONE * (1.0 + pulse * 0.025)


func _find_player() -> Node3D:
	var scene: Node = get_tree().current_scene
	if scene == null:
		scene = game_root
	if scene == null:
		return null
	for group_name: String in ["player", "players", "hero"]:
		var nodes: Array = get_tree().get_nodes_in_group(group_name)
		for value: Variant in nodes:
			if value is Node3D and is_instance_valid(value):
				return value as Node3D
	return _find_player_recursive(scene)


func _find_player_recursive(root: Node) -> Node3D:
	if root == null:
		return null
	var lower_name: String = str(root.name).to_lower()
	if root is Node3D:
		if lower_name.find("player") >= 0 or lower_name.find("hero") >= 0 or lower_name.find("character") >= 0:
			if not RuntimeDetectionSystemScript.is_generated_visual(root, true):
				return root as Node3D
	for child: Node in root.get_children():
		var found: Node3D = _find_player_recursive(child)
		if found != null:
			return found
	return null


func _make_disc(node_name: String, radius: float, color: Color, radial_segments: int = 48) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.025
	mesh.radial_segments = radial_segments
	mesh.rings = 1
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.material_override = _mat(node_name, color)
	return node


func _mat(label: String, color: Color) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.resource_name = label
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
	return mat
