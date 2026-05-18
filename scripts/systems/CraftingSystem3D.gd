class_name RVCraftingSystem3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")

static func craft_selected(state: Object, action: String) -> bool:
	if state == null: return false
	var backpack: Array = Array(state.get("backpack"))
	var index: int = int(state.get("inventory_cursor"))
	if backpack.is_empty() or index < 0 or index >= backpack.size():
		state.call("add_notice", "No item selected")
		return false
	var item: Dictionary = Dictionary(backpack[index])
	if item.is_empty(): return false
	var materials: Dictionary = Dictionary(state.get("materials"))
	var cost_id: String = "embers"
	var cost: int = 2
	if action == "seal":
		cost_id = "shards"; cost = 2
	elif action == "reforge":
		cost_id = "embers"; cost = 6
	elif action == "polish":
		cost_id = "runes"; cost = 1
	if int(materials.get(cost_id, 0)) < cost:
		state.call("add_notice", "Need " + str(cost) + " " + cost_id)
		return false
	if int(item.get("forge_potential", 0)) <= 0:
		state.call("add_notice", "No forge potential")
		return false
	materials[cost_id] = int(materials.get(cost_id, 0)) - cost
	state.set("materials", materials)
	if action == "seal":
		item = ItemDBScript.add_random_crafted_mod(item, state.get("rng"))
	elif action == "reforge":
		item = ItemDBScript.make_item(str(item.get("base_id", "iron_sword")), int(item.get("item_level", 1)), "rare", state.get("rng"))
	elif action == "polish":
		item["forge_potential"] = max(0, int(item.get("forge_potential", 0)) - 1)
		var stats: Dictionary = Dictionary(item.get("implicit_stats", {}))
		for key_value: Variant in stats.keys():
			stats[key_value] = float(stats[key_value]) * 1.08
		item["implicit_stats"] = stats
		item["total_stats"] = ItemDBScript.total_stats(item)
	backpack[index] = item
	state.set("backpack", backpack)
	state.call("recompute_stats")
	state.call("add_notice", "Crafted item")
	return true

static func panel_text(state: Object) -> String:
	if state == null: return "Crafting unavailable."
	var text: String = "FORGE\n"
	text += "1 Seal: add crafted mod (2 shards)\n2 Reforge: reroll as rare (6 embers)\n3 Polish: improve implicit (1 rune)\n\n"
	text += "Materials: " + str(state.get("materials")) + "\n\n"
	var item: Dictionary = state.call("selected_backpack_item")
	text += ItemDBScript.item_detail(item)
	return text
