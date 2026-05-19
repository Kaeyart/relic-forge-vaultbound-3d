extends RefCounted

const UIItemFormatSystemScript := preload("res://scripts/systems/UIItemFormatSystem3D.gd")

static func panel_hint() -> String:
	return "[b]Forge[/b] Pick an item, inspect current affixes, review cost/risk, then apply a crafting operation."

static func forge_detail_text(state: Object) -> String:
	if state == null:
		return "[i]No forge state bound.[/i]"
	var item: Dictionary = selected_item(state)
	var lines: PackedStringArray = []
	lines.append(panel_hint())
	lines.append("")
	if item.is_empty():
		lines.append("[b]No item selected[/b]")
		lines.append("Select an item from inventory/backpack to preview forge operations.")
	else:
		lines.append("[b]Selected Item[/b]")
		lines.append(UIItemFormatSystemScript.item_detail_text(item))
		lines.append("")
		lines.append(preview_text(state, item))
	lines.append("")
	lines.append(currency_text(state))
	return "\n".join(lines)

static func selected_item(state: Object) -> Dictionary:
	if state == null:
		return {}
	var uid: String = str(_state_get(state, "crafting_selected_item_uid", _state_get(state, "selected_crafting_item_uid", "")))
	var backpack: Array = Array(_state_get(state, "backpack", []))
	if uid != "":
		for value: Variant in backpack:
			if typeof(value) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = Dictionary(value)
			if str(item.get("uid", item.get("id", ""))) == uid:
				return item
	var cursor: int = clampi(_safe_int(_state_get(state, "inventory_cursor", -1), -1), -1, max(-1, backpack.size() - 1))
	if cursor >= 0 and cursor < backpack.size() and typeof(backpack[cursor]) == TYPE_DICTIONARY:
		return Dictionary(backpack[cursor])
	return {}

static func preview_text(state: Object, item: Dictionary) -> String:
	var operation: String = str(_state_get(state, "crafting_operation", _state_get(state, "selected_crafting_operation", ""))).strip_edges()
	if operation == "":
		operation = "Choose operation"
	var potential: int = _safe_int(item.get("forge_potential", item.get("crafting_potential", -1)), -1)
	var lines: PackedStringArray = []
	lines.append("[b]Preview[/b]")
	lines.append("Operation: " + _title_case(operation.replace("_", " ")))
	if potential >= 0:
		lines.append("Forge Potential: " + str(potential))
		if potential <= 0:
			lines.append("[color=orange]This item has no safe forge potential left.[/color]")
	else:
		lines.append("Forge Potential: not tracked on this item yet")
	lines.append("Result Preview: existing crafting logic decides the final outcome. This is the readable workbench view.")
	return "\n".join(lines)

static func currency_text(state: Object) -> String:
	var currency: Dictionary = Dictionary(_state_get(state, "currency", {}))
	if currency.is_empty():
		return "[b]Currency[/b]\nNo currency tracked yet."
	var lines: PackedStringArray = []
	lines.append("[b]Currency[/b]")
	for key: Variant in currency.keys():
		lines.append("• " + _title_case(str(key).replace("_", " ")) + ": " + str(_safe_int(currency[key], 0)))
	return "\n".join(lines)

static func _title_case(value: String) -> String:
	var parts: PackedStringArray = value.split(" ", false)
	for i: int in range(parts.size()):
		if parts[i].length() > 0:
			parts[i] = parts[i].substr(0, 1).to_upper() + parts[i].substr(1).to_lower()
	return " ".join(parts)

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback
