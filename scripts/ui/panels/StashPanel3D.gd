extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const MouseUIScript: GDScript = preload("res://scripts/systems/UIMouseInteractionSystem3D.gd")
const I: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")

var _categories: Array[String] = ["all", "gear", "unique", "high", "weapons", "armor", "jewelry", "gems", "maps", "currency", "runes", "seals"]

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(8)
	_set_expand(root, true, true)
	add_child(root)
	var tabs: PanelContainer = _panel("SPECIALIZED STASH")
	tabs.custom_minimum_size = Vector2(180, 0)
	root.add_child(tabs)
	_build_tabs(_panel_content(tabs))
	var items_panel: PanelContainer = _panel("STORED ITEMS")
	_set_expand(items_panel, true, true)
	root.add_child(items_panel)
	_build_items(_panel_content(items_panel))
	var detail: PanelContainer = _panel("DETAIL")
	detail.custom_minimum_size = Vector2(330, 0)
	root.add_child(detail)
	_build_detail(_panel_content(detail))

func _build_tabs(box: VBoxContainer) -> void:
	var active: String = str(_state_get("stash_category", "all"))
	for category: String in _categories:
		var b: Button = _button(("▶ " if category == active else "") + category.capitalize(), self, "_select_category", [category], Vector2(160, 30))
		box.add_child(b)
	box.add_child(_button("Store Inventory Selection", self, "_store_inventory_selected", [], Vector2(160, 42)))
	box.add_child(_button("Open Inventory", self, "_open_inventory", [], Vector2(160, 34)))

func _build_items(box: VBoxContainer) -> void:
	var stash: Array = _as_array(_state_get("stash", []))
	var cursor: int = _to_int(_state_get("stash_cursor", 0))
	var category: String = str(_state_get("stash_category", "all"))
	var scroll: ScrollContainer = ScrollContainer.new()
	_set_expand(scroll, true, true)
	var list: VBoxContainer = _vbox(4)
	scroll.add_child(list)
	box.add_child(scroll)
	if stash.is_empty():
		list.add_child(_label("[color=#8f8777]Stash empty. Select an inventory item and click Store Inventory Selection.[/color]"))
		return
	for i: int in range(stash.size()):
		if typeof(stash[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = I.normalize_item(Dictionary(stash[i]))
		if not _passes_category(item, category):
			continue
		var selected: bool = i == cursor
		var text: String = ("▶ " if selected else "") + str(i + 1) + ". " + _short(str(item.get("display_name", item.get("label", "Item"))), 34)
		text += "\n[color=" + I.rarity_color(str(item.get("rarity", "normal"))) + "]" + str(item.get("rarity", "normal")).capitalize() + "[/color] · " + str(item.get("slot", item.get("kind", "")))
		var b: Button = _button(text, self, "_select_stash_item", [i], Vector2(330, 56))
		if selected:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		list.add_child(b)

func _build_detail(box: VBoxContainer) -> void:
	var stash: Array = _as_array(_state_get("stash", []))
	var cursor: int = _to_int(_state_get("stash_cursor", 0))
	var item: Dictionary = {}
	if cursor >= 0 and cursor < stash.size() and typeof(stash[cursor]) == TYPE_DICTIONARY:
		item = I.normalize_item(Dictionary(stash[cursor]))
	box.add_child(_label(I.item_detail_text(item), 12))
	box.add_child(_button("Take Selected", self, "_take_selected", [], Vector2(180, 38)))

func _passes_category(item: Dictionary, category: String) -> bool:
	if category == "all":
		return true
	if category == "gear":
		return I.is_equipment(item)
	if category == "unique":
		return str(item.get("rarity", "")) == "unique"
	if category == "high":
		return int(item.get("loot_priority", 0)) >= 75
	if category == "weapons":
		return str(item.get("slot", "")) == "weapon"
	if category == "armor":
		return str(item.get("category", "")) == "armor"
	if category == "jewelry":
		return str(item.get("category", "")) == "jewelry"
	var kind: String = str(item.get("kind", item.get("item_kind", "")))
	if category == "gems":
		return kind.find("gem") >= 0
	if category == "maps":
		return kind == "map"
	if category == "currency":
		return kind == "currency" or kind == "material"
	if category == "runes":
		return str(item.get("display_name", "")).to_lower().find("rune") >= 0
	if category == "seals":
		return str(item.get("display_name", "")).to_lower().find("seal") >= 0
	return true

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
