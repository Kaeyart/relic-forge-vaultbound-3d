extends Control

const GemCoreSystemScript := preload("res://scripts/systems/GemCoreSystem3D.gd")
const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")

const FILTER_ALL: int = 0
const FILTER_ACTIVE: int = 1
const FILTER_SUPPORT: int = 2
const FILTER_SPIRIT: int = 3
const SOCKET_CAP: int = 6

var state_ref: Object = null
var selected_active_index: int = 0
var selected_spirit_index: int = -1
var selected_inventory_index: int = -1
var selected_socket_index: int = -1
var inventory_filter: int = FILTER_ALL
var _last_signature: String = ""

var _root: PanelContainer = null
var _active_list: VBoxContainer = null
var _active_detail: RichTextLabel = null
var _socket_grid: GridContainer = null
var _inventory_filter: OptionButton = null
var _inventory_list: VBoxContainer = null
var _inventory_detail: RichTextLabel = null
var _spirit_list: VBoxContainer = null
var _spirit_summary: RichTextLabel = null
var _action_label: Label = null
var _context_menu: PopupMenu = null


func _ready() -> void:
	_ensure_ui()
	set_process(false)


func bind_state(state: Object) -> void:
	state_ref = state
	_refresh(true)


func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh(false)


func _ensure_ui() -> void:
	if _root != null and is_instance_valid(_root):
		return

	_clear_children(self)

	_context_menu = PopupMenu.new()
	_context_menu.name = "SkillGemContextMenu094D"
	_context_menu.id_pressed.connect(_on_context_action)
	add_child(_context_menu)

	_root = PanelContainer.new()
	_root.name = "SkillGemRoot094D"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	_root.add_child(margin)

	var main: VBoxContainer = VBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	margin.add_child(main)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	main.add_child(header)

	var title: Label = Label.new()
	title.text = "Skill Gems"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_button: Button = _button("Close", Vector2(86, 34))
	close_button.pressed.connect(_close_panel)
	header.add_child(close_button)

	var hint: RichTextLabel = RichTextLabel.new()
	hint.bbcode_enabled = true
	hint.fit_content = true
	hint.scroll_active = false
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.custom_minimum_size = Vector2(0, 44)
	hint.text = "[b]Skill Loadout[/b] · Active gems hold support sockets. Support gems socket into active or spirit gems. Spirit gems reserve spirit and can trigger/passively modify builds."
	main.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(body)

	var active_panel: PanelContainer = PanelContainer.new()
	active_panel.custom_minimum_size = Vector2(260, 0)
	active_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(active_panel)

	var active_margin: MarginContainer = _margin()
	active_panel.add_child(active_margin)

	var active_box: VBoxContainer = VBoxContainer.new()
	active_box.add_theme_constant_override("separation", 8)
	active_margin.add_child(active_box)

	var active_title: Label = Label.new()
	active_title.text = "Active Skills"
	active_title.add_theme_font_size_override("font_size", 18)
	active_box.add_child(active_title)

	_active_list = VBoxContainer.new()
	_active_list.add_theme_constant_override("separation", 6)
	active_box.add_child(_active_list)

	var center_panel: PanelContainer = PanelContainer.new()
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center_panel)

	var center_margin: MarginContainer = _margin()
	center_panel.add_child(center_margin)

	var center_box: VBoxContainer = VBoxContainer.new()
	center_box.add_theme_constant_override("separation", 10)
	center_margin.add_child(center_box)

	var active_detail_title: Label = Label.new()
	active_detail_title.text = "Selected Active Gem"
	active_detail_title.add_theme_font_size_override("font_size", 18)
	center_box.add_child(active_detail_title)

	_active_detail = RichTextLabel.new()
	_active_detail.name = "SelectedActiveGemDetail094D"
	_active_detail.bbcode_enabled = true
	_active_detail.scroll_active = true
	_active_detail.fit_content = false
	_active_detail.custom_minimum_size = Vector2(0, 132)
	center_box.add_child(_active_detail)

	var sockets_title: Label = Label.new()
	sockets_title.text = "Support Sockets"
	sockets_title.add_theme_font_size_override("font_size", 18)
	center_box.add_child(sockets_title)

	_socket_grid = GridContainer.new()
	_socket_grid.name = "SupportSocketGrid094D"
	_socket_grid.columns = 3
	_socket_grid.add_theme_constant_override("h_separation", 8)
	_socket_grid.add_theme_constant_override("v_separation", 8)
	center_box.add_child(_socket_grid)

	var spirit_title: Label = Label.new()
	spirit_title.text = "Spirit Gems"
	spirit_title.add_theme_font_size_override("font_size", 18)
	center_box.add_child(spirit_title)

	_spirit_summary = RichTextLabel.new()
	_spirit_summary.bbcode_enabled = true
	_spirit_summary.fit_content = true
	_spirit_summary.scroll_active = false
	_spirit_summary.custom_minimum_size = Vector2(0, 42)
	center_box.add_child(_spirit_summary)

	var spirit_scroll: ScrollContainer = ScrollContainer.new()
	spirit_scroll.custom_minimum_size = Vector2(0, 150)
	spirit_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_box.add_child(spirit_scroll)

	_spirit_list = VBoxContainer.new()
	_spirit_list.add_theme_constant_override("separation", 6)
	spirit_scroll.add_child(_spirit_list)

	var inventory_panel: PanelContainer = PanelContainer.new()
	inventory_panel.custom_minimum_size = Vector2(340, 0)
	inventory_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(inventory_panel)

	var inventory_margin: MarginContainer = _margin()
	inventory_panel.add_child(inventory_margin)

	var inventory_box: VBoxContainer = VBoxContainer.new()
	inventory_box.add_theme_constant_override("separation", 8)
	inventory_margin.add_child(inventory_box)

	var inventory_header: HBoxContainer = HBoxContainer.new()
	inventory_header.add_theme_constant_override("separation", 8)
	inventory_box.add_child(inventory_header)

	var inventory_title: Label = Label.new()
	inventory_title.text = "Available Gems"
	inventory_title.add_theme_font_size_override("font_size", 18)
	inventory_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_header.add_child(inventory_title)

	_inventory_filter = OptionButton.new()
	_inventory_filter.add_item("All", FILTER_ALL)
	_inventory_filter.add_item("Active", FILTER_ACTIVE)
	_inventory_filter.add_item("Support", FILTER_SUPPORT)
	_inventory_filter.add_item("Spirit", FILTER_SPIRIT)
	_inventory_filter.item_selected.connect(_on_filter_selected)
	inventory_header.add_child(_inventory_filter)

	var inventory_scroll: ScrollContainer = ScrollContainer.new()
	inventory_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_box.add_child(inventory_scroll)

	_inventory_list = VBoxContainer.new()
	_inventory_list.add_theme_constant_override("separation", 6)
	inventory_scroll.add_child(_inventory_list)

	_inventory_detail = RichTextLabel.new()
	_inventory_detail.bbcode_enabled = true
	_inventory_detail.scroll_active = true
	_inventory_detail.fit_content = false
	_inventory_detail.custom_minimum_size = Vector2(0, 140)
	inventory_box.add_child(_inventory_detail)

	_action_label = Label.new()
	_action_label.text = ""
	main.add_child(_action_label)

	var action_row: HBoxContainer = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	main.add_child(action_row)

	_add_action(action_row, "Install / Socket", _install_selected_inventory_gem)
	_add_action(action_row, "Socket to Spirit", _socket_selected_support_to_spirit)
	_add_action(action_row, "Remove Support", _remove_selected_support)
	_add_action(action_row, "Toggle Spirit", _toggle_selected_spirit)
	_add_action(action_row, "Remove Spirit", _remove_selected_spirit)
	_add_action(action_row, "Close", _close_panel)


