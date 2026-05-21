extends Control
class_name RVMapDevicePanel3D

var state_ref: Object = null

var _built: bool = false
var _map_list: VBoxContainer = null
var _selected_title: Label = null
var _selected_meta: Label = null
var _device_summary: RichTextLabel = null
var _details_text: RichTextLabel = null
var _reward_text: RichTextLabel = null
var _footer_text: Label = null
var _launch_button: Button = null
var _prev_button: Button = null
var _next_button: Button = null


func _ready() -> void:
	_build_ui()
	_refresh()


func bind_state(state: Object) -> void:
	state_ref = state
	_refresh()


func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh()


func mark_dirty() -> void:
	_refresh()


func _build_ui() -> void:
	if _built:
		return

	_built = true
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_STOP

	for child: Node in get_children():
		child.queue_free()

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "MapDeviceRoot"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 18)
	root_margin.add_theme_constant_override("margin_right", 18)
	root_margin.add_theme_constant_override("margin_top", 16)
	root_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(root_margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.name = "RootVBox"
	root.add_theme_constant_override("separation", 10)
	root_margin.add_child(root)

	var header: HBoxContainer = HBoxContainer.new()
	header.name = "Header"
	header.add_theme_constant_override("separation", 10)
	root.add_child(header)

	var title: Label = _make_label("MAP DEVICE", 24, Color(0.90, 0.72, 0.34, 1.0))
	title.name = "Title"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var hint: Label = _make_label("[ / ] select map    T launch    Esc close", 13, Color(0.62, 0.56, 0.46, 1.0))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	root.add_child(body)

	var left_panel: PanelContainer = _make_panel("AvailableMapsPanel")
	left_panel.custom_minimum_size = Vector2(300, 0)
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(left_panel)

	var left_margin: MarginContainer = _panel_margin()
	left_panel.add_child(left_margin)

	var left_vbox: VBoxContainer = VBoxContainer.new()
	left_vbox.name = "AvailableMapsVBox"
	left_vbox.add_theme_constant_override("separation", 8)
	left_margin.add_child(left_vbox)

	left_vbox.add_child(_make_label("AVAILABLE MAPS", 16, Color(0.86, 0.68, 0.34, 1.0)))
	left_vbox.add_child(_make_label("Tier list · selected map is highlighted", 12, Color(0.58, 0.53, 0.45, 1.0)))

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "MapScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(scroll)

	_map_list = VBoxContainer.new()
	_map_list.name = "MapList"
	_map_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_map_list)

	var nav: HBoxContainer = HBoxContainer.new()
	nav.name = "Navigation"
	nav.add_theme_constant_override("separation", 8)
	left_vbox.add_child(nav)

	_prev_button = _make_button("← Previous")
	_prev_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_prev_button.pressed.connect(_move_cursor.bind(-1))
	nav.add_child(_prev_button)

	_next_button = _make_button("Next →")
	_next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_next_button.pressed.connect(_move_cursor.bind(1))
	nav.add_child(_next_button)

	var center_panel: PanelContainer = _make_panel("DevicePanel")
	center_panel.custom_minimum_size = Vector2(430, 0)
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center_panel)

	var center_margin: MarginContainer = _panel_margin()
	center_panel.add_child(center_margin)

	var center_vbox: VBoxContainer = VBoxContainer.new()
	center_vbox.name = "DeviceVBox"
	center_vbox.add_theme_constant_override("separation", 10)
	center_margin.add_child(center_vbox)

	_selected_title = _make_label("No Map Selected", 22, Color(0.91, 0.72, 0.34, 1.0))
	_selected_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_vbox.add_child(_selected_title)

	_selected_meta = _make_label("Tier — · Area Level —", 13, Color(0.72, 0.66, 0.55, 1.0))
	_selected_meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_vbox.add_child(_selected_meta)

	var device_box: PanelContainer = _make_panel("RitualDeviceMock")
	device_box.custom_minimum_size = Vector2(0, 250)
	device_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.add_child(device_box)

	var device_margin: MarginContainer = _panel_margin()
	device_box.add_child(device_margin)

	_device_summary = RichTextLabel.new()
	_device_summary.name = "DeviceSummary"
	_device_summary.bbcode_enabled = true
	_device_summary.fit_content = false
	_device_summary.scroll_active = false
	_device_summary.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_device_summary.add_theme_font_size_override("normal_font_size", 14)
	_device_summary.add_theme_color_override("default_color", Color(0.78, 0.72, 0.62, 1.0))
	device_margin.add_child(_device_summary)

	var insert_row: HBoxContainer = HBoxContainer.new()
	insert_row.name = "MapInputSlots"
	insert_row.add_theme_constant_override("separation", 8)
	center_vbox.add_child(insert_row)

	for label_text: String in ["Seal", "Ore", "Essence", "Fragment", "Empty"]:
		var slot: PanelContainer = _make_panel("InputSlot_" + label_text)
		slot.custom_minimum_size = Vector2(78, 58)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		insert_row.add_child(slot)
		var slot_margin: MarginContainer = _panel_margin()
		slot.add_child(slot_margin)
		var slot_label: Label = _make_label(label_text, 11, Color(0.69, 0.63, 0.53, 1.0))
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_margin.add_child(slot_label)

	_launch_button = _make_button("LAUNCH MAP  [T]")
	_launch_button.custom_minimum_size = Vector2(0, 44)
	_launch_button.pressed.connect(_launch_selected_map)
	center_vbox.add_child(_launch_button)

	var right_panel: PanelContainer = _make_panel("MapDetailsPanel")
	right_panel.custom_minimum_size = Vector2(390, 0)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(right_panel)

	var right_margin: MarginContainer = _panel_margin()
	right_panel.add_child(right_margin)

	var right_vbox: VBoxContainer = VBoxContainer.new()
	right_vbox.name = "DetailsVBox"
	right_vbox.add_theme_constant_override("separation", 8)
	right_margin.add_child(right_vbox)

	right_vbox.add_child(_make_label("MAP DETAILS", 16, Color(0.86, 0.68, 0.34, 1.0)))

	_details_text = RichTextLabel.new()
	_details_text.name = "DetailsText"
	_details_text.bbcode_enabled = true
	_details_text.fit_content = false
	_details_text.scroll_active = true
	_details_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_details_text.custom_minimum_size = Vector2(0, 265)
	_details_text.add_theme_font_size_override("normal_font_size", 13)
	_details_text.add_theme_color_override("default_color", Color(0.78, 0.72, 0.62, 1.0))
	right_vbox.add_child(_details_text)

	right_vbox.add_child(_make_label("REWARD EXPECTATION", 16, Color(0.86, 0.68, 0.34, 1.0)))

	_reward_text = RichTextLabel.new()
	_reward_text.name = "RewardText"
	_reward_text.bbcode_enabled = true
	_reward_text.fit_content = true
	_reward_text.scroll_active = false
	_reward_text.custom_minimum_size = Vector2(0, 120)
	_reward_text.add_theme_font_size_override("normal_font_size", 13)
	_reward_text.add_theme_color_override("default_color", Color(0.78, 0.72, 0.62, 1.0))
	right_vbox.add_child(_reward_text)

	_footer_text = _make_label("", 12, Color(0.64, 0.58, 0.48, 1.0))
	_footer_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_footer_text)

	_apply_button_style(_launch_button, true)


