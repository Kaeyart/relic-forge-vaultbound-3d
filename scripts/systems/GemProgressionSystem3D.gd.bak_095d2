extends RefCounted
const GemCoreSystemScript := preload("res://scripts/systems/GemCoreSystem3D.gd")

const MAX_SUPPORT_SOCKETS: int = 6
const STARTING_SUPPORT_SOCKETS: int = 2
const SOCKET_INTERVAL: int = 5

static func ensure_progression_defaults(state: Object) -> void:
	GemCoreSystemScript.ensure_defaults(state)
static func ensure_starter_gem_items(state: Object) -> void:
	GemCoreSystemScript.ensure_starter_gem_items(state)
static func award_selected_skill_xp(state: Object, amount: int) -> void:
	GemCoreSystemScript.award_selected_active_xp(state, amount)
static func try_award_cast_input_xp(event: InputEvent, state: Object) -> void:
	if state == null or str(_state_get(state, "mode", "")) != "combat":
		return
	if _is_cast_input(event):
		award_selected_skill_xp(state, 3)

static func roll_gem_drop_to_backpack(state: Object, force: bool = false) -> bool:
	return GemCoreSystemScript.roll_gem_drop_to_backpack(state, force)
static func xp_to_next(level: int) -> int:
	return max(80, level * 100)

static func unlocked_support_sockets(level: int) -> int:
	return clampi(STARTING_SUPPORT_SOCKETS + int(floor(float(max(1, level)) / float(SOCKET_INTERVAL))), STARTING_SUPPORT_SOCKETS, MAX_SUPPORT_SOCKETS)


static func make_gem_item_from_drop(drop_kind: String, gem_id: String) -> Dictionary:
	var gem_type: String = "support"
	match drop_kind:
		"active_gem": gem_type = "active"
		"support_gem": gem_type = "support"
		"spirit_gem": gem_type = "spirit"
		_: gem_type = str(drop_kind).replace("_gem", "")
	var readable: String = gem_id.replace("_", " ").capitalize()
	var color: String = "blue"
	if gem_type == "active":
		color = "red" if gem_id.find("ember") >= 0 or gem_id.find("arc") >= 0 else "blue"
	elif gem_type == "support":
		color = "green"
	elif gem_type == "spirit":
		color = "blue"
	return _gem_item(gem_type, gem_id, readable, color)

static func _active_instance(id: String) -> Dictionary:
	return {
		"kind": "active",
		"gem_id": id,
		"active": id,
		"active_id": id,
		"level": 1,
		"xp": 0,
		"quality": 0,
		"supports": [],
		"unlocked_support_sockets": STARTING_SUPPORT_SOCKETS,
	}

static func _gem_item(gem_type: String, id: String, name: String, color: String) -> Dictionary:
	var kind: String = gem_type + "_gem"
	return {
		"id": "gem_" + id + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 9999),
		"base_id": id,
		"gem_id": id,
		"name": name,
		"display_name": name,
		"kind": kind,
		"item_kind": kind,
		"category": "skill_gem",
		"slot": kind,
		"rarity": "magic",
		"gem_type": gem_type,
		"skill_gem_type": gem_type,
		"base_color": color,
		"gem_color": color,
		"carved": true,
		"level": 1,
		"gem_level": 1,
		"xp": 0,
		"gem_xp": 0,
		"quality": 0,
		"gem_quality": 0,
		"tags": ["gem", kind, gem_type],
		"grid_w": 1,
		"grid_h": 1,
	}

static func _is_cast_input(event: InputEvent) -> bool:
	if event == null:
		return false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		return mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventKey:
		var key := event as InputEventKey
		return key.pressed and not key.echo and key.keycode == KEY_SPACE
	return event.is_action_pressed("cast") or event.is_action_pressed("attack")

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			return s.to_int() if s.is_valid_int() else fallback
		_:
			return fallback
