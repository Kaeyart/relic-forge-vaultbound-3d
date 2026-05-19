extends Control

const SlotButtonScript := preload("res://scripts/ui/widgets/UISlotButton3D.gd")
const ItemRulesScript := preload("res://scripts/systems/InventoryItemRules3D.gd")

const GRID_COLUMNS: int = 10
const GRID_ROWS: int = 8
const GRID_CAPACITY: int = GRID_COLUMNS * GRID_ROWS
const CELL_GAP: float = 4.0
const BACKPACK_MIN_SIZE: Vector2 = Vector2(520.0, 340.0)
const DEFAULT_CELL_SIZE: Vector2 = Vector2(52.0, 38.0)

const LEFT_EQUIPMENT_SLOTS: Array = ["head", "chest", "gloves", "boots", "weapon"]
const RIGHT_EQUIPMENT_SLOTS: Array = ["amulet", "ring1", "ring2", "relic", "offhand"]

const SLOT_LABELS: Dictionary = {
	"head": "Helm",
	"chest": "Chest",
	"gloves": "Gloves",
	"boots": "Boots",
	"weapon": "Weapon",
	"amulet": "Amulet",
	"ring1": "Ring 1",
	"ring2": "Ring 2",
	"relic": "Relic",
	"offhand": "Offhand",
}

var title_label: Label = null
var close_button: Button = null
var left_equipment_column: VBoxContainer = null
var right_equipment_column: VBoxContainer = null
var backpack_area: Control = null
var selected_label: RichTextLabel = null
var compare_label: RichTextLabel = null
var equip_button: Button = null
var unequip_button: Button = null
var deposit_button: Button = null
var salvage_button: Button = null
var sort_button: Button = null

var state_ref: Object = null
var selected_equipment_slot: String = ""

func _ready() -> void:
	_bind_nodes()
	_connect_buttons()
	_apply_backpack_area_size()
	if not resized.is_connected(_on_resized):
		resized.connect(_on_resized)

func _on_resized() -> void:
	if visible and state_ref != null:
		call_deferred("_rebuild")

func _bind_nodes() -> void:
	title_label = get_node_or_null("RootVBox/HeaderBar/TitleLabel") as Label
	close_button = get_node_or_null("RootVBox/HeaderBar/CloseButton") as Button
	left_equipment_column = get_node_or_null("RootVBox/MainBody/EquipmentPanel/EquipmentMargin/EquipmentHBox/LeftEquipmentColumn") as VBoxContainer
	right_equipment_column = get_node_or_null("RootVBox/MainBody/EquipmentPanel/EquipmentMargin/EquipmentHBox/RightEquipmentColumn") as VBoxContainer
	backpack_area = get_node_or_null("RootVBox/MainBody/BackpackPanel/BackpackMargin/BackpackVBox/BackpackArea") as Control
	selected_label = get_node_or_null("RootVBox/BottomPanel/BottomMargin/BottomHBox/SelectedItemLabel") as RichTextLabel
	compare_label = get_node_or_null("RootVBox/BottomPanel/BottomMargin/BottomHBox/CompareLabel") as RichTextLabel
	equip_button = get_node_or_null("RootVBox/BottomPanel/BottomMargin/BottomHBox/ActionColumn/EquipButton") as Button
	unequip_button = get_node_or_null("RootVBox/BottomPanel/BottomMargin/BottomHBox/ActionColumn/UnequipButton") as Button
	deposit_button = get_node_or_null("RootVBox/BottomPanel/BottomMargin/BottomHBox/ActionColumn/DepositButton") as Button
	salvage_button = get_node_or_null("RootVBox/BottomPanel/BottomMargin/BottomHBox/ActionColumn/SalvageButton") as Button
	sort_button = get_node_or_null("RootVBox/BottomPanel/BottomMargin/BottomHBox/ActionColumn/SortButton") as Button
	_apply_backpack_area_size()

