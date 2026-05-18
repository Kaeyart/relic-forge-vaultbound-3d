class_name RVCraftingSystem3D
extends RefCounted

static func ash_temper(state: Object, index: int) -> bool:
	return _upgrade_rarity(state, index, "magic", 2, "Ash Temper")

static func vault_alchemy(state: Object, index: int) -> bool:
	return _upgrade_rarity(state, index, "rare", 5, "Vault Alchemy")

static func _upgrade_rarity(state: Object, index: int, rarity: String, cost: int, verb: String) -> bool:
	if state == null:
		return false
	var backpack: Array = Array(state.get("backpack"))
	if index < 0 or index >= backpack.size():
		return false
	var materials: Dictionary = Dictionary(state.get("materials"))
	if int(materials.get("embers", 0)) < cost:
		if state.has_method("add_notice"):
			state.call("add_notice", "Need embers")
		return false
	var item: Dictionary = Dictionary(backpack[index])
	if int(item.get("forge_potential", 0)) <= 0:
		return false
	materials["embers"] = int(materials.get("embers", 0)) - cost
	item["rarity"] = rarity
	item["name"] = str(item.get("name", "Item")).replace("Tempered ", "").replace("Vaultforged ", "")
	item["name"] = ("Tempered " if rarity == "magic" else "Vaultforged ") + str(item["name"])
	item["forge_potential"] = max(0, int(item.get("forge_potential", 0)) - cost)
	backpack[index] = item
	state.set("materials", materials)
	state.set("backpack", backpack)
	if state.has_method("add_notice"):
		state.call("add_notice", verb + ": " + str(item.get("name", "item")))
	return true
