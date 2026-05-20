extends Node3D
class_name RVSkillVFXLayer3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")

var game_root: Node = null
var player_ref: Node3D = null
var camera_ref: Camera3D = null
var _live_effects: Array = []


func _ready() -> void:
	name = "SkillVFXLayer096D"
	set_process(true)
	set_process_unhandled_input(true)


func bind_game(root: Node) -> void:
	game_root = root
	_refresh_refs()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_combat_mode():
		return

	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			spawn_selected_skill_vfx()
			return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_SPACE:
			spawn_selected_skill_vfx()
			return


func _process(delta: float) -> void:
	_refresh_refs()
	_update_effects(delta)


func spawn_selected_skill_vfx() -> void:
	_refresh_refs()
	if player_ref == null or not is_instance_valid(player_ref):
		return

	var skill_id: String = _selected_skill_id()
	var origin: Vector3 = player_ref.global_position + Vector3(0.0, 0.55, 0.0)
	var direction: Vector3 = _aim_direction()

	match skill_id:
		"fireball":
			_spawn_fireball(origin, direction)
		"storm_lance":
			_spawn_storm_lance(origin, direction)
		"arc_slash":
			_spawn_arc_slash(origin, direction)
		"void_rift":
			_spawn_void_rift(_ground_target(origin, direction, 4.0))
		"ember_mine":
			_spawn_ember_mine(_ground_target(origin, direction, 2.6))
		_:
			_spawn_generic_cast(origin, direction)


func _spawn_fireball(origin: Vector3, direction: Vector3) -> void:
	var root: Node3D = Node3D.new()
	root.name = "FireballVFX096D"
	root.global_position = origin
	add_child(root)

	root.add_child(PrimitiveKitScript.sphere("FireballOrb", 0.22, Vector3.ZERO, VisualPaletteScript.ember_mat(0.95)))
	root.add_child(PrimitiveKitScript.sphere("FireballGlow", 0.42, Vector3.ZERO, VisualPaletteScript.ember_mat(0.26)))

	var tail: MeshInstance3D = PrimitiveKitScript.box("FireballTrail", Vector3(0.14, 0.14, 0.88), Vector3(0.0, 0.0, 0.52), VisualPaletteScript.ember_mat(0.38))
	tail.look_at(root.global_position - direction, Vector3.UP)
	root.add_child(tail)

	_live_effects.append({
		"node": root,
		"kind": "projectile",
		"time": 0.0,
		"duration": 0.72,
		"dir": direction,
		"speed": 10.0,
		"spawn_impact": true,
		"impact_kind": "fire",
	})


func _spawn_storm_lance(origin: Vector3, direction: Vector3) -> void:
	var root: Node3D = Node3D.new()
	root.name = "StormLanceVFX096D"
	root.global_position = origin + direction * 2.7
	root.look_at(origin + direction * 7.0, Vector3.UP)
	add_child(root)

	root.add_child(PrimitiveKitScript.box("StormBeam", Vector3(0.12, 0.12, 6.4), Vector3(0.0, 0.0, -3.2), VisualPaletteScript.blue_mat(0.62)))
	root.add_child(PrimitiveKitScript.box("StormCore", Vector3(0.05, 0.05, 6.8), Vector3(0.0, 0.0, -3.4), VisualPaletteScript.white_mat(0.82)))

	for i: int in range(4):
		var fork: MeshInstance3D = PrimitiveKitScript.box("StormFork", Vector3(0.05, 0.05, 1.1), Vector3(-0.45 + float(i) * 0.3, 0.0, -1.1 - float(i) * 0.9), VisualPaletteScript.blue_mat(0.52))
		fork.rotation.y = deg_to_rad(25.0 if i % 2 == 0 else -25.0)
		root.add_child(fork)

	_live_effects.append({"node": root, "kind": "flash", "time": 0.0, "duration": 0.22})


func _spawn_arc_slash(origin: Vector3, direction: Vector3) -> void:
	var root: Node3D = Node3D.new()
	root.name = "ArcSlashVFX096D"
	root.global_position = origin + direction * 1.35
	root.look_at(origin + direction * 3.0, Vector3.UP)
	root.scale = Vector3(0.82, 0.82, 0.82)
	add_child(root)

	var mat: Material = VisualPaletteScript.green_mat(0.42)
	for i: int in range(5):
		var x: float = -0.9 + float(i) * 0.45
		var blade: MeshInstance3D = PrimitiveKitScript.box("ArcSlashBlade", Vector3(0.16, 0.08, 1.4), Vector3(x, 0.0, -0.35), mat)
		blade.rotation.y = deg_to_rad(-34.0 + float(i) * 17.0)
		root.add_child(blade)

	root.add_child(PrimitiveKitScript.ground_disc("ArcShockRing", 1.35, Vector3(0.0, -0.48, -0.35), VisualPaletteScript.green_mat(0.22)))

	_live_effects.append({
		"node": root,
		"kind": "expand",
		"time": 0.0,
		"duration": 0.32,
		"start_scale": Vector3(0.82, 0.82, 0.82),
		"end_scale": Vector3(1.26, 1.26, 1.26),
	})


