extends Control

const SkillGemSystemScript: GDScript = preload("res://scripts/systems/SkillGemSystem3D.gd")

const BG: Color = Color(0.045, 0.037, 0.030, 0.96)
const BG_2: Color = Color(0.075, 0.060, 0.045, 0.96)
const BG_SEL: Color = Color(0.150, 0.095, 0.035, 0.98)
const BORDER: Color = Color(0.260, 0.205, 0.115, 1.0)
const GOLD: Color = Color(0.750, 0.545, 0.225, 1.0)
const TEXT: Color = Color(0.870, 0.825, 0.720, 1.0)
const MUTED: Color = Color(0.570, 0.520, 0.430, 1.0)
const BLUE: Color = Color(0.420, 0.620, 1.000, 1.0)
const RED: Color = Color(0.950, 0.390, 0.230, 1.0)
const GREEN: Color = Color(0.470, 0.850, 0.440, 1.0)

var state_ref: Object = null
var hotbar_box: VBoxContainer = null
var gem_page_box: VBoxContainer = null
var detail_box: VBoxContainer = null
var socket_box: HBoxContainer = null
var carve_box: VBoxContainer = null
var inventory_box: VBoxContainer = null
var support_box: VBoxContainer = null
var spirit_box: VBoxContainer = null
var footer_label: RichTextLabel = null


func _ready() -> void:
	_build_layout()
	_render()


func bind_state(state: Object) -> void:
	state_ref = state
	_prepare_state()
	_render()


func update_from_state(state: Object) -> void:
	state_ref = state
	_prepare_state()
	_render()


func mark_dirty() -> void:
	_prepare_state()
	_render()


func _prepare_state() -> void:
	if state_ref == null:
		return
	SkillGemSystemScript.ensure_defaults(state_ref)
	_normalize_gem_inventory()
	_import_backpack_gems_to_gem_inventory()
	_ensure_testable_gems_if_empty()


