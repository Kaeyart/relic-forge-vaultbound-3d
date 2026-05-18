class_name RVGameRoot3D
extends Node3D

const GameStateScript := preload("res://scripts/core/GameState3D.gd")
const SaveSystemScript := preload("res://scripts/systems/SaveSystem3D.gd")
const MapLoopSystemScript := preload("res://scripts/systems/MapLoopSystem3D.gd")
const MapDBScript := preload("res://scripts/data/MapDB3D.gd")
const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")

@onready var hub: Node3D = %Hub
@onready var combat: Node3D = %Combat
@onready var player: Node3D = %Player
@onready var camera: Camera3D = %Camera3D
@onready var hud: CanvasLayer = %GameHUD3D

var state: RVGameState3D
var autosave_timer: float = 0.0

func _ready() -> void:
	state = GameStateScript.new()
	SaveSystemScript.load_into(state)
	state.enter_hub()
	player.call("sync_from_state", state)
	combat.visible = false
	set_process(true)

func _process(delta: float) -> void:
	if state == null:
		return
	_update_cooldowns(delta)
	_update_player(delta)
	if state.mode == "hub":
		_hub_tick(delta)
	else:
		_combat_tick(delta)
	_update_camera(delta)
	_update_notice(delta)
	_update_ui()
	autosave_timer += delta
	if autosave_timer >= 12.0:
		autosave_timer = 0.0
		SaveSystemScript.save(state)

func _unhandled_input(event: InputEvent) -> void:
	if state == null:
		return
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and not key_event.echo:
			_handle_key(key_event.keycode)
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT and state.panel_mode == "" and state.mode == "combat":
			_cast_selected_skill()

func _handle_key(keycode: int) -> void:
	match keycode:
		KEY_F5:
			SaveSystemScript.save(state)
			state.add_notice("Saved")
		KEY_F8:
			state.panel_mode = ""
			state.add_notice("UI unlocked")
		KEY_ESCAPE:
			if state.panel_mode != "":
				state.panel_mode = ""
			elif state.mode == "combat":
				_return_to_hub(false)
		KEY_I:
			_toggle_panel("inventory")
		KEY_C:
			_toggle_panel("character")
		KEY_M:
			_toggle_panel("maps")
		KEY_H:
			_toggle_panel("help")
		KEY_Z:
			state.use_health_flask()
		KEY_X:
			state.use_mana_flask()
		KEY_Q:
			state.cycle_skill(-1)
		KEY_R:
			state.cycle_skill(1)
		KEY_SPACE:
			if state.mode == "combat" and state.panel_mode == "":
				_cast_selected_skill()
		KEY_T:
			if state.mode == "hub":
				_start_map_from_hub()
			else:
				_return_to_hub(false)
		KEY_E:
			if state.mode == "hub":
				if hub.has_method("player_near_map_device") and bool(hub.call("player_near_map_device", state.player_pos)):
					_start_map_from_hub()
			elif state.mode == "combat":
				var result: Dictionary = combat.call("interact", state)
				if str(result.get("action", "")) == "return_hub":
					_return_to_hub(true)
		KEY_U:
			_equip_inventory_cursor()
		KEY_BRACKETLEFT:
			state.inventory_cursor = max(0, state.inventory_cursor - 1)
		KEY_BRACKETRIGHT:
			state.inventory_cursor = min(max(0, state.backpack.size() - 1), state.inventory_cursor + 1)
		_:
			if keycode >= KEY_1 and keycode <= KEY_6:
				var index: int = keycode - KEY_1
				if index < state.active_skills.size():
					state.selected_skill_index = index

func _toggle_panel(mode_name: String) -> void:
	state.panel_mode = "" if state.panel_mode == mode_name else mode_name

