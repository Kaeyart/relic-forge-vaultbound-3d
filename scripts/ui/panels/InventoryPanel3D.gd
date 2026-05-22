extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const I: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")
const C: GDScript = preload("res://scripts/systems/ItemCraftingSystem3D.gd")

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(10)
	_set_expand(root, true, true)
	add_child(root)

	var equipment_panel: PanelContainer = _panel("EQUIPMENT")
	equipment_panel.custom_minimum_size = Vector2(250, 0)
	root.add_child(equipment_panel)
	_build_equipment(_panel_content(equipment_panel))

	var backpack_panel: PanelContainer = _panel("BACKPACK")
	backpack_panel.custom_minimum_size = Vector2(340, 0)
	root.add_child(backpack_panel)
	_build_backpack(_panel_content(backpack_panel))

	var detail_panel: PanelContainer = _panel("ITEM DETAIL / ACTIONS")
	_set_expand(detail_panel, true, true)
	root.add_child(detail_panel)
	_build_detail(_panel_content(detail_panel))

func _build_equipment(box: VBoxContainer) -> void:
	var equipped: Dictionary = _as_dict(_state_get("equipped", {}))
	var slots: Array[String] = ["weapon", "offhand", "head", "chest", "gloves", "boots", "amulet", "ring1", "ring2", "relic"]
	for slot: String in slots:
		var item: Dictionary = {}
		var raw: Variant = equipped.get(slot, {})
		if typeof(raw) == TYPE_DICTIONARY:
			item = I.normalize_item(Dictionary(raw))
		var item_name: String = "—"
		if not item.is_empty():
			item_name = str(item.get("display_name", "—"))
		box.add_child(_label("[color=#c59b4a]" + slot.capitalize() + "[/color]\n" + item_name, 12))

func _build_backpack(box: VBoxContainer) -> void:
	var backpack: Array = _as_array(_state_get("backpack", []))
	var cursor: int = _selected_backpack_index()
	var scroll: ScrollContainer = ScrollContainer.new()
	_set_expand(scroll, true, true)
	var list: VBoxContainer = _vbox(4)
	scroll.add_child(list)
	box.add_child(scroll)
	if backpack.is_empty():
		list.add_child(_label("Backpack empty."))
		return
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = I.normalize_item(Dictionary(backpack[i]))
		var prefix: String = "▶ " if i == cursor else ""
		var label_text: String = prefix + str(i + 1) + ". " + str(item.get("display_name", item.get("label", "Item")))
		label_text += "\n" + str(item.get("rarity", "")).capitalize() + " · " + str(item.get("slot", item.get("kind", "")))
		list.add_child(_button(label_text, self, "_select", [i], Vector2(305, 54)))

func _build_detail(box: VBoxContainer) -> void:
	var item: Dictionary = I.normalize_item(_selected_backpack_item())
	box.add_child(_label(I.item_detail_text(item), 12))
	box.add_child(_label(_comparison(item), 12))
	var grid: GridContainer = _grid(4, 6)
	box.add_child(grid)
	var actions: Array[String] = ["equip", "forge", "sell", "disenchant", "salvage", "favorite", "lock", "drop"]
	for action: String in actions:
		grid.add_child(_button(action.capitalize(), self, "_act", [action], Vector2(118, 34)))

func _comparison(item: Dictionary) -> String:
	if item.is_empty() or not I.is_equipment(item):
		return ""
	var equipped: Dictionary = _as_dict(_state_get("equipped", {}))
	var slot: String = str(item.get("slot", ""))
	var current: Dictionary = {}
	var raw: Variant = equipped.get(slot, {})
	if typeof(raw) == TYPE_DICTIONARY:
		current = Dictionary(raw)
	if current.is_empty():
		return "[color=#8f8777]No equipped item in this slot.[/color]"
	return I.compare_items_text(item, current)

func _select(index: int) -> void:
	_set_selected_backpack_index(index)

func _act(action: String) -> void:
	if action == "equip":
		if state_ref != null and state_ref.has_method("equip_backpack_index"):
			state_ref.call("equip_backpack_index", _selected_backpack_index())
	elif action == "forge":
		_open_panel("crafting")
	elif action in ["sell", "disenchant", "salvage"]:
		C.apply_to_selected(state_ref, action)
	elif action in ["favorite", "lock"]:
		_toggle_flag(action)
	elif action == "drop":
		_drop()
	refresh_panel()

func _toggle_flag(flag: String) -> void:
	var backpack: Array = _as_array(_state_get("backpack", []))
	var index: int = _selected_backpack_index()
	if index < 0 or index >= backpack.size():
		return
	if typeof(backpack[index]) != TYPE_DICTIONARY:
		return
	var item: Dictionary = Dictionary(backpack[index])
	item[flag] = not bool(item.get(flag, false))
	backpack[index] = item
	_state_set("backpack", backpack)

func _drop() -> void:
	var backpack: Array = _as_array(_state_get("backpack", []))
	var index: int = _selected_backpack_index()
	if index < 0 or index >= backpack.size():
		return
	var item: Dictionary = {}
	if typeof(backpack[index]) == TYPE_DICTIONARY:
		item = Dictionary(backpack[index])
	if bool(item.get("locked", false)) or bool(item.get("favorite", false)):
		_notice("Unlock/unfavorite before dropping.")
		return
	backpack.remove_at(index)
	_state_set("backpack", backpack)
