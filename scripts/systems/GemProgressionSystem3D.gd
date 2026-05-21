extends RefCounted

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

const MAX_SUPPORT_SOCKETS: int = 5
const STARTING_SUPPORT_SOCKETS: int = 2
const SOCKET_INTERVAL: int = 4

static func ensure_progression_defaults(state: Object) -> void:
	SkillGemSystemScript.ensure_defaults(state)

static func ensure_starter_gem_items(state: Object) -> void:
	SkillGemSystemScript.ensure_starter_gem_items(state)

static func award_selected_skill_xp(state: Object, amount: int) -> void:
	SkillGemSystemScript.award_selected_active_xp(state, amount)

static func try_award_cast_input_xp(event: InputEvent, state: Object) -> void:
	if state == null or str(_state_get(state, "mode", "")) != "combat":
		return
	if _is_cast_input(event):
		award_selected_skill_xp(state, 3)

static func roll_gem_drop_to_backpack(state: Object, force: bool = false) -> bool:
	return SkillGemSystemScript.roll_gem_drop_to_backpack(state, force)

static func xp_to_next(level: int) -> int:
	return SkillGemSystemScript.xp_to_next(level)

static func unlocked_support_sockets(level: int) -> int:
	return SkillGemSystemScript.unlocked_support_sockets(level)

static func make_gem_item_from_drop(drop_kind: String, gem_id: String) -> Dictionary:
	return SkillGemSystemScript.make_gem_item_from_drop(drop_kind, gem_id)

static func _active_instance(id: String) -> Dictionary:
	return SkillGemSystemScript.active_instance(id)

static func _gem_item(gem_type: String, id: String, name: String = "", color: String = "") -> Dictionary:
	return SkillGemSystemScript.make_gem_item(gem_type, id)

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