func _connect_buttons() -> void:
	if close_button != null and not close_button.pressed.is_connected(_close_panel):
		close_button.pressed.connect(_close_panel)
	if equip_button != null and not equip_button.pressed.is_connected(_equip_selected_backpack_item):
		equip_button.pressed.connect(_equip_selected_backpack_item)
	if unequip_button != null and not unequip_button.pressed.is_connected(_unequip_selected_slot):
		unequip_button.pressed.connect(_unequip_selected_slot)
	if deposit_button != null and not deposit_button.pressed.is_connected(_deposit_selected_item):
		deposit_button.pressed.connect(_deposit_selected_item)
	if salvage_button != null and not salvage_button.pressed.is_connected(_salvage_selected_item):
		salvage_button.pressed.connect(_salvage_selected_item)
	if sort_button != null and not sort_button.pressed.is_connected(_sort_backpack):
		sort_button.pressed.connect(_sort_backpack)

func update_from_state(state: Object) -> void:
	state_ref = state
	if backpack_area == null:
		_bind_nodes()
	if state_ref != null:
		ItemRulesScript.sanitize_inventory_state(state_ref)
	call_deferred("_rebuild")

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func _state_set(key: String, value: Variant) -> void:
	if state_ref != null:
		state_ref.set(key, value)

func _clear(root: Node) -> void:
	if root == null:
		return
	for child: Node in root.get_children():
		child.queue_free()

func _backpack_available_size() -> Vector2:
	if backpack_area == null:
		return BACKPACK_MIN_SIZE
	var s: Vector2 = backpack_area.size
	if s.x < 32.0 or s.y < 32.0:
		return BACKPACK_MIN_SIZE
	return s

func _cell_size() -> Vector2:
	var s: Vector2 = _backpack_available_size()
	var w: float = (s.x - float(GRID_COLUMNS - 1) * CELL_GAP) / float(GRID_COLUMNS)
	var h: float = (s.y - float(GRID_ROWS - 1) * CELL_GAP) / float(GRID_ROWS)
	if w <= 8.0 or h <= 8.0:
		return DEFAULT_CELL_SIZE
	return Vector2(w, h)

func _apply_backpack_area_size() -> void:
	if backpack_area == null:
		return
	backpack_area.custom_minimum_size = BACKPACK_MIN_SIZE
	backpack_area.mouse_filter = Control.MOUSE_FILTER_PASS

func _cell_position(x: int, y: int) -> Vector2:
	var c: Vector2 = _cell_size()
	return Vector2(float(x) * (c.x + CELL_GAP), float(y) * (c.y + CELL_GAP))

func _item_pixel_size(w: int, h: int) -> Vector2:
	var c: Vector2 = _cell_size()
	return Vector2(
		float(w) * c.x + float(max(0, w - 1)) * CELL_GAP,
		float(h) * c.y + float(max(0, h - 1)) * CELL_GAP
	)

func _rebuild() -> void:
	if state_ref == null:
		return
	ItemRulesScript.sanitize_inventory_state(state_ref)
	if title_label != null:
		title_label.text = "Inventory"
	_apply_backpack_area_size()
	_normalize_backpack_tetris_layout()
	_rebuild_equipment()
	_rebuild_backpack_area()
	_refresh_bottom_panel()
	_refresh_action_states()

func _rebuild_equipment() -> void:
	_clear(left_equipment_column)
	_clear(right_equipment_column)
	var equipped: Dictionary = Dictionary(_state_get("equipped", {}))
	for slot_id: String in LEFT_EQUIPMENT_SLOTS:
		_add_equipment_slot(left_equipment_column, slot_id, equipped)
	for slot_id: String in RIGHT_EQUIPMENT_SLOTS:
		_add_equipment_slot(right_equipment_column, slot_id, equipped)

func _add_equipment_slot(parent: VBoxContainer, slot_id: String, equipped: Dictionary) -> void:
	if parent == null:
		return
	var item: Dictionary = Dictionary(equipped.get(slot_id, {}))
	var label: String = str(SLOT_LABELS.get(slot_id, slot_id.capitalize()))
	var color: Color = Color(0.9, 0.9, 0.9, 1.0)
	if not item.is_empty():
		label += "\n" + _fit_name(str(item.get("display_name", item.get("name", "Item"))), 18)
		color = _rarity_color(item)
	else:
		label += "\n[empty]"

	var is_selected: bool = selected_equipment_slot == slot_id
	var tip: String = "Equipment slot: " + str(SLOT_LABELS.get(slot_id, slot_id))
	if not item.is_empty():
		tip += "\n\n" + _item_text_plain(item)

	var b: Button = SlotButtonScript.new()
	b.custom_minimum_size = Vector2(142, 58)
	b.setup(slot_id, label, {"kind":"equipment_slot", "slot":slot_id}, ["inventory_item"], is_selected, tip, color, true)
	b.slot_clicked.connect(_on_equipment_slot_clicked)
	b.slot_double_clicked.connect(_on_equipment_slot_double_clicked)
	b.slot_right_clicked.connect(_on_equipment_slot_double_clicked)
	b.slot_dropped.connect(_on_equipment_slot_drop)
	parent.add_child(b)