func _refresh(force: bool) -> void:
	if state_ref == null:
		return
	_ensure_ui()
	GemCoreSystemScript.ensure_defaults(state_ref)

	var sig: String = _signature()
	if not force and sig == _last_signature:
		return
	_last_signature = sig

	_clamp_selection()
	_refresh_active_list()
	_refresh_active_editor()
	_refresh_inventory()
	_refresh_spirit()
	_refresh_action_label()


func _signature() -> String:
	return JSON.stringify([
		_state_get("active_skill_slots", []),
		_state_get("spirit_gem_slots", []),
		_state_get("backpack", []),
		_state_get("selected_skill_slot", 0),
		_state_get("spirit_reserved", 0),
		_state_get("spirit_max", 0),
		selected_active_index,
		selected_spirit_index,
		selected_inventory_index,
		selected_socket_index,
		inventory_filter,
	])


func _clamp_selection() -> void:
	var slots: Array = Array(_state_get("active_skill_slots", []))
	if slots.is_empty():
		selected_active_index = 0
	else:
		selected_active_index = clampi(selected_active_index, 0, slots.size() - 1)

	var spirits: Array = Array(_state_get("spirit_gem_slots", []))
	if spirits.is_empty():
		selected_spirit_index = -1
	else:
		selected_spirit_index = clampi(selected_spirit_index, -1, spirits.size() - 1)

	var backpack: Array = Array(_state_get("backpack", []))
	if backpack.is_empty():
		selected_inventory_index = -1
	else:
		selected_inventory_index = clampi(selected_inventory_index, -1, backpack.size() - 1)

	selected_socket_index = clampi(selected_socket_index, -1, SOCKET_CAP - 1)


