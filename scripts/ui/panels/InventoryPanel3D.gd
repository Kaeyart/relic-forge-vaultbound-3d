extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

# Patch 08: Inventory screen rebuild.
# Goal: translate the generated inventory concept into a no-art Godot layout:
# equipment paper-doll, backpack grid, selected item card, and comparison card.

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

const GRID_VISIBLE_SLOTS: int = 30
const GRID_COLUMNS: int = 5

func render(state: Object) -> void:
	_reset_columns()

	var equipped: Dictionary = _as_dict(_state_get(state, "equipped", {}))
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var cursor: int = _inventory_cursor(state, backpack.size())
	var selected: Dictionary = _selected_backpack_item(state)
	var selected_slot: String = _normalized_slot(_item_slot(selected)) if not selected.is_empty() else ""

	var equipment_box: VBoxContainer = _section("Equipment", 1.10)
	var backpack_box: VBoxContainer = _section("Backpack", 1.28)
	var detail_box: VBoxContainer = _section("Selected Item", 1.42)
	var compare_box: VBoxContainer = _section("Compare", 1.12)

	_render_equipment(equipment_box, equipped, selected_slot)
	_render_backpack(backpack_box, state, backpack, cursor)
	_render_selected_detail(detail_box, selected, state)
	_render_compare(compare_box, selected, equipped)

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
	_add_line(parent, "Equipment shows current build anchors. Selected item slot is highlighted.", 11, RVUIStyle.color_muted())

func _render_backpack(parent: VBoxContainer, state: Object, backpack: Array, cursor: int) -> void:
	_add_line(parent, "Gold " + RVUIStyle.compact_number(_state_get(state, "gold", 0)) + "  ·  " + _materials_text(state), 12, RVUIStyle.color_gold())

	var grid: GridContainer = GridContainer.new()
	grid.columns = GRID_COLUMNS
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	parent.add_child(grid)

	var shown: int = mini(GRID_VISIBLE_SLOTS, maxi(GRID_VISIBLE_SLOTS, backpack.size()))
	for i: int in range(shown):
		if i < backpack.size() and typeof(backpack[i]) == TYPE_DICTIONARY:
			_add_backpack_slot(grid, i, Dictionary(backpack[i]), i == cursor)
		else:
			_add_empty_grid_slot(grid)

	if backpack.size() > GRID_VISIBLE_SLOTS:
		_add_line(parent, "+" + str(backpack.size() - GRID_VISIBLE_SLOTS) + " more items not shown in prototype grid", 11, RVUIStyle.color_muted())

	_add_line(parent, "", 3)
	_add_line(parent, "[ / ] select · [U] equip/use · [F] forge · [B] stash later", 12, RVUIStyle.color_muted())

func _render_selected_detail(parent: VBoxContainer, item: Dictionary, state: Object) -> void:
	if item.is_empty():
		_add_line(parent, "No item selected.", 14, RVUIStyle.color_muted())
		_add_line(parent, "Pick up loot or move the inventory cursor with [ and ].", 12, RVUIStyle.color_muted())
		return

	_add_item_header(parent, item)

	var metrics: GridContainer = GridContainer.new()
	metrics.columns = 2
	metrics.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metrics.add_theme_constant_override("h_separation", 8)
	metrics.add_theme_constant_override("v_separation", 6)
	parent.add_child(metrics)
	_add_metric(metrics, "Item Power", str(_item_power(item)), RVUIStyle.color_gold())
	_add_metric(metrics, "Slot", RVUIStyle.title_case(_normalized_slot(_item_slot(item))), RVUIStyle.color_text())
	_add_metric(metrics, "Quality", "+" + str(_to_int(item.get("quality", 0))) + "%", RVUIStyle.color_text())
	_add_metric(metrics, "Forge Potential", _forge_potential_text(item), RVUIStyle.color_gold())

	_add_socket_row(parent, item)
	_add_stat_block(parent, item)
	_add_special_rules(parent, item)

	var detail: String = str(item.get("description", item.get("flavor_text", "")))
	if detail != "":
		_add_line(parent, "", 4)
		_add_rich(parent, "[i]" + detail + "[/i]", 12)

	_add_line(parent, "", 4)
	_add_line(parent, "Actions", 12, RVUIStyle.color_gold())
	_add_line(parent, "[U] Equip / Use    [F] Send to Forge    [Y] Inspect later", 12, RVUIStyle.color_muted())
	_add_line(parent, "Inventory Cursor: " + str(_inventory_cursor(state, _as_array(_state_get(state, "backpack", [])).size()) + 1), 11, RVUIStyle.color_muted())

