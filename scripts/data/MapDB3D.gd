class_name RVMapDB3D
extends RefCounted

const MapDifficultySystemScript := preload("res://scripts/systems/MapDifficultySystem3D.gd")

static func map_bases() -> Dictionary:
	return {
		"ash_vault": {"name":"Ash Vault", "tier":1, "level":1, "layout":"box_blockers"},
		"chain_crossing": {"name":"Chain Crossing", "tier":2, "level":3, "layout":"cross"},
		"cinder_ring": {"name":"Cinder Ring", "tier":3, "level":5, "layout":"ring"},
		"brass_ossuary": {"name":"Brass Ossuary", "tier":5, "level":8, "layout":"box_blockers"},
		"furnace_court": {"name":"Furnace Court", "tier":8, "level":12, "layout":"ring"},
		"penitent_gate": {"name":"Penitent Gate", "tier":11, "level":16, "layout":"cross"},
		"black_ledger": {"name":"Black Ledger", "tier":14, "level":20, "layout":"box_blockers"}
	}


static func make_map_item(base_id: String, tier: int, rng: RandomNumberGenerator, rarity: String = "normal") -> Dictionary:
	var bases: Dictionary = map_bases()
	var base: Dictionary = Dictionary(bases.get(base_id, bases["ash_vault"])).duplicate(true)
	var safe_tier: int = clampi(max(tier, int(base.get("tier", 1))), 1, 15)
	var safe_rarity: String = rarity.strip_edges().to_lower()
	if safe_rarity != "magic" and safe_rarity != "rare":
		safe_rarity = "normal"

	var map_item: Dictionary = {
		"uid":"map_" + str(Time.get_ticks_usec()) + "_" + str(rng.randi()),
		"base_id":base_id,
		"display_name":str(base.get("name", base_id)),
		"tier":safe_tier,
		"map_tier":safe_tier,
		"map_level":max(1, int(base.get("level", 1)) + max(0, safe_tier - int(base.get("tier", 1)))),
		"layout":str(base.get("layout", "box_blockers")),
		"rarity":safe_rarity,
		"mods":MapDifficultySystemScript.roll_mods_for_rarity(safe_rarity, safe_tier, rng),
		"entries":6,
		"kind":"map",
		"item_kind":"map",
		"category":"map",
		"slot":"map",
		"tags":["map"]
	}
	return MapDifficultySystemScript.normalize_map_item(map_item, null)


static func make_magic_map_item(base_id: String, tier: int, rng: RandomNumberGenerator) -> Dictionary:
	return make_map_item(base_id, tier, rng, "magic")


static func make_rare_map_item(base_id: String, tier: int, rng: RandomNumberGenerator) -> Dictionary:
	return make_map_item(base_id, tier, rng, "rare")


static func describe(map_item: Dictionary) -> String:
	return MapDifficultySystemScript.describe_map(map_item, null)