func _spawn_void_rift(pos: Vector3) -> void:
	var root: Node3D = Node3D.new()
	root.name = "VoidRiftVFX096D"
	root.global_position = Vector3(pos.x, 0.11, pos.z)
	root.scale = Vector3(0.55, 0.55, 0.55)
	add_child(root)

	root.add_child(PrimitiveKitScript.ground_disc("VoidRiftDisc", 1.35, Vector3.ZERO, VisualPaletteScript.violet_mat(0.34)))
	root.add_child(PrimitiveKitScript.sphere("VoidCore", 0.32, Vector3(0.0, 0.35, 0.0), VisualPaletteScript.violet_mat(0.68)))

	for i: int in range(6):
		var angle: float = TAU * float(i) / 6.0
		var spoke: MeshInstance3D = PrimitiveKitScript.box("VoidSpoke", Vector3(0.08, 0.04, 1.05), Vector3(sin(angle) * 0.45, 0.02, cos(angle) * 0.45), VisualPaletteScript.violet_mat(0.38))
		spoke.rotation.y = angle
		root.add_child(spoke)

	_live_effects.append({
		"node": root,
		"kind": "expand",
		"time": 0.0,
		"duration": 0.95,
		"start_scale": Vector3(0.55, 0.55, 0.55),
		"end_scale": Vector3(1.45, 1.45, 1.45),
	})


func _spawn_ember_mine(pos: Vector3) -> void:
	var root: Node3D = Node3D.new()
	root.name = "EmberMineVFX096D"
	root.global_position = Vector3(pos.x, 0.12, pos.z)
	add_child(root)

	root.add_child(PrimitiveKitScript.ground_disc("MineGlyph", 0.75, Vector3.ZERO, VisualPaletteScript.ember_mat(0.32)))
	root.add_child(PrimitiveKitScript.sphere("MineCore", 0.16, Vector3(0.0, 0.20, 0.0), VisualPaletteScript.ember_mat(0.92)))

	_live_effects.append({
		"node": root,
		"kind": "mine",
		"time": 0.0,
		"duration": 0.86,
		"exploded": false,
	})


func _spawn_generic_cast(origin: Vector3, direction: Vector3) -> void:
	var root: Node3D = Node3D.new()
	root.name = "GenericCastVFX096D"
	root.global_position = origin + direction * 1.0
	add_child(root)
	root.add_child(PrimitiveKitScript.sphere("GenericCastFlash", 0.34, Vector3.ZERO, VisualPaletteScript.white_mat(0.58)))
	_live_effects.append({"node": root, "kind": "flash", "time": 0.0, "duration": 0.22})


func _spawn_impact(pos: Vector3, kind: String) -> void:
	var root: Node3D = Node3D.new()
	root.name = "SkillImpactVFX096D"
	root.global_position = Vector3(pos.x, 0.12, pos.z)
	root.scale = Vector3(0.65, 0.65, 0.65)
	add_child(root)

	var mat: Material = VisualPaletteScript.ember_mat(0.38)
	if kind == "void":
		mat = VisualPaletteScript.violet_mat(0.38)
	elif kind == "storm":
		mat = VisualPaletteScript.blue_mat(0.38)

	root.add_child(PrimitiveKitScript.ground_disc("ImpactRing", 0.45, Vector3.ZERO, mat))
	root.add_child(PrimitiveKitScript.sphere("ImpactBurst", 0.22, Vector3(0.0, 0.28, 0.0), mat))

	_live_effects.append({
		"node": root,
		"kind": "expand",
		"time": 0.0,
		"duration": 0.34,
		"start_scale": Vector3(0.65, 0.65, 0.65),
		"end_scale": Vector3(2.0, 2.0, 2.0),
	})


