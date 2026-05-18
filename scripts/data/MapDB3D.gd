class_name RVMapDB3D
extends RefCounted

static func make_test_map(tier: int = 1) -> Dictionary:
	return {
		"id": "ash_vault_t" + str(tier),
		"name": "Ash Vault",
		"tier": max(1, tier),
		"level": max(1, tier),
		"rarity": "normal",
		"layout": "ash_vault_cross",
		"mods": []
	}

static func describe(map_item: Dictionary) -> String:
	if map_item.is_empty():
		return "No map"
	return str(map_item.get("name", "Map")) + " T" + str(int(map_item.get("tier", 1))) + " Lv" + str(int(map_item.get("level", 1)))