func _normalize_backpack_tetris_layout() -> void:
	var backpack: Array = Array(_state_get("backpack", []))
	var occupancy: Array = _new_occupancy()
	var changed: bool = false

	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i])
		_apply_item_size_defaults(item)
		var x: int = _safe_int(item.get("grid_x", -1), -1)
		var y: int = _safe_int(item.get("grid_y", -1), -1)
		var w: int = _item_w(item)
		var h: int = _item_h(item)

		if not _can_place_in_occupancy(occupancy, x, y, w, h, i):
			var pos: Vector2i = _find_first_fit(occupancy, w, h, i)
			if pos.x >= 0:
				x = pos.x
				y = pos.y
				item["grid_x"] = x
				item["grid_y"] = y
				changed = true
			else:
				item["grid_x"] = -99
				item["grid_y"] = -99
				changed = true
		_mark_occupancy(occupancy, x, y, w, h, i)
		backpack[i] = item

	if changed:
		_state_set("backpack", backpack)

func _rebuild_backpack_area() -> void:
	_clear(backpack_area)
	if backpack_area == null:
		return
	_apply_backpack_area_size()

	var c: Vector2 = _cell_size()
	for y: int in range(GRID_ROWS):
		for x: int in range(GRID_COLUMNS):
			var cell: Button = SlotButtonScript.new()
			cell.position = _cell_position(x, y)
			cell.size = c
			cell.custom_minimum_size = c
			cell.setup("cell_%d_%d" % [x, y], "", {"kind":"inventory_cell", "grid_x":x, "grid_y":y}, ["inventory_item"], false, "Empty cell %d,%d" % [x + 1, y + 1], Color(0.16, 0.16, 0.16, 0.85), false)
			cell.slot_dropped.connect(_on_inventory_cell_drop)
			backpack_area.add_child(cell)

	var backpack: Array = Array(_state_get("backpack", []))
	var cursor: int = clampi(_safe_int(_state_get("inventory_cursor", 0)), 0, max(0, backpack.size() - 1))
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i])
		var x2: int = _safe_int(item.get("grid_x", -99), -99)
		var y2: int = _safe_int(item.get("grid_y", -99), -99)
		var w2: int = _item_w(item)
		var h2: int = _item_h(item)
		if x2 < 0 or y2 < 0:
			continue

		var item_button: Button = SlotButtonScript.new()
		item_button.position = _cell_position(x2, y2)
		item_button.size = _item_pixel_size(w2, h2)
		item_button.custom_minimum_size = _item_pixel_size(w2, h2)
		var selected: bool = i == cursor and selected_equipment_slot == ""
		item_button.setup("item_%d" % i, _backpack_slot_label(item, w2, h2), {"kind":"inventory_item", "index":i}, [], selected, _item_text_plain(item), _rarity_color(item), true)
		item_button.slot_clicked.connect(_on_backpack_item_clicked)
		item_button.slot_double_clicked.connect(_on_backpack_item_double_clicked)
		item_button.slot_right_clicked.connect(_on_backpack_item_double_clicked)
		backpack_area.add_child(item_button)

func _new_occupancy() -> Array:
	var occupancy: Array = []
	occupancy.resize(GRID_CAPACITY)
	for i: int in range(GRID_CAPACITY):
		occupancy[i] = -1
	return occupancy

func _cell_index(x: int, y: int) -> int:
	return y * GRID_COLUMNS + x

func _can_place_in_occupancy(occupancy: Array, x: int, y: int, w: int, h: int, item_index: int) -> bool:
	if x < 0 or y < 0 or x + w > GRID_COLUMNS or y + h > GRID_ROWS:
		return false
	for yy: int in range(y, y + h):
		for xx: int in range(x, x + w):
			var occupant: int = _safe_int(occupancy[_cell_index(xx, yy)], -1)
			if occupant != -1 and occupant != item_index:
				return false
	return true

