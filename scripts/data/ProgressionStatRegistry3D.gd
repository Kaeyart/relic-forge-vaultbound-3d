extends RefCounted
class_name RVProgressionStatRegistry3D

const KNOWN_STATS: Array[String] = [
	"Strength", "Dexterity", "Intelligence",
	"Maximum Life", "Maximum Mana", "Maximum Spirit", "Spirit Reservation Efficiency",
	"Armor", "Block Chance", "Ward", "Runic Ward", "Physical Reduction", "Elemental Mitigation",
	"Fire Resistance", "Lightning Resistance", "Void Resistance",
	"Fire Damage", "Lightning Damage", "Void Damage", "Physical Damage",
	"Spell Damage", "Attack Damage", "Projectile Damage", "Area Damage", "Melee Damage", "Slam Damage", "Bow Damage",
	"Cast Speed", "Attack Speed", "Movement Speed", "Critical Chance", "Critical Multiplier",
	"Ignite Chance", "Shock Chance", "Bleed Chance", "Poison Chance", "Ailment Damage",
	"Chain Bonus", "Pierce Chance", "Projectile Speed", "Trap Damage", "Trap Arming Speed",
	"Stun Buildup", "Stun Damage", "Rage Gain", "Warcry Effect", "Aftershock Damage",
	"Mana Cost", "Life Cost", "Life Leech", "Mana Leech", "Life on Hit", "Mana on Hit",
	"Item Rarity", "Item Quantity", "Forge Potential Bonus", "Rune Effect", "Essence Effect",
]

const KNOWN_RULE_PREFIXES: Array[String] = [
	"class:", "asc:", "passive:", "keystone:", "weapon_bias:", "skill_bias:",
	"blood_", "elementalist_", "chrono_", "titan_", "juggernaut_", "warbringer_",
	"deadeye_", "warden_", "nightstalker_", "atlas_", "forge_", "map_", "item_",
]

static func normalize_stat_key(raw_key: String) -> String:
	match raw_key:
		"str", "strength":
			return "Strength"
		"dex", "dexterity":
			return "Dexterity"
		"int", "intelligence":
			return "Intelligence"
		"life", "max_life", "maximum_life":
			return "Maximum Life"
		"mana", "max_mana", "maximum_mana":
			return "Maximum Mana"
		"spirit", "max_spirit", "maximum_spirit":
			return "Maximum Spirit"
		"armor":
			return "Armor"
		"fire_damage":
			return "Fire Damage"
		"lightning_damage":
			return "Lightning Damage"
		"void_damage":
			return "Void Damage"
		"physical_damage":
			return "Physical Damage"
		"spell_damage":
			return "Spell Damage"
		"attack_damage":
			return "Attack Damage"
		"projectile_damage":
			return "Projectile Damage"
		"area_damage":
			return "Area Damage"
		"movement_speed":
			return "Movement Speed"
		"cast_speed":
			return "Cast Speed"
		"attack_speed":
			return "Attack Speed"
		_:
			return raw_key.replace("_", " ").capitalize()

static func is_known_stat(stat_key: String) -> bool:
	return KNOWN_STATS.has(stat_key) or KNOWN_STATS.has(normalize_stat_key(stat_key))

static func is_known_rule(rule: String) -> bool:
	if rule == "":
		return false
	for prefix: String in KNOWN_RULE_PREFIXES:
		if rule.begins_with(prefix):
			return true
	return false
