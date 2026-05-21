extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

# patch_14_inventory_grid_item_state
# POE-style inventory pass: real grid occupancy, item size readability,
# identified/favorite/locked flags, and stronger item decision panels.

const InventoryGridSystemScript := preload("res://scripts/systems/InventoryGridSystem3D.gd")

const EQUIPMENT_SLOTS: Array[String] = [
	"weapon",
	"offhand",
	"helmet",
	"chest",
	"gloves",
	"boots",
	"amulet",
	"ring_1",
	"ring_2",
	"belt",
	"relic",
]

func render(state: Object) -> void:
	_reset_columns()
	InventoryGridSystemScript.normalize_inventory_state(state)

	var equipped: Dictionary = _as_dict(_state_get(state, "equipped", {}))
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var cursor: int = _inventory_cursor(state, backpack.size())
	var selected: Dictionary = _selected_backpack_item(state)
	var selected_slot: String = InventoryGridSystemScript.normalized_slot(selected) if not selected.is_empty() else ""

	var equipment_box: VBoxContainer = _section("Equipment", 1.05)
	var backpack_box: VBoxContainer = _section("Backpack Grid", 1.55)
	var detail_box: VBoxContainer = _section("Selected Item", 1.30)
	var compare_box: VBoxContainer = _section("Decision", 1.15)

	_render_equipment(equipment_box, equipped, selected_slot)
	_render_backpack_grid(backpack_box, state, backpack, cursor)
	_render_selected_detail(detail_box, selected, state)
	_render_decision(compare_box, selected, equipped, state)


func _render_equipment(parent: VBoxContainer, equipped: Dictionary, selected_slot: String) -> void:
	_add_line(parent, "Paper-doll Slots", 12, RVUIStyle.color_muted())

	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 7)
	grid.add_theme_constant_override("v_separation", 7)
	parent.add_child(grid)

	for slot_key: String in EQUIPMENT_SLOTS:
		var item: Dictionary = {}
		if equipped.has(slot_key) and typeof(equipped[slot_key]) == TYPE_DICTIONARY:
			item = Dictionary(equipped[slot_key])

		var highlighted: bool = _slot_matches(slot_key, selected_slot)
		_add_equipment_slot(grid, slot_key, item, highlighted)

	_add_line(parent, "", 3)
	_add_line(parent, "Equipment is now separate from the backpack grid.", 11, RVUIStyle.color_muted())
	_add_line(parent, "Skill gems stay in the Gems screen; gear sockets/runes come later.", 11, RVUIStyle.color_muted())


func _render_backpack_grid(parent: VBoxContainer, state: Object, backpack: Array, cursor: int) -> void:
	var used_cells: int = _used_cell_count(backpack)
	_add_line(parent, "Backpack " + str(used_cells) + "/" + str(InventoryGridSystemScript.GRID_CELLS) + " cells", 12, RVUIStyle.color_muted())

	var grid: GridContainer = GridContainer.new()
	grid.columns = InventoryGridSystemScript.GRID_COLUMNS
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	parent.add_child(grid)

	var snapshot: Dictionary = InventoryGridSystemScript.layout_snapshot(state)

	for y: int in range(InventoryGridSystemScript.GRID_ROWS):
		for x: int in range(InventoryGridSystemScript.GRID_COLUMNS):
			_add_grid_cell(grid, x, y, snapshot, cursor)

	var overflow: Array[int] = _overflow_indexes(backpack)
	if not overflow.is_empty():
		_add_line(parent, "", 4)
		_add_line(parent, "Overflow", 12, RVUIStyle.color_bad())
		for index: int in overflow:
			if index >= 0 and index < backpack.size() and typeof(backpack[index]) == TYPE_DICTIONARY:
				var item: Dictionary = Dictionary(backpack[index])
				var selected: bool = index == cursor
				_add_button_like(parent, _inventory_row_text(index, item), selected)

	_add_line(parent, "", 5)
	_add_line(parent, "[ / ] Select · U Equip · Y Appraise · L Lock · V Favorite · Delete Drop", 11, RVUIStyle.color_muted())