func _mark_occupancy(occupancy: Array, x: int, y: int, w: int, h: int, item_index: int) -> void:
	if x < 0 or y < 0 or x + w > GRID_COLUMNS or y + h > GRID_ROWS:
		return
	for yy: int in range(y, y + h):
		for xx: int in range(x, x + w):
			occupancy[_cell_index(xx, yy)] = item_index

func _find_first_fit(occupancy: Array, w: int, h: int, item_index: int) -> Vector2i:
	for y: int in range(0, GRID_ROWS - h + 1):
		for x: int in range(0, GRID_COLUMNS - w + 1):
			if _can_place_in_occupancy(occupancy, x, y, w, h, item_index):
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func _on_inventory_cell_drop(_slot_id: String, payload: Dictionary) -> void:
	if str(payload.get("kind", "")) != "inventory_item":
		return
	var index: int = _safe_int(payload.get("index", -1), -1)
	var x: int = -1
	var y: int = -1
	var parts: PackedStringArray = str(_slot_id).split("_")
	if parts.size() >= 3:
		x = _safe_int(parts[1], -1)
		y = _safe_int(parts[2], -1)
	_move_item_to_grid(index, x, y)

func _move_item_to_grid(index: int, x: int, y: int) -> void:
	var backpack: Array = Array(_state_get("backpack", []))
	if index < 0 or index >= backpack.size() or typeof(backpack[index]) != TYPE_DICTIONARY:
		return
	var item: Dictionary = Dictionary(backpack[index])
	_apply_item_size_defaults(item)
	var w: int = _item_w(item)
	var h: int = _item_h(item)
	var occupancy: Array = _build_occupancy_excluding(index, backpack)
	if not _can_place_in_occupancy(occupancy, x, y, w, h, index):
		_notice("No space there")
		return
	item["grid_x"] = x
	item["grid_y"] = y
	backpack[index] = item
	_state_set("backpack", backpack)
	_state_set("inventory_cursor", index)
	selected_equipment_slot = ""
	_rebuild()

func _build_occupancy_excluding(exclude_index: int, backpack: Array) -> Array:
	var occupancy: Array = _new_occupancy()
	for i: int in range(backpack.size()):
		if i == exclude_index or typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i])
		var x: int = _safe_int(item.get("grid_x", -99), -99)
		var y: int = _safe_int(item.get("grid_y", -99), -99)
		var w: int = _item_w(item)
		var h: int = _item_h(item)
		_mark_occupancy(occupancy, x, y, w, h, i)
	return occupancy

func _apply_item_size_defaults(item: Dictionary) -> void:
	if not item.has("grid_w") and not item.has("inventory_w"):
		item["grid_w"] = _default_item_width(item)
	if not item.has("grid_h") and not item.has("inventory_h"):
		item["grid_h"] = _default_item_height(item)

func _item_w(item: Dictionary) -> int:
	return clampi(_safe_int(item.get("grid_w", item.get("inventory_w", _default_item_width(item))), _default_item_width(item)), 1, GRID_COLUMNS)

func _item_h(item: Dictionary) -> int:
	return clampi(_safe_int(item.get("grid_h", item.get("inventory_h", _default_item_height(item))), _default_item_height(item)), 1, GRID_ROWS)

func _backpack_slot_label(item: Dictionary, w: int, h: int) -> String:
	var name_limit: int = max(6, w * 7)
	var rarity_text: String = _rarity_prefix(item)
	var size_text: String = str(w) + "x" + str(h)
	var item_name: String = _fit_name(str(item.get("display_name", item.get("name", "Item"))), name_limit)
	if h <= 1:
		return rarity_text.substr(0, min(4, rarity_text.length())) + " " + size_text + "\n" + item_name
	return rarity_text + " " + size_text + "\n" + item_name

func _fit_name(value: String, max_chars: int) -> String:
	var clean: String = value.strip_edges().replace("\n", " ")
	if clean.length() <= max_chars:
		return clean
	if max_chars <= 3:
		return clean.substr(0, max_chars)
	return clean.substr(0, max_chars - 1) + "…"

func _sort_backpack() -> void:
	var backpack: Array = Array(_state_get("backpack", []))
	backpack.sort_custom(ItemRulesScript.compare_items_for_sort)
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(backpack[i])
		_strip_grid_position(item)
		backpack[i] = item
	_state_set("backpack", backpack)
	_state_set("inventory_cursor", 0)
	selected_equipment_slot = ""
	_notice("Inventory sorted")
	_rebuild()