func _build_layout() -> void:
	_clear_children(self)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS

	var root: MarginContainer = MarginContainer.new()
	root.name = "GemTransactionRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 6)
	root.add_theme_constant_override("margin_right", 6)
	root.add_theme_constant_override("margin_top", 6)
	root.add_theme_constant_override("margin_bottom", 6)
	add_child(root)

	var main: VBoxContainer = VBoxContainer.new()
	main.name = "Main"
	main.add_theme_constant_override("separation", 6)
	root.add_child(main)

	var header: PanelContainer = _panel(BG, GOLD, 2)
	header.custom_minimum_size = Vector2(0, 46)
	main.add_child(header)

	var header_margin: MarginContainer = _margin(10, 5, 10, 5)
	header.add_child(header_margin)

	var header_row: HBoxContainer = HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 8)
	header_margin.add_child(header_row)

	var title: Label = Label.new()
	title.text = "SKILL GEMS · GEMCUTTING BENCH"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(title)

	var hint: RichTextLabel = _rich("[color=#c59b4a]Mouse-first:[/color] Click Uncut → click result. Click support → click socket.", 11)
	hint.custom_minimum_size = Vector2(360, 34)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	main.add_child(body)

	var left: VBoxContainer = VBoxContainer.new()
	left.custom_minimum_size = Vector2(235, 0)
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 6)
	body.add_child(left)

	var hotbar_panel: PanelContainer = _panel(BG, BORDER, 1)
	hotbar_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(hotbar_panel)
	var hotbar_margin: MarginContainer = _margin(7, 7, 7, 7)
	hotbar_panel.add_child(hotbar_margin)
	var hotbar_main: VBoxContainer = VBoxContainer.new()
	hotbar_main.add_theme_constant_override("separation", 5)
	hotbar_margin.add_child(hotbar_main)
	hotbar_main.add_child(_section("HOTBAR BINDINGS"))
	hotbar_box = VBoxContainer.new()
	hotbar_box.add_theme_constant_override("separation", 4)
	hotbar_main.add_child(hotbar_box)

	var page_panel: PanelContainer = _panel(BG, BORDER, 1)
	page_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(page_panel)
	var page_scroll: ScrollContainer = ScrollContainer.new()
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_panel.add_child(page_scroll)
	var page_margin: MarginContainer = _margin(7, 7, 7, 7)
	page_scroll.add_child(page_margin)
	var page_main: VBoxContainer = VBoxContainer.new()
	page_main.add_theme_constant_override("separation", 5)
	page_margin.add_child(page_main)
	page_main.add_child(_section("EQUIPPED GEM PAGE"))
	gem_page_box = VBoxContainer.new()
	gem_page_box.add_theme_constant_override("separation", 4)
	page_main.add_child(gem_page_box)

	var center_panel: PanelContainer = _panel(BG, BORDER, 1)
	center_panel.custom_minimum_size = Vector2(410, 0)
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center_panel)

	var center_scroll: ScrollContainer = ScrollContainer.new()
	center_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	center_panel.add_child(center_scroll)
	var center_margin: MarginContainer = _margin(8, 8, 8, 8)
	center_scroll.add_child(center_margin)
	var center_main: VBoxContainer = VBoxContainer.new()
	center_main.add_theme_constant_override("separation", 8)
	center_margin.add_child(center_main)
	center_main.add_child(_section("SELECTED GEM"))
	detail_box = VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 8)
	center_main.add_child(detail_box)
	center_main.add_child(_section("SUPPORT SOCKETS"))
	socket_box = HBoxContainer.new()
	socket_box.add_theme_constant_override("separation", 5)
	center_main.add_child(socket_box)
	center_main.add_child(_section("GEMCUTTING TARGETS"))
	carve_box = VBoxContainer.new()
	carve_box.add_theme_constant_override("separation", 4)
	center_main.add_child(carve_box)

	var right_panel: PanelContainer = _panel(BG, BORDER, 1)
	right_panel.custom_minimum_size = Vector2(260, 0)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(right_panel)

	var right_scroll: ScrollContainer = ScrollContainer.new()
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_panel.add_child(right_scroll)
	var right_margin: MarginContainer = _margin(8, 8, 8, 8)
	right_scroll.add_child(right_margin)
	var right_main: VBoxContainer = VBoxContainer.new()
	right_main.add_theme_constant_override("separation", 8)
	right_margin.add_child(right_main)
	right_main.add_child(_section("UNCUT GEMS"))
	inventory_box = VBoxContainer.new()
	inventory_box.add_theme_constant_override("separation", 4)
	right_main.add_child(inventory_box)
	right_main.add_child(_section("SUPPORT GEMS"))
	support_box = VBoxContainer.new()
	support_box.add_theme_constant_override("separation", 4)
	right_main.add_child(support_box)
	right_main.add_child(_section("SPIRIT GEMS"))
	spirit_box = VBoxContainer.new()
	spirit_box.add_theme_constant_override("separation", 4)
	right_main.add_child(spirit_box)

	var footer_panel: PanelContainer = _panel(BG_2, BORDER, 1)
	footer_panel.custom_minimum_size = Vector2(0, 38)
	main.add_child(footer_panel)
	var footer_margin: MarginContainer = _margin(8, 5, 8, 5)
	footer_panel.add_child(footer_margin)
	footer_label = _rich("", 13)
	footer_margin.add_child(footer_label)


func _render() -> void:
	if hotbar_box == null:
		return
	if state_ref != null:
		_prepare_state()
	_render_hotbar()
	_render_gem_page()
	_render_detail()
	_render_sockets()
	_render_carve_targets()
	_render_uncut_inventory()
	_render_support_inventory()
	_render_spirit_inventory()
	_render_footer()


func _render_hotbar() -> void:
	_clear_children(hotbar_box)
	if state_ref == null:
		hotbar_box.add_child(_muted("No state bound."))
		return
	var hotbar: Array = _as_array(_state_get("hotbar_slots", []))
	var selected: int = clampi(_to_int(_state_get("selected_hotbar_slot", _state_get("selected_skill_slot", 0))), 0, 4)
	for i: int in range(5):
		var uid: String = ""
		if i < hotbar.size():
			uid = str(hotbar[i])
		var active: Dictionary = _find_active(uid)
		var name_text: String = "Empty"
		if not active.is_empty():
			name_text = SkillGemSystemScript.active_display_name(active)
		var button: Button = _button(str(i + 1) + " · " + name_text, _select_hotbar.bind(i), i == selected, 34)
		hotbar_box.add_child(button)