func _render_selected_detail(parent: VBoxContainer, item: Dictionary, _state: Object) -> void:
	if item.is_empty():
		_add_line(parent, "No backpack item selected.", 13, RVUIStyle.color_muted())
		return

	var hidden: String = InventoryGridSystemScript.hidden_affix_text(item)
	if hidden != "":
		_add_rich(parent, hidden, 13)
		_add_line(parent, "", 5)
		_add_line(parent, _grid_state_line(item), 11, RVUIStyle.color_muted())
		_add_line(parent, _item_flags_line(item), 11, RVUIStyle.color_bad())
		return

	_add_rich(parent, _describe_item_enhanced(item), 13)
	_add_line(parent, "", 5)
	_add_line(parent, _grid_state_line(item), 11, RVUIStyle.color_muted())
	_add_line(parent, _item_flags_line(item), 11, RVUIStyle.color_bad())
	_add_line(parent, _tag_line(item), 11, RVUIStyle.color_muted())


func _render_decision(parent: VBoxContainer, selected: Dictionary, equipped: Dictionary, _state: Object) -> void:
	if selected.is_empty():
		_add_line(parent, "Select a backpack item to compare.", 13, RVUIStyle.color_muted())
		return

	_add_line(parent, "Inventory Gameplay", 13, RVUIStyle.color_gold())
	_add_line(parent, "This item now has size, grid position, and persistent flags.", 11, RVUIStyle.color_muted())
	_add_line(parent, "", 4)

	var slot: String = InventoryGridSystemScript.normalized_slot(selected)
	var current: Dictionary = _equipped_for_slot(equipped, slot)

	if current.is_empty():
		_add_line(parent, "No equipped item in " + RVUIStyle.title_case(slot.replace("_", " ")) + ".", 12, RVUIStyle.color_muted())
	else:
		_add_rich(parent, _comparison_text(selected, current), 12)

	_add_line(parent, "", 7)
	_add_line(parent, "Actions", 13, RVUIStyle.color_gold())
	_add_line(parent, "U Equip if equippable", 12)
	_add_line(parent, "Y Appraise hidden affixes", 12)
	_add_line(parent, "L Lock against drop/salvage", 12)
	_add_line(parent, "V Mark as favorite", 12)
	_add_line(parent, "Delete Drop if not locked/favorited", 12)
	_add_line(parent, "", 5)
	_add_line(parent, "Next inventory pass: stash/salvage/socket actions.", 11, RVUIStyle.color_muted())


func _add_equipment_slot(parent: GridContainer, slot_key: String, item: Dictionary, highlighted: bool) -> void:
	var button: Button = Button.new()
	button.disabled = true
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(116, 54)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label: String = RVUIStyle.title_case(slot_key.replace("_", " "))
	if item.is_empty():
		button.text = label + "\n—"
	else:
		button.text = label + "\n" + _compact_name(_item_name(item), 18)

	RVUIStyle.apply_button(button, highlighted)
	parent.add_child(button)