func _rarity_prefix(item: Dictionary) -> String:
	match str(item.get("rarity", "normal")).to_lower():
		"magic":
			return "MAG"
		"rare":
			return "RARE"
		"unique":
			return "UNIQ"
		_:
			return "NORMAL"

func _rarity_color(item: Dictionary) -> Color:
	match str(item.get("rarity", "normal")).to_lower():
		"magic":
			return Color(0.35, 0.55, 1.0, 1.0)
		"rare":
			return Color(1.0, 0.86, 0.22, 1.0)
		"unique":
			return Color(1.0, 0.52, 0.16, 1.0)
		_:
			return Color(0.94, 0.94, 0.90, 1.0)

func _item_grid_size_text(item: Dictionary) -> String:
	return str(_item_w(item)) + "x" + str(_item_h(item))

func _default_item_width(item: Dictionary) -> int:
	var slot: String = str(item.get("slot", ""))
	match slot:
		"ring", "ring1", "ring2", "amulet", "relic":
			return 1
		"weapon":
			return 2
		"chest":
			return 2
		"offhand":
			return 2
		"head", "gloves", "boots":
			return 2
		_:
			return 1

func _default_item_height(item: Dictionary) -> int:
	var slot: String = str(item.get("slot", ""))
	match slot:
		"ring", "ring1", "ring2", "amulet", "relic":
			return 1
		"weapon":
			return 3
		"chest":
			return 3
		"offhand":
			return 2
		"head", "gloves", "boots":
			return 2
		_:
			return 1

func _on_backpack_item_clicked(_slot_id: String, payload: Dictionary) -> void:
	selected_equipment_slot = ""
	_state_set("inventory_cursor", _safe_int(payload.get("index", 0)))
	_rebuild()

func _on_backpack_item_double_clicked(_slot_id: String, payload: Dictionary) -> void:
	selected_equipment_slot = ""
	_state_set("inventory_cursor", _safe_int(payload.get("index", 0)))
	_equip_selected_backpack_item()

func _on_equipment_slot_clicked(_slot_id: String, payload: Dictionary) -> void:
	selected_equipment_slot = str(payload.get("slot", ""))
	_rebuild()

func _on_equipment_slot_double_clicked(_slot_id: String, payload: Dictionary) -> void:
	selected_equipment_slot = str(payload.get("slot", ""))
	_unequip_selected_slot()

func _on_equipment_slot_drop(slot_id: String, payload: Dictionary) -> void:
	if state_ref == null or str(payload.get("kind", "")) != "inventory_item":
		return
	var backpack: Array = Array(_state_get("backpack", []))
	var index: int = _safe_int(payload.get("index", -1), -1)
	if index < 0 or index >= backpack.size():
		return
	var item: Dictionary = Dictionary(backpack[index])
	var item_slot: String = _normalized_slot_for_item(item)
	if item_slot != "" and item_slot != slot_id:
		_notice("Wrong equipment slot")
		return
	selected_equipment_slot = ""
	_state_set("inventory_cursor", index)
	_equip_selected_backpack_item()

func _equip_selected_backpack_item() -> void:
	if state_ref == null:
		return
	selected_equipment_slot = ""
	var backpack: Array = Array(_state_get("backpack", []))
	if backpack.is_empty():
		_notice("No item selected")
		return

	var index: int = clampi(_safe_int(_state_get("inventory_cursor", 0)), 0, backpack.size() - 1)
	var item: Dictionary = Dictionary(backpack[index])
	var slot: String = _normalized_slot_for_item(item)
	if slot == "":
		_notice("Item cannot be equipped")
		return

	if state_ref.has_method("inventory_equip_selected"):
		state_ref.call("inventory_equip_selected")
	else:
		_direct_equip(index, slot)
	_rebuild()

func _direct_equip(index: int, slot: String) -> void:
	var backpack: Array = Array(_state_get("backpack", []))
	if index < 0 or index >= backpack.size():
		return
	var equipped: Dictionary = Dictionary(_state_get("equipped", {}))
	var item: Dictionary = Dictionary(backpack[index])
	var previous: Dictionary = Dictionary(equipped.get(slot, {}))
	equipped[slot] = item
	backpack.remove_at(index)
	if not previous.is_empty():
		_strip_grid_position(previous)
		backpack.append(previous)
	_state_set("equipped", equipped)
	_state_set("backpack", backpack)
	_state_set("inventory_cursor", clampi(index, 0, max(0, backpack.size() - 1)))