func _render_compare(parent: VBoxContainer, selected: Dictionary, equipped: Dictionary) -> void:
	if selected.is_empty():
		_add_line(parent, "No comparison.", 13, RVUIStyle.color_muted())
		return

	var slot: String = _comparison_slot_for_item(selected)
	var current: Dictionary = _equipped_for_slot(equipped, slot)
	if current.is_empty():
		_add_line(parent, "No equipped item in this slot.", 13, RVUIStyle.color_muted())
		_add_line(parent, "Slot: " + RVUIStyle.title_case(slot), 12, RVUIStyle.color_muted())
		return

	_add_line(parent, "Currently Equipped", 12, RVUIStyle.color_muted())
	_add_item_header(parent, current, true)

	var selected_power: int = _item_power(selected)
	var current_power: int = _item_power(current)
	var delta_power: int = selected_power - current_power
	_add_line(parent, "Power Delta: " + _signed_int(delta_power), 14, RVUIStyle.color_good() if delta_power >= 0 else RVUIStyle.color_bad())

	_add_line(parent, "", 3)
	_add_line(parent, "Changes if Equipped", 12, RVUIStyle.color_gold())

	var selected_stats: Dictionary = _stat_map(selected)
	var current_stats: Dictionary = _stat_map(current)
	var keys: Array[String] = _merged_stat_keys(selected_stats, current_stats)
	var emitted: int = 0
	for stat_key: String in keys:
		var new_value: float = _to_float(selected_stats.get(stat_key, 0.0))
		var old_value: float = _to_float(current_stats.get(stat_key, 0.0))
		var delta: float = new_value - old_value
		if absf(delta) <= 0.001:
			continue
		emitted += 1
		_add_line(parent, "• " + stat_key + "  " + _signed_float(delta), 12, RVUIStyle.color_good() if delta > 0.0 else RVUIStyle.color_bad())

	if emitted == 0:
		_add_line(parent, "No explicit stat deltas found.", 12, RVUIStyle.color_muted())

func _add_equipment_slot(parent: Control, slot_key: String, item: Dictionary, highlighted: bool) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(128, 66)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	RVUIStyle.apply_panel(panel, "selected" if highlighted else "normal")
	parent.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var box: VBoxContainer = RVUIStyle.make_vbox("SlotBox", 2)
	margin.add_child(box)
	box.add_child(RVUIStyle.label(RVUIStyle.title_case(slot_key), 11, RVUIStyle.color_gold(), true))
	if item.is_empty():
		box.add_child(RVUIStyle.label("empty", 12, RVUIStyle.color_muted()))
	else:
		box.add_child(RVUIStyle.label(_item_name(item), 12, RVUIStyle.rarity_color(_item_rarity(item))))
		box.add_child(RVUIStyle.label("P" + str(_item_power(item)), 11, RVUIStyle.color_muted()))

func _add_backpack_slot(parent: Control, index: int, item: Dictionary, selected: bool) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(112, 72)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	RVUIStyle.apply_panel(panel, "selected" if selected else "normal")
	parent.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 7)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 7)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var box: VBoxContainer = RVUIStyle.make_vbox("ItemBox", 2)
	margin.add_child(box)
	box.add_child(RVUIStyle.label(str(index + 1) + " · " + _rarity_short(_item_rarity(item)), 10, RVUIStyle.color_muted()))
	box.add_child(RVUIStyle.label(_compact_item_name(_item_name(item), 17), 12, RVUIStyle.rarity_color(_item_rarity(item))))
	box.add_child(RVUIStyle.label(RVUIStyle.title_case(_normalized_slot(_item_slot(item))) + " · P" + str(_item_power(item)), 10, RVUIStyle.color_muted()))

func _add_empty_grid_slot(parent: Control) -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(112, 72)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	RVUIStyle.apply_panel(panel)
	panel.modulate = Color(1.0, 1.0, 1.0, 0.42)
	parent.add_child(panel)

func _add_item_header(parent: VBoxContainer, item: Dictionary, compact: bool = false) -> void:
	var rarity: String = _item_rarity(item)
	var name_color: Color = RVUIStyle.rarity_color(rarity)
	_add_line(parent, _item_name(item), 18 if not compact else 15, name_color)
	_add_line(parent, rarity.capitalize() + " " + RVUIStyle.title_case(_normalized_slot(_item_slot(item))), 12, RVUIStyle.color_muted())

func _add_metric(parent: GridContainer, label_text: String, value_text: String, value_color: Color) -> void:
	parent.add_child(RVUIStyle.label(label_text, 11, RVUIStyle.color_muted(), true))
	parent.add_child(RVUIStyle.label(value_text, 13, value_color))

