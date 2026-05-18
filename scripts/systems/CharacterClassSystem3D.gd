class_name RVCharacterClassSystem3D
extends RefCounted

static func class_data(class_id: String) -> Dictionary:
	return Dictionary(classes().get(class_id, classes()["sorceress"])).duplicate(true)

static func classes() -> Dictionary:
	return {
		"sorceress": {"name": "Sorceress", "description": "Spell, fire, lightning, mana.", "skills": ["fireball", "storm_lance", "void_rift"]},
		"warden": {"name": "Warden", "description": "Melee, armor, bleed, sustain.", "skills": ["arc_slash", "fireball"]},
		"voidbinder": {"name": "Voidbinder", "description": "Void, curse, sacrifice.", "skills": ["void_rift", "fireball"]},
		"machinist": {"name": "Machinist", "description": "Traps, projectiles, devices.", "skills": ["fireball", "storm_lance"]}
	}