func _unequip_selected_slot() -> void:
	if state_ref == null:
		return
	if selected_equipment_slot == "":
		_notice("Select an equipment slot first")
		return
	var equipped: Dictionary = Dictionary(_state_get("equipped", {}))
	var item: Dictionary = Dictionary(equipped.get(selected_equipment_slot, {}))
	if item.is_empty():
		_notice("Equipment slot is empty")
		return
	var backpack: Array = Array(_state_get("backpack", []))
	_strip_grid_position(item)
	_apply_item_size_defaults(item)
	var occupancy: Array = _build_occupancy_excluding(-1, backpack)
	var pos: Vector2i = _find_first_fit(occupancy, _item_w(item), _item_h(item), backpack.size())
	if pos.x < 0:
		_notice("Backpack has no space")
		return
	item["grid_x"] = pos.x
	item["grid_y"] = pos.y
	equipped.erase(selected_equipment_slot)
	backpack.append(item)
	_state_set("equipped", equipped)
	_state_set("backpack", backpack)
	_state_set("inventory_cursor", backpack.size() - 1)
	selected_equipment_slot = ""
	_notice("Unequipped")
	_rebuild()

func _deposit_selected_item() -> void:
	if state_ref == null:
		return
	if state_ref.has_method("inventory_deposit_selected"):
		state_ref.call("inventory_deposit_selected")
		_rebuild()
		return
	_notice("Deposit needs stash system wiring")

func _salvage_selected_item() -> void:
	if state_ref == null:
		return
	selected_equipment_slot = ""
	var backpack: Array = Array(_state_get("backpack", []))
	if backpack.is_empty():
		_notice("No item selected")
		return
	var index: int = clampi(_safe_int(_state_get("inventory_cursor", 0)), 0, backpack.size() - 1)
	var item: Dictionary = Dictionary(backpack[index])
	backpack.remove_at(index)
	_state_set("backpack", backpack)
	_state_set("inventory_cursor", clampi(index, 0, max(0, backpack.size() - 1)))

	var currency: Dictionary = Dictionary(_state_get("currency", {}))
	var gained: int = _salvage_value(item)
	currency["salvage_shards"] = _safe_int(currency.get("salvage_shards", 0)) + gained
	_state_set("currency", currency)
	_notice("Salvaged +" + str(gained) + " shards")
	_rebuild()

func _salvage_value(item: Dictionary) -> int:
	match str(item.get("rarity", "normal")).to_lower():
		"unique":
			return 8
		"rare":
			return 5
		"magic":
			return 3
		_:
			return 1

func _close_panel() -> void:
	if state_ref != null:
		state_ref.set("panel_mode", "")

func _refresh_bottom_panel() -> void:
	if selected_label == null:
		return
	if selected_equipment_slot != "":
		var item: Dictionary = Dictionary(Dictionary(_state_get("equipped", {})).get(selected_equipment_slot, {}))
		if item.is_empty():
			selected_label.text = "[b]" + str(SLOT_LABELS.get(selected_equipment_slot, selected_equipment_slot)) + "[/b]\nEmpty equipment slot."
			if compare_label != null:
				compare_label.text = "[b]Compare[/b]\nSelect a backpack item to compare."
		else:
			selected_label.text = _item_text_bbcode(item)
			if compare_label != null:
				compare_label.text = "[b]Equipped Item[/b]\nClick Unequip to move this item to backpack."
		return

	var backpack: Array = Array(_state_get("backpack", []))
	if backpack.is_empty():
		selected_label.text = "[b]Selected Item[/b]\nBackpack is empty."
		if compare_label != null:
			compare_label.text = "[b]Compare[/b]\nNo item selected."
		return

	var index: int = clampi(_safe_int(_state_get("inventory_cursor", 0)), 0, backpack.size() - 1)
	var item2: Dictionary = Dictionary(backpack[index])
	selected_label.text = _item_text_bbcode(item2)
	if compare_label != null:
		compare_label.text = _compare_text(item2)