func _refresh_active_list() -> void:
	_clear_children(_active_list)

	var slots: Array = Array(_state_get("active_skill_slots", []))
	for i: int in range(slots.size()):
		var slot: Dictionary = _active_slot(i)
		var button: Button = _button(_active_slot_text(i, slot), Vector2(0, 76))
		button.clip_text = true
		if i == selected_active_index:
			button.text = "▶ " + button.text
		button.modulate = _gem_color("active", str(slot.get("gem_id", "")))
		button.pressed.connect(_select_active.bind(i))
		_active_list.add_child(button)


func _active_slot_text(index: int, slot: Dictionary) -> String:
	var name: String = GemCoreSystemScript.active_display_name(slot)
	var level: int = _to_int(slot.get("level", 1), 1)
	var xp: int = _to_int(slot.get("xp", 0), 0)
	var quality: int = _to_int(slot.get("quality", 0), 0)
	var supports: Array = Array(slot.get("supports", []))
	var sockets: int = GemCoreSystemScript.unlocked_support_sockets(level)
	return "Slot " + str(index + 1) + "\n" + name + "  Lv " + str(level) + " Q+" + str(quality) + "\nXP " + str(xp) + "/" + str(GemCoreSystemScript.xp_to_next(level)) + " · " + str(supports.size()) + "/" + str(sockets) + " supports"


func _refresh_active_editor() -> void:
	var active: Dictionary = _selected_active()
	if active.is_empty():
		_active_detail.text = "[i]No active skill selected.[/i]"
		_clear_children(_socket_grid)
		return

	var lines: PackedStringArray = []
	lines.append("[b]" + GemCoreSystemScript.active_display_name(active) + "[/b]")
	lines.append("Active Gem · Level " + str(_to_int(active.get("level", 1), 1)) + " · XP " + str(_to_int(active.get("xp", 0), 0)) + "/" + str(GemCoreSystemScript.xp_to_next(_to_int(active.get("level", 1), 1))))
	lines.append("Quality +" + str(_to_int(active.get("quality", 0), 0)) + "%")
	lines.append(GemCoreSystemScript.quality_effect_text("active", str(active.get("gem_id", "")), _to_int(active.get("quality", 0), 0)))
	lines.append("Sockets unlocked: " + str(GemCoreSystemScript.unlocked_support_sockets(_to_int(active.get("level", 1), 1))) + "/" + str(SOCKET_CAP))
	lines.append("")
	lines.append("[i]Select a support gem on the right, then press Install / Socket. Click a filled socket, then Remove Support to unsocket it.[/i]")
	_active_detail.text = "\n".join(lines)

	_refresh_sockets(active)