func _render_gem_page() -> void:
	_clear_children(gem_page_box)
	if state_ref == null:
		return
	var page: Array = _as_array(_state_get("equipped_gem_page", []))
	var selected_uid: String = str(_state_get("selected_gem_uid", ""))
	for i: int in range(9):
		var gem: Dictionary = {}
		if i < page.size() and typeof(page[i]) == TYPE_DICTIONARY:
			gem = Dictionary(page[i])
		var uid: String = str(gem.get("uid", ""))
		var label: String = "Row " + str(i + 1) + " · Empty"
		if not gem.is_empty():
			var level: int = _to_int(gem.get("level", 1), 1)
			var sockets_used: int = _socket_used_count(gem)
			var sockets_max: int = SkillGemSystemScript.support_socket_count_for_gem(gem)
			label = str(i + 1) + " · " + SkillGemSystemScript.active_display_name(gem) + "  Lv " + str(level) + "  " + str(sockets_used) + "/" + str(sockets_max)
		var button: Button = _button(label, _select_active_gem.bind(uid), uid != "" and uid == selected_uid, 42)
		button.disabled = gem.is_empty()
		gem_page_box.add_child(button)


func _render_detail() -> void:
	_clear_children(detail_box)
	if state_ref == null:
		detail_box.add_child(_muted("No state."))
		return
	var active: Dictionary = _selected_active_or_hotbar()
	var spirit: Dictionary = _selected_spirit()
	var uncut: Dictionary = _selected_uncut()
	var support: Dictionary = _selected_support()

	if not uncut.is_empty():
		var text: String = "[font_size=20][color=#c59b4a]" + _gem_label(uncut) + "[/color][/font_size]\n"
		text += "Level " + str(_to_int(uncut.get("gem_level", uncut.get("level", 1)), 1)) + " · choose a carve target below.\n"
		text += "This consumes the uncut gem and creates a real gem instance."
		detail_box.add_child(_rich(text, 14))
		return

	if not active.is_empty():
		var detail: String = SkillGemSystemScript.gem_detail_text(active, "active")
		detail += "\n\n[color=#8f8777]" + SkillGemSystemScript.behavior_preview_text(state_ref, active) + "[/color]"
		detail += "\n\n[color=#c59b4a]Bind selected active to hotbar:[/color]"
		detail_box.add_child(_rich(detail, 14))
		var bind_row: HBoxContainer = HBoxContainer.new()
		bind_row.add_theme_constant_override("separation", 8)
		detail_box.add_child(bind_row)
		var uid: String = str(active.get("uid", ""))
		for i: int in range(5):
			bind_row.add_child(_small_button("Bind " + str(i + 1), _bind_active_to_hotbar.bind(uid, i)))
		return

	if not spirit.is_empty():
		var enabled_text: String = "Enabled" if bool(spirit.get("enabled", false)) else "Disabled"
		var stext: String = "[font_size=20][color=#c59b4a]" + SkillGemSystemScript.spirit_display_name(spirit) + "[/color][/font_size]\n"
		stext += enabled_text + " · Reserves " + str(SkillGemSystemScript.spirit_reservation(spirit)) + " Spirit\n"
		stext += "Support sockets unlock like active gems: 2 base, +1 every 5 levels, max 6."
		detail_box.add_child(_rich(stext, 14))
		detail_box.add_child(_button("Toggle Selected Spirit Gem", _toggle_selected_spirit.bind(str(spirit.get("uid", ""))), false, 42))
		return

	if not support.is_empty():
		var support_text: String = "[font_size=20][color=#c59b4a]" + SkillGemSystemScript.support_display_name(support) + "[/color][/font_size]\n"
		support_text += "Click an empty unlocked socket on the selected active/spirit gem to socket this support."
		detail_box.add_child(_rich(support_text, 14))
		return

	detail_box.add_child(_muted("Select an active gem, uncut gem, support gem, or spirit gem."))


