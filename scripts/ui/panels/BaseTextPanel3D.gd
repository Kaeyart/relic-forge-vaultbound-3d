class_name RVBaseTextPanel3D
extends Control

# Mouse-first base panel used by patch_16.
# Panels build clickable controls at runtime while keeping the scene files minimal and stable.

var state_ref: Object = null
var _built_once: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build_if_needed()

func bind_state(state: Object) -> void:
	state_ref = state
	refresh_panel()

func update_from_state(state: Object) -> void:
	state_ref = state
	refresh_panel()

func refresh_panel() -> void:
	_build_if_needed()

func _build_if_needed() -> void:
	if not _built_once:
		_built_once = true

func _clear() -> void:
	for child: Node in get_children():
		child.queue_free()

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback
	return value

func _state_set(key: String, value: Variant) -> void:
	if state_ref != null:
		state_ref.set(key, value)

func _notice(text: String) -> void:
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", text)

func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []

func _as_dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}

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

func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return float(value)
		TYPE_INT:
			return float(int(value))
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		_:
			return fallback

func _item_name(item: Dictionary) -> String:
	return str(item.get("display_name", item.get("name", item.get("base_id", "Item"))))

func _item_slot(item: Dictionary) -> String:
	return str(item.get("slot", item.get("equipment_slot", item.get("kind", ""))))

func _item_rarity(item: Dictionary) -> String:
	return str(item.get("rarity", "normal"))

func _item_power(item: Dictionary) -> int:
	if item.has("item_power"):
		return _to_int(item.get("item_power", 0))
	if item.has("power"):
		return _to_int(item.get("power", 0))
	if item.has("item_level"):
		return _to_int(item.get("item_level", 0))
	return _to_int(item.get("level", 0))

func _rarity_prefix(item: Dictionary) -> String:
	var rarity: String = _item_rarity(item).to_upper()
	if rarity == "NORMAL":
		return ""
	return "[" + rarity + "] "

func _button(text: String, target: Object, method: String, binds: Array = [], min_size: Vector2 = Vector2(110, 34)) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	var cb: Callable = Callable(target, method)
	for value: Variant in binds:
		cb = cb.bind(value)
	b.pressed.connect(cb)
	return b

func _label(text: String, size: int = 13, autowrap: bool = true) -> RichTextLabel:
	var l: RichTextLabel = RichTextLabel.new()
	l.bbcode_enabled = true
	l.fit_content = true
	l.scroll_active = false
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.text = text
	l.add_theme_font_size_override("normal_font_size", size)
	if autowrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		l.autowrap_mode = TextServer.AUTOWRAP_OFF
	return l

func _vbox(spacing: int = 6) -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", spacing)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	return box

func _hbox(spacing: int = 6) -> HBoxContainer:
	var box: HBoxContainer = HBoxContainer.new()
	box.add_theme_constant_override("separation", spacing)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	return box

func _grid(columns: int, spacing: int = 4) -> GridContainer:
	var g: GridContainer = GridContainer.new()
	g.columns = columns
	g.add_theme_constant_override("h_separation", spacing)
	g.add_theme_constant_override("v_separation", spacing)
	g.mouse_filter = Control.MOUSE_FILTER_PASS
	return g

func _panel(title: String = "") -> PanelContainer:
	var p: PanelContainer = PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	var box: VBoxContainer = _vbox(6)
	box.name = "Content"
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	p.add_child(box)
	if title != "":
		box.add_child(_label("[color=#c59b4a][b]" + title + "[/b][/color]", 15))
	return p

func _panel_content(panel: PanelContainer) -> VBoxContainer:
	var node: Node = panel.get_node_or_null("Content")
	if node is VBoxContainer:
		return node as VBoxContainer
	var box: VBoxContainer = _vbox(6)
	box.name = "Content"
	panel.add_child(box)
	return box

func _set_expand(control: Control, horizontal: bool = true, vertical: bool = true) -> void:
	if horizontal:
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if vertical:
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _short(text: String, max_len: int = 18) -> String:
	if text.length() <= max_len:
		return text
	return text.substr(0, max_len - 1) + "…"

func _item_summary(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."
	var lines: PackedStringArray = PackedStringArray()
	var identified: bool = bool(item.get("identified", true))
	lines.append("[font_size=16][color=#c59b4a][b]" + _item_name(item) + "[/b][/color][/font_size]")
	lines.append(_item_rarity(item).capitalize() + " · " + _item_slot(item) + " · Power " + str(_item_power(item)))
	if not identified:
		lines.append("[color=#d65a32]Unappraised: affixes hidden. Click Appraise.[/color]")
		return "\n".join(lines)
	lines.append("Quality +" + str(_to_int(item.get("quality", item.get("item_quality", 0)))) + "% · Forge Potential " + str(_to_int(item.get("forge_potential", 0))))
	if item.has("grid_w"):
		lines.append("Grid " + str(_to_int(item.get("grid_w", 1))) + "x" + str(_to_int(item.get("grid_h", 1))) + " @ " + str(_to_int(item.get("grid_x", -1))) + "," + str(_to_int(item.get("grid_y", -1))))
	var flags: PackedStringArray = PackedStringArray()
	if bool(item.get("new_item", false)):
		flags.append("NEW")
	if bool(item.get("favorite", false)):
		flags.append("FAVORITE")
	if bool(item.get("locked", false)):
		flags.append("LOCKED")
	if not flags.is_empty():
		lines.append("[color=#8f8777]" + " · ".join(flags) + "[/color]")
	if typeof(item.get("affixes", [])) == TYPE_ARRAY:
		var affixes: Array = Array(item.get("affixes", []))
		if not affixes.is_empty():
			lines.append("\n[color=#8f8777]Affixes[/color]")
			for affix_value: Variant in affixes:
				if typeof(affix_value) == TYPE_DICTIONARY:
					var affix: Dictionary = Dictionary(affix_value)
					var stat_name: String = str(affix.get("display_name", affix.get("stat", affix.get("id", "modifier"))))
					var amount: String = str(affix.get("value", affix.get("amount", "")))
					lines.append("• " + stat_name + (" " + amount if amount != "" else ""))
				else:
					lines.append("• " + str(affix_value))
	if typeof(item.get("tags", [])) == TYPE_ARRAY:
		var tags: Array = Array(item.get("tags", []))
		if not tags.is_empty():
			lines.append("\n[color=#8f8777]Tags[/color] " + ", ".join(_array_to_strings(tags)))
	return "\n".join(lines)

func _array_to_strings(values: Array) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for value: Variant in values:
		out.append(str(value))
	return out

func _selected_backpack_index() -> int:
	return _to_int(_state_get("inventory_cursor", 0), 0)

func _selected_backpack_item() -> Dictionary:
	var backpack: Array = _as_array(_state_get("backpack", []))
	var index: int = _selected_backpack_index()
	if index >= 0 and index < backpack.size() and typeof(backpack[index]) == TYPE_DICTIONARY:
		return Dictionary(backpack[index])
	return {}

func _set_selected_backpack_index(index: int) -> void:
	var backpack: Array = _as_array(_state_get("backpack", []))
	if backpack.is_empty():
		_state_set("inventory_cursor", 0)
	else:
		_state_set("inventory_cursor", clampi(index, 0, backpack.size() - 1))
	refresh_panel()

func _open_panel(mode: String) -> void:
	_state_set("panel_mode", mode)
