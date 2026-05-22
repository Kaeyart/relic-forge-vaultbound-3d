extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const MouseUIScript: GDScript = preload("res://scripts/systems/UIMouseInteractionSystem3D.gd")

var _equipment_slots: Array[String] = ["weapon", "offhand", "helm", "chest", "gloves", "boots", "amulet", "ring_1", "ring_2", "belt", "relic"]

func refresh_panel() -> void:
	_clear()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS

	var root: MarginContainer = MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 6)
	root.add_theme_constant_override("margin_right", 6)
	root.add_theme_constant_override("margin_top", 6)
	root.add_theme_constant_override("margin_bottom", 6)
	add_child(root)

	var row: HBoxContainer = _hbox(8)
	_set_expand(row, true, true)
	root.add_child(row)

	var equipment_panel: PanelContainer = _panel("EQUIPMENT")
	equipment_panel.custom_minimum_size = Vector2(185, 0)
	equipment_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(equipment_panel)
	var eq_scroll: ScrollContainer = ScrollContainer.new()
	eq_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_panel_content(equipment_panel).add_child(eq_scroll)
	var eq_box: VBoxContainer = _vbox(4)
	eq_scroll.add_child(eq_box)
	_build_equipment(eq_box)

	var backpack_panel: PanelContainer = _panel("BACKPACK")
	backpack_panel.custom_minimum_size = Vector2(430, 0)
	backpack_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	backpack_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(backpack_panel)
	var bp_scroll: ScrollContainer = ScrollContainer.new()
	bp_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bp_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel_content(backpack_panel).add_child(bp_scroll)
	var bp_box: VBoxContainer = _vbox(6)
	bp_scroll.add_child(bp_box)
	_build_backpack(bp_box)

	var right_panel: PanelContainer = _panel("ITEM / ACTIONS")
	right_panel.custom_minimum_size = Vector2(360, 0)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(right_panel)
	var right_scroll: ScrollContainer = ScrollContainer.new()
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel_content(right_panel).add_child(right_scroll)
	var right_box: VBoxContainer = _vbox(6)
	right_scroll.add_child(right_box)
	_build_selected_detail(right_box)
	right_box.add_child(_label("\n[color=#c59b4a][b]COMPARE / ACTIONS[/b][/color]", 14))
	_build_compare_actions(right_box)

func _build_equipment(box: VBoxContainer) -> void:
	var equipped: Dictionary = _as_dict(_state_get("equipped", {}))
	for slot_name: String in _equipment_slots:
		var item: Dictionary = {}
		if equipped.has(slot_name) and typeof(equipped[slot_name]) == TYPE_DICTIONARY:
			item = Dictionary(equipped[slot_name])
		var label_text: String = slot_name.replace("_", " ").capitalize()
		var text: String = label_text + "\n" + ("— empty —" if item.is_empty() else _short(_item_name(item), 18))
		box.add_child(_button(text, self, "_click_equipped_slot", [slot_name], Vector2(160, 42)))

func _build_backpack(box: VBoxContainer) -> void:
	var backpack: Array = _as_array(_state_get("backpack", []))
	var cursor: int = _selected_backpack_index()
	if backpack.is_empty():
		box.add_child(_label("[color=#8f8777]Backpack empty. Run maps, pick up loot, or use the Gem Bench for gem items.[/color]"))
		return
	var grid: GridContainer = _grid(3, 5)
	box.add_child(grid)
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i])
		var selected: bool = i == cursor
		var flags: String = ""
		if bool(item.get("new_item", false)):
			flags += " N"
		if bool(item.get("favorite", false)):
			flags += " ★"
		if bool(item.get("locked", false)):
			flags += " 🔒"
		if not bool(item.get("identified", true)):
			flags += " ?"
		var size_text: String = str(_to_int(item.get("grid_w", 1))) + "x" + str(_to_int(item.get("grid_h", 1)))
		var button_text: String = ("▶ " if selected else "") + str(i + 1) + ". " + _short(_rarity_prefix(item) + _item_name(item), 20) + "\n" + _short(_item_slot(item), 12) + " · " + size_text + flags
		var b: Button = _button(button_text, self, "_select_backpack", [i], Vector2(135, 54))
		if selected:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		grid.add_child(b)

