extends Control

const StashSystemScript := preload("res://scripts/systems/StashSystem3D.gd")
const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")

const ITEM_CARD_MIN_SIZE: Vector2 = Vector2(148, 76)

var state_ref: Object = null
var _root: PanelContainer = null
var _category_list: VBoxContainer = null
var _tab_row: HBoxContainer = null
var _content_grid: GridContainer = null
var _detail: RichTextLabel = null
var _search_box: LineEdit = null
var _global_search_check: CheckBox = null
var _summary_label: RichTextLabel = null
var _context_menu: PopupMenu = null
var _customize_popup: PopupPanel = null
var _customize_name: LineEdit = null
var _customize_color: LineEdit = null
var _customize_icon: LineEdit = null
var _customize_affinity: OptionButton = null
var _customize_rarity: OptionButton = null
var _customize_slot: LineEdit = null
var _customize_kind: LineEdit = null

var _last_signature: String = ""
var _selected_view_items: Array = []


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
	_context_menu.name = "StashContextMenu094C"
	_context_menu.id_pressed.connect(_on_context_action)
	add_child(_context_menu)

	_customize_popup = PopupPanel.new()
	_customize_popup.name = "StashCustomizePopup094C"
	add_child(_customize_popup)
	_build_customize_popup()

	_root = PanelContainer.new()
	_root.name = "StashRoot094C"
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
	title.text = "Stash"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var quick_button: Button = _button("Quick Deposit All", Vector2(150, 34))
	quick_button.pressed.connect(_quick_deposit_all)
	header.add_child(quick_button)

	var buy_button: Button = _button("Buy Item Tab", Vector2(124, 34))
	buy_button.pressed.connect(_buy_item_tab)
	header.add_child(buy_button)

	var close_button: Button = _button("Close", Vector2(86, 34))
	close_button.pressed.connect(_close_panel)
	header.add_child(close_button)

	var hint: RichTextLabel = RichTextLabel.new()
	hint.bbcode_enabled = true
	hint.fit_content = true
	hint.scroll_active = false
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.custom_minimum_size = Vector2(0, 42)
	hint.text = "[b]Stash[/b] · Categories left, tabs top, stash contents center, item details right. Quick Deposit All routes physical items into the correct tabs."
	main.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(body)

	var category_panel: PanelContainer = PanelContainer.new()
	category_panel.custom_minimum_size = Vector2(180, 0)
	category_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(category_panel)

	var category_margin: MarginContainer = MarginContainer.new()
	category_margin.add_theme_constant_override("margin_left", 8)
	category_margin.add_theme_constant_override("margin_top", 8)
	category_margin.add_theme_constant_override("margin_right", 8)
	category_margin.add_theme_constant_override("margin_bottom", 8)
	category_panel.add_child(category_margin)

	var category_box: VBoxContainer = VBoxContainer.new()
	category_box.add_theme_constant_override("separation", 6)
	category_margin.add_child(category_box)

	var category_title: Label = Label.new()
	category_title.text = "Categories"
	category_title.add_theme_font_size_override("font_size", 18)
	category_box.add_child(category_title)

	var category_scroll: ScrollContainer = ScrollContainer.new()
	category_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	category_box.add_child(category_scroll)

	_category_list = VBoxContainer.new()
	_category_list.add_theme_constant_override("separation", 5)
	category_scroll.add_child(_category_list)

	var new_category_button: Button = _button("New Category", Vector2(0, 32))
	new_category_button.pressed.connect(_create_category)
	category_box.add_child(new_category_button)

	var center_panel: PanelContainer = PanelContainer.new()
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center_panel)

	var center_margin: MarginContainer = MarginContainer.new()
	center_margin.add_theme_constant_override("margin_left", 10)
	center_margin.add_theme_constant_override("margin_top", 10)
	center_margin.add_theme_constant_override("margin_right", 10)
	center_margin.add_theme_constant_override("margin_bottom", 10)
	center_panel.add_child(center_margin)

	var center_box: VBoxContainer = VBoxContainer.new()
	center_box.add_theme_constant_override("separation", 8)
	center_margin.add_child(center_box)

	var tab_scroll: ScrollContainer = ScrollContainer.new()
	tab_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	tab_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tab_scroll.custom_minimum_size = Vector2(0, 48)
	center_box.add_child(tab_scroll)

	_tab_row = HBoxContainer.new()
	_tab_row.add_theme_constant_override("separation", 6)
	tab_scroll.add_child(_tab_row)

	var search_row: HBoxContainer = HBoxContainer.new()
	search_row.add_theme_constant_override("separation", 8)
	center_box.add_child(search_row)

	_search_box = LineEdit.new()
	_search_box.placeholder_text = "Search current tab..."
	_search_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_box.text_submitted.connect(_on_search_submitted)
	_search_box.text_changed.connect(_on_search_changed)
	search_row.add_child(_search_box)

	_global_search_check = CheckBox.new()
	_global_search_check.text = "Global"
	_global_search_check.toggled.connect(_on_global_search_toggled)
	search_row.add_child(_global_search_check)

	var customize_button: Button = _button("Customize Tab", Vector2(128, 32))
	customize_button.pressed.connect(_open_customize_popup)
	search_row.add_child(customize_button)

	var content_scroll: ScrollContainer = ScrollContainer.new()
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_box.add_child(content_scroll)

	_content_grid = GridContainer.new()
	_content_grid.columns = 4
	_content_grid.add_theme_constant_override("h_separation", 8)
	_content_grid.add_theme_constant_override("v_separation", 8)
	content_scroll.add_child(_content_grid)

	var detail_panel: PanelContainer = PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(360, 0)
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(detail_panel)

	var detail_margin: MarginContainer = MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 10)
	detail_margin.add_theme_constant_override("margin_top", 10)
	detail_margin.add_theme_constant_override("margin_right", 10)
	detail_margin.add_theme_constant_override("margin_bottom", 10)
	detail_panel.add_child(detail_margin)

	var detail_box: VBoxContainer = VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 8)
	detail_margin.add_child(detail_box)

	_summary_label = RichTextLabel.new()
	_summary_label.bbcode_enabled = true
	_summary_label.fit_content = true
	_summary_label.scroll_active = false
	_summary_label.custom_minimum_size = Vector2(0, 86)
	detail_box.add_child(_summary_label)

	_detail = RichTextLabel.new()
	_detail.name = "StashItemCard094C"
	_detail.bbcode_enabled = true
	_detail.scroll_active = true
	_detail.fit_content = false
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail.text = "[i]Select an item.[/i]"
	detail_box.add_child(_detail)

	var action_row: HBoxContainer = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	main.add_child(action_row)

	var withdraw_button: Button = _button("Withdraw", Vector2(112, 34))
	withdraw_button.pressed.connect(_withdraw_selected)
	action_row.add_child(withdraw_button)

	var quick_bottom: Button = _button("Quick Deposit All", Vector2(150, 34))
	quick_bottom.pressed.connect(_quick_deposit_all)
	action_row.add_child(quick_bottom)

	var sort_button: Button = _button("Refresh / Sort", Vector2(128, 34))
	sort_button.pressed.connect(_force_rebuild)
	action_row.add_child(sort_button)

	var close_bottom: Button = _button("Close", Vector2(86, 34))
	close_bottom.pressed.connect(_close_panel)
	action_row.add_child(close_bottom)


