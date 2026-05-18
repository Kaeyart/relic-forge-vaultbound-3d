class_name RVMapDB3D
extends RefCounted

static func map_bases() -> Dictionary:
	return {
		"ash_vault":{"name":"Ash Vault", "tier":1, "level":1, "layout":"box_blockers"},
		"chain_crossing":{"name":"Chain Crossing", "tier":2, "level":3, "layout":"cross"},
		"cinder_ring":{"name":"Cinder Ring", "tier":3, "level":5, "layout":"ring"}
	}

static func make_map_item(base_id: String, tier: int, rng: RandomNumberGenerator) -> Dictionary:
	var base: Dictionary = Dictionary(map_bases().get(base_id, map_bases()["ash_vault"])).duplicate(true)
	var mods: Array[Dictionary] = []
	if rng.randf() < 0.45:
		mods.append({"id":"pack_size", "name":"Crowded", "stats":{"Pack Size":0.18,"Item Quantity":0.08}})
	if rng.randf() < 0.30:
		mods.append({"id":"elite_presence", "name":"Commanded", "stats":{"Elite Chance":0.15,"Item Rarity":0.10}})
	if rng.randf() < 0.22:
		mods.append({"id":"boss_reward", "name":"Hoarded", "stats":{"Boss Rewards":1.0}})
	return {
		"uid":"map_" + str(Time.get_ticks_usec()) + "_" + str(rng.randi()),
		"base_id":base_id,
		"display_name":str(base.get("name", base_id)),
		"tier":max(1, tier),
		"map_level":max(1, int(base.get("level", 1)) + max(0, tier - 1)),
		"layout":str(base.get("layout", "box_blockers")),
		"mods":mods,
		"entries":6
	}

static func describe(map_item: Dictionary) -> String:
	if map_item.is_empty(): return "No map selected."
	var text: String = str(map_item.get("display_name", "Map")) + " · Tier " + str(map_item.get("tier", 1)) + " · Level " + str(map_item.get("map_level", 1)) + "\n"
	text += "Entries: " + str(map_item.get("entries", 6)) + "\n"
	for m: Dictionary in Array(map_item.get("mods", [])):
		text += "  " + str(m.get("name", "Map Mod")) + "\n"
	return text