func _refresh() -> void:
	if not _built:
		_build_ui()

	var maps: Array = _map_stash()
	var cursor: int = _selected_index(maps)
	_refresh_map_list(maps, cursor)

	var selected: Dictionary = {}
	if cursor >= 0 and cursor < maps.size() and typeof(maps[cursor]) == TYPE_DICTIONARY:
		selected = Dictionary(maps[cursor])

	_refresh_selected(selected, maps.size(), cursor)


func _refresh_map_list(maps: Array, cursor: int) -> void:
	if _map_list == null:
		return

	for child: Node in _map_list.get_children():
		child.queue_free()

	if maps.is_empty():
		var empty_label: Label = _make_label("No maps in stash.\nRun starter content or add maps to map_stash.", 13, Color(0.75, 0.68, 0.56, 1.0))
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_map_list.add_child(empty_label)
		return

	for i: int in range(maps.size()):
		var map_data: Dictionary = {}
		if typeof(maps[i]) == TYPE_DICTIONARY:
			map_data = Dictionary(maps[i])

		var row_button: Button = _make_button(_map_row_text(map_data, i))
		row_button.custom_minimum_size = Vector2(0, 56)
		row_button.text_alignment = HORIZONTAL_ALIGNMENT_LEFT
		row_button.pressed.connect(_select_index.bind(i))
		_apply_button_style(row_button, i == cursor)
		_map_list.add_child(row_button)