func _build_customize_popup() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_customize_popup.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var title: Label = Label.new()
	title.text = "Customize Stash Tab"
	title.add_theme_font_size_override("font_size", 20)
	box.add_child(title)

	_customize_name = LineEdit.new()
	_customize_name.placeholder_text = "Tab name"
	box.add_child(_customize_name)

	_customize_color = LineEdit.new()
	_customize_color.placeholder_text = "#cfcfcf"
	box.add_child(_customize_color)

	_customize_icon = LineEdit.new()
	_customize_icon.placeholder_text = "icon name"
	box.add_child(_customize_icon)

	_customize_affinity = OptionButton.new()
	_customize_affinity.add_item("None", 0)
	_customize_affinity.add_item("Custom Items", 1)
	box.add_child(_customize_affinity)

	_customize_rarity = OptionButton.new()
	_customize_rarity.add_item("Any Rarity", 0)
	_customize_rarity.add_item("Normal", 1)
	_customize_rarity.add_item("Magic", 2)
	_customize_rarity.add_item("Rare", 3)
	_customize_rarity.add_item("Unique", 4)
	box.add_child(_customize_rarity)

	_customize_slot = LineEdit.new()
	_customize_slot.placeholder_text = "Slot rule, e.g. gloves, weapon, ring1"
	box.add_child(_customize_slot)

	_customize_kind = LineEdit.new()
	_customize_kind.placeholder_text = "Kind rule, e.g. equipment, map, gem"
	box.add_child(_customize_kind)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)

	var apply: Button = _button("Apply", Vector2(100, 34))
	apply.pressed.connect(_apply_customize_popup)
	row.add_child(apply)

	var cancel: Button = _button("Cancel", Vector2(100, 34))
	cancel.pressed.connect(func() -> void: _customize_popup.hide())
	row.add_child(cancel)