func _update_player(delta: float) -> void:
	var move: Vector3 = Vector3.ZERO
	if state.panel_mode == "":
		if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_UP):
			move.z -= 1.0
		if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_DOWN):
			move.z += 1.0
		if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_LEFT):
			move.x -= 1.0
		if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_RIGHT):
			move.x += 1.0
	var old_pos: Vector3 = state.player_pos
	if move.length() > 0.01:
		move = move.normalized()
		state.player_pos += move * max(1.0, state.player_speed) * delta
		player.call("set_facing", move)
	if state.mode == "combat":
		state.player_pos = combat.call("constrain_player_position", old_pos, state.player_pos, state.player_radius)
	else:
		state.player_pos.x = clampf(state.player_pos.x, -8.5, 8.5)
		state.player_pos.z = clampf(state.player_pos.z, -6.5, 6.5)
	state.invuln = max(0.0, state.invuln - delta)
	state.player_mana = min(state.max_mana, state.player_mana + 9.0 * delta)
	player.call("sync_from_state", state)

func _hub_tick(_delta: float) -> void:
	if not hub.visible:
		hub.visible = true
	if combat.visible:
		combat.visible = false
	if hub.has_method("update_focus"):
		hub.call("update_focus", state, state.player_pos)

func _combat_tick(delta: float) -> void:
	if hub.visible:
		hub.visible = false
	if not combat.visible:
		combat.visible = true
	combat.call("update_combat", state, player, delta)
	if state.player_hp <= 0.0:
		state.deaths += 1
		state.map_entries_remaining = max(0, state.map_entries_remaining - 1)
		state.add_notice("You died. Entries remaining: " + str(state.map_entries_remaining))
		_return_to_hub(false)

func _update_camera(delta: float) -> void:
	var target: Vector3 = state.player_pos
	var desired: Vector3 = target + Vector3(0.0, 15.5, 13.5)
	camera.global_position = camera.global_position.lerp(desired, clampf(delta * 8.0, 0.0, 1.0))
	camera.look_at(target + Vector3(0, 0.6, 0), Vector3.UP)

func _update_cooldowns(delta: float) -> void:
	var cooldowns: Dictionary = state.skill_cooldowns
	for key_value: Variant in cooldowns.keys():
		cooldowns[key_value] = max(0.0, float(cooldowns[key_value]) - delta)
	state.skill_cooldowns = cooldowns

func _update_notice(delta: float) -> void:
	if state.notice_time > 0.0:
		state.notice_time = max(0.0, state.notice_time - delta)

func _update_ui() -> void:
	if hud != null and hud.has_method("update_from_state"):
		hud.call("update_from_state", state)

func _start_map_from_hub() -> void:
	var map_item: Dictionary = MapLoopSystemScript.map_to_run(state)
	MapLoopSystemScript.consume_map_for_run(state, map_item)
	if not MapLoopSystemScript.consume_entry(state):
		state.add_notice("No map entries")
		return
	state.enter_combat(map_item)
	combat.call("start_map", state, map_item)
	player.call("sync_from_state", state)
	state.add_notice("Entered " + MapDBScript.describe(map_item))

func _return_to_hub(completed: bool) -> void:
	if completed:
		state.add_notice("Returned to hub with map complete")
	combat.call("stop_map")
	state.enter_hub()
	hub.visible = true
	combat.visible = false
	player.call("sync_from_state", state)

func _cast_selected_skill() -> void:
	if state.mode != "combat":
		return
	var aim: Vector3 = _mouse_world_point()
	combat.call("cast_selected_skill", state, state.player_pos, aim)

func _mouse_world_point() -> Vector3:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir: Vector3 = camera.project_ray_normal(mouse_pos)
	if abs(dir.y) < 0.001:
		return state.player_pos + Vector3.FORWARD
	var t: float = -from.y / dir.y
	return from + dir * t

func _equip_inventory_cursor() -> void:
	if state.backpack.is_empty():
		state.add_notice("No item in backpack")
		return
	state.inventory_cursor = clampi(state.inventory_cursor, 0, state.backpack.size() - 1)
	ItemDBScript.equip_item(state, state.inventory_cursor)
