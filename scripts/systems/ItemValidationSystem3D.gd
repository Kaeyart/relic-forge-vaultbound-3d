class_name RVItemValidationSystem3D
extends RefCounted

const ItemizationScript: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")
const CombatItemScript: GDScript = preload("res://scripts/systems/ItemCombatIntegrationSystem3D.gd")

static func ensure_runtime_defaults(state: Object) -> void:
	if state == null:
		return
	if state.get("item_validation_report") == null:
		state.set("item_validation_report", "Item validator ready.")
	if state.get("runic_ward_current") == null:
		state.set("runic_ward_current", 0.0)
	if state.get("runic_ward_max") == null:
		state.set("runic_ward_max", 0.0)
	if state.get("melee_hit_counter") == null:
		state.set("melee_hit_counter", 0)


static func validate_state(state: Object) -> Dictionary:
	var result: Dictionary = {
		"ok": true,
		"errors": [],
		"warnings": [],
		"item_count": 0,
	}
	if state == null:
		result["ok"] = false
		Array(result["errors"]).append("State is null.")
		return result
	var seen_uids: Dictionary = {}
	_validate_item_array(state, "backpack", Array(result["errors"]), Array(result["warnings"]), seen_uids, result)
	_validate_item_array(state, "stash", Array(result["errors"]), Array(result["warnings"]), seen_uids, result)
	var equipped_value: Variant = state.get("equipped")
	if typeof(equipped_value) == TYPE_DICTIONARY:
		var equipped: Dictionary = Dictionary(equipped_value)
		for slot_key: Variant in equipped.keys():
			var raw: Variant = equipped[slot_key]
			if typeof(raw) == TYPE_DICTIONARY and not Dictionary(raw).is_empty():
				var item: Dictionary = ItemizationScript.normalize_item(Dictionary(raw))
				_validate_one_item(item, "equipped." + str(slot_key), Array(result["errors"]), Array(result["warnings"]), seen_uids)
				result["item_count"] = int(result.get("item_count", 0)) + 1
	result["ok"] = Array(result["errors"]).is_empty()
	return result


static func _validate_item_array(state: Object, field: String, errors: Array, warnings: Array, seen_uids: Dictionary, result: Dictionary) -> void:
	var value: Variant = state.get(field)
	if typeof(value) != TYPE_ARRAY:
		return
	var arr: Array = Array(value)
	for i: int in range(arr.size()):
		if typeof(arr[i]) != TYPE_DICTIONARY:
			warnings.append(field + "[" + str(i) + "] is not a Dictionary.")
			continue
		var item: Dictionary = ItemizationScript.normalize_item(Dictionary(arr[i]))
		_validate_one_item(item, field + "[" + str(i) + "]", errors, warnings, seen_uids)
		result["item_count"] = int(result.get("item_count", 0)) + 1


static func _validate_one_item(item: Dictionary, path: String, errors: Array, warnings: Array, seen_uids: Dictionary) -> void:
	if item.is_empty():
		return
	var uid: String = str(item.get("uid", ""))
	if uid == "":
		warnings.append(path + ": missing uid.")
	elif seen_uids.has(uid):
		errors.append(path + ": duplicate uid " + uid + ".")
	else:
		seen_uids[uid] = true
	var rarity: String = str(item.get("rarity", "normal"))
	var explicit_mods: Array = Array(item.get("explicit_mods", []))
	var prefix_count: int = 0
	var suffix_count: int = 0
	var groups: Dictionary = {}
	for mod_value: Variant in explicit_mods:
		if typeof(mod_value) != TYPE_DICTIONARY:
			warnings.append(path + ": non-dictionary explicit mod.")
			continue
		var mod: Dictionary = Dictionary(mod_value)
		var side: String = str(mod.get("prefix_suffix", mod.get("side", "")))
		if side == "prefix":
			prefix_count += 1
		elif side == "suffix":
			suffix_count += 1
		var group: String = str(mod.get("group", ""))
		if group != "":
			if groups.has(group):
				warnings.append(path + ": repeated affix group " + group + ".")
			groups[group] = true
	if rarity == "magic" and explicit_mods.size() > 2:
		warnings.append(path + ": magic item has more than 2 explicit mods.")
	if rarity == "rare" and explicit_mods.size() > 6:
		errors.append(path + ": rare item has more than 6 explicit mods.")
	if prefix_count > 3:
		errors.append(path + ": more than 3 prefixes.")
	if suffix_count > 3:
		errors.append(path + ": more than 3 suffixes.")
	var total_stats: Variant = item.get("total_stats", {})
	if typeof(total_stats) == TYPE_DICTIONARY:
		var canonical: Dictionary = CombatItemScript.canonicalize_stats(Dictionary(total_stats))
		if canonical.is_empty() and not Dictionary(total_stats).is_empty():
			warnings.append(path + ": stats could not be canonicalized.")
	var sockets: Array = Array(item.get("sockets", []))
	var socket_limit: int = int(item.get("socket_limit", max(0, sockets.size())))
	if sockets.size() > max(0, socket_limit):
		warnings.append(path + ": socket count exceeds socket limit.")


static func runtime_report_text(state: Object) -> String:
	var result: Dictionary = validate_state(state)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a]Item Runtime Validation[/color]")
	lines.append("Items checked: " + str(int(result.get("item_count", 0))))
	lines.append("Status: " + ("OK" if bool(result.get("ok", false)) else "ERRORS"))
	var errors: Array = Array(result.get("errors", []))
	var warnings: Array = Array(result.get("warnings", []))
	if not errors.is_empty():
		lines.append("[color=#d65a32]Errors[/color]")
		for e: Variant in errors.slice(0, min(8, errors.size())):
			lines.append("• " + str(e))
	if not warnings.is_empty():
		lines.append("[color=#c59b4a]Warnings[/color]")
		for w: Variant in warnings.slice(0, min(8, warnings.size())):
			lines.append("• " + str(w))
	if errors.is_empty() and warnings.is_empty():
		lines.append("No obvious item shape problems detected.")
	return "\n".join(lines)


static func item_runtime_text(item: Dictionary) -> String:
	if item.is_empty():
		return ""
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a]Runtime[/color]")
	var reasons: Array[String] = CombatItemScript.invalid_equip_reasons(null, {})
	# Requirements are state-dependent, so this function only reports item-local data.
	lines.append("UID: " + str(item.get("uid", "—")))
	lines.append("Item Level: " + str(int(item.get("item_level", item.get("level", 1)))))
	lines.append("Forge Potential: " + str(int(item.get("forge_potential", 0))) + "/" + str(int(item.get("forge_potential_max", 0))))
	if not bool(item.get("identified", true)):
		lines.append("Unidentified: appraise before full evaluation.")
	return "\n".join(lines)


static func run_smoke_test(state: Object) -> String:
	ensure_runtime_defaults(state)
	var result: Dictionary = validate_state(state)
	var text: String = runtime_report_text(state)
	if state != null:
		state.set("item_validation_report", text)
		if state.has_method("add_notice"):
			state.call("add_notice", "Item validation: " + ("OK" if bool(result.get("ok", false)) else "errors found"))
	return text
