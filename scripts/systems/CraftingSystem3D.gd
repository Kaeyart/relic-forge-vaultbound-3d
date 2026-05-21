class_name RVCraftingSystem3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")

static func craft_selected(state: Object, action: String) -> bool:
	if state == null:
		return false
	var backpack: Array = Array(state.get("backpack"))
	var index: int = int(state.get("inventory_cursor"))
	if backpack.is_empty() or index < 0 or index >= backpack.size():
		_notice(state, "No item selected")
		return false
	var item: Dictionary = Dictionary(backpack[index]).duplicate(true)
	if item.is_empty() or str(item.get("item_kind", item.get("kind", ""))) in ["map", "active_gem", "support_gem", "spirit_gem"]:
		_notice(state, "Select equipment")
		return false
	var rarity: String = str(item.get("rarity", "normal")).to_lower()
	var materials: Dictionary = Dictionary(state.get("materials"))
	var cost_id: String = "embers"
	var cost: int = 2
	var result_text: String = "Crafted item"

	match action:
		"seal":
			cost_id = "shards"
			cost = 2
			if _crafted_count(item) >= 2:
				_notice(state, "Crafted mod limit reached")
				return false
		"reforge":
			cost_id = "embers"
			cost = 7
			if rarity == "unique":
				_notice(state, "Cannot reforge uniques")
				return false
		"polish":
			cost_id = "runes"
			cost = 1
			if int(item.get("quality", 0)) >= 20:
				_notice(state, "Quality already capped")
				return false
		_:
			_notice(state, "Unknown craft")
			return false

	if int(materials.get(cost_id, 0)) < cost:
		_notice(state, "Need " + str(cost) + " " + cost_id)
		return false
	if int(item.get("forge_potential", 0)) <= 0:
		_notice(state, "No forge potential")
		return false

	materials[cost_id] = int(materials.get(cost_id, 0)) - cost
	state.set("materials", materials)

	if action == "seal":
		item = ItemDBScript.add_random_crafted_mod(item, state.get("rng"))
		result_text = "Sealed a crafted modifier"
	elif action == "reforge":
		item = ItemDBScript.reforge_item(item, state.get("rng"))
		result_text = "Reforged as rare"
	elif action == "polish":
		item = ItemDBScript.polish_item(item)
		result_text = "Polished item quality"

	backpack[index] = item
	state.set("backpack", backpack)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	_notice(state, result_text)
	return true

static func panel_text(state: Object) -> String:
	if state == null:
		return "Crafting unavailable."
	var text: String = "FORGE\n"
	text += "1 Seal: add crafted modifier (2 shards, costs forge potential)\n"
	text += "2 Reforge: reroll selected non-unique as rare (7 embers)\n"
	text += "3 Polish: +4% item quality, up to +20% (1 rune)\n\n"
	text += "Materials: " + str(state.get("materials")) + "\n\n"
	var item: Dictionary = state.call("selected_backpack_item")
	text += ItemDBScript.item_detail(item)
	return text

static func _crafted_count(item: Dictionary) -> int:
	return Array(item.get("crafted_mods", [])).size()

static func _notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)