func _refresh(force: bool) -> void:
	if state_ref == null:
		return

	_ensure_ui()
	StashSystemScript.ensure_defaults(state_ref)

	var sig: String = _signature()
	if not force and sig == _last_signature:
		return
	_last_signature = sig

	_sync_search_controls()
	_refresh_categories()
	_refresh_tabs()
	_refresh_content()
	_refresh_detail()


func _signature() -> String:
	return JSON.stringify([
		_state_get("stash_categories", []),
		_state_get("stash_tabs", []),
		_state_get("selected_stash_category_id", ""),
		_state_get("selected_stash_tab_id", ""),
		_state_get("stash_selected_item_index", -1),
		_state_get("stash_search_query", ""),
		_state_get("stash_search_all", false),
		_state_get("backpack", []),
		_state_get("gold", 0),
		_state_get("map_completion", {}),
	])


func _sync_search_controls() -> void:
	if _search_box != null:
		var query: String = str(_state_get("stash_search_query", ""))
		if _search_box.text != query:
			_search_box.text = query

	if _global_search_check != null:
		var global_value: bool = bool(_state_get("stash_search_all", false))
		if _global_search_check.button_pressed != global_value:
			_global_search_check.button_pressed = global_value


func _refresh_categories() -> void:
	_clear_children(_category_list)

	var categories: Array = Array(_state_get("stash_categories", []))
	var selected_id: String = str(_state_get("selected_stash_category_id", ""))

	for value: Variant in categories:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var category: Dictionary = Dictionary(value)
		var id: String = str(category.get("id", ""))
		var name: String = str(category.get("name", id))
		var button: Button = _button(name, Vector2(0, 36))
		if id == selected_id:
			button.text = "▶ " + button.text
		button.pressed.connect(_select_category.bind(id))
		_category_list.add_child(button)


func _refresh_tabs() -> void:
	_clear_children(_tab_row)

	var selected_category: String = str(_state_get("selected_stash_category_id", "cat_general"))
	var selected_tab: String = str(_state_get("selected_stash_tab_id", ""))
	var tabs: Array = StashSystemScript.tabs_in_category(state_ref, selected_category)

	for value: Variant in tabs:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var tab: Dictionary = Dictionary(value)
		var id: String = str(tab.get("id", ""))
		var name: String = str(tab.get("name", id))
		var count: int = Array(tab.get("items", [])).size()
		var button: Button = _button(name + " (" + str(count) + ")", Vector2(128, 36))
		button.clip_text = true
		if id == selected_tab:
			button.text = "▶ " + button.text
		button.modulate = _color_from_hex(str(tab.get("color", "#cfcfcf")))
		button.pressed.connect(_select_tab.bind(id))
		button.gui_input.connect(_on_tab_gui_input.bind(id))
		_tab_row.add_child(button)


