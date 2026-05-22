class_name RVClassDB3D
extends RefCounted

static func classes() -> Dictionary:
	return {
		"sorceress": {
			"id": "sorceress",
			"display_name": "Sorceress",
			"description": "Spellcaster archetype. Scales spells, mana, Spirit, projectiles, and elemental ailments.",
			"attributes": {"strength": 8, "dexterity": 10, "intelligence": 18},
			"tags": ["caster", "spell", "elemental", "mana", "spirit"],
			"rules": ["class:sorceress"],
			"stats": {"Spell Damage": 0.12, "Maximum Mana": 24.0, "Cast Speed": 0.04},
			"starting_tree_region": "north_arcane",
			"ascendancies": ["blood_mage", "elementalist", "chronomancer"],
			"recommended_weapons": ["wand", "focus", "staff"],
			"starter_build": {
				"active": "fireball",
				"supports": ["split_projectile", "ignition"],
				"spirit": "ember_pact",
				"weapon_hint": "Ash Wand"
			}
		},
		"warrior": {
			"id": "warrior",
			"display_name": "Warrior",
			"description": "Heavy melee archetype. Scales maces, armor, slam area, stun, and brutal physical hits.",
			"attributes": {"strength": 18, "dexterity": 9, "intelligence": 8},
			"tags": ["melee", "attack", "mace", "armor", "slam", "stun"],
			"rules": ["class:warrior"],
			"stats": {"Attack Damage": 0.12, "Maximum Life": 28.0, "Armor": 34.0, "Stun Buildup": 0.10},
			"starting_tree_region": "west_martial",
			"ascendancies": ["titan", "juggernaut", "warbringer"],
			"recommended_weapons": ["mace", "two_handed_mace", "shield"],
			"starter_build": {
				"active": "heavy_slam",
				"supports": ["brutality", "focused_area"],
				"spirit": "iron_skin",
				"weapon_hint": "Iron Mace"
			}
		},
		"huntress": {
			"id": "huntress",
			"display_name": "Huntress",
			"description": "Projectile archetype. Scales bows, marks, speed, evasion, crit windows, pierce, chain, and traps.",
			"attributes": {"strength": 9, "dexterity": 18, "intelligence": 9},
			"tags": ["bow", "projectile", "evasion", "mark", "trap", "crit"],
			"rules": ["class:huntress"],
			"stats": {"Projectile Damage": 0.12, "Movement Speed": 0.04, "Critical Chance": 0.04, "Evasion": 24.0},
			"starting_tree_region": "east_hunt",
			"ascendancies": ["deadeye", "warden", "nightstalker"],
			"recommended_weapons": ["bow", "quiver"],
			"starter_build": {
				"active": "piercing_shot",
				"supports": ["split_projectile", "chain_current"],
				"spirit": "predators_focus",
				"weapon_hint": "Vault Bow"
			}
		}
	}

static func has_class(class_id: String) -> bool:
	return classes().has(class_id)

static func class_data(class_id: String) -> Dictionary:
	var all: Dictionary = classes()
	if all.has(class_id):
		return Dictionary(all[class_id]).duplicate(true)
	return Dictionary(all["sorceress"]).duplicate(true)

static func class_ids() -> Array[String]:
	return ["sorceress", "warrior", "huntress"]

static func class_bundle(class_id: String) -> Dictionary:
	var data: Dictionary = class_data(class_id)
	return {
		"stats": Dictionary(data.get("stats", {})).duplicate(true),
		"rules": Array(data.get("rules", [])).duplicate(true),
		"tags": Array(data.get("tags", [])).duplicate(true),
	}
