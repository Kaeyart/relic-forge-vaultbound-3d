extends Node3D
class_name RVCombatFeedbackLayer3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")
const RuntimeDetectionSystemScript := preload("res://scripts/systems/RuntimeDetectionSystem3D.gd")

var game_root: Node = null
var _scan_timer: float = 0.0
var _enemy_states: Dictionary = {}
var _floaters: Array = []
var _bursts: Array = []


func _ready() -> void:
	name = "CombatFeedbackLayer096G"
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root


func _process(delta: float) -> void:
	if not _is_combat_mode():
		visible = false
		return

	visible = true
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.22
		_scan_enemies()

	_update_enemy_feedback(delta)
	_update_floaters(delta)
	_update_bursts(delta)


func _scan_enemies() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return

	var candidates: Array = []
	_collect_enemy_candidates(scene, candidates)

	for value: Variant in candidates:
		if value == null or not is_instance_valid(value):
			continue
		if not (value is Node3D):
			continue

		var enemy: Node3D = value as Node3D
		var id: int = enemy.get_instance_id()
		if not _enemy_states.has(id):
			_register_enemy(enemy)


func _register_enemy(enemy: Node3D) -> void:
	var hp: float = _read_hp(enemy)
	var max_hp: float = _read_max_hp(enemy, hp)
	var decorator: Node3D = _ensure_decorator(enemy)

	_enemy_states[enemy.get_instance_id()] = {
		"enemy": enemy,
		"last_hp": hp,
		"max_hp": max_hp,
		"decorator": decorator,
		"dead": false,
		"flash_time": 0.0,
	}


func _ensure_decorator(enemy: Node3D) -> Node3D:
	var existing: Node = enemy.get_node_or_null("CombatFeedbackDecorator096G")
	if existing != null and existing is Node3D:
		return existing as Node3D

	var root: Node3D = Node3D.new()
	root.name = "CombatFeedbackDecorator096G"
	RuntimeDetectionSystemScript.mark_generated_visual(root, "combat_feedback")
	enemy.add_child(root)
	root.position = Vector3.ZERO

	var rarity: String = str(enemy.get_meta("rv_enemy_rarity", "normal"))
	var color: Color = _rarity_color(rarity)

	var back_mat: Material = VisualPaletteScript.material("Enemy HP Back", Color(0.025, 0.020, 0.018, 0.82), false, 0.0, 0.82)
	var fill_mat: Material = VisualPaletteScript.material("Enemy HP Fill " + rarity, color, rarity != "normal", 0.65, 0.95)
	var tick_mat: Material = VisualPaletteScript.material("Enemy HP Tick", Color(1.0, 1.0, 1.0, 0.55), false, 0.0, 0.55)

	root.add_child(PrimitiveKitScript.box("HPBarBack", Vector3(1.22, 0.055, 0.075), Vector3(0.0, 1.82, 0.0), back_mat))
	root.add_child(PrimitiveKitScript.box("HPBarFill", Vector3(1.16, 0.065, 0.085), Vector3(0.0, 1.825, -0.006), fill_mat))
	root.add_child(PrimitiveKitScript.box("HPBarLeftTick", Vector3(0.035, 0.12, 0.09), Vector3(-0.63, 1.825, -0.005), tick_mat))
	root.add_child(PrimitiveKitScript.box("HPBarRightTick", Vector3(0.035, 0.12, 0.09), Vector3(0.63, 1.825, -0.005), tick_mat))

	if rarity == "magic" or rarity == "rare":
		var label: Label3D = PrimitiveKitScript.label_3d("EnemyTierTinyLabel", rarity.capitalize(), Vector3(0.0, 2.03, 0.0), color)
		label.font_size = 13
		root.add_child(label)

	var flash_mat: Material = VisualPaletteScript.material("Hit Flash Idle", Color(1.0, 0.95, 0.72, 0.0), true, 1.0, 0.0)
	var flash: MeshInstance3D = PrimitiveKitScript.sphere("HitFlash", 0.72, Vector3(0.0, 0.75, 0.0), flash_mat)
	flash.visible = false
	root.add_child(flash)

	return root