func _refresh_content() -> void:
	_clear_children(_content_grid)
	_selected_view_items = []

	var tab: Dictionary = _selected_tab()
	if tab.is_empty():
		_add_empty_content("No stash tab selected.")
		return

	var affinity: String = str(tab.get("affinity", "none"))
	var query: String = str(_state_get("stash_search_query", "")).strip_edges()
	var global_search: bool = bool(_state_get("stash_search_all", false))

	if global_search and query != "":
		_content_grid.columns = 4
		_add_section_label("Global Search Results")
		_add_items(StashSystemScript.visible_items_for_current_view(state_ref), "item")
		return

	match affinity:
		"currency":
			_content_grid.columns = 2
			_add_section_label("Currency")
			_add_items(StashSystemScript.visible_items_for_current_view(state_ref), "currency")
		"maps":
			_content_grid.columns = 3
			_add_section_label("Maps by Tier")
			_add_items(StashSystemScript.visible_items_for_current_view(state_ref), "map")
		"gems":
			_content_grid.columns = 3
			_add_gem_sections(StashSystemScript.visible_items_for_current_view(state_ref))
		"crystals":
			_content_grid.columns = 2
			_add_section_label("Crystals")
			_add_items(StashSystemScript.visible_items_for_current_view(state_ref), "crystal")
		"uniques":
			_content_grid.columns = 3
			_add_section_label("Unique Collection")
			_add_items(StashSystemScript.visible_items_for_current_view(state_ref), "unique")
		_:
			_content_grid.columns = 4
			_add_section_label("Items")
			_add_items(StashSystemScript.visible_items_for_current_view(state_ref), "item")


func _add_gem_sections(items: Array) -> void:
	var active: Array = []
	var support: Array = []
	var spirit: Array = []
	var other: Array = []

	for value: Variant in items:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(value)
		var gem_type: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower()
		match gem_type:
			"active":
				active.append(item)
			"support":
				support.append(item)
			"spirit":
				spirit.append(item)
			_:
				other.append(item)

	_add_section_label("Active Gems")
	_add_items(active, "gem")
	_add_section_label("Support Gems")
	_add_items(support, "gem")
	_add_section_label("Spirit Gems")
	_add_items(spirit, "gem")
	if not other.is_empty():
		_add_section_label("Other Gems")
		_add_items(other, "gem")


func _add_section_label(text_value: String) -> void:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", 17)
	label.custom_minimum_size = Vector2(0, 32)
	_content_grid.add_child(label)

	var filler_count: int = max(0, _content_grid.columns - 1)
	for i: int in range(filler_count):
		var spacer: Control = Control.new()
		spacer.custom_minimum_size = Vector2(1, 1)
		_content_grid.add_child(spacer)


func _add_empty_content(text_value: String) -> void:
	var label: Label = Label.new()
	label.text = text_value
	label.custom_minimum_size = Vector2(340, 40)
	_content_grid.add_child(label)


func _add_items(items: Array, view_type: String) -> void:
	if items.is_empty():
		_add_empty_content("No items.")
		return

	for value: Variant in items:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(value)
		var view_index: int = _selected_view_items.size()
		_selected_view_items.append(item)
		_add_item_button(view_index, item, view_type)


func _add_item_button(view_index: int, item: Dictionary, view_type: String) -> void:
	var button: Button = Button.new()
	button.custom_minimum_size = ITEM_CARD_MIN_SIZE
	button.clip_text = true
	button.text = _button_text_for_item(item, view_type)
	button.modulate = _item_color(item)

	var selected_index: int = _to_int(_state_get("stash_selected_item_index", -1), -1)
	var item_index: int = _to_int(item.get("_stash_item_index", -999), -999)
	if item_index == selected_index:
		button.text = "▶ " + button.text

	button.pressed.connect(_select_view_item.bind(view_index))
	button.gui_input.connect(_on_item_gui_input.bind(view_index))
	_content_grid.add_child(button)