func _refresh_sockets(active: Dictionary) -> void:
	_clear_children(_socket_grid)

	var level: int = _to_int(active.get("level", 1), 1)
	var unlocked: int = GemCoreSystemScript.unlocked_support_sockets(level)
	var supports: Array = Array(active.get("supports", []))

	for i: int in range(SOCKET_CAP):
		var socket_button: Button = _button("", Vector2(170, 70))
		socket_button.clip_text = true

		if i < supports.size() and typeof(supports[i]) == TYPE_DICTIONARY:
			var support: Dictionary = GemCoreSystemScript.normalize_support(Dictionary(supports[i]))
			socket_button.text = "Socket " + str(i + 1) + "\n" + GemCoreSystemScript.support_display_name(support) + "\nLv " + str(_to_int(support.get("level", 1), 1)) + " Q+" + str(_to_int(support.get("quality", 0), 0))
			socket_button.modulate = _gem_color("support", str(support.get("gem_id", "")))
		elif i < unlocked:
			socket_button.text = "Socket " + str(i + 1) + "\nEmpty\nUnlocked"
			socket_button.modulate = Color(0.86, 0.86, 0.86, 1.0)
		else:
			var req_level: int = _socket_required_level(i)
			socket_button.text = "Socket " + str(i + 1) + "\nLocked\nUnlocks Lv " + str(req_level)
			socket_button.modulate = Color(0.42, 0.42, 0.42, 1.0)

		if i == selected_socket_index:
			socket_button.text = "▶ " + socket_button.text

		socket_button.pressed.connect(_select_socket.bind(i))
		_socket_grid.add_child(socket_button)


func _refresh_inventory() -> void:
	_clear_children(_inventory_list)

	if _inventory_filter != null and _inventory_filter.selected != inventory_filter:
		_inventory_filter.select(inventory_filter)

	var gem_count: int = 0
	var backpack: Array = Array(_state_get("backpack", []))
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i])
		var type: String = GemCoreSystemScript.gem_type(item)
		if type == "":
			continue
		if not _filter_accepts(type):
			continue

		gem_count += 1
		var button: Button = _button(_inventory_gem_text(i, item, type), Vector2(0, 72))
		button.clip_text = true
		button.modulate = _gem_color(type, str(item.get("gem_id", item.get("base_id", ""))))
		if i == selected_inventory_index:
			button.text = "▶ " + button.text
		button.pressed.connect(_select_inventory_gem.bind(i))
		button.gui_input.connect(_on_inventory_gem_input.bind(i))
		_inventory_list.add_child(button)

	if gem_count == 0:
		var label: Label = Label.new()
		label.text = "No matching gem items in backpack."
		_inventory_list.add_child(label)

	_refresh_inventory_detail()


func _inventory_gem_text(index: int, item: Dictionary, type: String) -> String:
	var name: String = str(item.get("display_name", item.get("name", "Gem")))
	var level: int = _to_int(item.get("level", item.get("gem_level", 1)), 1)
	var xp: int = _to_int(item.get("xp", item.get("gem_xp", 0)), 0)
	var quality: int = _to_int(item.get("quality", item.get("gem_quality", 0)), 0)
	return type.capitalize() + " · #" + str(index + 1) + "\n" + name + "\nLv " + str(level) + " XP " + str(xp) + " Q+" + str(quality)


func _refresh_inventory_detail() -> void:
	if _inventory_detail == null:
		return

	var item: Dictionary = _selected_inventory_gem()
	if item.is_empty():
		_inventory_detail.text = "[i]Select an inventory gem.[/i]\nActive: installs into the selected active slot.\nSupport: sockets into selected active or spirit target.\nSpirit: installs into spirit section disabled."
		return

	var type: String = GemCoreSystemScript.gem_type(item)
	_inventory_detail.text = GemCoreSystemScript.gem_detail_text(item, type)


