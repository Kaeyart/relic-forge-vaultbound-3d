extends RefCounted
class_name RVClassDB3D

const CLASSES: Dictionary = {
	"sorceress": {
		"id": "sorceress",
		"display_name": "Sorceress",
		"fantasy": "Spellcaster who scales elemental damage, mana, Spirit, and dangerous magical tradeoffs.",
		"attributes": {"Strength": 8.0, "Dexterity": 10.0, "Intelligence": 18.0},
		"stats": {"Maximum Mana": 25.0, "Spell Damage": 10.0, "Cast Speed": 0.04},
		"rules": ["class:sorceress", "weapon_bias:wand_focus", "skill_bias:spell"],
		"tree_regions": ["sorc_fire", "sorc_storm", "sorc_mana_time"],
		"recommended_lanes": [
			{"id": "fire_projectile", "name": "Fire Projectile Caster", "tags": ["fire", "spell", "projectile", "ignite"]},
			{"id": "storm_chain", "name": "Storm Chain Caster", "tags": ["lightning", "spell", "chain", "shock"]},
			{"id": "mana_time", "name": "Mana-Time Caster", "tags": ["mana", "spirit", "cooldown", "echo"]}
		],
		"ascendancies": ["blood_mage", "elementalist", "chronomancer"],
		"starter": {
			"weapon_base": "ash_wand",
			"offhand_base": "focus",
			"active_gems": ["fireball", "storm_lance"],
			"support_gems": ["split_projectile", "ignition", "chain_current"],
			"spirit_gems": ["ember_pact"],
			"recommended_ascendancy": "elementalist"
		}
	},
	"warrior": {
		"id": "warrior",
		"display_name": "Warrior",
		"fantasy": "Heavy melee fighter built around mace impacts, armor, stun, rage, and brutal commitment.",
		"attributes": {"Strength": 18.0, "Dexterity": 8.0, "Intelligence": 8.0},
		"stats": {"Maximum Life": 28.0, "Armor": 20.0, "Physical Damage": 10.0},
		"rules": ["class:warrior", "weapon_bias:mace", "skill_bias:slam"],
		"tree_regions": ["war_slam", "war_armor", "war_rage"],
		"recommended_lanes": [
			{"id": "titan_slam", "name": "Titan Slammer", "tags": ["mace", "slam", "stun", "aftershock"]},
			{"id": "juggernaut_tank", "name": "Juggernaut Tank", "tags": ["armor", "block", "ward", "mitigation"]},
			{"id": "warbringer_rage", "name": "Warbringer Rage Slam", "tags": ["rage", "warcry", "shockwave", "physical"]}
		],
		"ascendancies": ["titan", "juggernaut", "warbringer"],
		"starter": {
			"weapon_base": "iron_mace",
			"offhand_base": "shield",
			"active_gems": ["heavy_slam", "ground_rupture"],
			"support_gems": ["brutality", "focused_area", "greater_area"],
			"spirit_gems": ["iron_skin"],
			"recommended_ascendancy": "titan"
		}
	},
	"huntress": {
		"id": "huntress",
		"display_name": "Huntress",
		"fantasy": "Mobile bow/projectile class focused on marks, traps, distance, precision, bleed, and execution.",
		"attributes": {"Strength": 8.0, "Dexterity": 18.0, "Intelligence": 10.0},
		"stats": {"Projectile Damage": 10.0, "Attack Speed": 0.04, "Movement Speed": 0.03},
		"rules": ["class:huntress", "weapon_bias:bow_quiver", "skill_bias:projectile"],
		"tree_regions": ["hunt_projectile", "hunt_mark", "hunt_trap"],
		"recommended_lanes": [
			{"id": "deadeye_projectile", "name": "Deadeye Projectile", "tags": ["bow", "projectile", "chain", "farshot"]},
			{"id": "warden_trap", "name": "Warden Trap Control", "tags": ["trap", "snare", "slow", "control"]},
			{"id": "nightstalker_bleed", "name": "Nightstalker Bleed/Crit", "tags": ["mark", "crit", "bleed", "execute"]}
		],
		"ascendancies": ["deadeye", "warden", "nightstalker"],
		"starter": {
			"weapon_base": "vault_bow",
			"offhand_base": "quiver",
			"active_gems": ["piercing_shot", "rain_of_arrows"],
			"support_gems": ["split_projectile", "chain_current", "bloodletting"],
			"spirit_gems": ["predators_focus"],
			"recommended_ascendancy": "deadeye"
		}
	}
}

static func class_ids() -> Array:
	return CLASSES.keys()

static func class_data(class_id: String) -> Dictionary:
	if CLASSES.has(class_id):
		return Dictionary(CLASSES[class_id]).duplicate(true)
	return Dictionary(CLASSES["sorceress"]).duplicate(true)

static func display_name(class_id: String) -> String:
	return str(class_data(class_id).get("display_name", class_id.capitalize()))

static func class_bundle(class_id: String) -> Dictionary:
	var data: Dictionary = class_data(class_id)
	return {
		"stats": Dictionary(data.get("stats", {})).duplicate(true),
		"rules": Array(data.get("rules", [])).duplicate(true),
		"attributes": Dictionary(data.get("attributes", {})).duplicate(true),
	}

static func ascendancy_ids(class_id: String) -> Array:
	return Array(class_data(class_id).get("ascendancies", []))

static func starter_bundle(class_id: String) -> Dictionary:
	return Dictionary(class_data(class_id).get("starter", {})).duplicate(true)

static func recommended_lanes(class_id: String) -> Array:
	return Array(class_data(class_id).get("recommended_lanes", [])).duplicate(true)

static func is_valid_class(class_id: String) -> bool:
	return CLASSES.has(class_id)