func _button_text_for_item(item: Dictionary, view_type: String) -> String:
	var name: String = _short(str(item.get("display_name", item.get("name", "Item"))), 20)
	match view_type:
		"currency":
			return name + "\nx" + str(_to_int(item.get("stack", item.get("amount", 1)), 1))
		"map":
			var tier: int = _to_int(item.get("tier", item.get("map_tier", 1)), 1)
			var rarity: String = str(item.get("rarity", "normal")).capitalize()
			return "T" + str(tier) + " " + rarity + "\n" + name
		"gem":
			var gem_type: String = str(item.get("gem_type", item.get("skill_gem_type", "gem"))).capitalize()
			var level: int = _to_int(item.get("level", item.get("gem_level", 1)), 1)
			var quality: int = _to_int(item.get("quality", item.get("gem_quality", 0)), 0)
			return gem_type + "\n" + name + "\nLv " + str(level) + " Q+" + str(quality)
		"crystal":
			return "Crystal\n" + name + "\nx" + str(_to_int(item.get("stack", item.get("amount", 1)), 1))
		"unique":
			return "UNIQUE\n" + name + "\nQ+" + str(_to_int(item.get("quality", item.get("unique_quality", 0)), 0))
		_:
			var rarity: String = str(item.get("rarity", "normal")).capitalize()
			var slot: String = str(item.get("slot", item.get("kind", ""))).capitalize()
			return rarity + "\n" + name + "\n" + slot


func _refresh_detail() -> void:
	var tab: Dictionary = _selected_tab()

	if _summary_label != null:
		if tab.is_empty():
			_summary_label.text = "[b]No tab selected[/b]"
		else:
			_summary_label.text = "[b]" + str(tab.get("name", "Tab")) + "[/b]\n" + StashSystemScript.tab_summary_line(tab) + "\nItems: " + str(Array(tab.get("items", [])).size())

	if _detail == null:
		return

	var item: Dictionary = _selected_item()
	if item.is_empty():
		_detail.text = "[i]Select an item. Double-click or right-click to withdraw.[/i]"
	else:
		_detail.text = UIFoundationSystemScript.item_card_text(item, {})


func _select_view_item(view_index: int) -> void:
	if view_index < 0 or view_index >= _selected_view_items.size():
		return
	var item: Dictionary = Dictionary(_selected_view_items[view_index])
	var tab_id: String = str(item.get("_stash_tab_id", _state_get("selected_stash_tab_id", "")))
	var item_index: int = _to_int(item.get("_stash_item_index", -1), -1)

	if tab_id != "":
		state_ref.set("selected_stash_tab_id", tab_id)
	if item_index >= 0:
		state_ref.set("stash_selected_item_index", item_index)

	_last_signature = ""
	_refresh(true)