func _add_grid_cell(parent: GridContainer, x: int, y: int, snapshot: Dictionary, cursor: int) -> void:
	var key: String = InventoryGridSystemScript.cell_key(x, y)
	var button: Button = Button.new()
	button.disabled = true
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(56, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if not snapshot.has(key):
		button.text = "·"
		RVUIStyle.apply_button(button, false)
		button.modulate = Color(0.55, 0.55, 0.55, 0.55)
		parent.add_child(button)
		return

	var cell: Dictionary = Dictionary(snapshot[key])
	var index: int = _to_int(cell.get("index", -1), -1)
	var item: Dictionary = Dictionary(cell.get("item", {}))
	var selected: bool = index == cursor
	var origin: bool = bool(cell.get("origin", false))

	if origin:
		button.text = _grid_origin_text(index, item)
	else:
		button.text = "↳"

	RVUIStyle.apply_button(button, selected)
	if not origin:
		button.modulate = Color(0.68, 0.62, 0.48, 0.80)

	parent.add_child(button)


func _grid_origin_text(index: int, item: Dictionary) -> String:
	var rarity: String = _item_rarity(item)
	var marker: String = _rarity_marker(rarity)
	var flag: String = ""

	if not bool(item.get("identified", true)):
		flag = "?"
	elif bool(item.get("favorite", false)):
		flag = "★"
	elif bool(item.get("locked", false)):
		flag = "L"
	elif bool(item.get("new_item", false)):
		flag = "!"

	return marker + str(index + 1) + flag + "\n" + _compact_name(_item_name(item), 8)


func _inventory_row_text(index: int, item: Dictionary) -> String:
	return str(index + 1) + ". " + _item_name(item) + "  " + str(item.get("grid_w", 1)) + "x" + str(item.get("grid_h", 1))


func _describe_item_enhanced(item: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	var rarity: String = _item_rarity(item)
	var color: String = RVUIStyle.rarity_color(rarity).to_html(false)

	lines.append("[color=#" + color + "][b]" + _item_name(item) + "[/b][/color]")
	lines.append(rarity.capitalize() + " · " + RVUIStyle.title_case(InventoryGridSystemScript.normalized_slot(item).replace("_", " ")) + " · Power " + str(_item_power(item)))
	lines.append("Item Level " + str(_to_int(item.get("item_level", 1), 1)) + " · Size " + str(item.get("grid_w", 1)) + "x" + str(item.get("grid_h", 1)))

	var quality: int = _to_int(item.get("quality", -1), -1)
	if quality >= 0:
		lines.append("Quality +" + str(quality) + "%")

	var forge_potential: int = _to_int(item.get("forge_potential", item.get("potential", -1)), -1)
	if forge_potential >= 0:
		lines.append("Forge Potential " + str(forge_potential))

	var sockets: Array = _as_array(item.get("sockets", []))
	if not sockets.is_empty():
		lines.append("Sockets: " + _socket_text(sockets))

	var stats: Dictionary = _stat_map(item)
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for key: Variant in stats.keys():
			var value: float = _to_float(stats[key])
			var sign: String = "+" if value > 0.0 else ""
			lines.append("• " + sign + str(snappedf(value, 0.01)) + " " + str(key))

	var detail: String = str(item.get("detail_text", item.get("description", "")))
	if detail != "" and lines.size() < 22:
		lines.append("")
		lines.append(detail)

	return "\n".join(lines)


func _comparison_text(candidate: Dictionary, current: Dictionary) -> String:
	if not bool(candidate.get("identified", true)):
		return "Comparison locked until appraisal."

	var lines: PackedStringArray = PackedStringArray()
	lines.append("[b]Current Equipped[/b]")
	lines.append(_item_name(current))
	lines.append("")

	var next_stats: Dictionary = _stat_map(candidate)
	var old_stats: Dictionary = _stat_map(current)
	var keys: Array[String] = []

	for key: Variant in next_stats.keys():
		var k: String = str(key)
		if not keys.has(k):
			keys.append(k)

	for key: Variant in old_stats.keys():
		var k: String = str(key)
		if not keys.has(k):
			keys.append(k)

	var power_delta: int = _item_power(candidate) - _item_power(current)
	lines.append("Power: " + _signed_int(power_delta))

	var socket_delta: int = _as_array(candidate.get("sockets", [])).size() - _as_array(current.get("sockets", [])).size()
	if socket_delta != 0:
		lines.append("Sockets: " + _signed_int(socket_delta))

	var potential_delta: int = _to_int(candidate.get("forge_potential", candidate.get("potential", 0)), 0) - _to_int(current.get("forge_potential", current.get("potential", 0)), 0)
	if potential_delta != 0:
		lines.append("Forge Potential: " + _signed_int(potential_delta))

	if not keys.is_empty():
		lines.append("")
		lines.append("[b]Stat Deltas[/b]")
		for stat_key: String in keys:
			var delta: float = _to_float(next_stats.get(stat_key, 0.0)) - _to_float(old_stats.get(stat_key, 0.0))
			if absf(delta) <= 0.001:
				continue
			lines.append("• " + stat_key + ": " + _signed_float(delta))

	return "\n".join(lines)


func _equipped_for_slot(equipped: Dictionary, slot: String) -> Dictionary:
	if slot == "":
		return {}

	if equipped.has(slot) and typeof(equipped[slot]) == TYPE_DICTIONARY:
		return Dictionary(equipped[slot])

	if slot == "ring" or slot == "ring_1" or slot == "ring_2":
		if equipped.has("ring_1") and typeof(equipped["ring_1"]) == TYPE_DICTIONARY:
			return Dictionary(equipped["ring_1"])
		if equipped.has("ring_2") and typeof(equipped["ring_2"]) == TYPE_DICTIONARY:
			return Dictionary(equipped["ring_2"])

	return {}


func _inventory_cursor(state: Object, size: int) -> int:
	if size <= 0:
		return 0

	return clampi(_to_int(_state_get(state, "inventory_cursor", 0), 0), 0, size - 1)


func _used_cell_count(backpack: Array) -> int:
	var total: int = 0
	for value: Variant in backpack:
		if typeof(value) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = Dictionary(value)
		var x: int = _to_int(item.get("grid_x", -1), -1)
		if x < 0:
			continue

		total += maxi(1, _to_int(item.get("grid_w", 1), 1)) * maxi(1, _to_int(item.get("grid_h", 1), 1))

	return total


func _overflow_indexes(backpack: Array) -> Array[int]:
	var out: Array[int] = []
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = Dictionary(backpack[i])
		if _to_int(item.get("grid_x", -1), -1) < 0:
			out.append(i)

	return out


func _grid_state_line(item: Dictionary) -> String:
	var x: int = _to_int(item.get("grid_x", -1), -1)
	var y: int = _to_int(item.get("grid_y", -1), -1)
	var pos: String = "overflow" if x < 0 else str(x) + "," + str(y)
	return "Grid: " + str(item.get("grid_w", 1)) + "x" + str(item.get("grid_h", 1)) + " at " + pos


func _item_flags_line(item: Dictionary) -> String:
	var text: String = InventoryGridSystemScript.flag_text(item)
	if text == "":
		return "Flags: none"

	return "Flags: " + text


func _tag_line(item: Dictionary) -> String:
	var tags: Array = _as_array(item.get("tags", []))
	if tags.is_empty():
		return "Tags: —"

	var parts: PackedStringArray = PackedStringArray()
	for tag_value: Variant in tags:
		parts.append(str(tag_value))
		if parts.size() >= 7:
			break

	return "Tags: " + ", ".join(parts)


func _slot_matches(slot_key: String, selected_slot: String) -> bool:
	if selected_slot == "":
		return false

	if slot_key == selected_slot:
		return true

	if slot_key == "ring_1" and selected_slot == "ring":
		return true

	if slot_key == "ring_2" and selected_slot == "ring":
		return true

	return false


func _socket_text(sockets: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()

	for socket_value: Variant in sockets:
		if typeof(socket_value) == TYPE_DICTIONARY:
			var socket: Dictionary = Dictionary(socket_value)
			var label: String = str(socket.get("color", socket.get("type", "socket")))
			if socket.has("item") and typeof(socket["item"]) == TYPE_DICTIONARY:
				label += ":" + _compact_name(_item_name(Dictionary(socket["item"])), 8)
			parts.append(label)
		else:
			parts.append(str(socket_value))

	return ", ".join(parts)


func _rarity_marker(rarity: String) -> String:
	match rarity:
		"unique":
			return "U"
		"rare":
			return "R"
		"magic":
			return "M"
		_:
			return "N"


func _compact_name(value: String, limit: int) -> String:
	if value.length() <= limit:
		return value

	return value.substr(0, maxi(1, limit - 1)) + "…"


func _signed_int(value: int) -> String:
	if value > 0:
		return "+" + str(value)

	return str(value)


func _signed_float(value: float) -> String:
	var rounded: float = snappedf(value, 0.01)
	if rounded > 0.0:
		return "+" + str(rounded)

	return str(rounded)
