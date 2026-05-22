extends RefCounted
class_name RVGemDB3D

const ACTIVE_ORDER: Array[String] = [
	"fireball", "ember_mine", "storm_lance", "chain_spark", "arc_slash", "void_rift",
	"blood_cleave", "bone_spear", "ash_nova", "shield_burst", "infernal_step", "furnace_totem"
]

const SUPPORT_ORDER: Array[String] = [
	"split_projectile", "chain_current", "ignition", "focused_area", "wild_spread", "spell_echo",
	"molten_catalyst", "arcane_dampener", "chained_fury", "burning_focus", "brutality",
	"bloodletting", "controlled_power", "greater_area", "life_leech"
]

const SPIRIT_ORDER: Array[String] = [
	"clarity", "vitality", "iron_skin", "ember_pact", "storm_rhythm", "void_tithe",
	"revenant_guard", "execution_focus"
]

const ACTIVE_DATA: Dictionary = {
	"fireball": {"name": "Fireball", "tags": ["spell", "projectile", "fire", "hit", "area"], "damage": 28.0, "mana_cost": 10},
	"ember_mine": {"name": "Ember Mine", "tags": ["mine", "fire", "area", "hit"], "damage": 42.0, "mana_cost": 12},
	"storm_lance": {"name": "Storm Lance", "tags": ["spell", "projectile", "lightning", "hit"], "damage": 22.0, "mana_cost": 9},
	"chain_spark": {"name": "Chain Spark", "tags": ["spell", "projectile", "lightning", "chain", "hit"], "damage": 18.0, "mana_cost": 8},
	"arc_slash": {"name": "Arc Slash", "tags": ["attack", "melee", "physical", "hit"], "damage": 34.0, "mana_cost": 6},
	"void_rift": {"name": "Void Rift", "tags": ["spell", "area", "void", "duration", "hit"], "damage": 30.0, "mana_cost": 14},
	"blood_cleave": {"name": "Blood Cleave", "tags": ["attack", "melee", "physical", "bleed", "hit"], "damage": 46.0, "mana_cost": 8},
	"bone_spear": {"name": "Bone Spear", "tags": ["spell", "projectile", "physical", "hit"], "damage": 26.0, "mana_cost": 10},
	"ash_nova": {"name": "Ash Nova", "tags": ["spell", "area", "fire", "hit"], "damage": 24.0, "mana_cost": 11},
	"shield_burst": {"name": "Shield Burst", "tags": ["attack", "area", "physical", "guard", "hit"], "damage": 28.0, "mana_cost": 7},
	"infernal_step": {"name": "Infernal Step", "tags": ["movement", "fire", "area"], "damage": 18.0, "mana_cost": 12},
	"furnace_totem": {"name": "Furnace Totem", "tags": ["totem", "fire", "area"], "damage": 20.0, "mana_cost": 16},
}

const SUPPORT_DATA: Dictionary = {
	"split_projectile": {"name": "Split Projectile", "requires_any": ["projectile"], "tags": ["projectile"], "extra_projectiles": 2, "mana_cost_more": 0.15},
	"chain_current": {"name": "Chain Current", "requires_any": ["projectile", "lightning"], "tags": ["chain", "lightning"], "chain": 2, "mana_cost_more": 0.20},
	"ignition": {"name": "Ignition", "requires_any": ["fire", "hit"], "tags": ["fire"], "ignite_chance": 0.35},
	"focused_area": {"name": "Focused Area", "requires_any": ["area"], "tags": ["area"], "area_mult": -0.20, "damage_more": 0.25},
	"wild_spread": {"name": "Wild Spread", "requires_any": ["area", "projectile"], "tags": ["area", "projectile"], "area_mult": 0.35, "damage_more": -0.10},
	"spell_echo": {"name": "Spell Echo", "requires_any": ["spell"], "tags": ["spell"], "repeat": 1, "mana_cost_more": 0.25},
	"molten_catalyst": {"name": "Molten Catalyst", "requires_any": ["fire"], "tags": ["fire"], "damage_more": 0.20},
	"arcane_dampener": {"name": "Arcane Dampener", "requires_any": ["spell"], "tags": ["mana"], "mana_cost_more": -0.15},
	"chained_fury": {"name": "Chained Fury", "requires_any": ["projectile"], "tags": ["chain"], "chain": 1},
	"burning_focus": {"name": "Burning Focus", "requires_any": ["fire"], "tags": ["fire", "critical"], "ignite_chance": 0.20},
	"brutality": {"name": "Brutality", "requires_any": ["physical"], "tags": ["physical"], "damage_more": 0.25},
	"bloodletting": {"name": "Bloodletting", "requires_any": ["bleed", "physical"], "tags": ["bleed"], "bleed_chance": 0.30},
	"controlled_power": {"name": "Controlled Power", "requires_any": ["spell", "attack"], "tags": ["damage"], "damage_more": 0.15},
	"greater_area": {"name": "Greater Area", "requires_any": ["area"], "tags": ["area"], "area_mult": 0.45, "mana_cost_more": 0.15},
	"life_leech": {"name": "Life Leech", "requires_any": ["hit"], "tags": ["recovery"], "life_leech": 0.02},
}

