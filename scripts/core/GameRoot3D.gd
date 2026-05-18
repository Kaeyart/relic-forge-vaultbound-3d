class_name RVGameRoot3D
extends Node3D

const StateScript := preload("res://scripts/core/GameState3D.gd")
const SaveSystemScript := preload("res://scripts/core/SaveSystem3D.gd")

@onready var hub: RVVaultHub3D = %Hub3D
@onready var combat: RVCombatArena3D = %CombatArena3D
@onready var player: RVPlayerActor3D = %Player3D
@onready var camera: Camera3D = %Camera3D
@onready var hud: RVHUD3D = %HUD3D

var state: RVGameState3D = StateScript.new()
var autosave_timer: float = 0.0
var camera_offset: Vector3 = Vector3(0.0, 12.0, 10.5)

func _ready() -> void:
	set_process(true)
	state.reset_new()
	SaveSystemScript.load_into(state)
	_enter_hub(false)

func _process(delta: float) -> void:
	_update_player(delta)
	if state.mode == "hub":
		hub.update_focus(state)
	else:
		combat.update_combat(state, player, delta)
	if state.notice_time > 0.0:
		state.notice_time = max(0.0, state.notice_time - delta)
	_update_camera(delta)
	hud.update_from_state(state)
	autosave_timer += delta
	if autosave_timer >= 10.0:
		autosave_timer = 0.0
		SaveSystemScript.save(state)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo:
			_handle_key(key.keycode)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			_cast_selected_skill()

func _handle_key(keycode: int) -> void:
	if keycode >= KEY_1 and keycode <= KEY_6:
		state.selected_skill_index = clampi(keycode - KEY_1, 0, max(0, state.active_skills.size() - 1))
		return
	match keycode:
		KEY_E:
			if state.mode == "hub":
				var activity := hub.interact_primary(state)
				if not activity.is_empty():
					_start_activity(activity)
			elif state.mode == "combat" and combat.interact(state):
				_enter_hub(true)
		KEY_T:
			if state.mode == "hub":
				_start_activity({"kind": "map", "name": "3D Test Vault", "tier": 1, "map_level": state.level})
			else:
				_enter_hub(true)
		KEY_Z:
			state.use_life_flask()
		KEY_X:
			state.use_mana_flask()
		KEY_Q:
			state.selected_skill_index = wrapi(state.selected_skill_index - 1, 0, state.active_skills.size())
		KEY_R:
			state.selected_skill_index = wrapi(state.selected_skill_index + 1, 0, state.active_skills.size())
		KEY_SPACE:
			_cast_selected_skill()
		KEY_F5:
			SaveSystemScript.save(state)
			state.add_notice("Saved")

func _update_player(delta: float) -> void:
	var move := Vector3.ZERO
	if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_UP):
		move.z -= 1.0
	if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_DOWN):
		move.z += 1.0
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1.0
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1.0
	if move.length() > 0.01:
		move = move.normalized()
		state.player_pos += move * state.player_speed * delta
		player.face_direction(move)
	if state.mode == "combat":
		state.player_pos = combat.constrain_player_position(state.player_pos)
	else:
		state.player_pos.x = clamp(state.player_pos.x, -10.0, 10.0)
		state.player_pos.z = clamp(state.player_pos.z, -7.0, 7.0)
	state.player_mana = min(state.max_mana, state.player_mana + 7.0 * delta)
	player.sync_from_state(state)

func _update_camera(delta: float) -> void:
	var target_pos := state.player_pos + camera_offset
	camera.global_position = camera.global_position.lerp(target_pos, min(1.0, delta * 8.0))
	camera.look_at(state.player_pos, Vector3.UP)

func _cast_selected_skill() -> void:
	if state.mode != "combat":
		return
	var aim := _mouse_to_ground()
	combat.cast_selected_skill(state, state.player_pos, aim)

func _mouse_to_ground() -> Vector3:
	var viewport := get_viewport()
	var mouse_pos := viewport.get_mouse_position()
	var origin := camera.project_ray_origin(mouse_pos)
	var direction := camera.project_ray_normal(mouse_pos)
	if abs(direction.y) < 0.0001:
		return state.player_pos + Vector3.FORWARD
	var t := -origin.y / direction.y
	return origin + direction * t

func _start_activity(activity: Dictionary) -> void:
	state.active_map_entries = max(0, state.active_map_max_entries - 1)
	hub.visible = false
	combat.start_activity(state, activity)
	player.sync_from_state(state)
	state.add_notice("Entered " + str(activity.get("name", "3D map")))

func _enter_hub(from_activity: bool) -> void:
	state.mode = "hub"
	state.current_activity = {}
	state.player_pos = Vector3.ZERO
	state.full_restore()
	hub.visible = true
	combat.stop_activity()
	player.sync_from_state(state)
	if from_activity:
		state.add_notice("Returned to hub")

func on_enemy_killed_3d(elite: bool, boss: bool) -> void:
	state.on_enemy_killed(elite, boss)
