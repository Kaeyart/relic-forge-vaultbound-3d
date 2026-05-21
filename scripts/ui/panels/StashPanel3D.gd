extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const MouseUIScript: GDScript = preload("res://scripts/systems/UIMouseInteractionSystem3D.gd")

var _categories: Array[String] = ["all", "gear", "weapons", "armor", "jewelry", "gems", "maps", "materials", "uniques"]

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(10)
	_set_expand(root, true, true)
	add_child(root)
	var tabs: PanelContainer = _panel("STASH TABS")
	_set_expand(tabs, false, true)
	tabs.custom_minimum_size = Vector2(180, 0)
	root.add_child(tabs)
	_build_tabs(_panel_content(tabs))
	var grid_panel: PanelContainer = _panel("STASH GRID · CLICK ITEM")
	_set_expand(grid_panel, true, true)
	root.add_child(grid_panel)
	_build_items(_panel_content(grid_panel))
	var detail: PanelContainer = _panel("SELECTED STASH ITEM")
	_set_expand(detail, true, true)
	detail.custom_minimum_size = Vector2(310, 0)
	root.add_child(detail)
	_build_detail(_panel_content(detail))

func _build_tabs(box: VBoxContainer) -> void:
	var active: String = str(_state_get("stash_category", "all"))
	for category: String in _categories:
		var b: Button = _button(("▶ " if category == active else "") + category.capitalize(), self, "_select_category", [category], Vector2(160, 34))
		box.add_child(b)
	box.add_child(_button("Store Selected Inventory", self, "_store_inventory_selected", [], Vector2(160, 42)))

func _build_items(box: VBoxContainer) -> void:
	var stash: Array = _as_array(_state_get("stash", []))
	var cursor: int = _to_int(_state_get("stash_cursor", 0))
	if stash.is_empty():
		box.add_child(_label("[color=#8f8777]Stash empty. Select an inventory item and click Store Selected Inventory.[/color]"))
		return
	var grid: GridContainer = _grid(3, 5)
	box.add_child(grid)
	for i: int in range(stash.size()):
		if typeof(stash[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(stash[i])
		var selected: bool = i == cursor
		var text: String = ("▶ " if selected else "") + str(i + 1) + ". " + _short(_item_name(item), 22) + "\n" + _item_slot(item) + " · " + _item_rarity(item)
		var b: Button = _button(text, self, "_select_stash_item", [i], Vector2(190, 58))
		if selected:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		grid.add_child(b)

func _build_detail(box: VBoxContainer) -> void:
	var stash: Array = _as_array(_state_get("stash", []))
	var cursor: int = _to_int(_state_get("stash_cursor", 0))
	var item: Dictionary = {}
	if cursor >= 0 and cursor < stash.size() and typeof(stash[cursor]) == TYPE_DICTIONARY:
		item = Dictionary(stash[cursor])
	box.add_child(_label(_item_summary(item)))
	box.add_child(_button("Take Selected", self, "_take_selected", [], Vector2(180, 38)))
	box.add_child(_button("Open Inventory", self, "_open_inventory", [], Vector2(180, 34)))

func _select_category(category: String) -> void:
	_state_set("stash_category", category)
	refresh_panel()

func _select_stash_item(index: int) -> void:
	_state_set("stash_cursor", index)
	refresh_panel()

func _take_selected() -> void:
	MouseUIScript.take_selected_from_stash(state_ref)
	refresh_panel()

func _store_inventory_selected() -> void:
	MouseUIScript.store_selected_to_stash(state_ref)
	refresh_panel()

func _open_inventory() -> void:
	_open_panel("inventory")