func _render_sockets() -> void:
	_clear_children(socket_box)
	if state_ref == null:
		return
	var target: Dictionary = _selected_socket_owner()
	if target.is_empty():
		socket_box.add_child(_muted("No active/spirit gem selected."))
		return
	var sockets: Array = _as_array(target.get("support_sockets", []))
	var unlocked: int = SkillGemSystemScript.support_socket_count_for_gem(target)
	var target_uid: String = str(target.get("uid", ""))
	for i: int in range(6):
		var occupied_uid: String = ""
		if i < sockets.size():
			occupied_uid = str(sockets[i])
		var label: String = "Socket " + str(i + 1)
		var disabled: bool = false
		var action: Callable = _socket_selected_support.bind(target_uid, i)
		if i >= unlocked:
			label += "\nLocked\nLv " + str(_socket_required_level(i))
			disabled = true
		elif occupied_uid != "":
			var supp: Dictionary = _find_support(occupied_uid, false)
			label += "\n" + (SkillGemSystemScript.support_display_name(supp) if not supp.is_empty() else occupied_uid) + "\nRight/Click remove"
			action = _unsocket.bind(target_uid, i)
		else:
			label += "\nEmpty\nClick to socket"
		var button: Button = _button(label, action, false, 68)
		button.custom_minimum_size = Vector2(84, 68)
		button.disabled = disabled
		socket_box.add_child(button)


func _render_carve_targets() -> void:
	_clear_children(carve_box)
	if state_ref == null:
		return
	var uncut: Dictionary = _selected_uncut()
	if uncut.is_empty():
		carve_box.add_child(_muted("Select an Uncut Gem on the right. Carve targets appear here."))
		return
	var targets: Array = SkillGemSystemScript.possible_carve_targets(uncut)
	if targets.is_empty():
		carve_box.add_child(_muted("No carve targets for " + _gem_label(uncut) + "."))
		return
	var grid: GridContainer = GridContainer.new()
	grid.columns = 1
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	carve_box.add_child(grid)
	var kind_value: String = str(uncut.get("kind", ""))
	var uncut_uid: String = str(uncut.get("uid", ""))
	for value: Variant in targets:
		var gem_id: String = str(value)
		var name_text: String = SkillGemSystemScript.display_name_for_target(kind_value, gem_id)
		grid.add_child(_button(name_text + " · carve", _carve_target.bind(uncut_uid, gem_id), false, 42))


func _render_uncut_inventory() -> void:
	_clear_children(inventory_box)
	if state_ref == null:
		return
	var uncut: Array = SkillGemSystemScript.uncut_gem_instances(state_ref)
	var selected: String = str(_state_get("selected_uncut_uid", ""))
	if uncut.is_empty():
		inventory_box.add_child(_muted("No Uncut Gems. Run maps or use the starter injection below."))
		inventory_box.add_child(_small_button("Create test Uncut set", _create_test_uncuts))
		return
	for value: Variant in uncut:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		var uid: String = str(gem.get("uid", ""))
		var label: String = _gem_label(gem) + "\nClick → choose target"
		inventory_box.add_child(_button(label, _select_uncut.bind(uid), uid == selected, 44))


func _render_support_inventory() -> void:
	_clear_children(support_box)
	if state_ref == null:
		return
	var selected: String = str(_state_get("selected_support_uid", ""))
	var supports: Array = SkillGemSystemScript.support_gem_instances(state_ref, false)
	if supports.is_empty():
		support_box.add_child(_muted("No support gems yet. Carve an Uncut Support Gem."))
		return
	for value: Variant in supports:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		var uid: String = str(gem.get("uid", ""))
		var equipped_to: String = str(gem.get("equipped_to", ""))
		var label: String = SkillGemSystemScript.support_display_name(gem)
		if equipped_to != "":
			label += "\nSocketed"
		else:
			label += "\nAvailable · click then click socket"
		support_box.add_child(_button(label, _select_support.bind(uid), uid == selected, 42))


