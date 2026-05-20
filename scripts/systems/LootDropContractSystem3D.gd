extends RefCounted
class_name RVLootDropContractSystem3D

const MapThreatSystemScript := preload("res://scripts/systems/MapThreatSystem3D.gd")

static func roll_drops_for_enemy(enemy: Object, state: Object) -> Array:
	var tier: int = MapThreatSystemScript.active_tier(state)
	var rarity: String = "normal"
	if enemy != null and enemy.has_meta("rv_enemy_rarity"):
		rarity = str(enemy.get_meta("rv_enemy_rarity"))

	var drops: Array = []
	var base_chance: float = 0.10
	if rarity == "magic":
		base_chance = 0.28
	elif rarity == "rare":
		base_chance = 1.0

	if randf() <= base_chance:
		drops.append(_roll_gear_drop(rarity, tier))
	if rarity == "magic" and randf() < 0.35:
		drops.append(_currency_drop(tier))
	if rarity == "rare":
		drops.append(_currency_drop(tier))
		if randf() < 0.42:
			drops.append(_gem_drop(tier))
		if tier >= 3 and randf() < 0.28:
			drops.append(_map_drop(tier))
		if tier >= 6 and randf() < 0.22:
			drops.append(_crystal_drop(tier))
	return drops


static func _roll_gear_drop(enemy_rarity: String, tier: int) -> Dictionary:
	var rarity: String = "normal"
	var roll: float = randf()
	if enemy_rarity == "rare":
		if roll < 0.08:
			rarity = "unique"
		elif roll < 0.58:
			rarity = "rare"
		else:
			rarity = "magic"
	elif enemy_rarity == "magic":
		rarity = "magic" if roll < 0.72 else "rare"
	else:
		rarity = "normal" if roll < 0.72 else "magic"

	var slots: Array = ["helm", "chest", "gloves", "boots", "weapon", "offhand", "amulet", "ring"]
	var slot: String = str(slots[randi_range(0, slots.size() - 1)])
	return {"kind": "gear", "slot": slot, "rarity": rarity, "name": rarity.capitalize() + " " + slot.capitalize(), "item_level": max(1, tier)}


static func _currency_drop(tier: int) -> Dictionary:
	return {"kind": "currency", "rarity": "normal", "name": "Forge Shard", "stack": randi_range(1, max(1, 1 + tier / 3))}


static func _gem_drop(tier: int) -> Dictionary:
	var types: Array = ["active", "support", "spirit"]
	var gem_type: String = str(types[randi_range(0, types.size() - 1)])
	return {"kind": "gem", "gem_type": gem_type, "rarity": "magic", "name": gem_type.capitalize() + " Gem", "level": 1, "quality": 0, "item_level": tier}


static func _map_drop(tier: int) -> Dictionary:
	return {"kind": "map", "rarity": "normal" if tier < 6 else ("magic" if tier < 10 else "rare"), "name": "Unopened Map", "tier": clampi(tier + randi_range(-1, 1), 1, 15)}


static func _crystal_drop(tier: int) -> Dictionary:
	return {"kind": "crystal", "rarity": "rare", "name": "Frozen Monster Crystal", "tier": tier}
