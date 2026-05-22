class_name RVProgressionValidationSystem3D
extends RefCounted

const PassiveTreeSystemScript := preload("res://scripts/systems/PassiveTreeSystem3D.gd")
const AscendancySystemScript := preload("res://scripts/systems/AscendancySystem3D.gd")
const AtlasPassiveSystemScript := preload("res://scripts/systems/AtlasPassiveSystem3D.gd")

static func report(state: Object) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Progression Validation")
	if state == null:
		lines.append("No state.")
		return "\n".join(lines)
	lines.append("Class: " + str(_state_get(state, "class_id", "?")) + " / " + str(_state_get(state, "class_display_name", "?")))
	lines.append("Passive Points: " + str(_state_get(state, "passive_points", 0)))
	lines.append("Ascendancy Points: " + str(_state_get(state, "ascendancy_points", 0)))
	lines.append("Atlas Passive Points: " + str(_state_get(state, "atlas_passive_points", 0)))
	if PassiveTreeSystemScript != null:
		lines.append(PassiveTreeSystemScript.validation_report(state))
	if AscendancySystemScript != null:
		lines.append(AscendancySystemScript.validation_report(state))
	lines.append(AtlasPassiveSystemScript.validation_report(state))
	var unknown_stats: Array[String] = _unknown_stat_report(state)
	if unknown_stats.is_empty():
		lines.append("Stats: OK")
	else:
		lines.append("Unknown/possibly unwired stats: " + ", ".join(unknown_stats))
	return "\n".join(lines)


static func _unknown_stat_report(state: Object) -> Array[String]:
	var known: Dictionary = {}
	for k: String in ["Maximum Life", "Maximum Mana", "Maximum Spirit", "Armor", "Movement Speed", "Fire Damage", "Lightning Damage", "Void Damage", "Physical Damage", "Spell Damage", "Attack Damage", "Projectile Damage", "Area Damage", "Melee Damage", "Cast Speed", "Attack Speed", "Critical Chance", "Critical Multiplier", "Ignite Chance", "Shock Chance", "Bleed Chance", "Chain Bonus", "Extra Projectiles", "Projectile Speed", "Area Radius", "Mana Cost", "Mana Cost Reduction", "Life Leech", "Mana Leech", "Block Chance", "Ward", "Runic Ward", "Item Quantity", "Item Rarity", "Waystone Drop Chance", "Tablet Drop Chance", "Uncut Gem Chance", "Forge Material Chance", "Boss Relic Chance"]:
		known[k] = true
	var out: Array[String] = []
	var stats_value: Variant = state.get("build_stats")
	if typeof(stats_value) == TYPE_DICTIONARY:
		for key: Variant in Dictionary(stats_value).keys():
			var stat_key: String = str(key)
			if not known.has(stat_key) and not out.has(stat_key):
				out.append(stat_key)
	return out


static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value