func _update_enemy_feedback(delta: float) -> void:
	var ids: Array = _enemy_states.keys()
	for id_value: Variant in ids:
		var id: int = int(id_value)
		var data: Dictionary = Dictionary(_enemy_states.get(id, {}))
		var enemy_value: Variant = data.get("enemy", null)

		if enemy_value == null or not is_instance_valid(enemy_value):
			_enemy_states.erase(id)
			continue

		var enemy: Node3D = enemy_value as Node3D
		if enemy == null:
			_enemy_states.erase(id)
			continue

		var hp: float = _read_hp(enemy)
		var max_hp: float = _read_max_hp(enemy, _to_float(data.get("max_hp", hp), hp))
		max_hp = max(1.0, max_hp)

		var last_hp: float = _to_float(data.get("last_hp", hp), hp)
		var delta_hp: float = last_hp - hp

		if delta_hp > 0.01:
			_spawn_damage_number(enemy.global_position + Vector3(0.0, 2.25, 0.0), int(round(delta_hp)), str(enemy.get_meta("rv_enemy_rarity", "normal")))
			data["flash_time"] = 0.18

		var dead: bool = bool(data.get("dead", false))
		if hp <= 0.0 and not dead:
			data["dead"] = true
			_spawn_death_burst(enemy.global_position, str(enemy.get_meta("rv_enemy_rarity", "normal")))

		data["last_hp"] = hp
		data["max_hp"] = max_hp
		_update_decorator(data, hp, max_hp, delta)
		_enemy_states[id] = data


func _update_decorator(data: Dictionary, hp: float, max_hp: float, delta: float) -> void:
	var decorator_value: Variant = data.get("decorator", null)
	if decorator_value == null or not is_instance_valid(decorator_value):
		return

	var decorator: Node3D = decorator_value as Node3D
	if decorator == null:
		return

	var ratio: float = clampf(hp / max(1.0, max_hp), 0.0, 1.0)
	var fill_node: Node = decorator.get_node_or_null("HPBarFill")
	if fill_node != null and fill_node is MeshInstance3D:
		var fill: MeshInstance3D = fill_node as MeshInstance3D
		fill.scale.x = max(0.001, ratio)
		fill.position.x = -0.58 + 0.58 * ratio

	var flash_time: float = _to_float(data.get("flash_time", 0.0), 0.0)
	var flash_node: Node = decorator.get_node_or_null("HitFlash")
	if flash_node != null and flash_node is MeshInstance3D:
		var flash: MeshInstance3D = flash_node as MeshInstance3D
		if flash_time > 0.0:
			flash.visible = true
			flash_time = max(0.0, flash_time - delta)
			var alpha: float = clampf(flash_time / 0.18, 0.0, 1.0) * 0.34
			flash.scale = Vector3.ONE * (1.0 + (1.0 - alpha) * 0.25)
			flash.set_surface_override_material(0, VisualPaletteScript.material("Runtime Hit Flash", Color(1.0, 0.88, 0.45, alpha), true, 1.0, alpha))
			data["flash_time"] = flash_time
		else:
			flash.visible = false


func _spawn_damage_number(pos: Vector3, amount: int, rarity: String) -> void:
	var color: Color = _rarity_color(rarity)
	var label: Label3D = Label3D.new()
	label.name = "FloatingDamage096G"
	label.text = "-" + str(max(1, amount))
	label.font_size = 28 if rarity == "rare" else 23
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	label.global_position = pos
	add_child(label)

	_floaters.append({
		"node": label,
		"time": 0.0,
		"duration": 0.62,
		"velocity": Vector3(randf_range(-0.35, 0.35), 1.45, randf_range(-0.15, 0.15)),
	})


func _spawn_death_burst(pos: Vector3, rarity: String) -> void:
	var color: Color = _rarity_color(rarity)
	var mat: Material = VisualPaletteScript.material("Death Burst " + rarity, color, rarity != "normal", 1.0, 0.48)

	var root: Node3D = Node3D.new()
	root.name = "EnemyDeathBurst096G"
	root.global_position = pos + Vector3(0.0, 0.4, 0.0)
	add_child(root)

	var count: int = 7
	if rarity == "magic":
		count = 9
	elif rarity == "rare":
		count = 13

	for i: int in range(count):
		var angle: float = TAU * float(i) / float(count)
		var shard: MeshInstance3D = PrimitiveKitScript.box("DeathShard", Vector3(0.10, 0.10, 0.46), Vector3.ZERO, mat)
		shard.rotation.y = angle
		root.add_child(shard)

		_bursts.append({
			"node": shard,
			"dir": Vector3(sin(angle), randf_range(0.25, 0.85), cos(angle)).normalized(),
			"time": 0.0,
			"duration": 0.55,
			"speed": randf_range(2.6, 4.4),
		})


