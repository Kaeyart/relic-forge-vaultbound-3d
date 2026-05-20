extends RefCounted
class_name RVMapThreatSystem3D

static func active_tier(state: Object) -> int:
	if state == null:
		return 1
	var value: Variant = state.get("active_map_tier")
	if value == null:
		value = state.get("map_tier")
	if value == null:
		var active_map: Variant = state.get("active_map_item")
		if typeof(active_map) == TYPE_DICTIONARY:
			var map_data: Dictionary = active_map
			value = map_data.get("tier", map_data.get("map_tier", 1))
	return clampi(_to_int(value, 1), 1, 15)


static func profile_for_tier(tier_value: int) -> Dictionary:
	var tier: int = clampi(tier_value, 1, 15)
	if tier >= 10:
		return {"tier": tier, "band": "rare", "magic_pack_chance": 0.68, "magic_pack_min": 4, "magic_pack_max": 7, "rare_chance": 0.55, "rare_max": 2, "rare_mod_count": 5, "normal_xp_mult": 1.35, "magic_xp_mult": 2.05, "rare_xp_mult": 5.25}
	if tier >= 6:
		return {"tier": tier, "band": "magic", "magic_pack_chance": 0.56, "magic_pack_min": 3, "magic_pack_max": 6, "rare_chance": 0.35, "rare_max": 1, "rare_mod_count": 4, "normal_xp_mult": 1.18, "magic_xp_mult": 1.90, "rare_xp_mult": 4.65}
	return {"tier": tier, "band": "white", "magic_pack_chance": 0.42, "magic_pack_min": 2, "magic_pack_max": 5, "rare_chance": 0.20, "rare_max": 1, "rare_mod_count": 3, "normal_xp_mult": 1.0, "magic_xp_mult": 1.75, "rare_xp_mult": 4.0}


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


static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