func _render_spirit_inventory() -> void:
	_clear_children(spirit_box)
	if state_ref == null:
		return
	var spirits: Array = SkillGemSystemScript.spirit_gem_instances(state_ref)
	var selected: String = str(_state_get("selected_spirit_uid", ""))
	if spirits.is_empty():
		spirit_box.add_child(_muted("No spirit gems yet. Carve an Uncut Spirit Gem."))
		return
	for value: Variant in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		var uid: String = str(gem.get("uid", ""))
		var enabled_text: String = "Enabled" if bool(gem.get("enabled", false)) else "Disabled"
		var label: String = SkillGemSystemScript.spirit_display_name(gem) + "\n" + enabled_text + " · Reserves " + str(SkillGemSystemScript.spirit_reservation(gem))
		spirit_box.add_child(_button(label, _select_spirit.bind(uid), uid == selected, 42))


func _render_footer() -> void:
	if footer_label == null:
		return
	var message: String = str(_state_get("gem_last_message", ""))
	if message == "":
		message = "Click Uncut Gem → click carve target. Click Support Gem → click empty socket. Click occupied socket → remove support."
	footer_label.text = "[color=#c59b4a]Gem Bench:[/color] " + message


func _select_hotbar(index: int) -> void:
	if state_ref == null:
		return
	state_ref.set("selected_hotbar_slot", index)
	state_ref.set("selected_skill_slot", index)
	var hotbar: Array = _as_array(_state_get("hotbar_slots", []))
	if index >= 0 and index < hotbar.size():
		var uid: String = str(hotbar[index])
		if uid != "":
			state_ref.set("selected_gem_uid", uid)
	_render()


func _select_active_gem(uid: String) -> void:
	if state_ref == null or uid == "":
		return
	state_ref.set("selected_gem_uid", uid)
	state_ref.set("selected_uncut_uid", "")
	state_ref.set("selected_spirit_uid", "")
	_render()


func _select_uncut(uid: String) -> void:
	if state_ref == null:
		return
	state_ref.set("selected_uncut_uid", uid)
	state_ref.set("selected_support_uid", "")
	state_ref.set("selected_spirit_uid", "")
	_set_message("Selected " + _gem_label(_selected_uncut()) + ". Choose a carve target.")
	_render()


func _select_support(uid: String) -> void:
	if state_ref == null:
		return
	state_ref.set("selected_support_uid", uid)
	state_ref.set("selected_uncut_uid", "")
	_set_message("Selected support. Click an empty unlocked socket to socket it.")
	_render()


func _select_spirit(uid: String) -> void:
	if state_ref == null:
		return
	state_ref.set("selected_spirit_uid", uid)
	state_ref.set("selected_gem_uid", uid)
	state_ref.set("selected_uncut_uid", "")
	_render()


func _carve_target(uncut_uid: String, gem_id: String) -> void:
	if state_ref == null:
		return
	var result: Dictionary = SkillGemSystemScript.carve_uncut_gem(state_ref, uncut_uid, gem_id)
	_apply_result(result)
	_render()


func _socket_selected_support(target_uid: String, socket_index: int) -> void:
	if state_ref == null:
		return
	var support_uid: String = str(_state_get("selected_support_uid", ""))
	if support_uid == "":
		_set_message("Select a support gem first, then click an empty socket.")
		_render()
		return
	var result: Dictionary = SkillGemSystemScript.socket_support(state_ref, target_uid, support_uid, socket_index)
	_apply_result(result)
	_render()


func _unsocket(target_uid: String, socket_index: int) -> void:
	if state_ref == null:
		return
	var result: Dictionary = SkillGemSystemScript.unsocket_support(state_ref, target_uid, socket_index)
	_apply_result(result)
	_render()


func _bind_active_to_hotbar(active_uid: String, hotbar_index: int) -> void:
	if state_ref == null:
		return
	var result: Dictionary = SkillGemSystemScript.bind_gem_to_hotbar(state_ref, active_uid, hotbar_index)
	_apply_result(result)
	_render()


func _toggle_selected_spirit(spirit_uid: String) -> void:
	if state_ref == null:
		return
	var result: Dictionary = SkillGemSystemScript.toggle_spirit_gem(state_ref, spirit_uid)
	_apply_result(result)
	_render()