func _on_item_gui_input(event: InputEvent, view_index: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed:
			return
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_select_view_item(view_index)
			_show_item_context(mouse_event.global_position)
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.double_click:
			_select_view_item(view_index)
			_withdraw_selected()


func _show_item_context(global_pos: Vector2) -> void:
	_context_menu.clear()
	_context_menu.add_item("Withdraw", 1)
	_context_menu.add_item("Inspect", 2)
	_context_menu.position = Vector2i(int(global_pos.x), int(global_pos.y))
	_context_menu.popup()


func _on_context_action(id: int) -> void:
	match id:
		1:
			_withdraw_selected()
		2:
			_refresh_detail()


func _on_tab_gui_input(event: InputEvent, tab_id: String) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_select_tab(tab_id)
			_open_customize_popup()


func _selected_item() -> Dictionary:
	var tab: Dictionary = _selected_tab()
	if tab.is_empty():
		return {}
	var index: int = _to_int(_state_get("stash_selected_item_index", -1), -1)
	var items: Array = Array(tab.get("items", []))
	if index < 0 or index >= items.size() or typeof(items[index]) != TYPE_DICTIONARY:
		return {}
	return Dictionary(items[index])


func _selected_tab() -> Dictionary:
	if state_ref == null:
		return {}
	return StashSystemScript.find_tab(state_ref, str(_state_get("selected_stash_tab_id", "")))


func _select_category(category_id: String) -> void:
	StashSystemScript.select_category(state_ref, category_id)
	_last_signature = ""
	_refresh(true)


func _select_tab(tab_id: String) -> void:
	StashSystemScript.select_tab(state_ref, tab_id)
	_last_signature = ""
	_refresh(true)


func _create_category() -> void:
	var msg: String = StashSystemScript.create_category(state_ref)
	_notice(msg)
	_last_signature = ""
	_refresh(true)


func _buy_item_tab() -> void:
	var msg: String = StashSystemScript.buy_tab(state_ref)
	_notice(msg)
	_last_signature = ""
	_refresh(true)


func _quick_deposit_all() -> void:
	var msg: String = StashSystemScript.quick_deposit_inventory(state_ref)
	_notice(msg)
	_last_signature = ""
	_refresh(true)


func _withdraw_selected() -> void:
	var msg: String = StashSystemScript.withdraw_selected_stash_item(state_ref)
	_notice(msg)
	_last_signature = ""
	_refresh(true)


func _force_rebuild() -> void:
	_last_signature = ""
	_refresh(true)


func _open_customize_popup() -> void:
	var tab: Dictionary = _selected_tab()
	if tab.is_empty():
		_notice("No tab selected.")
		return

	_customize_name.text = str(tab.get("name", ""))
	_customize_color.text = str(tab.get("color", "#cfcfcf"))
	_customize_icon.text = str(tab.get("icon", "box"))

	var affinity: String = str(tab.get("affinity", "none"))
	_customize_affinity.select(1 if affinity == "custom_items" else 0)

	var rules: Dictionary = Dictionary(tab.get("custom_rules", {}))
	var rarity: String = str(rules.get("rarity", "")).to_lower()
	match rarity:
		"normal":
			_customize_rarity.select(1)
		"magic":
			_customize_rarity.select(2)
		"rare":
			_customize_rarity.select(3)
		"unique":
			_customize_rarity.select(4)
		_:
			_customize_rarity.select(0)

	_customize_slot.text = str(rules.get("slot", ""))
	_customize_kind.text = str(rules.get("kind", ""))

	_customize_popup.popup_centered(Vector2i(430, 430))


func _apply_customize_popup() -> void:
	var tab: Dictionary = _selected_tab()
	if tab.is_empty():
		return

	var affinity: String = "none"
	if _customize_affinity.selected == 1:
		affinity = "custom_items"

	var rarity: String = ""
	match _customize_rarity.selected:
		1:
			rarity = "normal"
		2:
			rarity = "magic"
		3:
			rarity = "rare"
		4:
			rarity = "unique"
		_:
			rarity = ""

	var rules: Dictionary = {
		"rarity": rarity,
		"slot": _customize_slot.text.strip_edges().to_lower(),
		"kind": _customize_kind.text.strip_edges().to_lower(),
		"min_tier": 0,
		"max_tier": 0,
	}

	var msg: String = StashSystemScript.customize_tab(
		state_ref,
		str(tab.get("id", "")),
		_customize_name.text,
		_customize_color.text,
		_customize_icon.text,
		affinity,
		rules
	)

	_customize_popup.hide()
	_notice(msg)
	_last_signature = ""
	_refresh(true)


func _on_search_changed(new_text: String) -> void:
	if state_ref == null:
		return
	state_ref.set("stash_search_query", new_text)
	_last_signature = ""
	_refresh(true)


func _on_search_submitted(new_text: String) -> void:
	_on_search_changed(new_text)


func _on_global_search_toggled(value: bool) -> void:
	if state_ref == null:
		return
	state_ref.set("stash_search_all", value)
	_last_signature = ""
	_refresh(true)


func _close_panel() -> void:
	if state_ref != null:
		state_ref.set("panel_mode", "")


func _button(text_value: String, min_size: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = min_size
	button.clip_text = true
	return button


func _item_color(item: Dictionary) -> Color:
	return UIFoundationSystemScript.rarity_color(str(item.get("rarity", "normal")))


func _color_from_hex(hex: String) -> Color:
	var c: Color = Color(0.8, 0.8, 0.8, 1.0)
	if hex.begins_with("#") and (hex.length() == 7 or hex.length() == 9):
		c = Color.html(hex)
	return c


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


func _short(value: String, limit: int) -> String:
	if value.length() <= limit:
		return value
	return value.substr(0, max(1, limit - 1)) + "…"


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
