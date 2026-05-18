class_name RVGameRoot3D
extends Node3D

const GameStateScript := preload("res://scripts/core/GameState3D.gd")
const SaveSystemScript := preload("res://scripts/systems/SaveSystem3D.gd")
const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

@onready var hub: Node3D = $Hub
@onready var combat: RVCombatArena3D = $Combat
@onready var player: RVPlayerActor3D = $Player
@onready var camera: Camera3D = $Camera3D
@onready var hud: Node = $HUD
@onready var skill_panel: Node = $SkillLoadoutPanel

var state: RVGameState3D = GameStateScript.new()
var autosave_timer: float = 0.0

func _ready() -> void:
	if not SaveSystemScript.load_into(state):
		state.init_new()
	state.ensure_defaults()
	state.mode = "hub"
	state.player_pos = Vector3(0, 0, 2.5)
	if hub.has_method("setup"):
		hub.call("setup")
	combat.visible = false
	player.sync_from_state(state)
	_update_camera(0.0)
	set_process(true)

func _process(delta: float) -> void:
	state.update_resources(delta)
	_update_player(delta)
	if state.mode == "hub":
		state.prompt_text = hub.call("prompt_for_player", player.global_position) if hub.has_method("prompt_for_player") else "Hub"
	elif state.mode == "combat":
		combat.update_combat(state, player, delta)
		if float(state.player_hp) <= 0.0:
			_return_to_hub("Returned to hub after death")
	autosave_timer += delta
	if autosave_timer >= 15.0:
		autosave_timer = 0.0
		SaveSystemScript.save(state)
	_update_ui()
	_update_camera(delta)

func _update_player(delta: float) -> void:
	if state.panel_mode != "":
		player.sync_from_state(state)
		return
	var move: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move.z -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move.z += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1.0
	if move.length() > 0.01:
		move = move.normalized()
		state.player_pos += move * float(state.player_speed) * float(state.movement_speed_mult) * delta
	if state.mode == "combat":
		state.player_pos = combat.constrain_player_position(state.player_pos)
	else:
		state.player_pos = Vector3(clampf(state.player_pos.x, -8.0, 8.0), 0.0, clampf(state.player_pos.z, -8.0, 8.0))
	player.sync_from_state(state)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and not key_event.echo:
			_handle_key(key_event.keycode)
	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT and state.panel_mode == "" and state.mode == "combat":
			_cast_selected_skill()

func _handle_key(keycode: int) -> void:
	match keycode:
		KEY_F8:
			state.panel_mode = ""
			state.add_notice("UI lock cleared")
		KEY_F5:
			SaveSystemScript.save(state)
			state.add_notice("Saved")
		KEY_ESCAPE:
			if state.panel_mode != "":
				state.panel_mode = ""
			elif state.mode == "combat":
				_return_to_hub("Returned to hub")
		KEY_H:
			_toggle_panel("help")
		KEY_I:
			_toggle_panel("inventory")
		KEY_C:
			_toggle_panel("character")
		KEY_M:
			_toggle_panel("maps")
		KEY_K:
			_toggle_panel("skills")
		KEY_Z:
			state.use_health_flask()
		KEY_X:
			state.use_mana_flask()
		KEY_Q:
			state.selected_skill_slot = wrapi(state.selected_skill_slot - 1, 0, 4)
		KEY_R:
			state.selected_skill_slot = wrapi(state.selected_skill_slot + 1, 0, 4)
		KEY_1, KEY_2, KEY_3, KEY_4:
			state.selected_skill_slot = keycode - KEY_1
		KEY_SPACE:
			if state.mode == "combat" and state.panel_mode == "":
				_cast_selected_skill()
		KEY_E:
			if state.mode == "hub":
				_start_map()
			elif state.mode == "combat" and combat.room_clear:
				_return_to_hub("Map complete")
		KEY_T:
			if state.mode == "hub":
				_start_map()
			elif state.mode == "combat":
				_return_to_hub("Town portal")
		KEY_BRACKETLEFT:
			state.inventory_cursor = clampi(state.inventory_cursor - 1, 0, max(0, state.inventory.size() - 1))
		KEY_BRACKETRIGHT:
			state.inventory_cursor = clampi(state.inventory_cursor + 1, 0, max(0, state.inventory.size() - 1))
		KEY_U:
			state.equip_inventory_item(state.inventory_cursor)

func _toggle_panel(mode_name: String) -> void:
	state.panel_mode = "" if state.panel_mode == mode_name else mode_name

func _start_map() -> void:
	state.ensure_defaults()
	state.mode = "combat"
	state.panel_mode = ""
	state.player_pos = Vector3(0, 0, -7)
	hub.visible = false
	combat.visible = true
	combat.start_map(state, {"map_level": max(1, state.level)})
	player.sync_from_state(state)
	state.add_notice("Entered Ash Vault")

func _return_to_hub(message: String) -> void:
	state.mode = "hub"
	state.panel_mode = ""
	state.player_pos = Vector3(0, 0, 2.5)
	state.full_restore()
	hub.visible = true
	combat.stop_map()
	player.sync_from_state(state)
	state.add_notice(message)
	SaveSystemScript.save(state)

func _cast_selected_skill() -> void:
	var cast_data: Dictionary = SkillGemSystemScript.build_cast_data(state, state.selected_skill_slot)
	if cast_data.is_empty():
		state.add_notice("No active gem in slot")
		return
	if not SkillGemSystemScript.pay_cost(state, cast_data):
		return
	var aim: Vector3 = _mouse_to_world()
	combat.cast_skill(state, player.global_position, aim, cast_data)

func _mouse_to_world() -> Vector3:
	var viewport := get_viewport()
	var mouse_pos: Vector2 = viewport.get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)
	if abs(dir.y) < 0.001:
		return player.global_position + Vector3.FORWARD * 4.0
	var t: float = -from.y / dir.y
	return from + dir * t

func _update_ui() -> void:
	if hud != null and hud.has_method("update_from_state"):
		hud.call("update_from_state", state)
	if skill_panel != null and skill_panel.has_method("update_from_state"):
		skill_panel.call("update_from_state", state)

func _update_camera(delta: float) -> void:
	var target: Vector3 = player.global_position + Vector3(0, 10.5, 9.5)
	camera.global_position = camera.global_position.lerp(target, min(1.0, delta * 8.0)) if delta > 0.0 else target
	camera.look_at(player.global_position, Vector3.UP)