func _refresh_selected(map_data: Dictionary, map_count: int, cursor: int) -> void:
	var has_map: bool = not map_data.is_empty()

	if _selected_title != null:
		_selected_title.text = _map_name(map_data) if has_map else "No Map Selected"

	if _selected_meta != null:
		if has_map:
			_selected_meta.text = "Tier " + str(_map_tier(map_data)) + " · Area Level " + str(_map_area_level(map_data)) + " · " + str(cursor + 1) + "/" + str(maxi(1, map_count))
		else:
			_selected_meta.text = "Tier — · Area Level —"

	if _device_summary != null:
		if has_map:
			_device_summary.text = _device_summary_text(map_data)
		else:
			_device_summary.text = "[center][b]RITUAL DEVICE IDLE[/b][/center]\n\nNo map is selected.\n\nAdd maps to the map stash, then choose one on the left and launch it from this device."

	if _details_text != null:
		_details_text.text = _details_panel_text(map_data)

	if _reward_text != null:
		_reward_text.text = _reward_panel_text(map_data)

	if _footer_text != null:
		if has_map:
			_footer_text.text = "Map Device flow: choose a map → inspect danger and rewards → press T or LAUNCH MAP. Later this center row becomes real map input slots."
		else:
			_footer_text.text = "No selected map. The screen is ready, but the state has no map_stash entries."

	if _launch_button != null:
		_launch_button.disabled = not has_map
		_launch_button.text = "LAUNCH MAP  [T]" if has_map else "NO MAP AVAILABLE"


func _map_row_text(map_data: Dictionary, index: int) -> String:
	var name_text: String = _map_name(map_data)
	var tier_text: String = str(_map_tier(map_data))
	var area_text: String = str(_map_area_level(map_data))
	var mod_count: int = _map_mods(map_data).size()
	return str(index + 1) + ". " + name_text + "\nTier " + tier_text + " · Area " + area_text + " · " + str(mod_count) + " mods"