func _create_test_uncuts() -> void:
	if state_ref == null:
		return
	var inventory: Array = _as_array(_state_get("gem_inventory", []))
	inventory.append(_make_uncut_item("uncut_active_gem", 1))
	inventory.append(_make_uncut_item("uncut_support_gem", 1))
	inventory.append(_make_uncut_item("uncut_spirit_gem", 1))
	state_ref.set("gem_inventory", inventory)
	_set_message("Created test Uncut Skill, Support, and Spirit gems.")
	_render()


func _apply_result(result: Dictionary) -> void:
	var message: String = str(result.get("message", ""))
	if message == "":
		message = "Gem action completed." if bool(result.get("ok", false)) else "Gem action failed."
	_set_message(message)
	if state_ref != null and state_ref.has_method("recompute_stats"):
		state_ref.call("recompute_stats")


func _selected_active_or_hotbar() -> Dictionary:
	var uid: String = str(_state_get("selected_gem_uid", ""))
	var active: Dictionary = _find_active(uid)
	if not active.is_empty():
		return active
	var hotbar_index: int = clampi(_to_int(_state_get("selected_hotbar_slot", _state_get("selected_skill_slot", 0))), 0, 4)
	var hotbar: Array = _as_array(_state_get("hotbar_slots", []))
	if hotbar_index >= 0 and hotbar_index < hotbar.size():
		return _find_active(str(hotbar[hotbar_index]))
	return {}


func _selected_socket_owner() -> Dictionary:
	var spirit: Dictionary = _selected_spirit()
	if not spirit.is_empty():
		return spirit
	return _selected_active_or_hotbar()


func _selected_uncut() -> Dictionary:
	return _find_gem_inventory(str(_state_get("selected_uncut_uid", "")))


func _selected_support() -> Dictionary:
	return _find_support(str(_state_get("selected_support_uid", "")), false)


func _selected_spirit() -> Dictionary:
	var uid: String = str(_state_get("selected_spirit_uid", ""))
	var spirits: Array = SkillGemSystemScript.spirit_gem_instances(state_ref)
	for value: Variant in spirits:
		if typeof(value) == TYPE_DICTIONARY:
			var spirit: Dictionary = Dictionary(value)
			if str(spirit.get("uid", "")) == uid:
				return spirit
	return {}


func _find_active(uid: String) -> Dictionary:
	if state_ref == null or uid == "":
		return {}
	var active_gems: Array = SkillGemSystemScript.active_gem_instances(state_ref)
	for value: Variant in active_gems:
		if typeof(value) == TYPE_DICTIONARY:
			var gem: Dictionary = Dictionary(value)
			if str(gem.get("uid", "")) == uid:
				return gem
	return {}


func _find_support(uid: String, available_only: bool) -> Dictionary:
	if state_ref == null or uid == "":
		return {}
	var supports: Array = SkillGemSystemScript.support_gem_instances(state_ref, available_only)
	for value: Variant in supports:
		if typeof(value) == TYPE_DICTIONARY:
			var gem: Dictionary = Dictionary(value)
			if str(gem.get("uid", "")) == uid:
				return gem
	return {}


func _find_gem_inventory(uid: String) -> Dictionary:
	if state_ref == null or uid == "":
		return {}
	var inventory: Array = _as_array(_state_get("gem_inventory", []))
	for value: Variant in inventory:
		if typeof(value) == TYPE_DICTIONARY:
			var gem: Dictionary = Dictionary(value)
			if str(gem.get("uid", "")) == uid:
				return gem
	return {}


func _import_backpack_gems_to_gem_inventory() -> void:
	if state_ref == null:
		return
	var backpack_value: Variant = state_ref.get("backpack")
	if typeof(backpack_value) != TYPE_ARRAY:
		return
	var backpack: Array = Array(backpack_value)
	if backpack.is_empty():
		return
	var gem_inventory: Array = _as_array(_state_get("gem_inventory", []))
	var known: Dictionary = {}
	for value: Variant in gem_inventory:
		if typeof(value) == TYPE_DICTIONARY:
			known[str(Dictionary(value).get("uid", ""))] = true
	var moved: int = 0
	for i: int in range(backpack.size() - 1, -1, -1):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i]).duplicate(true)
		if not _looks_like_gem_item(item):
			continue
		_normalize_imported_gem(item)
		var uid: String = _ensure_gem_uid(item)
		if not known.has(uid):
			gem_inventory.append(item)
			known[uid] = true
		backpack.remove_at(i)
		moved += 1
	if moved > 0:
		state_ref.set("backpack", backpack)
		state_ref.set("gem_inventory", gem_inventory)
		_set_message("Moved " + str(moved) + " gem item(s) from backpack to Gem Bench inventory.")