func _update_floaters(delta: float) -> void:
	for i: int in range(_floaters.size() - 1, -1, -1):
		var data: Dictionary = Dictionary(_floaters[i])
		var node_value: Variant = data.get("node", null)
		if node_value == null or not is_instance_valid(node_value):
			_floaters.remove_at(i)
			continue

		var node: Label3D = node_value as Label3D
		if node == null:
			_floaters.remove_at(i)
			continue

		var time: float = _to_float(data.get("time", 0.0), 0.0) + delta
		var duration: float = max(0.01, _to_float(data.get("duration", 0.6), 0.6))
		var velocity: Vector3 = _dict_vec3(data, "velocity", Vector3.UP)
		var ratio: float = clampf(time / duration, 0.0, 1.0)

		node.global_position += velocity * delta
		var c: Color = node.modulate
		c.a = 1.0 - ratio
		node.modulate = c
		data["time"] = time
		_floaters[i] = data

		if time >= duration:
			node.queue_free()
			_floaters.remove_at(i)


func _update_bursts(delta: float) -> void:
	for i: int in range(_bursts.size() - 1, -1, -1):
		var data: Dictionary = Dictionary(_bursts[i])
		var node_value: Variant = data.get("node", null)
		if node_value == null or not is_instance_valid(node_value):
			_bursts.remove_at(i)
			continue

		var node: Node3D = node_value as Node3D
		if node == null:
			_bursts.remove_at(i)
			continue

		var time: float = _to_float(data.get("time", 0.0), 0.0) + delta
		var duration: float = max(0.01, _to_float(data.get("duration", 0.55), 0.55))
		var direction: Vector3 = _dict_vec3(data, "dir", Vector3.UP)
		var speed: float = _to_float(data.get("speed", 3.0), 3.0)
		var ratio: float = clampf(time / duration, 0.0, 1.0)

		node.global_position += direction * speed * delta * (1.0 - ratio * 0.5)
		node.scale = Vector3.ONE * max(0.05, 1.0 - ratio)
		data["time"] = time
		_bursts[i] = data

		if time >= duration:
			node.queue_free()
			_bursts.remove_at(i)


func _collect_enemy_candidates(root: Node, out: Array) -> void:
	for child: Node in root.get_children():
		if _looks_like_enemy(child):
			out.append(child)
		_collect_enemy_candidates(child, out)


func _looks_like_enemy(node: Node) -> bool:
	return RuntimeDetectionSystemScript.is_real_enemy(node)

func _read_hp(enemy: Object) -> float:
	for prop: String in ["hp", "current_hp", "health", "current_health"]:
		if _has_property(enemy, prop):
			return _to_float(enemy.get(prop), 1.0)
	return 1.0


func _read_max_hp(enemy: Object, fallback: float) -> float:
	for prop: String in ["max_hp", "health_max", "max_health"]:
		if _has_property(enemy, prop):
			return max(1.0, _to_float(enemy.get(prop), fallback))
	return max(1.0, fallback)


func _has_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false
	var props: Array = obj.get_property_list()
	for value: Variant in props:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(value)
		if str(data.get("name", "")) == prop:
			return true
	return false


func _rarity_color(rarity: String) -> Color:
	match rarity.strip_edges().to_lower():
		"magic":
			return Color(0.34, 0.56, 1.0, 1.0)
		"rare":
			return Color(1.0, 0.76, 0.18, 1.0)
		"unique":
			return Color(1.0, 0.42, 0.12, 1.0)
		_:
			return Color(0.92, 0.92, 0.86, 1.0)


func _is_combat_mode() -> bool:
	var state_obj: Object = _state()
	if state_obj == null:
		return false
	return str(state_obj.get("mode")) == "combat"


func _state() -> Object:
	if game_root == null:
		return null
	var state_value: Variant = game_root.get("state")
	if state_value != null and state_value is Object:
		return state_value as Object
	return null


func _dict_vec3(data: Dictionary, key: String, fallback: Vector3) -> Vector3:
	var value: Variant = data.get(key, fallback)
	if typeof(value) == TYPE_VECTOR3:
		return value
	return fallback


func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(int(value))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		_:
			return fallback