func _update_effects(delta: float) -> void:
	for i: int in range(_live_effects.size() - 1, -1, -1):
		var value: Variant = _live_effects[i]
		if typeof(value) != TYPE_DICTIONARY:
			_live_effects.remove_at(i)
			continue

		var data: Dictionary = Dictionary(value)
		var node_value: Variant = data.get("node", null)
		if node_value == null or not is_instance_valid(node_value):
			_live_effects.remove_at(i)
			continue

		var node: Node3D = node_value as Node3D
		if node == null:
			_live_effects.remove_at(i)
			continue

		var time: float = _to_float(data.get("time", 0.0), 0.0) + delta
		var duration: float = max(0.01, _to_float(data.get("duration", 0.25), 0.25))
		var ratio: float = clampf(time / duration, 0.0, 1.0)
		var kind: String = str(data.get("kind", "flash"))

		if kind == "projectile":
			var direction: Vector3 = _dict_vec3(data, "dir", Vector3.FORWARD)
			var speed: float = _to_float(data.get("speed", 8.0), 8.0)
			node.global_position += direction * speed * delta
			node.scale = Vector3.ONE * (1.0 + sin(time * 18.0) * 0.07)
		elif kind == "flash":
			node.scale = Vector3.ONE * (1.0 + ratio * 1.6)
		elif kind == "expand":
			var start_scale: Vector3 = _dict_vec3(data, "start_scale", Vector3.ONE)
			var end_scale: Vector3 = _dict_vec3(data, "end_scale", Vector3.ONE)
			node.scale = start_scale.lerp(end_scale, ratio)
		elif kind == "mine":
			var pulse: float = 1.0 + sin(time * 16.0) * 0.12
			node.scale = Vector3(pulse, pulse, pulse)
			if time >= duration * 0.72 and not bool(data.get("exploded", false)):
				data["exploded"] = true
				_spawn_impact(node.global_position, "fire")

		data["time"] = time
		_live_effects[i] = data

		if time >= duration:
			if bool(data.get("spawn_impact", false)):
				_spawn_impact(node.global_position, str(data.get("impact_kind", "fire")))
			node.queue_free()
			_live_effects.remove_at(i)


func _selected_skill_id() -> String:
	var state_obj: Object = _state()
	if state_obj == null:
		return "fireball"

	var slot_index: int = _to_int(state_obj.get("selected_skill_slot"), 0)
	var slot_value: Variant = state_obj.get("active_skill_slots")
	var slots: Array = []
	if typeof(slot_value) == TYPE_ARRAY:
		slots = slot_value

	if slots.is_empty():
		return "fireball"

	slot_index = clampi(slot_index, 0, slots.size() - 1)
	if typeof(slots[slot_index]) != TYPE_DICTIONARY:
		return "fireball"

	var slot: Dictionary = Dictionary(slots[slot_index])
	if slot.has("active"):
		return str(slot.get("active"))
	if slot.has("active_id"):
		return str(slot.get("active_id"))
	if slot.has("gem_id"):
		return str(slot.get("gem_id"))
	return "fireball"


func _aim_direction() -> Vector3:
	var fallback: Vector3 = -player_ref.global_transform.basis.z
	fallback.y = 0.0
	if fallback.length() > 0.01:
		fallback = fallback.normalized()
	else:
		fallback = Vector3.FORWARD

	var target: Vector3 = _mouse_world_point()
	if target != Vector3.INF:
		var dir: Vector3 = target - player_ref.global_position
		dir.y = 0.0
		if dir.length() > 0.01:
			return dir.normalized()

	return fallback


func _mouse_world_point() -> Vector3:
	if camera_ref == null or not is_instance_valid(camera_ref):
		return Vector3.INF

	var viewport: Viewport = get_viewport()
	if viewport == null:
		return Vector3.INF

	var mouse_pos: Vector2 = viewport.get_mouse_position()
	var ray_origin: Vector3 = camera_ref.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = camera_ref.project_ray_normal(mouse_pos)
	if abs(ray_dir.y) <= 0.001:
		return Vector3.INF

	var t: float = -ray_origin.y / ray_dir.y
	if t < 0.0:
		return Vector3.INF
	return ray_origin + ray_dir * t


func _ground_target(origin: Vector3, direction: Vector3, distance: float) -> Vector3:
	var mouse_target: Vector3 = _mouse_world_point()
	if mouse_target != Vector3.INF:
		return mouse_target
	return origin + direction * distance


func _refresh_refs() -> void:
	if game_root != null:
		var player_node: Node = game_root.get_node_or_null("Player")
		if player_node != null and player_node is Node3D:
			player_ref = player_node as Node3D

		var camera_node: Node = game_root.get_node_or_null("Camera3D")
		if camera_node != null and camera_node is Camera3D:
			camera_ref = camera_node as Camera3D

	if player_ref == null or not is_instance_valid(player_ref):
		var scene: Node = get_tree().current_scene
		if scene != null:
			var found_player: Node = scene.get_node_or_null("Player")
			if found_player != null and found_player is Node3D:
				player_ref = found_player as Node3D

	if camera_ref == null or not is_instance_valid(camera_ref):
		camera_ref = get_viewport().get_camera_3d()


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
		_:
			return fallback


func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