func _build_selected_detail(box: VBoxContainer) -> void:
	var item: Dictionary = _selected_backpack_item()
	box.add_child(_label(_item_summary(item), 13))

func _build_compare_actions(box: VBoxContainer) -> void:
	var item: Dictionary = _selected_backpack_item()
	if item.is_empty():
		box.add_child(_label("Select an item with the mouse."))
		return
	box.add_child(_label(_compare_text(item), 12))
	var actions: GridContainer = _grid(2, 5)
	box.add_child(actions)
	actions.add_child(_button("Equip", self, "_equip_selected", [], Vector2(160, 34)))
	actions.add_child(_button("Appraise", self, "_appraise_selected", [], Vector2(160, 34)))
	actions.add_child(_button("Favorite", self, "_favorite_selected", [], Vector2(160, 34)))
	actions.add_child(_button("Lock", self, "_lock_selected", [], Vector2(160, 34)))
	actions.add_child(_button("Send Stash", self, "_stash_selected", [], Vector2(160, 34)))
	actions.add_child(_button("Open Forge", self, "_open_forge", [], Vector2(160, 34)))
	actions.add_child(_button("Drop", self, "_drop_selected", [], Vector2(160, 34)))

func _compare_text(item: Dictionary) -> String:
	var equipped: Dictionary = _as_dict(_state_get("equipped", {}))
	var slot_name: String = _item_slot(item)
	var current: Dictionary = {}
	if equipped.has(slot_name) and typeof(equipped[slot_name]) == TYPE_DICTIONARY:
		current = Dictionary(equipped[slot_name])
	elif slot_name == "ring" and equipped.has("ring_1") and typeof(equipped["ring_1"]) == TYPE_DICTIONARY:
		current = Dictionary(equipped["ring_1"])
	if current.is_empty():
		return "[color=#8f8777]No equipped item in matching slot.[/color]"
	var delta_power: int = _item_power(item) - _item_power(current)
	var sign: String = "+" if delta_power >= 0 else ""
	return "Equipped: " + _item_name(current) + "\nPower Delta: " + sign + str(delta_power) + "\nForge Potential: " + str(_to_int(current.get("forge_potential", 0))) + " → " + str(_to_int(item.get("forge_potential", 0)))

func _click_equipped_slot(slot_name: String) -> void:
	_state_set("selected_equipment_slot", slot_name)
	_notice("Selected equipment slot: " + slot_name.replace("_", " ").capitalize())
	refresh_panel()

func _select_backpack(index: int) -> void:
	_set_selected_backpack_index(index)
	MouseUIScript.mutate_selected_item(state_ref, "new_item", false)
	refresh_panel()

func _equip_selected() -> void:
	if state_ref != null and state_ref.has_method("equip_backpack_index"):
		state_ref.call("equip_backpack_index", _selected_backpack_index())
	else:
		_notice("Equip action unavailable on state.")
	refresh_panel()

func _appraise_selected() -> void:
	MouseUIScript.appraise_selected(state_ref)
	refresh_panel()

func _favorite_selected() -> void:
	MouseUIScript.toggle_selected_flag(state_ref, "favorite")
	refresh_panel()

func _lock_selected() -> void:
	MouseUIScript.toggle_selected_flag(state_ref, "locked")
	refresh_panel()

func _stash_selected() -> void:
	MouseUIScript.store_selected_to_stash(state_ref)
	refresh_panel()

func _open_forge() -> void:
	_open_panel("crafting")

func _drop_selected() -> void:
	MouseUIScript.drop_selected(state_ref)
	refresh_panel()
