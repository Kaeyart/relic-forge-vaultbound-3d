extends Control
class_name RVStashPanel3D

var state_ref: Object = null
var _built: bool = false

var _tab_list: VBoxContainer = null
var _stash_grid: GridContainer = null
var _stash_summary: RichTextLabel = null
var _item_detail: RichTextLabel = null
var _action_text: RichTextLabel = null
var _take_button: Button = null
var _store_button: Button = null
var _selected_tab: String = "all"
var _stash_cursor: int = 0

const TABS: Array[Dictionary] = [
	{"id": "all", "title": "All Items"},
	{"id": "gear", "title": "Gear"},
	{"id": "weapon", "title": "Weapons"},
	{"id": "armor", "title": "Armor"},
	{"id": "jewelry", "title": "Jewelry"},
	{"id": "gem", "title": "Gems"},
	{"id": "map", "title": "Maps"},
	{"id": "material", "title": "Materials"},
	{"id": "unique", "title": "Uniques"}
]


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


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if not key_event.pressed or key_event.echo:
			return
		match key_event.keycode:
			KEY_BRACKETLEFT:
				_move_cursor(-1)
				get_viewport().set_input_as_handled()
			KEY_BRACKETRIGHT:
				_move_cursor(1)
				get_viewport().set_input_as_handled()
			KEY_U:
				_take_selected()
				get_viewport().set_input_as_handled()


func _build_ui() -> void:
	if _built:
		return
	_built = true
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_STOP

	for child: Node in get_children():
		child.queue_free()

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "StashRoot"
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

	var title: Label = _make_label("STASH", 24, _gold())
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var hint: Label = _make_label("Left: categories · Center: stored loot · Right: selected item · U take item", 13, _muted())
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	root.add_child(body)

	_build_left_tabs(body)
	_build_center_grid(body)
	_build_right_detail(body)

	_action_text = _make_rich_label(false)
	_action_text.custom_minimum_size = Vector2(0, 42)
	_action_text.text = "[color=#8f8777]Controls:[/color] [ / ] select stash item · U take item · Store button moves current inventory selection into stash."
	root.add_child(_action_text)


