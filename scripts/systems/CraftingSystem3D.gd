class_name RVCraftingSystem3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")

static func craft_selected(state: Object, action: String) -> bool:
	if state == null:
		return false

	var selection: Dictionary = _selected_item_ref(state)
	if selection.is_empty():
		_notice(state, "No item selected")
		return false

	var backpack: Array = selection["backpack"]
	var index: int = int(selection["index"])
	var item: Dictionary = ItemDBScript.normalize_item(selection["item"])
	var normalized_action: String = _normalize_action(action)
	var cost: Dictionary = _action_cost(normalized_action, item)

	if cost.is_empty():
		_notice(state, "Unknown forge action")
		return false

	if _to_int(item.get("forge_potential", 0), 0) < _to_int(cost.get("potential", 0), 0):
		_notice(state, "Not enough forge potential")
		return false

	if not _pay_cost(state, cost):
		_notice(state, "Need " + _cost_text(cost))
		return false

	var before: Dictionary = item.duplicate(true)
	item = _apply_action(normalized_action, item, state)

	if item == before:
		_notice(state, "Forge action had no effect")
		return false

	item = ItemDBScript.normalize_item(item)
	backpack[index] = item
	state.set("backpack", backpack)
	state.set("crafting_selected_item_uid", str(item.get("uid", "")))

	if state.has_method("recompute_stats"):
		state.call("recompute_stats")

	_notice(state, _action_success_text(normalized_action))
	return true


static func preview_selected(state: Object, action: String) -> String:
	if state == null:
		return "Forge unavailable."

	var selection: Dictionary = _selected_item_ref(state)
	if selection.is_empty():
		return "Select an item."

	var item: Dictionary = ItemDBScript.normalize_item(selection["item"])
	var normalized_action: String = _normalize_action(action)
	var cost: Dictionary = _action_cost(normalized_action, item)

	var lines: Array[String] = []
	lines.append(_action_title(normalized_action))
	lines.append("Cost: " + _cost_text(cost))
	lines.append("Forge Potential Cost: " + str(cost.get("potential", 0)))
	lines.append("")
	lines.append(_action_description(normalized_action))
	lines.append("")
	lines.append(ItemDBScript.item_detail_text(item))
	return "\n".join(lines)


static func panel_text(state: Object) -> String:
	if state == null:
		return "Crafting unavailable."

	var lines: Array[String] = []
	lines.append("FORGE")
	lines.append("Items keep Forge Potential. Every deterministic action consumes potential.")
	lines.append("")
	lines.append("1 Seal: add crafted affix")
	lines.append("2 Reforge: reroll affix values")
	lines.append("3 Polish: improve quality")
	lines.append("4 Upgrade: normal → magic → rare")
	lines.append("5 Remove: remove weakest affix")
	lines.append("")
	lines.append("Materials: " + _wallet_text(state))
	lines.append("")

	var selection: Dictionary = _selected_item_ref(state)
	if selection.is_empty():
		lines.append("Select an item to craft.")
	else:
		lines.append(ItemDBScript.item_detail_text(selection["item"]))

	return "\n".join(lines)


static func _apply_action(action: String, item: Dictionary, state: Object) -> Dictionary:
	var rng: RandomNumberGenerator = _rng(state)
	match action:
		"seal":
			return ItemDBScript.add_crafted_mod(item, rng)
		"reforge":
			return ItemDBScript.reroll_affix_values(item, rng)
		"polish":
			return ItemDBScript.improve_quality(item, 5)
		"upgrade":
			return ItemDBScript.upgrade_rarity(item, rng)
		"remove":
			return ItemDBScript.remove_weakest_affix(item)
		_:
			return item


static func _action_cost(action: String, item: Dictionary) -> Dictionary:
	match action:
		"seal":
			return {"currency":"shards", "amount":2, "potential":3}
		"reforge":
			return {"currency":"embers", "amount":5, "potential":4}
		"polish":
			return {"currency":"runes", "amount":1, "potential":1}
		"upgrade":
			if str(item.get("rarity", "normal")) == "normal":
				return {"currency":"shards", "amount":4, "potential":4}
			if str(item.get("rarity", "normal")) == "magic":
				return {"currency":"embers", "amount":8, "potential":6}
			return {}
		"remove":
			return {"currency":"runes", "amount":2, "potential":4}
		_:
			return {}


static func _normalize_action(action: String) -> String:
	match action.strip_edges().to_lower():
		"seal", "add", "add_affix", "craft":
			return "seal"
		"reforge", "reroll", "reroll_values":
			return "reforge"
		"polish", "quality":
			return "polish"
		"upgrade", "upgrade_rarity":
			return "upgrade"
		"remove", "remove_affix", "annul":
			return "remove"
		_:
			return action.strip_edges().to_lower()