func _refresh_spirit() -> void:
	_clear_children(_spirit_list)

	var spirit_max: int = _to_int(_state_get("spirit_max", 100), 100)
	var reserved: int = _to_int(_state_get("spirit_reserved", 0), 0)

	_spirit_summary.text = "[b]Spirit Reservation[/b]\nReserved: " + str(reserved) + " / " + str(spirit_max) + "\n[i]Spirit gems start disabled. Toggle them to reserve spirit. Support gems increase reservation but modify the spirit effect.[/i]"

	var spirits: Array = Array(_state_get("spirit_gem_slots", []))
	if spirits.is_empty():
		var label: Label = Label.new()
		label.text = "No spirit gems installed."
		_spirit_list.add_child(label)
		return

	for i: int in range(spirits.size()):
		if typeof(spirits[i]) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = GemCoreSystemScript.normalize_spirit(Dictionary(spirits[i]))
		var button: Button = _button(_spirit_text(i, spirit), Vector2(0, 76))
		button.clip_text = true
		button.modulate = _gem_color("spirit", str(spirit.get("gem_id", "")))
		if i == selected_spirit_index:
			button.text = "▶ " + button.text
		button.pressed.connect(_select_spirit.bind(i))
		button.gui_input.connect(_on_spirit_input.bind(i))
		_spirit_list.add_child(button)


func _spirit_text(index: int, spirit: Dictionary) -> String:
	var name: String = GemCoreSystemScript.spirit_display_name(spirit)
	var enabled: String = "ON" if bool(spirit.get("enabled", false)) else "OFF"
	var level: int = _to_int(spirit.get("level", 1), 1)
	var quality: int = _to_int(spirit.get("quality", 0), 0)
	var supports: Array = Array(spirit.get("supports", []))
	var sockets: int = GemCoreSystemScript.unlocked_support_sockets(level)
	return "Spirit " + str(index + 1) + " [" + enabled + "]\n" + name + " · Lv " + str(level) + " Q+" + str(quality) + "\nSupports " + str(supports.size()) + "/" + str(sockets)


func _refresh_action_label() -> void:
	if _action_label == null:
		return

	var item: Dictionary = _selected_inventory_gem()
	if item.is_empty():
		_action_label.text = "Action: select an inventory gem, active slot, support socket, or spirit gem."
		return

	var type: String = GemCoreSystemScript.gem_type(item)
	match type:
		"active":
			_action_label.text = "Action: install active gem into Active Slot " + str(selected_active_index + 1) + "."
		"support":
			if selected_spirit_index >= 0:
				_action_label.text = "Action: socket support into selected active gem, or press Socket to Spirit for selected spirit gem."
			else:
				_action_label.text = "Action: socket support into selected active gem."
		"spirit":
			_action_label.text = "Action: install spirit gem disabled, then toggle it when you want to reserve spirit."
		_:
			_action_label.text = "Action: selected item is not a gem."


func _select_active(index: int) -> void:
	selected_active_index = index
	selected_socket_index = -1
	if state_ref != null:
		state_ref.set("selected_skill_slot", index)
	_last_signature = ""
	_refresh(true)


func _select_socket(index: int) -> void:
	selected_socket_index = index
	_last_signature = ""
	_refresh(true)


func _select_spirit(index: int) -> void:
	selected_spirit_index = index
	_last_signature = ""
	_refresh(true)


func _select_inventory_gem(index: int) -> void:
	selected_inventory_index = index
	_last_signature = ""
	_refresh(true)


func _on_filter_selected(index: int) -> void:
	inventory_filter = index
	_last_signature = ""
	_refresh(true)