func _device_summary_text(map_data: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[center][b]" + _map_name(map_data).to_upper() + "[/b][/center]")
	lines.append("[center]Ritual frame locked · vault route prepared[/center]")
	lines.append("")
	lines.append("[center]╔════════════════════╗[/center]")
	lines.append("[center]║      MAP CORE      ║[/center]")
	lines.append("[center]║   forged conduit   ║[/center]")
	lines.append("[center]╚════════════════════╝[/center]")
	lines.append("")
	lines.append("[b]Inserted Inputs[/b]")
	lines.append("• Vault Seal: empty")
	lines.append("• Corrupting Essence: empty")
	lines.append("• Blackened Ore: empty")
	lines.append("• Relic Fragment: empty")
	lines.append("")
	lines.append("[color=#c59b4a]Launch will consume the selected map when the map loop supports consumption.[/color]")
	return "\n".join(lines)


func _details_panel_text(map_data: Dictionary) -> String:
	if map_data.is_empty():
		return "[b]No map selected.[/b]"

	var lines: PackedStringArray = PackedStringArray()
	lines.append("[b]" + _map_name(map_data) + "[/b]")
	lines.append("Tier: " + str(_map_tier(map_data)))
	lines.append("Area Level: " + str(_map_area_level(map_data)))
	lines.append("Danger: " + _danger_label(map_data))
	lines.append("Boss: " + _boss_name(map_data))
	lines.append("")
	lines.append("[b]Map Modifiers[/b]")
	var mods: Array = _map_mods(map_data)
	if mods.is_empty():
		lines.append("• No explicit modifiers")
	else:
		for mod_value: Variant in mods:
			lines.append("• " + _mod_display_text(mod_value))
	lines.append("")
	lines.append("[b]Run Objective[/b]")
	lines.append("• Clear enemy packs")
	lines.append("• Defeat elite or boss if present")
	lines.append("• Loot reward burst")
	lines.append("• Extract back to hub")
	return "\n".join(lines)


func _reward_panel_text(map_data: Dictionary) -> String:
	if map_data.is_empty():
		return "No reward data."

	var quantity: int = _map_int(map_data, ["item_quantity", "quantity", "quant"], 0)
	var rarity: int = _map_int(map_data, ["item_rarity", "rarity"], 0)
	var pack_size: int = _map_int(map_data, ["pack_size", "monster_pack_size"], 0)
	var elite_chance: int = _map_int(map_data, ["elite_chance"], 0)

	var lines: PackedStringArray = PackedStringArray()
	lines.append("Expected reward pressure:")
	lines.append("• Item Quantity +" + str(quantity) + "%")
	lines.append("• Item Rarity +" + str(rarity) + "%")
	lines.append("• Pack Size +" + str(pack_size) + "%")
	lines.append("• Elite Chance +" + str(elite_chance) + "%")
	lines.append("")
	lines.append("Likely drops:")
	lines.append("• Gear")
	lines.append("• Gold / materials")
	lines.append("• Skill gems")
	lines.append("• Follow-up maps")
	return "\n".join(lines)


func _launch_selected_map() -> void:
	if state_ref == null:
		return

	var maps: Array = _map_stash()
	if maps.is_empty():
		_add_notice("No map available.")
		return

	state_ref.set("panel_mode", "")
	var scene: Node = get_tree().current_scene
	if scene != null and scene.has_method("_start_map"):
		scene.call_deferred("_start_map")
	else:
		_add_notice("Press T to launch the selected map.")


func _select_index(index: int) -> void:
	if state_ref == null:
		return

	var maps: Array = _map_stash()
	if maps.is_empty():
		return

	state_ref.set("map_cursor", clampi(index, 0, maps.size() - 1))
	_refresh()


func _move_cursor(dir: int) -> void:
	if state_ref == null:
		return

	var maps: Array = _map_stash()
	if maps.is_empty():
		return

	var current: int = _selected_index(maps)
	state_ref.set("map_cursor", wrapi(current + dir, 0, maps.size()))
	_refresh()


func _map_stash() -> Array:
	return _as_array(_get_state_value("map_stash", []))


func _selected_index(maps: Array) -> int:
	if maps.is_empty():
		return -1

	return clampi(_to_int(_get_state_value("map_cursor", 0)), 0, maps.size() - 1)


func _map_name(map_data: Dictionary) -> String:
	for key: String in ["display_name", "name", "map_name", "id", "base_id"]:
		if map_data.has(key):
			var value: String = str(map_data.get(key, ""))
			if value != "":
				return value.replace("_", " ").capitalize()
	return "Unknown Map"


func _map_tier(map_data: Dictionary) -> int:
	return _map_int(map_data, ["tier", "map_tier"], 1)


func _map_area_level(map_data: Dictionary) -> int:
	return _map_int(map_data, ["area_level", "level", "monster_level"], 1)


func _boss_name(map_data: Dictionary) -> String:
	for key: String in ["boss_name", "boss", "guardian"]:
		if map_data.has(key):
			var value: String = str(map_data.get(key, ""))
			if value != "":
				return value
	return "Unknown guardian"


func _danger_label(map_data: Dictionary) -> String:
	var tier: int = _map_tier(map_data)
	var mods: int = _map_mods(map_data).size()
	var score: int = tier + mods * 2
	if score >= 12:
		return "Extreme"
	if score >= 8:
		return "High"
	if score >= 5:
		return "Moderate"
	return "Low"


func _map_mods(map_data: Dictionary) -> Array:
	if map_data.has("mods"):
		return _as_array(map_data.get("mods", []))
	if map_data.has("modifiers"):
		return _as_array(map_data.get("modifiers", []))
	return []


func _mod_display_text(mod_value: Variant) -> String:
	if typeof(mod_value) == TYPE_DICTIONARY:
		var mod: Dictionary = Dictionary(mod_value)
		for key: String in ["display_name", "name", "text", "id"]:
			if mod.has(key):
				var text: String = str(mod.get(key, ""))
				if text != "":
					return text.replace("_", " ").capitalize()
		return JSON.stringify(mod)
	return str(mod_value)


func _map_int(map_data: Dictionary, keys: Array[String], fallback: int) -> int:
	for key: String in keys:
		if map_data.has(key):
			return _to_int(map_data.get(key), fallback)

	var mods: Array = _map_mods(map_data)
	var total: int = 0
	for mod_value: Variant in mods:
		if typeof(mod_value) != TYPE_DICTIONARY:
			continue
		var mod: Dictionary = Dictionary(mod_value)
		for key: String in keys:
			if mod.has(key):
				total += _to_int(mod.get(key), 0)

	if total == 0:
		return fallback
	return total


func _get_state_value(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback
	return value


func _add_notice(text: String) -> void:
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", text)


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


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.clip_text = true
	button.add_theme_font_size_override("font_size", 12)
	_apply_button_style(button, false)
	return button


func _make_panel(node_name: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = node_name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _stylebox(Color(0.055, 0.045, 0.035, 0.94), Color(0.36, 0.27, 0.14, 1.0), 2))
	return panel


func _panel_margin() -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	return margin


func _apply_button_style(button: Button, selected: bool) -> void:
	var bg: Color = Color(0.18, 0.12, 0.055, 0.98) if selected else Color(0.09, 0.075, 0.06, 0.94)
	var border: Color = Color(0.90, 0.65, 0.25, 1.0) if selected else Color(0.34, 0.26, 0.15, 1.0)
	button.add_theme_stylebox_override("normal", _stylebox(bg, border, 2))
	button.add_theme_stylebox_override("hover", _stylebox(Color(0.22, 0.15, 0.07, 0.98), Color(0.95, 0.72, 0.34, 1.0), 2))
	button.add_theme_stylebox_override("pressed", _stylebox(Color(0.28, 0.17, 0.07, 1.0), Color(1.0, 0.78, 0.34, 1.0), 2))
	button.add_theme_stylebox_override("disabled", _stylebox(Color(0.06, 0.055, 0.05, 0.65), Color(0.16, 0.14, 0.12, 0.9), 1))
	button.add_theme_color_override("font_color", Color(0.86, 0.80, 0.68, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.88, 0.56, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.40, 0.38, 0.34, 1.0))


func _stylebox(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.border_width_left = width
	box.border_width_right = width
	box.border_width_top = width
	box.border_width_bottom = width
	box.corner_radius_top_left = 4
	box.corner_radius_top_right = 4
	box.corner_radius_bottom_left = 4
	box.corner_radius_bottom_right = 4
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	return box
