extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const MouseUIScript: GDScript = preload("res://scripts/systems/UIMouseInteractionSystem3D.gd")

var _equipment_slots: Array[String] = ["weapon", "offhand", "helm", "chest", "gloves", "boots", "amulet", "ring_1", "ring_2", "belt", "relic"]

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(10)
	_set_expand(root, true, true)
	add_child(root)

	var equipment_panel: PanelContainer = _panel("EQUIPMENT")
	_set_expand(equipment_panel, true, true)
	root.add_child(equipment_panel)
	_build_equipment(_panel_content(equipment_panel))

	var backpack_panel: PanelContainer = _panel("BACKPACK · CLICK ITEM TO SELECT")
	_set_expand(backpack_panel, true, true)
	root.add_child(backpack_panel)
	_build_backpack(_panel_content(backpack_panel))

	var detail_panel: PanelContainer = _panel("SELECTED ITEM")
	_set_expand(detail_panel, true, true)
	root.add_child(detail_panel)
	_build_selected_detail(_panel_content(detail_panel))

	var compare_panel: PanelContainer = _panel("COMPARE / ACTIONS")
	_set_expand(compare_panel, true, true)
	root.add_child(compare_panel)
	_build_compare_actions(_panel_content(compare_panel))

func _build_equipment(box: VBoxContainer) -> void:
	var equipped: Dictionary = _as_dict(_state_get("equipped", {}))
	for slot_name: String in _equipment_slots:
		var item: Dictionary = {}
		if equipped.has(slot_name) and typeof(equipped[slot_name]) == TYPE_DICTIONARY:
			item = Dictionary(equipped[slot_name])
		var label_text: String = slot_name.replace("_", " ").capitalize()
		if item.is_empty():
			box.add_child(_button(label_text + "\n— empty —", self, "_click_equipped_slot", [slot_name], Vector2(150, 48)))
		else:
			box.add_child(_button(label_text + "\n" + _short(_item_name(item), 20), self, "_click_equipped_slot", [slot_name], Vector2(150, 54)))

func _build_backpack(box: VBoxContainer) -> void:
	var backpack: Array = _as_array(_state_get("backpack", []))
	var cursor: int = _selected_backpack_index()
	var grid: GridContainer = _grid(4, 5)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(grid)
	if backpack.is_empty():
		grid.add_child(_label("[color=#8f8777]Backpack empty. Run a map and pick up loot.[/color]"))
		return
	for i: int in range(backpack.size()):
		var item: Dictionary = {}
		if typeof(backpack[i]) == TYPE_DICTIONARY:
			item = Dictionary(backpack[i])
		var selected: bool = i == cursor
		var prefix: String = "▶ " if selected else ""
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
		var button_text: String = prefix + str(i + 1) + ". " + _short(_rarity_prefix(item) + _item_name(item), 24) + "\n" + _item_slot(item) + " · " + size_text + flags
		var b: Button = _button(button_text, self, "_select_backpack", [i], Vector2(178, 58))
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
	box.add_child(_label(_compare_text(item)))
	box.add_child(_button("Equip Selected", self, "_equip_selected", [], Vector2(180, 38)))
	box.add_child(_button("Appraise", self, "_appraise_selected", [], Vector2(180, 34)))
	box.add_child(_button("Toggle Favorite", self, "_favorite_selected", [], Vector2(180, 34)))
	box.add_child(_button("Toggle Lock", self, "_lock_selected", [], Vector2(180, 34)))
	box.add_child(_button("Send to Stash", self, "_stash_selected", [], Vector2(180, 34)))
	box.add_child(_button("Open Forge", self, "_open_forge", [], Vector2(180, 34)))
	box.add_child(_button("Drop Item", self, "_drop_selected", [], Vector2(180, 34)))
	box.add_child(_label("[color=#8f8777]Mouse rule: every visible item row and action button is clickable. Keyboard shortcuts still work, but are no longer required.[/color]", 12))

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