const SPIRIT_DATA: Dictionary = {
	"clarity": {"name": "Clarity", "reservation": 20, "tags": ["persistent", "mana"], "stats": {"Maximum Mana": 10.0, "Mana Regeneration": 3.0}},
	"vitality": {"name": "Vitality", "reservation": 25, "tags": ["persistent", "life"], "stats": {"Maximum Life": 18.0, "Life Regeneration": 2.0}},
	"iron_skin": {"name": "Iron Skin", "reservation": 25, "tags": ["persistent", "defense"], "stats": {"Armor": 18.0}},
	"ember_pact": {"name": "Ember Pact", "reservation": 30, "tags": ["persistent", "fire"], "stats": {"Fire Damage": 18.0, "Ignite Chance": 10.0}},
	"storm_rhythm": {"name": "Storm Rhythm", "reservation": 30, "tags": ["persistent", "lightning"], "stats": {"Lightning Damage": 15.0, "Chain Bonus": 1.0}},
	"void_tithe": {"name": "Void Tithe", "reservation": 35, "tags": ["persistent", "void"], "stats": {"Void Damage": 22.0, "Mana Cost": 8.0}},
	"revenant_guard": {"name": "Revenant Guard", "reservation": 35, "tags": ["persistent", "guard"], "stats": {"Block Chance": 8.0, "Armor": 14.0}},
	"execution_focus": {"name": "Execution Focus", "reservation": 25, "tags": ["persistent", "execute"], "stats": {"Execute More": 18.0}},
}

static func active_ids() -> Array:
	return ACTIVE_ORDER.duplicate()

static func support_ids() -> Array:
	return SUPPORT_ORDER.duplicate()

static func spirit_ids() -> Array:
	return SPIRIT_ORDER.duplicate()

static func active_data(id: String) -> Dictionary:
	return Dictionary(ACTIVE_DATA.get(id, {"name": id.capitalize(), "tags": [], "damage": 10.0, "mana_cost": 5})).duplicate(true)

static func support_data(id: String) -> Dictionary:
	return Dictionary(SUPPORT_DATA.get(id, {"name": id.capitalize(), "tags": [], "requires_any": []})).duplicate(true)

static func spirit_data(id: String) -> Dictionary:
	return spirit(id)

static func spirit(id: String) -> Dictionary:
	return Dictionary(SPIRIT_DATA.get(id, {"name": id.capitalize(), "reservation": 25, "tags": ["persistent"], "stats": {}})).duplicate(true)

static func gem_data(type: String, id: String) -> Dictionary:
	match type:
		"active", "active_gem", "skill":
			return active_data(id)
		"support", "support_gem":
			return support_data(id)
		"spirit", "spirit_gem":
			return spirit_data(id)
		_:
			if ACTIVE_DATA.has(id):
				return active_data(id)
			if SUPPORT_DATA.has(id):
				return support_data(id)
			if SPIRIT_DATA.has(id):
				return spirit_data(id)
			return {"name": id.capitalize(), "tags": []}

static func support_compatible(active_id: String, support_id: String) -> bool:
	var active: Dictionary = active_data(active_id)
	var support: Dictionary = support_data(support_id)
	var active_tags: Array = Array(active.get("tags", []))
	var requires: Array = Array(support.get("requires_any", []))
	if requires.is_empty():
		return true
	for required: Variant in requires:
		if active_tags.has(str(required)):
			return true
	return false

static func make_gem_item(type: String, id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	var kind: String = "active_gem"
	var data: Dictionary = active_data(id)
	match type:
		"active", "active_gem", "skill":
			kind = "active_gem"
			data = active_data(id)
		"support", "support_gem":
			kind = "support_gem"
			data = support_data(id)
		"spirit", "spirit_gem":
			kind = "spirit_gem"
			data = spirit_data(id)

	return {
		"uid": kind + "_" + id + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000),
		"kind": kind,
		"item_kind": kind,
		"category": "gem",
		"gem_type": type,
		"gem_id": id,
		"level": maxi(1, level),
		"xp": maxi(0, xp),
		"quality": clampi(quality, 0, 100),
		"supports": supports.duplicate(true),
		"display_name": str(data.get("name", id.capitalize())) + " Lv. " + str(maxi(1, level)),
		"name": str(data.get("name", id.capitalize())) + " Lv. " + str(maxi(1, level)),
		"label": str(data.get("name", id.capitalize())) + " Lv. " + str(maxi(1, level)),
		"tags": Array(data.get("tags", [])),
		"identified": true,
		"new_item": true,
		"grid_w": 1,
		"grid_h": 1,
	}
