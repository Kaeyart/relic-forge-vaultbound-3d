extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

func render(state: Object) -> void:
	_reset_columns()
	var equipment_box: VBoxContainer = _section("Equipped", 1.0)
	var backpack_box: VBoxContainer = _section("Backpack", 1.25)
	var detail_box: VBoxContainer = _section("Item Detail", 1.35)

	var equipped: Dictionary = _as_dict(_state_get(state, "equipped", {}))
	var equipment_slots: Array[String] = ["weapon", "offhand", "helmet", "chest", "gloves", "boots", "amulet", "ring_1", "ring_2", "belt", "relic"]
	for slot: String in equipment_slots:
		var label: String = RVUIStyle.title_case(slot)
		if equipped.has(slot) and typeof(equipped[slot]) == TYPE_DICTIONARY:
			var item: Dictionary = Dictionary(equipped[slot])
			_add_button_like(equipment_box, label + " · " + _item_name(item), false)
		else:
			_add_button_like(equipment_box, label + " · empty", false)

	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var cursor: int = clampi(_to_int(_state_get(state, "inventory_cursor", 0)), 0, max(0, backpack.size() - 1))
	if backpack.is_empty():
		_add_line(backpack_box, "Backpack is empty.", 13, RVUIStyle.color_muted())
	else:
		var shown: int = min(18, backpack.size())
		for i: int in range(shown):
			if typeof(backpack[i]) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = Dictionary(backpack[i])
			var text: String = str(i + 1) + ". " + _item_name(item) + " · " + _item_slot(item) + " · P" + str(_item_power(item))
			_add_button_like(backpack_box, text, i == cursor)
		if backpack.size() > shown:
			_add_line(backpack_box, "+" + str(backpack.size() - shown) + " more items", 12, RVUIStyle.color_muted())

	var selected: Dictionary = _selected_backpack_item(state)
	_add_rich(detail_box, _describe_item(selected), 13)
	_add_line(detail_box, "", 4)
	_add_line(detail_box, "Actions", 12, RVUIStyle.color_gold())
	_add_line(detail_box, "[U] equip/use selected · [F] forge selected · [B] move to stash", 12, RVUIStyle.color_muted())
	if not selected.is_empty():
		var slot: String = _item_slot(selected)
		var compare_slot: String = slot
		if slot == "ring":
			compare_slot = "ring_1"
		if equipped.has(compare_slot) and typeof(equipped[compare_slot]) == TYPE_DICTIONARY:
			var old_item: Dictionary = Dictionary(equipped[compare_slot])
			var delta: int = _item_power(selected) - _item_power(old_item)
			var sign: String = "+" if delta > 0 else ""
			_add_line(detail_box, "Power delta vs equipped: " + sign + str(delta), 13, RVUIStyle.color_good() if delta >= 0 else RVUIStyle.color_bad())
