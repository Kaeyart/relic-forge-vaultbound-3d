extends CanvasLayer

# Patch 18: clean gameplay-only HUD.
# No prompt spam, no map/objective panels, no top menu buttons.
# Only core combat readability remains: life, mana, flasks, and skill bar.

var state_ref: Object = null
var _root: Control = null
var _skill_box: HBoxContainer = null
var _left_label: RichTextLabel = null
var _right_label: RichTextLabel = null

func _ready() -> void:
	_build()
	_refresh()

func bind_state(state: Object) -> void:
	state_ref = state
	_refresh()

func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh()

func _build() -> void:
	if _root != null and is_instance_valid(_root):
		return

	_root = Control.new()
	_root.name = "CleanGameplayHUDRoot018"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_left_label = _hud_label(Vector2(20, -145), Vector2(320, -48), Control.PRESET_BOTTOM_LEFT)
	_root.add_child(_left_label)

	_right_label = _hud_label(Vector2(-320, -145), Vector2(-20, -48), Control.PRESET_BOTTOM_RIGHT)
	_root.add_child(_right_label)

	_skill_box = HBoxContainer.new()
	_skill_box.name = "CleanSkillBar018"
	_skill_box.add_theme_constant_override("separation", 6)
	_skill_box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_skill_box.offset_left = 430
	_skill_box.offset_right = -430
	_skill_box.offset_top = -88
	_skill_box.offset_bottom = -20
	_skill_box.mouse_filter = Control.MOUSE_FILTER_PASS
	_root.add_child(_skill_box)

func _hud_label(left_top: Vector2, right_bottom: Vector2, preset: int) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.scroll_active = false
	label.fit_content = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_anchors_preset(preset)
	label.offset_left = left_top.x
	label.offset_top = left_top.y
	label.offset_right = right_bottom.x
	label.offset_bottom = right_bottom.y
	label.add_theme_font_size_override("normal_font_size", 15)
	return label

func _refresh() -> void:
	_build()
	_update_resources()
	_update_skills()

func _update_resources() -> void:
	var hp: int = _to_int(_get_value("player_hp", 0))
	var max_hp: int = maxi(1, _to_int(_get_value("max_hp", 1)))
	var mana: int = _to_int(_get_value("player_mana", 0))
	var max_mana: int = maxi(1, _to_int(_get_value("max_mana", 1)))
	var spirit_max: int = _to_int(_get_value("spirit_max", 100))
	var spirit_reserved: int = _to_int(_get_value("spirit_reserved", 0))
	var armor: int = _to_int(_get_value("armor", 0))

	_left_label.text = "[color=#d8d0be][b]LIFE[/b][/color] " + str(hp) + "/" + str(max_hp) + "\nArmor " + str(armor) + "\n[color=#8f8777]Z Life Flask[/color]"
	_right_label.text = "[right][color=#d8d0be][b]MANA[/b][/color] " + str(mana) + "/" + str(max_mana) + "\nSpirit " + str(maxi(0, spirit_max - spirit_reserved)) + "/" + str(spirit_max) + "\n[color=#8f8777]X Mana Flask[/color][/right]"

func _update_skills() -> void:
	for child: Node in _skill_box.get_children():
		child.queue_free()

	var selected: int = _to_int(_get_value("selected_hotbar_slot", _get_value("selected_skill_slot", 0)))
	var hotbar: Array = _as_array(_get_value("hotbar_slots", []))

	for i: int in range(5):
		var name_text: String = _hotbar_name(i, hotbar)
		var button: Button = Button.new()
		button.text = str(i + 1) + "\n" + name_text
		button.custom_minimum_size = Vector2(106, 62)
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.pressed.connect(Callable(self, "_select_skill").bind(i))
		if i == selected:
			button.modulate = Color(1.0, 0.82, 0.34, 1.0)
		else:
			button.modulate = Color(1.0, 1.0, 1.0, 0.86)
		_skill_box.add_child(button)

func _hotbar_name(index: int, hotbar: Array) -> String:
	if index < 0 or index >= hotbar.size():
		return "Empty"

	var value: Variant = hotbar[index]
	if typeof(value) == TYPE_DICTIONARY:
		return _gem_display(Dictionary(value))

	var uid_value: String = str(value)
	if uid_value == "" or uid_value == "null":
		return "Empty"

	var equipped: Array = _as_array(_get_value("equipped_skill_gems", []))
	for gem_value: Variant in equipped:
		if typeof(gem_value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(gem_value)
		if str(gem.get("uid", "")) == uid_value:
			return _gem_display(gem)

	return uid_value.replace("_", " ").capitalize()

func _gem_display(gem: Dictionary) -> String:
	var id: String = str(gem.get("gem_id", gem.get("active", gem.get("active_id", "skill"))))
	return _short(id.replace("_", " ").capitalize(), 13)

func _select_skill(index: int) -> void:
	if state_ref != null:
		state_ref.set("selected_hotbar_slot", index)
		state_ref.set("selected_skill_slot", index)
	_refresh()

func _get_value(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback
	return value

func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []

func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback

func _short(text: String, max_len: int = 16) -> String:
	if text.length() <= max_len:
		return text
	return text.substr(0, max_len - 1) + "…"