func _normalize_gem_inventory() -> void:
	if state_ref == null:
		return
	var inventory: Array = _as_array(_state_get("gem_inventory", []))
	var changed: bool = false
	for i: int in range(inventory.size()):
		if typeof(inventory[i]) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(inventory[i]).duplicate(true)
		var before: String = JSON.stringify(gem)
		_normalize_imported_gem(gem)
		_ensure_gem_uid(gem)
		if JSON.stringify(gem) != before:
			inventory[i] = gem
			changed = true
	if changed:
		state_ref.set("gem_inventory", inventory)


func _ensure_testable_gems_if_empty() -> void:
	if state_ref == null:
		return
	var inventory: Array = _as_array(_state_get("gem_inventory", []))
	var has_uncut_active: bool = false
	var has_uncut_support: bool = false
	var has_uncut_spirit: bool = false
	var has_support: bool = false
	for value: Variant in inventory:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(value)
		var kind: String = str(gem.get("kind", gem.get("item_kind", "")))
		if kind == "uncut_active_gem" or kind == "uncut_skill_gem":
			has_uncut_active = true
		elif kind == "uncut_support_gem":
			has_uncut_support = true
		elif kind == "uncut_spirit_gem":
			has_uncut_spirit = true
		elif kind == "support_gem" and str(gem.get("equipped_to", "")) == "":
			has_support = true
	var added: int = 0
	if not has_uncut_active:
		inventory.append(_make_uncut_item("uncut_active_gem", 3))
		added += 1
	if not has_uncut_support:
		inventory.append(_make_uncut_item("uncut_support_gem", 3))
		added += 1
	if not has_uncut_spirit:
		inventory.append(_make_uncut_item("uncut_spirit_gem", 2))
		added += 1
	if not has_support:
		inventory.append({"uid": "support_ui_split_" + str(Time.get_ticks_msec()), "kind": "support_gem", "gem_id": "split_projectile", "level": 1, "quality": 0, "equipped_to": "", "socket_index": -1})
		inventory.append({"uid": "support_ui_ignite_" + str(Time.get_ticks_msec()), "kind": "support_gem", "gem_id": "ignition", "level": 1, "quality": 0, "equipped_to": "", "socket_index": -1})
		added += 2
	if added > 0:
		state_ref.set("gem_inventory", inventory)
		_set_message("Seeded missing Gem Bench test items.")


func _normalize_imported_gem(gem: Dictionary) -> void:
	var kind: String = str(gem.get("kind", gem.get("item_kind", "")))
	match kind:
		"uncut_skill_gem", "uncut_active_gem", "skill_uncut":
			gem["kind"] = "uncut_active_gem"
			gem["item_kind"] = "uncut_active_gem"
			gem["can_create"] = "active"
		"uncut_support_gem", "support_uncut":
			gem["kind"] = "uncut_support_gem"
			gem["item_kind"] = "uncut_support_gem"
			gem["can_create"] = "support"
		"uncut_spirit_gem", "spirit_uncut":
			gem["kind"] = "uncut_spirit_gem"
			gem["item_kind"] = "uncut_spirit_gem"
			gem["can_create"] = "spirit"
	if not gem.has("gem_level"):
		gem["gem_level"] = _to_int(gem.get("level", 1), 1)
	if not gem.has("level"):
		gem["level"] = _to_int(gem.get("gem_level", 1), 1)
	gem["category"] = "gem"
	gem["identified"] = true
	gem["grid_w"] = _to_int(gem.get("grid_w", 1), 1)
	gem["grid_h"] = _to_int(gem.get("grid_h", 1), 1)
	if not gem.has("display_name"):
		gem["display_name"] = _gem_label(gem)


