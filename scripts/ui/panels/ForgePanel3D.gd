extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

func render(state: Object) -> void:
	_reset_columns()
	var selected_box: VBoxContainer = _section("Forge Target", 1.25)
	var action_box: VBoxContainer = _section("Forge Actions", 1.15)
	var cost_box: VBoxContainer = _section("Cost / Risk", 1.0)
	var item: Dictionary = _selected_backpack_item(state)
	_add_rich(selected_box, _describe_item(item), 13)
	var actions: Array[String] = [
		"1 · Add random affix",
		"2 · Upgrade an affix tier",
		"3 · Reroll one modifier",
		"4 · Lock one modifier",
		"5 · Add socket / improve quality"
	]
	for action: String in actions:
		_add_button_like(action_box, action, false)
	_add_line(action_box, "", 4)
	_add_line(action_box, "Forge should be deterministic first, gambling second.", 12, RVUIStyle.color_muted())
	_add_line(cost_box, "Materials", 12, RVUIStyle.color_gold())
	_add_line(cost_box, _materials_text(state), 13, RVUIStyle.color_text())
	_add_line(cost_box, "", 4)
	if item.is_empty():
		_add_line(cost_box, "Select an inventory item first.", 13, RVUIStyle.color_bad())
	else:
		_add_line(cost_box, "Current potential: " + str(item.get("forge_potential", item.get("potential", "?"))), 13, RVUIStyle.color_gold())
		_add_line(cost_box, "No action preview yet. Patch goal is readable control surface first.", 12, RVUIStyle.color_muted())