func _on_inventory_gem_input(event: InputEvent, backpack_index: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed:
			return
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.double_click:
			_select_inventory_gem(backpack_index)
			_install_selected_inventory_gem()
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_select_inventory_gem(backpack_index)
			_show_context(mouse_event.global_position)


func _on_spirit_input(event: InputEvent, spirit_index: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed:
			return
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.double_click:
			_select_spirit(spirit_index)
			_toggle_selected_spirit()
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_select_spirit(spirit_index)
			_show_spirit_context(mouse_event.global_position)


func _show_context(global_pos: Vector2) -> void:
	_context_menu.clear()
	_context_menu.add_item("Install / Socket", 1)
	_context_menu.add_item("Socket to Spirit", 2)
	_context_menu.position = Vector2i(int(global_pos.x), int(global_pos.y))
	_context_menu.popup()


func _show_spirit_context(global_pos: Vector2) -> void:
	_context_menu.clear()
	_context_menu.add_item("Toggle Spirit", 3)
	_context_menu.add_item("Remove Spirit", 4)
	_context_menu.position = Vector2i(int(global_pos.x), int(global_pos.y))
	_context_menu.popup()


func _on_context_action(id: int) -> void:
	match id:
		1:
			_install_selected_inventory_gem()
		2:
			_socket_selected_support_to_spirit()
		3:
			_toggle_selected_spirit()
		4:
			_remove_selected_spirit()


func _install_selected_inventory_gem() -> void:
	if state_ref == null:
		return
	var item: Dictionary = _selected_inventory_gem()
	if item.is_empty():
		_notice("Select an inventory gem first.")
		return

	var type: String = GemCoreSystemScript.gem_type(item)
	var msg: String = ""

	match type:
		"active":
			msg = GemCoreSystemScript.install_active_from_inventory(state_ref, selected_inventory_index, selected_active_index)
			selected_inventory_index = -1
		"support":
			msg = GemCoreSystemScript.install_support_from_inventory_to_active(state_ref, selected_inventory_index, selected_active_index)
			selected_inventory_index = -1
		"spirit":
			msg = GemCoreSystemScript.install_spirit_from_inventory(state_ref, selected_inventory_index)
			selected_inventory_index = -1
		_:
			msg = "That item is not a gem."

	_notice(msg)
	_last_signature = ""
	_refresh(true)


func _socket_selected_support_to_spirit() -> void:
	if state_ref == null:
		return
	var item: Dictionary = _selected_inventory_gem()
	if item.is_empty():
		_notice("Select a support gem first.")
		return
	if GemCoreSystemScript.gem_type(item) != "support":
		_notice("Only support gems can socket into spirit gems.")
		return
	if selected_spirit_index < 0:
		_notice("Select a spirit gem first.")
		return

	var msg: String = GemCoreSystemScript.install_support_from_inventory_to_spirit(state_ref, selected_inventory_index, selected_spirit_index)
	selected_inventory_index = -1
	_notice(msg)
	_last_signature = ""
	_refresh(true)


func _remove_selected_support() -> void:
	if state_ref == null:
		return
	if selected_socket_index < 0:
		_notice("Select a filled support socket first.")
		return

	var slots: Array = Array(_state_get("active_skill_slots", []))
	if selected_active_index < 0 or selected_active_index >= slots.size() or typeof(slots[selected_active_index]) != TYPE_DICTIONARY:
		_notice("No active gem selected.")
		return

	var active: Dictionary = GemCoreSystemScript.normalize_active(Dictionary(slots[selected_active_index]))
	var supports: Array = Array(active.get("supports", []))
	if selected_socket_index < 0 or selected_socket_index >= supports.size() or typeof(supports[selected_socket_index]) != TYPE_DICTIONARY:
		_notice("That socket is empty.")
		return

	var support: Dictionary = GemCoreSystemScript.normalize_support(Dictionary(supports[selected_socket_index]))
	supports.remove_at(selected_socket_index)
	active["supports"] = supports
	slots[selected_active_index] = active

	var backpack: Array = Array(_state_get("backpack", []))
	backpack.append(GemCoreSystemScript.support_to_item(support))

	state_ref.set("active_skill_slots", slots)
	state_ref.set("backpack", backpack)
	selected_socket_index = -1
	_notice("Removed support gem.")
	_last_signature = ""
	_refresh(true)


func _toggle_selected_spirit() -> void:
	if state_ref == null:
		return
	var spirits: Array = Array(_state_get("spirit_gem_slots", []))
	if selected_spirit_index < 0 or selected_spirit_index >= spirits.size() or typeof(spirits[selected_spirit_index]) != TYPE_DICTIONARY:
		_notice("Select a spirit gem first.")
		return

	var spirit: Dictionary = GemCoreSystemScript.normalize_spirit(Dictionary(spirits[selected_spirit_index]))
	spirit["enabled"] = not bool(spirit.get("enabled", false))
	spirits[selected_spirit_index] = spirit
	state_ref.set("spirit_gem_slots", spirits)
	GemCoreSystemScript.recompute_spirit_reservation(state_ref)

	var reserved: int = _to_int(_state_get("spirit_reserved", 0), 0)
	var spirit_max: int = _to_int(_state_get("spirit_max", 100), 100)
	if reserved > spirit_max:
		spirit["enabled"] = false
		spirits[selected_spirit_index] = spirit
		state_ref.set("spirit_gem_slots", spirits)
		GemCoreSystemScript.recompute_spirit_reservation(state_ref)
		_notice("Not enough spirit reservation.")
	else:
		_notice("Spirit toggled.")

	_last_signature = ""
	_refresh(true)


func _remove_selected_spirit() -> void:
	if state_ref == null:
		return

	var spirits: Array = Array(_state_get("spirit_gem_slots", []))
	if selected_spirit_index < 0 or selected_spirit_index >= spirits.size() or typeof(spirits[selected_spirit_index]) != TYPE_DICTIONARY:
		_notice("Select a spirit gem first.")
		return

	var spirit: Dictionary = GemCoreSystemScript.normalize_spirit(Dictionary(spirits[selected_spirit_index]))
	spirits.remove_at(selected_spirit_index)

	var backpack: Array = Array(_state_get("backpack", []))
	backpack.append(GemCoreSystemScript.spirit_to_item(spirit))

	state_ref.set("spirit_gem_slots", spirits)
	state_ref.set("backpack", backpack)
	selected_spirit_index = clampi(selected_spirit_index, -1, spirits.size() - 1)
	GemCoreSystemScript.recompute_spirit_reservation(state_ref)
	_notice("Removed spirit gem.")
	_last_signature = ""
	_refresh(true)


func _filter_accepts(type: String) -> bool:
	match inventory_filter:
		FILTER_ACTIVE:
			return type == "active"
		FILTER_SUPPORT:
			return type == "support"
		FILTER_SPIRIT:
			return type == "spirit"
		_:
			return true


func _active_slot(index: int) -> Dictionary:
	var slots: Array = Array(_state_get("active_skill_slots", []))
	if index < 0 or index >= slots.size() or typeof(slots[index]) != TYPE_DICTIONARY:
		return {}
	return GemCoreSystemScript.normalize_active(Dictionary(slots[index]))


func _selected_active() -> Dictionary:
	return _active_slot(selected_active_index)


func _selected_inventory_gem() -> Dictionary:
	var backpack: Array = Array(_state_get("backpack", []))
	if selected_inventory_index < 0 or selected_inventory_index >= backpack.size() or typeof(backpack[selected_inventory_index]) != TYPE_DICTIONARY:
		return {}
	var item: Dictionary = Dictionary(backpack[selected_inventory_index])
	if GemCoreSystemScript.gem_type(item) == "":
		return {}
	return item


func _socket_required_level(socket_index: int) -> int:
	if socket_index < 2:
		return 1
	return (socket_index - 1) * 5


func _gem_color(type: String, id: String) -> Color:
	match type:
		"active":
			var active_data: Dictionary = GemCoreSystemScript.gem_data("active", id)
			return _color_for_gem_color(str(active_data.get("color", "blue")))
		"support":
			var support_data: Dictionary = GemCoreSystemScript.gem_data("support", id)
			return _color_for_gem_color(str(support_data.get("color", "green")))
		"spirit":
			var spirit_data: Dictionary = GemCoreSystemScript.gem_data("spirit", id)
			return _color_for_gem_color(str(spirit_data.get("color", "blue")))
		_:
			return Color(1, 1, 1, 1)


func _color_for_gem_color(value: String) -> Color:
	match value.strip_edges().to_lower():
		"red":
			return Color(1.0, 0.48, 0.42, 1.0)
		"green":
			return Color(0.46, 0.95, 0.56, 1.0)
		"blue":
			return Color(0.48, 0.66, 1.0, 1.0)
		_:
			return Color(0.9, 0.9, 0.9, 1.0)


func _button(text_value: String, min_size: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = min_size
	button.clip_text = true
	return button


func _add_action(parent: HBoxContainer, text_value: String, callback: Callable) -> void:
	var button: Button = _button(text_value, Vector2(132, 34))
	button.pressed.connect(callback)
	parent.add_child(button)


func _margin() -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	return margin


func _close_panel() -> void:
	if state_ref != null:
		state_ref.set("panel_mode", "")


func _notice(value: String) -> void:
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", value)


func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value


func _clear_children(node: Node) -> void:
	if node == null:
		return
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
