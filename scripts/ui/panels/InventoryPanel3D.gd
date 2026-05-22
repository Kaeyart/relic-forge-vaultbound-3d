extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const I: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")
const C: GDScript = preload("res://scripts/systems/ItemCraftingSystem3D.gd")
const E: GDScript = preload("res://scripts/systems/ItemEndgameSystem3D.gd")
const F: GDScript = preload("res://scripts/systems/LootFilterSystem3D.gd")
const ItemRuntimeScript: GDScript = preload("res://scripts/systems/ItemCombatIntegrationSystem3D.gd")
const ItemValidationScript: GDScript = preload("res://scripts/systems/ItemValidationSystem3D.gd")

var _filters: Array[String] = ["all", "gear", "unique", "boss", "endgame", "high", "currency", "rune", "seal", "gem", "map"]

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(8)
	_set_expand(root, true, true)
	add_child(root)

	var left: PanelContainer = _panel("FILTER / EQUIPPED")
	left.custom_minimum_size = Vector2(220, 0)
	root.add_child(left)
	_build_left(_panel_content(left))

	var middle: PanelContainer = _panel("BACKPACK / LOOT FILTER")
	middle.custom_minimum_size = Vector2(360, 0)
	root.add_child(middle)
	_build_backpack(_panel_content(middle))

	var detail: PanelContainer = _panel("ITEM CARD / BUILD DECISION")
	_set_expand(detail, true, true)
	root.add_child(detail)
	_build_detail(_panel_content(detail))

func _build_left(box: VBoxContainer) -> void:
	var active: String = str(_state_get("inventory_filter", "all"))
	var grid: GridContainer = _grid(2, 4)
	box.add_child(grid)
	for filter: String in _filters:
		grid.add_child(_button(("▶ " if filter == active else "") + filter.capitalize(), self, "_set_filter", [filter], Vector2(100, 30)))
	box.add_child(_label("\n[color=#c59b4a]Equipped[/color]", 13))
	var equipped: Dictionary = _as_dict(_state_get("equipped", {}))
	var slots: Array[String] = ["weapon", "offhand", "head", "chest", "gloves", "boots", "amulet", "ring1", "ring2", "relic"]
	for slot: String in slots:
		var item: Dictionary = {}
		var raw: Variant = equipped.get(slot, {})
		if typeof(raw) == TYPE_DICTIONARY:
			item = I.normalize_item(Dictionary(raw))
		var item_name: String = "—"
		var rarity: String = "normal"
		if not item.is_empty():
			item_name = str(item.get("display_name", "—"))
			rarity = str(item.get("rarity", "normal"))
		box.add_child(_label("[color=#8f8777]" + slot.capitalize() + "[/color]\n[color=" + I.rarity_color(rarity) + "]" + _short(item_name, 26) + "[/color]", 11))

func _build_backpack(box: VBoxContainer) -> void:
	var backpack: Array = _as_array(_state_get("backpack", []))
	var cursor: int = _selected_backpack_index()
	var filter: String = str(_state_get("inventory_filter", "all"))
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
		if not _passes_filter(item, filter):
			continue
		var selected: bool = i == cursor
		var rarity: String = str(item.get("rarity", "normal"))
		var label_text: String = ("▶ " if selected else "") + str(i + 1) + ". " + _short(str(item.get("display_name", item.get("label", "Item"))), 30)
		label_text += "\n[color=" + I.rarity_color(rarity) + "]" + rarity.capitalize() + "[/color] · " + str(item.get("slot", item.get("kind", "")))
		if I.is_equipment(item):
			label_text += " · FP " + str(int(item.get("forge_potential", 0))) + "/" + str(int(item.get("forge_potential_max", 0)))
			label_text += " · " + F.label_for_item(item)
			if not bool(item.get("identified", true)):
				label_text += " · ?"
		var button: Button = _button(label_text, self, "_select", [i], Vector2(340, 62))
		if selected:
			button.modulate = Color(1.0, 0.84, 0.36, 1.0)
		list.add_child(button)

func _build_detail(box: VBoxContainer) -> void:
	var item: Dictionary = I.normalize_item(_selected_backpack_item())
	var scroll: ScrollContainer = ScrollContainer.new()
	_set_expand(scroll, true, true)
	var inner: VBoxContainer = _vbox(6)
	scroll.add_child(inner)
	box.add_child(scroll)
	inner.add_child(_label(I.item_detail_text(item), 12))
	inner.add_child(_label(E.endgame_item_text(item), 12))
	inner.add_child(_label(ItemRuntimeScript.selected_skill_impact_text(state_ref, item), 12))
	inner.add_child(_label(ItemValidationScript.item_runtime_text(item), 11))
	inner.add_child(_label(_comparison(item), 12))
	var actions: GridContainer = _grid(4, 5)
	inner.add_child(actions)
	var action_list: Array[String] = ["appraise", "equip", "forge", "favorite", "lock", "sell", "disenchant", "salvage", "drop"]
	for action: String in action_list:
		actions.add_child(_button(action.capitalize(), self, "_act", [action], Vector2(118, 34)))

func _passes_filter(item: Dictionary, filter: String) -> bool:
	if filter == "all":
		return true
	if filter == "gear":
		return I.is_equipment(item)
	if filter == "unique":
		return str(item.get("rarity", "")) == "unique"
	if filter == "boss":
		return bool(item.get("boss_exclusive", false))
	if filter == "endgame":
		return E.endgame_loot_priority(item) >= 65
	if filter == "high":
		return F.priority_for_item(item) >= 80
	var kind: String = str(item.get("kind", item.get("item_kind", "")))
	if filter == "currency":
		return kind == "currency" or kind == "material"
	if filter == "rune":
		return str(item.get("display_name", "")).to_lower().find("rune") >= 0 or str(item.get("material_id", "")).find("rune") >= 0
	if filter == "seal":
		return str(item.get("display_name", "")).to_lower().find("seal") >= 0 or str(item.get("material_id", "")).find("seal") >= 0
	if filter == "gem":
		return kind.find("gem") >= 0
	if filter == "map":
		return kind == "map" or kind.find("waystone") >= 0
	return true

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
		return "[color=#8f8777]No equipped item in this slot.[/color]\n" + I.build_relevance_text(item)
	return I.compare_items_text(item, current) + "\n" + E.build_aware_delta(item, current)

func _set_filter(filter: String) -> void:
	_state_set("inventory_filter", filter)
	refresh_panel()

func _select(index: int) -> void:
	_set_selected_backpack_index(index)

func _act(action: String) -> void:
	if action == "equip":
		if state_ref != null and state_ref.has_method("equip_backpack_index"):
			state_ref.call("equip_backpack_index", _selected_backpack_index())
	elif action == "forge":
		_open_panel("crafting")
	elif action == "appraise":
		C.apply_to_selected(state_ref, "appraise")
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
	if index < 0 or index >= backpack.size() or typeof(backpack[index]) != TYPE_DICTIONARY:
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
