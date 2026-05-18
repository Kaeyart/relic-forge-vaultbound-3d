class_name RVCraftingSystem3D
extends RefCounted

static func can_temper(item: Dictionary) -> bool:
	return not item.is_empty() and str(item.get("rarity", "Normal")) == "Normal" and int(item.get("forge_potential", 0)) >= 2

static func can_alchemy(item: Dictionary) -> bool:
	return not item.is_empty() and str(item.get("rarity", "Normal")) == "Normal" and int(item.get("forge_potential", 0)) >= 5

static func can_scour(item: Dictionary) -> bool:
	return not item.is_empty() and str(item.get("rarity", "Normal")) != "Normal" and int(item.get("forge_potential", 0)) >= 1

static func ash_temper(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if not can_temper(item):
		return item
	var out: Dictionary = item.duplicate(true)
	out["rarity"] = "Magic"
	out["forge_potential"] = max(0, int(out.get("forge_potential", 0)) - 2)
	out["affixes"] = RVAffixDB3D.roll_affixes(out, "Magic", rng)
	out["stats"] = RVAffixDB3D.apply_affixes_to_stats(Dictionary(out.get("base_stats", {})), Array(out.get("affixes", [])))
	out["display_name"] = "Magic " + str(out.get("name", "Item"))
	return out

static func vault_alchemy(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if not can_alchemy(item):
		return item
	var out: Dictionary = item.duplicate(true)
	out["rarity"] = "Rare"
	out["forge_potential"] = max(0, int(out.get("forge_potential", 0)) - 5)
	out["affixes"] = RVAffixDB3D.roll_affixes(out, "Rare", rng)
	out["stats"] = RVAffixDB3D.apply_affixes_to_stats(Dictionary(out.get("base_stats", {})), Array(out.get("affixes", [])))
	out["display_name"] = "Rare " + str(out.get("name", "Item"))
	return out

static func scouring_ash(item: Dictionary) -> Dictionary:
	if not can_scour(item):
		return item
	var out: Dictionary = item.duplicate(true)
	out["rarity"] = "Normal"
	out["forge_potential"] = max(0, int(out.get("forge_potential", 0)) - 1)
	out["affixes"] = []
	out["stats"] = Dictionary(out.get("base_stats", {})).duplicate(true)
	out["display_name"] = str(out.get("name", "Item"))
	return out