func _refresh_action_states() -> void:
	var has_backpack_item: bool = not Array(_state_get("backpack", [])).is_empty() and selected_equipment_slot == ""
	var has_equipped_item: bool = selected_equipment_slot != "" and not Dictionary(Dictionary(_state_get("equipped", {})).get(selected_equipment_slot, {})).is_empty()
	if equip_button != null:
		equip_button.disabled = not has_backpack_item
	if unequip_button != null:
		unequip_button.disabled = not has_equipped_item
	if deposit_button != null:
		deposit_button.disabled = not has_backpack_item
	if salvage_button != null:
		salvage_button.disabled = not has_backpack_item
	if sort_button != null:
		sort_button.disabled = Array(_state_get("backpack", [])).size() <= 1

func _item_text_bbcode(item: Dictionary) -> String:
	var lines: PackedStringArray = []
	lines.append("[b]" + str(item.get("display_name", item.get("name", "Item"))) + "[/b]")
	lines.append(str(item.get("rarity", "normal")).to_upper() + " · " + _display_slot_name(_normalized_slot_for_item(item)))
	lines.append("Item Level " + str(_safe_int(item.get("item_level", 1))) + " · Forge " + str(_safe_int(item.get("forge_potential", 0))) + " · Size " + _item_grid_size_text(item))
	var stats: Dictionary = Dictionary(item.get("total_stats", {}))
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for k: Variant in stats.keys():
			lines.append(ItemRulesScript.display_stat_line(str(k), stats[k]))
	lines.append("")
	lines.append("[i]Drag within backpack to snap. Right/double click equips.[/i]")
	return "\n".join(lines)

func _item_text_plain(item: Dictionary) -> String:
	return _item_text_bbcode(item).replace("[b]", "").replace("[/b]", "").replace("[i]", "").replace("[/i]", "")

func _compare_text(item: Dictionary) -> String:
	var slot: String = _normalized_slot_for_item(item)
	var lines: PackedStringArray = ["[b]Compare[/b]"]
	if slot == "":
		lines.append("This item has no equipment slot.")
		return "\n".join(lines)

	var equipped: Dictionary = Dictionary(_state_get("equipped", {}))
	var current: Dictionary = Dictionary(equipped.get(slot, {}))
	if current.is_empty():
		lines.append("No item equipped in " + _display_slot_name(slot) + ".")
		lines.append("[color=#55ff88]All listed stats are gained.[/color]")
		var stats_gain: Dictionary = Dictionary(item.get("total_stats", {}))
		for kg: Variant in stats_gain.keys():
			lines.append("[color=#55ff88]" + ItemRulesScript.display_stat_line(str(kg), stats_gain[kg]) + "[/color]")
		return "\n".join(lines)

	lines.append("Equipped: " + str(current.get("display_name", current.get("name", "Item"))))
	var next_stats: Dictionary = Dictionary(item.get("total_stats", {}))
	var cur_stats: Dictionary = Dictionary(current.get("total_stats", {}))
	var keys: Array = []
	for k: Variant in next_stats.keys():
		if not keys.has(k):
			keys.append(k)
	for k: Variant in cur_stats.keys():
		if not keys.has(k):
			keys.append(k)

	if keys.is_empty():
		lines.append("No comparable stats.")
		return "\n".join(lines)

	for k2: Variant in keys:
		var next_value: int = _safe_int(round(_safe_float(next_stats.get(k2, 0))))
		var cur_value: int = _safe_int(round(_safe_float(cur_stats.get(k2, 0))))
		var diff: int = next_value - cur_value
		var color: String = "#aaaaaa"
		if diff > 0:
			color = "#55ff88"
		elif diff < 0:
			color = "#ff6666"
		lines.append("[color=" + color + "]" + ItemRulesScript.display_stat_delta(str(k2), cur_value, next_value) + "[/color]")
	return "\n".join(lines)

func _display_slot_name(slot: String) -> String:
	return str(SLOT_LABELS.get(slot, slot.capitalize()))

func _normalized_slot_for_item(item: Dictionary) -> String:
	return ItemRulesScript.normalized_slot(item)

func _strip_grid_position(item: Dictionary) -> void:
	item.erase("grid_x")
	item.erase("grid_y")

func _notice(text: String) -> void:
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", text)

func _safe_float(value: Variant, fallback: float = 0.0) -> float:
	return ItemRulesScript.safe_float(value, fallback)

func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_STRING:
			var s: String = str(value)
			return s.to_int() if s.is_valid_int() else fallback
		_:
			return fallback