func _looks_like_gem_item(item: Dictionary) -> bool:
	var kind: String = str(item.get("kind", item.get("item_kind", "")))
	if kind.find("gem") >= 0:
		return true
	if str(item.get("category", "")) == "gem":
		return true
	return false


func _make_uncut_item(kind: String, level: int) -> Dictionary:
	var uid: String = kind + "_ui_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000)
	var display: String = "Uncut Skill Gem"
	if kind == "uncut_support_gem":
		display = "Uncut Support Gem"
	elif kind == "uncut_spirit_gem":
		display = "Uncut Spirit Gem"
	return {
		"uid": uid,
		"id": uid,
		"kind": kind,
		"item_kind": kind,
		"category": "gem",
		"gem_level": maxi(1, level),
		"level": maxi(1, level),
		"display_name": display + " Lv. " + str(maxi(1, level)),
		"name": display + " Lv. " + str(maxi(1, level)),
		"identified": true,
		"grid_w": 1,
		"grid_h": 1,
	}


func _ensure_gem_uid(gem: Dictionary) -> String:
	var uid: String = str(gem.get("uid", gem.get("id", "")))
	if uid == "":
		uid = str(gem.get("kind", "gem")) + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000)
		gem["uid"] = uid
		gem["id"] = uid
	return uid


func _gem_label(gem: Dictionary) -> String:
	var name_value: String = str(gem.get("display_name", gem.get("name", gem.get("label", ""))))
	if name_value != "":
		return name_value
	var kind: String = str(gem.get("kind", "gem"))
	var level: int = _to_int(gem.get("gem_level", gem.get("level", 1)), 1)
	match kind:
		"uncut_active_gem":
			return "Uncut Skill Gem Lv. " + str(level)
		"uncut_support_gem":
			return "Uncut Support Gem Lv. " + str(level)
		"uncut_spirit_gem":
			return "Uncut Spirit Gem Lv. " + str(level)
		_:
			return kind.replace("_", " ").capitalize()


func _socket_used_count(gem: Dictionary) -> int:
	var count: int = 0
	for value: Variant in _as_array(gem.get("support_sockets", [])):
		if str(value) != "":
			count += 1
	return count


func _socket_required_level(index: int) -> int:
	if index < 2:
		return 1
	return (index - 1) * 5


func _set_message(message: String) -> void:
	if state_ref == null:
		return
	state_ref.set("gem_last_message", message)
	if state_ref.has_method("add_notice"):
		state_ref.call("add_notice", message)


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
		_:
			return fallback


func _button(text_value: String, action: Callable, selected: bool = false, height: int = 46) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, height)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", TEXT if selected else MUTED)
	button.add_theme_stylebox_override("normal", _style(BG_SEL if selected else BG_2, GOLD if selected else BORDER, 2 if selected else 1))
	button.add_theme_stylebox_override("hover", _style(Color(0.18, 0.12, 0.05, 1.0), GOLD, 2))
	button.gui_input.connect(_on_button_gui_input.bind(action))
	return button


func _small_button(text_value: String, action: Callable) -> Button:
	var button: Button = _button(text_value, action, false, 36)
	button.add_theme_font_size_override("font_size", 12)
	return button


func _on_button_gui_input(event: InputEvent, action: Callable) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and (mouse_event.button_index == MOUSE_BUTTON_LEFT or mouse_event.button_index == MOUSE_BUTTON_RIGHT):
			action.call()
			get_viewport().set_input_as_handled()


func _section(text_value: String) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", GOLD)
	return label


func _muted(text_value: String) -> RichTextLabel:
	return _rich("[color=#8f8777]" + text_value + "[/color]", 13)


func _rich(text_value: String, size: int = 13) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = text_value
	label.fit_content = true
	label.scroll_active = false
	label.add_theme_font_size_override("normal_font_size", size)
	label.add_theme_color_override("default_color", TEXT)
	return label


func _panel(fill: Color, border: Color, width: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(fill, border, width))
	return panel


func _style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(6)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _margin(left: int, top: int, right: int, bottom: int) -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_bottom", bottom)
	return margin


func _clear_children(node: Node) -> void:
	for child: Node in node.get_children():
		child.queue_free()