static func _selected_item_ref(state: Object) -> Dictionary:
	var backpack_value: Variant = state.get("backpack")
	var backpack: Array = _as_array(backpack_value).duplicate(true)
	if backpack.is_empty():
		return {}

	var selected_uid_value: Variant = state.get("crafting_selected_item_uid")
	var selected_uid: String = ""
	if selected_uid_value != null:
		selected_uid = str(selected_uid_value)

	if selected_uid != "":
		for i: int in range(backpack.size()):
			if typeof(backpack[i]) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = Dictionary(backpack[i])
			if str(item.get("uid", "")) == selected_uid:
				return {"backpack": backpack, "index": i, "item": item}

	var cursor_value: Variant = state.get("inventory_cursor")
	var cursor: int = clampi(_to_int(cursor_value, 0), 0, backpack.size() - 1)
	if typeof(backpack[cursor]) == TYPE_DICTIONARY:
		return {"backpack": backpack, "index": cursor, "item": Dictionary(backpack[cursor])}

	return {}


static func _pay_cost(state: Object, cost: Dictionary) -> bool:
	var id: String = str(cost.get("currency", "shards"))
	var amount: int = _to_int(cost.get("amount", 0), 0)
	if amount <= 0:
		return true

	var key: String = "materials"
	var wallet: Dictionary = {}
	if typeof(state.get("materials")) == TYPE_DICTIONARY:
		wallet = state.get("materials")
	elif typeof(state.get("currency")) == TYPE_DICTIONARY:
		key = "currency"
		wallet = state.get("currency")
	else:
		wallet = {}

	if _to_int(wallet.get(id, 0), 0) < amount:
		return false

	wallet[id] = _to_int(wallet.get(id, 0), 0) - amount
	state.set(key, wallet)

	if key == "materials" and typeof(state.get("currency")) == TYPE_DICTIONARY:
		var currency: Dictionary = state.get("currency")
		if currency.has(id):
			currency[id] = wallet[id]
			state.set("currency", currency)
	elif key == "currency" and typeof(state.get("materials")) == TYPE_DICTIONARY:
		var materials: Dictionary = state.get("materials")
		if materials.has(id):
			materials[id] = wallet[id]
			state.set("materials", materials)

	return true


static func _wallet_text(state: Object) -> String:
	var wallet: Dictionary = {}
	if typeof(state.get("materials")) == TYPE_DICTIONARY:
		wallet = state.get("materials")
	elif typeof(state.get("currency")) == TYPE_DICTIONARY:
		wallet = state.get("currency")

	if wallet.is_empty():
		return "{}"

	var parts: Array[String] = []
	for key_value: Variant in wallet.keys():
		parts.append(str(key_value) + ": " + str(wallet[key_value]))
	return ", ".join(parts)


static func _cost_text(cost: Dictionary) -> String:
	if cost.is_empty():
		return "unavailable"
	return str(cost.get("amount", 0)) + " " + str(cost.get("currency", ""))


static func _action_title(action: String) -> String:
	match action:
		"seal":
			return "Seal Affix"
		"reforge":
			return "Reforge Values"
		"polish":
			return "Polish Quality"
		"upgrade":
			return "Upgrade Rarity"
		"remove":
			return "Remove Weakest Affix"
		_:
			return "Forge"


static func _action_description(action: String) -> String:
	match action:
		"seal":
			return "Adds one crafted affix if the item has crafted space."
		"reforge":
			return "Rerolls numeric values on existing affixes without changing the affix types."
		"polish":
			return "Improves quality. Quality scales implicit stats."
		"upgrade":
			return "Raises rarity and fills missing affix slots."
		"remove":
			return "Removes the lowest-weight non-crafted prefix/suffix."
		_:
			return ""


static func _action_success_text(action: String) -> String:
	match action:
		"seal":
			return "Affix sealed"
		"reforge":
			return "Values reforged"
		"polish":
			return "Quality improved"
		"upgrade":
			return "Rarity upgraded"
		"remove":
			return "Weakest affix removed"
		_:
			return "Crafted item"


static func _notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)


static func _rng(state: Object) -> RandomNumberGenerator:
	if state != null:
		var value: Variant = state.get("rng")
		if value != null and value is RandomNumberGenerator:
			return value as RandomNumberGenerator
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng


static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value
	return []


static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return roundi(value)
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return roundi(s.to_float())
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
