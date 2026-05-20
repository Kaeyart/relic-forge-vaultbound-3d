extends RefCounted
class_name RVMapThreatSystem3D

const MapDifficultySystemScript := preload("res://scripts/systems/MapDifficultySystem3D.gd")

static func active_tier(state: Object) -> int:
	return MapDifficultySystemScript.active_tier(state)


static func profile_for_tier(tier_value: int) -> Dictionary:
	return MapDifficultySystemScript.threat_profile(null, {"tier":tier_value, "rarity":"normal", "mods":[]})


static func profile_for_state(state: Object) -> Dictionary:
	return MapDifficultySystemScript.threat_profile(state)


static func rare_modifier_count_for_tier(tier_value: int) -> int:
	var tier: int = clampi(tier_value, 1, 15)
	if tier >= 10:
		return 5
	if tier >= 6:
		return 4
	return 3


static func band_label(tier_value: int) -> String:
	var profile: Dictionary = profile_for_tier(tier_value)
	return str(profile.get("band", "white")).capitalize() + " Map Tier " + str(profile.get("tier", 1))
