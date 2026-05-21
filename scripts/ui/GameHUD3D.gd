extends CanvasLayer

var state_ref: Object = null
var _root: Control = null
var _skill_box: HBoxContainer = null
var _menu_box: HBoxContainer = null
var _left_label: RichTextLabel = null
var _right_label: RichTextLabel = null
var _prompt_label: RichTextLabel = null
var _notice_label: RichTextLabel = null

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
	_root.name = "MouseFirstHUDRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_left_label = _hud_label("", Vector2(20, -165), Vector2(320, -82), Control.PRESET_BOTTOM_LEFT)
	_root.add_child(_left_label)
	_right_label = _hud_label("", Vector2(-340, -165), Vector2(-20, -82), Control.PRESET_BOTTOM_RIGHT)
	_root.add_child(_right_label)
	_prompt_label = _hud_label("", Vector2(-360, -215), Vector2(360, -175), Control.PRESET_BOTTOM_WIDE)
	_root.add_child(_prompt_label)
	_notice_label = _hud_label("", Vector2(-340, 250), Vector2(-20, 380), Control.PRESET_TOP_RIGHT)
	_root.add_child(_notice_label)
	_skill_box = HBoxContainer.new()
	_skill_box.name = "ClickableSkillBar"
	_skill_box.add_theme_constant_override("separation", 6)
	_skill_box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_skill_box.offset_left = 420
	_skill_box.offset_right = -420
	_skill_box.offset_top = -92
	_skill_box.offset_bottom = -24
	_root.add_child(_skill_box)
	_menu_box = HBoxContainer.new()
	_menu_box.name = "ClickableMenuBar"
	_menu_box.add_theme_constant_override("separation", 4)
	_menu_box.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_menu_box.offset_left = -560
	_menu_box.offset_right = -20
	_menu_box.offset_top = 18
	_menu_box.offset_bottom = 56
	_root.add_child(_menu_box)

func _hud_label(text: String, left_top: Vector2, right_bottom: Vector2, preset: int) -> RichTextLabel:
	var l: RichTextLabel = RichTextLabel.new()
	l.bbcode_enabled = true
	l.text = text
	l.scroll_active = false
	l.fit_content = false
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.set_anchors_preset(preset)
	l.offset_left = left_top.x
	l.offset_top = left_top.y
	l.offset_right = right_bottom.x
	l.offset_bottom = right_bottom.y
	return l

func _refresh() -> void:
	_build()
	_update_resources()
	_update_skills()
	_update_menu()
	_update_prompt_notice()

func _update_resources() -> void:
	var hp: int = _to_int(_get_value("player_hp", 0))
	var max_hp: int = maxi(1, _to_int(_get_value("max_hp", 1)))
	var mana: int = _to_int(_get_value("player_mana", 0))
	var max_mana: int = maxi(1, _to_int(_get_value("max_mana", 1)))
	var spirit_max: int = _to_int(_get_value("spirit_max", 100))
	var spirit_reserved: int = _to_int(_get_value("spirit_reserved", 0))
	var armor: int = _to_int(_get_value("armor", 0))
	_left_label.text = "[color=#d8d0be][b]LIFE[/b][/color] " + str(hp) + "/" + str(max_hp) + "\nArmor " + str(armor) + "\n[Z] Life Flask"
	_right_label.text = "[color=#d8d0be][b]MANA[/b][/color] " + str(mana) + "/" + str(max_mana) + "\nSpirit " + str(max(0, spirit_max - spirit_reserved)) + "/" + str(spirit_max) + "\n[X] Mana Flask"

func _update_skills() -> void:
	for child: Node in _skill_box.get_children():
		child.queue_free()
	var selected: int = _to_int(_get_value("selected_hotbar_slot", _get_value("selected_skill_slot", 0)))
	var hotbar: Array = _as_array(_get_value("hotbar_slots", []))
	if hotbar.is_empty():
		hotbar = _as_array(_get_value("active_skill_slots", []))
	for i: int in range(5):
		var name_text: String = "Empty"
		if i < hotbar.size():
			var value: Variant = hotbar[i]
			if typeof(value) == TYPE_DICTIONARY:
				var gem: Dictionary = Dictionary(value)
				name_text = str(gem.get("gem_id", gem.get("active", gem.get("active_id", "skill")))).replace("_", " ").capitalize()
			elif value != null:
				name_text = str(value).replace("_", " ").capitalize()
		var b: Button = Button.new()
		b.text = str(i + 1) + "\n" + name_text
		b.custom_minimum_size = Vector2(104, 62)
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		b.pressed.connect(Callable(self, "_select_skill").bind(i))
		if i == selected:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		_skill_box.add_child(b)

func _update_menu() -> void:
	for child: Node in _menu_box.get_children():
		child.queue_free()
	var entries: Array[Dictionary] = [
		{"mode": "inventory", "label": "Inventory"},
		{"mode": "skills", "label": "Gems"},
		{"mode": "maps", "label": "Maps"},
		{"mode": "crafting", "label": "Forge"},
		{"mode": "character", "label": "Character"},
		{"mode": "stash", "label": "Stash"}
	]
	for entry: Dictionary in entries:
		var b: Button = Button.new()
		b.text = str(entry.get("label", "Panel"))
		b.custom_minimum_size = Vector2(82, 34)
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		b.pressed.connect(Callable(self, "_open_panel").bind(str(entry.get("mode", ""))))
		_menu_box.add_child(b)

func _update_prompt_notice() -> void:
	var mode: String = str(_get_value("mode", "hub"))
	var station: String = str(_get_value("near_station_name", ""))
	if mode == "combat":
		_prompt_label.text = "[center][color=#c59b4a][b]Combat[/b][/color] Click skill bar or use 1-5 · Left Click/Space casts · [E] Pick up / extract[/center]"
	elif station != "":
		_prompt_label.text = "[center][color=#c59b4a][b]Click top buttons or press E[/b][/color] Open " + station + "[/center]"
	else:
		_prompt_label.text = "[center]Mouse-first UI: click Inventory · Gems · Maps · Forge · Character · Stash[/center]"
	var notice_time: float = _to_float(_get_value("notice_time", 0.0))
	if notice_time > 0.0:
		_notice_label.text = "[color=#c59b4a][b]NOTICE[/b][/color]\n" + str(_get_value("notice_text", ""))
	else:
		_notice_label.text = ""

func _select_skill(index: int) -> void:
	if state_ref != null:
		state_ref.set("selected_hotbar_slot", index)
		state_ref.set("selected_skill_slot", index)
	_refresh()

func _open_panel(mode: String) -> void:
	if state_ref != null:
		state_ref.set("panel_mode", mode)

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
		TYPE_INT: return int(value)
		TYPE_FLOAT: return int(round(float(value)))
		TYPE_BOOL: return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int(): return s.to_int()
			if s.is_valid_float(): return int(round(s.to_float()))
			return fallback
		_: return fallback

func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT: return float(value)
		TYPE_INT: return float(int(value))
		TYPE_BOOL: return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float(): return s.to_float()
			return fallback
		_: return fallback