func _add_socket_row(parent: VBoxContainer, item: Dictionary) -> void:
	var sockets: Array = _as_array(item.get("sockets", []))
	var socket_count: int = sockets.size()
	if socket_count <= 0:
		socket_count = _to_int(item.get("socket_count", item.get("sockets_count", 0)))
	if socket_count <= 0:
		return

	_add_line(parent, "", 3)
	var socket_text: String = "Sockets: "
	for i: int in range(socket_count):
		socket_text += "● "
	_add_line(parent, socket_text, 12, RVUIStyle.color_magic())

func _add_stat_block(parent: VBoxContainer, item: Dictionary) -> void:
	var stats: Dictionary = _stat_map(item)
	if stats.is_empty():
		return
	_add_line(parent, "", 3)
	_add_line(parent, "Affixes / Stats", 12, RVUIStyle.color_gold())
	var count: int = 0
	for key: Variant in stats.keys():
		count += 1
		if count > 8:
			_add_line(parent, "+" + str(stats.size() - 8) + " more stats", 11, RVUIStyle.color_muted())
			break
		var stat_value: float = _to_float(stats[key])
		var sign: String = "+" if stat_value > 0.0 else ""
		_add_line(parent, "✦ " + sign + str(snappedf(stat_value, 0.01)) + " " + str(key), 12, RVUIStyle.color_magic())

func _add_special_rules(parent: VBoxContainer, item: Dictionary) -> void:
	var rules: Array = _as_array(item.get("rules", item.get("special_rules", [])))
	if rules.is_empty() and item.has("unique_rule"):
		rules.append(item.get("unique_rule"))
	if rules.is_empty():
		return
	_add_line(parent, "", 3)
	_add_line(parent, "Special", 12, RVUIStyle.color_gold())
	for rule_value: Variant in rules:
		_add_line(parent, "★ " + str(rule_value), 12, RVUIStyle.color_gold())

func _inventory_cursor(state: Object, backpack_size: int) -> int:
	if backpack_size <= 0:
		return 0
	return clampi(_to_int(_state_get(state, "inventory_cursor", 0)), 0, backpack_size - 1)

func _comparison_slot_for_item(item: Dictionary) -> String:
	var slot: String = _normalized_slot(_item_slot(item))
	if slot == "ring":
		return "ring_1"
	return slot

func _equipped_for_slot(equipped: Dictionary, slot: String) -> Dictionary:
	if equipped.has(slot) and typeof(equipped[slot]) == TYPE_DICTIONARY:
		return Dictionary(equipped[slot])
	if slot == "ring" or slot == "ring_1" or slot == "ring_2":
		if equipped.has("ring_1") and typeof(equipped["ring_1"]) == TYPE_DICTIONARY:
			return Dictionary(equipped["ring_1"])
		if equipped.has("ring_2") and typeof(equipped["ring_2"]) == TYPE_DICTIONARY:
			return Dictionary(equipped["ring_2"])
	return {}

func _slot_matches(slot_key: String, selected_slot: String) -> bool:
	if selected_slot == "":
		return false
	if slot_key == selected_slot:
		return true
	if selected_slot == "ring" and (slot_key == "ring_1" or slot_key == "ring_2"):
		return true
	return false

func _normalized_slot(raw_slot: String) -> String:
	var slot: String = raw_slot.to_lower()
	match slot:
		"helm":
			return "helmet"
		"body", "body_armor", "chest_armor", "armor_chest":
			return "chest"
		"mainhand", "main_hand":
			return "weapon"
		"shield":
			return "offhand"
		"jewelry":
			return "ring"
		_:
			return slot

func _forge_potential_text(item: Dictionary) -> String:
	var potential: int = _to_int(item.get("forge_potential", item.get("potential", -1)))
	if potential < 0:
		return "—"
	var max_potential: int = maxi(1, _to_int(item.get("max_forge_potential", 5)))
	return str(potential) + " / " + str(max_potential)

func _rarity_short(rarity: String) -> String:
	match rarity.to_lower():
		"normal":
			return "N"
		"magic":
			return "M"
		"rare":
			return "R"
		"unique":
			return "U"
		_:
			return "?"

func _compact_item_name(item_name: String, max_len: int) -> String:
	if item_name.length() <= max_len:
		return item_name
	return item_name.substr(0, maxi(1, max_len - 1)) + "…"

func _merged_stat_keys(a: Dictionary, b: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for key_a: Variant in a.keys():
		var text_a: String = str(key_a)
		if not out.has(text_a):
			out.append(text_a)
	for key_b: Variant in b.keys():
		var text_b: String = str(key_b)
		if not out.has(text_b):
			out.append(text_b)
	return out

func _signed_int(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)

func _signed_float(value: float) -> String:
	var rounded_value: float = snappedf(value, 0.01)
	if rounded_value > 0.0:
		return "+" + str(rounded_value)
	return str(rounded_value)
