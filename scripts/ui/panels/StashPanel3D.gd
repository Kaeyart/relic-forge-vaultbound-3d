extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

func render(state: Object) -> void:
	_reset_columns()
	var stash_box: VBoxContainer = _section("Stash", 1.25)
	var backpack_box: VBoxContainer = _section("Backpack", 1.1)
	var detail_box: VBoxContainer = _section("Selected", 1.25)
	var stash: Array = _as_array(_state_get(state, "stash", []))
	if stash.is_empty():
		_add_line(stash_box, "Stash is empty.", 13, RVUIStyle.color_muted())
	else:
		for i: int in range(min(18, stash.size())):
			if typeof(stash[i]) == TYPE_DICTIONARY:
				var item: Dictionary = Dictionary(stash[i])
				_add_button_like(stash_box, str(i + 1) + ". " + _item_name(item) + " · " + _item_slot(item), false)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack.is_empty():
		_add_line(backpack_box, "Backpack empty.", 13, RVUIStyle.color_muted())
	else:
		for j: int in range(min(12, backpack.size())):
			if typeof(backpack[j]) == TYPE_DICTIONARY:
				var backpack_item: Dictionary = Dictionary(backpack[j])
				_add_button_like(backpack_box, str(j + 1) + ". " + _item_name(backpack_item), false)
	_add_rich(detail_box, _describe_item(_selected_backpack_item(state)), 13)
	_add_line(detail_box, "[B] move selected item · future: tabs, filters, affinity", 12, RVUIStyle.color_muted())