func _build_left_tabs(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("StashTabsPanel")
	panel.custom_minimum_size = Vector2(250, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	box.add_child(_make_label("STASH TABS", 17, _gold()))
	_tab_list = VBoxContainer.new()
	_tab_list.add_theme_constant_override("separation", 6)
	box.add_child(_tab_list)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	_store_button = _make_button("STORE INVENTORY SELECTION")
	_store_button.custom_minimum_size = Vector2(0, 44)
	_store_button.pressed.connect(_store_inventory_selection)
	box.add_child(_store_button)


func _build_center_grid(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("StashGridPanel")
	panel.custom_minimum_size = Vector2(520, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	_stash_summary = _make_rich_label(false)
	_stash_summary.custom_minimum_size = Vector2(0, 58)
	box.add_child(_stash_summary)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	_stash_grid = GridContainer.new()
	_stash_grid.columns = 4
	_stash_grid.add_theme_constant_override("h_separation", 8)
	_stash_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_stash_grid)


func _build_right_detail(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("StashDetailPanel")
	panel.custom_minimum_size = Vector2(410, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	box.add_child(_make_label("SELECTED ITEM", 17, _gold()))
	_item_detail = _make_rich_label(true)
	_item_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_item_detail)

	_take_button = _make_button("TAKE SELECTED ITEM")
	_take_button.custom_minimum_size = Vector2(0, 44)
	_take_button.pressed.connect(_take_selected)
	box.add_child(_take_button)


func _refresh() -> void:
	if not _built:
		_build_ui()
	_refresh_tabs()
	_refresh_grid()
	_refresh_detail()


func _refresh_tabs() -> void:
	if _tab_list == null:
		return
	for child: Node in _tab_list.get_children():
		child.queue_free()
	var stash: Array = _stash()
	for tab: Dictionary in TABS:
		var tab_id: String = str(tab.get("id", "all"))
		var title: String = str(tab.get("title", tab_id.capitalize()))
		var count: int = _count_for_tab(stash, tab_id)
		var button: Button = _make_button(("◆ " if tab_id == _selected_tab else "  ") + title + "   " + str(count))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 42)
		_apply_button_style(button, tab_id == _selected_tab)
		button.pressed.connect(_select_tab.bind(tab_id))
		_tab_list.add_child(button)


func _refresh_grid() -> void:
	if _stash_grid == null:
		return
	for child: Node in _stash_grid.get_children():
		child.queue_free()
	var filtered: Array = _filtered_stash()
	if _stash_cursor >= filtered.size():
		_stash_cursor = max(0, filtered.size() - 1)
	if _stash_summary != null:
		_stash_summary.text = "[color=#c59b4a]" + _selected_tab.capitalize() + "[/color] · " + str(filtered.size()) + " shown · " + str(_stash().size()) + " total\n[color=#8f8777]Final art target: tabbed hoard grid with item detail preview and fast transfer actions.[/color]"
	if filtered.is_empty():
		var empty: Label = _make_label("No stash items in this category.", 15, _muted())
		_stash_grid.add_child(empty)
		return
	for i: int in range(filtered.size()):
		var item: Dictionary = Dictionary(filtered[i])
		var selected: bool = i == _stash_cursor
		var button: Button = _make_button(_stash_card_text(item, i, selected))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(150, 98)
		_apply_button_style(button, selected)
		button.pressed.connect(_select_cursor.bind(i))
		_stash_grid.add_child(button)


func _refresh_detail() -> void:
	var item: Dictionary = _selected_item()
	if _item_detail != null:
		_item_detail.text = _item_detail_text(item)
	if _take_button != null:
		_take_button.disabled = item.is_empty()


func _select_tab(tab_id: String) -> void:
	_selected_tab = tab_id
	_stash_cursor = 0
	_refresh()


func _select_cursor(index: int) -> void:
	_stash_cursor = index
	_refresh_detail()
	_refresh_grid()


func _move_cursor(dir: int) -> void:
	var filtered: Array = _filtered_stash()
	if filtered.is_empty():
		return
	_stash_cursor = wrapi(_stash_cursor + dir, 0, filtered.size())
	_refresh_grid()
	_refresh_detail()


func _take_selected() -> void:
	if state_ref == null:
		return
	var filtered: Array = _filtered_stash()
	if filtered.is_empty() or _stash_cursor < 0 or _stash_cursor >= filtered.size():
		_add_notice("No stash item selected.")
		return
	var selected_item: Dictionary = Dictionary(filtered[_stash_cursor])
	var stash: Array = _stash()
	var remove_index: int = _find_matching_item_index(stash, selected_item)
	if remove_index < 0:
		_add_notice("Could not find selected stash item.")
		return
	stash.remove_at(remove_index)
	var backpack: Array = _backpack()
	backpack.append(selected_item)
	state_ref.set("stash", stash)
	state_ref.set("backpack", backpack)
	_add_notice("Took " + _item_name(selected_item) + " from stash.")
	_refresh()


func _store_inventory_selection() -> void:
	if state_ref == null:
		return
	var backpack: Array = _backpack()
	if backpack.is_empty():
		_add_notice("Backpack is empty.")
		return
	var cursor: int = clampi(_to_int(_state_get("inventory_cursor", 0)), 0, backpack.size() - 1)
	if cursor < 0 or cursor >= backpack.size() or typeof(backpack[cursor]) != TYPE_DICTIONARY:
		_add_notice("No valid inventory item selected.")
		return
	var item: Dictionary = Dictionary(backpack[cursor])
	backpack.remove_at(cursor)
	var stash: Array = _stash()
	stash.append(item)
	state_ref.set("backpack", backpack)
	state_ref.set("stash", stash)
	state_ref.set("inventory_cursor", clampi(cursor, 0, max(0, backpack.size() - 1)))
	_add_notice("Stored " + _item_name(item) + ".")
	_refresh()


func _stash_card_text(item: Dictionary, index: int, selected: bool) -> String:
	var marker: String = "◆ " if selected else "  "
	var name_text: String = _item_name(item)
	var rarity: String = str(item.get("rarity", "normal")).capitalize()
	var kind: String = _item_kind_label(item)
	var power: int = _to_int(item.get("item_power", item.get("power", item.get("item_level", item.get("level", 1)))))
	return marker + str(index + 1) + " · " + name_text + "\n" + rarity + " · " + kind + "\nPower " + str(power)


func _item_detail_text(item: Dictionary) -> String:
	if item.is_empty():
		return "[color=#8f8777]No item selected.[/color]\n\nSelect an item from the stash grid."
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[font_size=18][color=#c59b4a]" + _item_name(item) + "[/color][/font_size]")
	lines.append(str(item.get("rarity", "normal")).capitalize() + " · " + _item_kind_label(item) + " · Power " + str(_to_int(item.get("item_power", item.get("power", 0)))))
	lines.append("")
	var category: String = _category_for_item(item)
	lines.append("[color=#8f8777]Category[/color] " + category.capitalize())
	lines.append("[color=#8f8777]Quality[/color] +" + str(_to_int(item.get("quality", 0))) + "%")
	lines.append("[color=#8f8777]Forge Potential[/color] " + str(_to_int(item.get("forge_potential", item.get("potential", 0)))))
	lines.append("[color=#8f8777]Sockets[/color] " + str(_to_int(item.get("sockets", 0))))
	var stats: Dictionary = _extract_stats(item)
	if not stats.is_empty():
		lines.append("")
		lines.append("[color=#c59b4a]Stats[/color]")
		for key: Variant in stats.keys():
			lines.append("• " + str(key).replace("_", " ").capitalize() + " " + _signed_float(_to_float(stats[key])))
	var rules: Array = _as_array(item.get("rules", []))
	if not rules.is_empty():
		lines.append("")
		lines.append("[color=#c59b4a]Rules[/color]")
		for rule: Variant in rules:
			lines.append("• " + str(rule))
	return "\n".join(lines)


func _filtered_stash() -> Array:
	var out: Array = []
	for value: Variant in _stash():
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(value)
		if _selected_tab == "all" or _category_matches(item, _selected_tab):
			out.append(item)
	return out


func _count_for_tab(stash: Array, tab_id: String) -> int:
	if tab_id == "all":
		return stash.size()
	var count: int = 0
	for value: Variant in stash:
		if typeof(value) == TYPE_DICTIONARY and _category_matches(Dictionary(value), tab_id):
			count += 1
	return count


func _category_matches(item: Dictionary, tab_id: String) -> bool:
	var category: String = _category_for_item(item)
	if tab_id == "unique":
		return str(item.get("rarity", "normal")).to_lower() == "unique"
	if tab_id == "gear":
		return category in ["gear", "weapon", "armor", "jewelry", "relic"]
	if tab_id == "armor":
		return category == "armor"
	if tab_id == "weapon":
		return category == "weapon"
	if tab_id == "jewelry":
		return category == "jewelry"
	if tab_id == "gem":
		return category == "gem"
	if tab_id == "map":
		return category == "map"
	if tab_id == "material":
		return category == "material"
	return category == tab_id


func _category_for_item(item: Dictionary) -> String:
	var category: String = str(item.get("category", "")).to_lower()
	var kind: String = str(item.get("item_kind", item.get("kind", item.get("slot", "")))).to_lower()
	var slot: String = str(item.get("slot", "")).to_lower()
	if category == "skill_gem" or kind.find("gem") >= 0:
		return "gem"
	if kind == "map" or category == "map":
		return "map"
	if kind in ["currency", "material"] or category in ["currency", "material"]:
		return "material"
	if slot in ["weapon", "offhand"] or kind in ["weapon", "sword", "axe", "wand", "scepter", "shield"]:
		return "weapon"
	if slot in ["helmet", "chest", "gloves", "boots"]:
		return "armor"
	if slot in ["ring", "ring_1", "ring_2", "amulet", "belt"]:
		return "jewelry"
	if slot == "relic" or kind == "relic":
		return "relic"
	return "gear"


func _find_matching_item_index(items: Array, target: Dictionary) -> int:
	var target_id: String = str(target.get("id", ""))
	for i: int in range(items.size()):
		if typeof(items[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(items[i])
		if target_id != "" and str(item.get("id", "")) == target_id:
			return i
		if item == target:
			return i
	return -1


func _selected_item() -> Dictionary:
	var filtered: Array = _filtered_stash()
	if filtered.is_empty() or _stash_cursor < 0 or _stash_cursor >= filtered.size():
		return {}
	if typeof(filtered[_stash_cursor]) == TYPE_DICTIONARY:
		return Dictionary(filtered[_stash_cursor])
	return {}


func _stash() -> Array:
	var value: Variant = _state_get("stash", [])
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []


func _backpack() -> Array:
	var value: Variant = _state_get("backpack", [])
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []


func _state_get(key: String, fallback: Variant = null) -> Variant:
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


func _extract_stats(item: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for field: String in ["stats", "implicit_stats", "explicit_stats"]:
		if item.has(field) and typeof(item[field]) == TYPE_DICTIONARY:
			var stats: Dictionary = Dictionary(item[field])
			for key: Variant in stats.keys():
				out[str(key)] = _to_float(out.get(str(key), 0.0)) + _to_float(stats[key])
	if item.has("affixes") and typeof(item["affixes"]) == TYPE_ARRAY:
		for affix_value: Variant in Array(item["affixes"]):
			if typeof(affix_value) != TYPE_DICTIONARY:
				continue
			var affix: Dictionary = Dictionary(affix_value)
			var stat_key: String = str(affix.get("stat", affix.get("stat_key", affix.get("id", ""))))
			if stat_key == "":
				continue
			out[stat_key] = _to_float(out.get(stat_key, 0.0)) + _to_float(affix.get("value", affix.get("amount", 0.0)))
	return out


func _item_name(item: Dictionary) -> String:
	return str(item.get("display_name", item.get("name", "Item")))


func _item_kind_label(item: Dictionary) -> String:
	return str(item.get("slot", item.get("item_kind", item.get("kind", "item")))).replace("_", " ").capitalize()


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
			return float(value)
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		_:
			return fallback


func _signed_float(value: float) -> String:
	var rounded_value: float = snappedf(value, 0.01)
	if rounded_value > 0.0:
		return "+" + str(rounded_value)
	return str(rounded_value)


func _add_notice(text: String) -> void:
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", text)


func _make_rich_label(scroll: bool) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = false
	label.scroll_active = scroll
	label.add_theme_font_size_override("normal_font_size", 13)
	label.add_theme_color_override("default_color", _text())
	return label


func _make_label(text_value: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_button(text_value: String) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", _text())
	button.add_theme_color_override("font_hover_color", _gold())
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.45, 1.0))
	_apply_button_style(button, false)
	return button


func _make_panel(panel_name: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = panel_name
	panel.add_theme_stylebox_override("panel", _panel_style(false))
	return panel


func _panel_margin() -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	return margin


func _apply_button_style(button: Button, selected: bool = false) -> void:
	button.add_theme_stylebox_override("normal", _button_style(selected, false))
	button.add_theme_stylebox_override("hover", _button_style(true, false))
	button.add_theme_stylebox_override("pressed", _button_style(true, true))
	button.add_theme_stylebox_override("disabled", _button_style(false, false))


func _panel_style(selected: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.047, 0.038, 0.94)
	style.border_color = Color(0.55, 0.40, 0.18, 1.0) if selected else Color(0.22, 0.17, 0.10, 1.0)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _button_style(selected: bool, pressed: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if pressed:
		style.bg_color = Color(0.26, 0.16, 0.07, 0.96)
	elif selected:
		style.bg_color = Color(0.18, 0.12, 0.055, 0.96)
	else:
		style.bg_color = Color(0.075, 0.062, 0.048, 0.94)
	style.border_color = Color(0.78, 0.56, 0.24, 1.0) if selected else Color(0.24, 0.18, 0.11, 1.0)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(7)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _gold() -> Color:
	return Color(0.84, 0.64, 0.30, 1.0)


func _text() -> Color:
	return Color(0.82, 0.78, 0.68, 1.0)


func _muted() -> Color:
	return Color(0.56, 0.52, 0.44, 1.0)
