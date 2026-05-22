extends RefCounted
class_name RVAscendancyDB3D

const ASCENDANCIES: Dictionary = {
	"blood_mage": {"id": "blood_mage", "class_id": "sorceress", "display_name": "Blood Mage", "fantasy": "Life becomes spell fuel."},
	"elementalist": {"id": "elementalist", "class_id": "sorceress", "display_name": "Elementalist", "fantasy": "Cycles fire, lightning, and void pressure."},
	"chronomancer": {"id": "chronomancer", "class_id": "sorceress", "display_name": "Chronomancer", "fantasy": "Repeats spells and manipulates tempo."},
	"titan": {"id": "titan", "class_id": "warrior", "display_name": "Titan", "fantasy": "Slam impact, stun, and aftershocks."},
	"juggernaut": {"id": "juggernaut", "class_id": "warrior", "display_name": "Juggernaut", "fantasy": "Armor, ward, and unstoppable defense."},
	"warbringer": {"id": "warbringer", "class_id": "warrior", "display_name": "Warbringer", "fantasy": "Rage, warcries, and explosions."},
	"deadeye": {"id": "deadeye", "class_id": "huntress", "display_name": "Deadeye", "fantasy": "Projectile chains, marks, and far-shot kills."},
	"warden": {"id": "warden", "class_id": "huntress", "display_name": "Warden", "fantasy": "Traps, snares, and survival zones."},
	"nightstalker": {"id": "nightstalker", "class_id": "huntress", "display_name": "Nightstalker", "fantasy": "Bleed, crit, ambush, and execution."},
}

static func all_nodes() -> Dictionary:
	var nodes: Dictionary = {}
	_add(nodes, "blood_mage", "Crimson Casting", "major", {}, ["blood_life_costs", "asc:blood_mage_crimson_casting"], [])
	_add(nodes, "blood_mage", "Sanguine Overflow", "major", {"Spell Damage": 12.0}, ["blood_charges", "asc:blood_mage_sanguine_overflow"], ["blood_mage_crimson_casting"])
	_add(nodes, "blood_mage", "Leeching Arcanum", "major", {"Life Leech": 0.04}, ["blood_spell_leech", "asc:blood_mage_leeching_arcanum"], ["blood_mage_sanguine_overflow"])
	_add(nodes, "blood_mage", "Last Heartbeat", "major", {"Spell Damage": 18.0, "Cast Speed": 0.08}, ["blood_low_life_power", "asc:blood_mage_last_heartbeat"], ["blood_mage_leeching_arcanum"])
	_add_minor_chain(nodes, "blood_mage", "Blood Vessel", {"Maximum Life": 12.0, "Life Cost": -0.03})

	_add(nodes, "elementalist", "Elemental Confluence", "major", {}, ["elementalist_confluence", "asc:elementalist_confluence"], [])
	_add(nodes, "elementalist", "Ash and Thunder", "major", {"Fire Damage": 10.0, "Lightning Damage": 10.0}, ["elementalist_ash_thunder", "asc:elementalist_ash_thunder"], ["elementalist_elemental_confluence"])
	_add(nodes, "elementalist", "Exposure Engine", "major", {"Ailment Damage": 12.0}, ["elementalist_exposure", "asc:elementalist_exposure_engine"], ["elementalist_ash_and_thunder"])
	_add(nodes, "elementalist", "Primordial Core", "major", {"Fire Damage": 12.0, "Lightning Damage": 12.0, "Void Damage": 12.0}, ["elementalist_triple_element", "asc:elementalist_primordial_core"], ["elementalist_exposure_engine"])
	_add_minor_chain(nodes, "elementalist", "Element Thread", {"Ignite Chance": 4.0, "Shock Chance": 4.0})

	_add(nodes, "chronomancer", "Echo Window", "major", {"Cast Speed": 0.04}, ["chrono_echo_window", "asc:chrono_echo_window"], [])
	_add(nodes, "chronomancer", "Borrowed Second", "major", {"Ward": 18.0}, ["chrono_rewind_guard", "asc:chrono_borrowed_second"], ["chronomancer_echo_window"])
	_add(nodes, "chronomancer", "Time Dilation", "major", {"Area Damage": 10.0}, ["chrono_slow_on_spell", "asc:chrono_time_dilation"], ["chronomancer_borrowed_second"])
	_add(nodes, "chronomancer", "Fractured Moment", "major", {"Cast Speed": 0.08}, ["chrono_cooldown_recovery", "asc:chrono_fractured_moment"], ["chronomancer_time_dilation"])
	_add_minor_chain(nodes, "chronomancer", "Clock Shard", {"Maximum Mana": 8.0, "Cast Speed": 0.02})

	_add(nodes, "titan", "Earthsplitter", "major", {"Slam Damage": 12.0}, ["titan_aftershock", "asc:titan_earthsplitter"], [])
	_add(nodes, "titan", "Colossal Impact", "major", {"Stun Damage": 15.0, "Stun Buildup": 15.0}, ["titan_stun_execute", "asc:titan_colossal_impact"], ["titan_earthsplitter"])
	_add(nodes, "titan", "Two-Handed Dominion", "major", {"Melee Damage": 18.0, "Attack Speed": -0.04}, ["titan_two_handed", "asc:titan_two_handed_dominion"], ["titan_colossal_impact"])
	_add(nodes, "titan", "Faultline", "major", {"Aftershock Damage": 20.0}, ["titan_faultline", "asc:titan_faultline"], ["titan_two_handed_dominion"])
	_add_minor_chain(nodes, "titan", "Stone Muscle", {"Maximum Life": 10.0, "Armor": 10.0})

	_add(nodes, "juggernaut", "Unbroken", "major", {"Armor": 18.0}, ["juggernaut_unbroken", "asc:juggernaut_unbroken"], [])
	_add(nodes, "juggernaut", "Iron Blood", "major", {"Elemental Mitigation": 0.05}, ["juggernaut_iron_blood", "asc:juggernaut_iron_blood"], ["juggernaut_unbroken"])
	_add(nodes, "juggernaut", "Vault Ward", "major", {"Runic Ward": 24.0}, ["juggernaut_vault_ward", "asc:juggernaut_vault_ward"], ["juggernaut_iron_blood"])
	_add(nodes, "juggernaut", "Immovable", "major", {"Block Chance": 8.0}, ["juggernaut_immovable", "asc:juggernaut_immovable"], ["juggernaut_vault_ward"])
	_add_minor_chain(nodes, "juggernaut", "Iron Step", {"Armor": 12.0, "Physical Reduction": 0.02})

	_add(nodes, "warbringer", "Battle Roar", "major", {"Warcry Effect": 15.0}, ["warbringer_battle_roar", "asc:warbringer_battle_roar"], [])
	_add(nodes, "warbringer", "Rage Furnace", "major", {"Rage Gain": 1.0}, ["warbringer_rage", "asc:warbringer_rage_furnace"], ["warbringer_battle_roar"])
	_add(nodes, "warbringer", "Corpse Breaker", "major", {"Physical Damage": 10.0}, ["warbringer_corpse_breaker", "asc:warbringer_corpse_breaker"], ["warbringer_rage_furnace"])
	_add(nodes, "warbringer", "Banner of Ruin", "major", {"Stun Buildup": 10.0}, ["warbringer_banner_ruin", "asc:warbringer_banner_of_ruin"], ["warbringer_corpse_breaker"])
	_add_minor_chain(nodes, "warbringer", "Red Chant", {"Physical Damage": 6.0, "Rage Gain": 0.25})

	_add(nodes, "deadeye", "Far Shot", "major", {"Projectile Damage": 12.0, "Projectile Speed": 12.0}, ["deadeye_far_shot", "asc:deadeye_far_shot"], [])
	_add(nodes, "deadeye", "Ricochet", "major", {"Chain Bonus": 1.0}, ["deadeye_ricochet", "asc:deadeye_ricochet"], ["deadeye_far_shot"])
	_add(nodes, "deadeye", "Perfect Angle", "major", {"Critical Chance": 0.06}, ["deadeye_perfect_angle", "asc:deadeye_perfect_angle"], ["deadeye_ricochet"])
	_add(nodes, "deadeye", "Marked Quarry", "major", {"Projectile Damage": 16.0}, ["deadeye_marked_quarry", "asc:deadeye_marked_quarry"], ["deadeye_perfect_angle"])
	_add_minor_chain(nodes, "deadeye", "Arrow Thread", {"Projectile Damage": 6.0, "Projectile Speed": 4.0})

	_add(nodes, "warden", "Snarecraft", "major", {"Trap Arming Speed": 0.12}, ["warden_snarecraft", "asc:warden_snarecraft"], [])
	_add(nodes, "warden", "Field Warden", "major", {"Armor": 8.0, "Movement Speed": 0.03}, ["warden_field_warden", "asc:warden_field_warden"], ["warden_snarecraft"])
	_add(nodes, "warden", "Beastcall", "major", {"Maximum Life": 12.0}, ["warden_beastcall", "asc:warden_beastcall"], ["warden_field_warden"])
	_add(nodes, "warden", "Predator's Ground", "major", {"Projectile Damage": 12.0, "Trap Damage": 16.0}, ["warden_predators_ground", "asc:warden_predators_ground"], ["warden_beastcall"])
	_add_minor_chain(nodes, "warden", "Trail Sign", {"Trap Damage": 6.0, "Movement Speed": 0.01})

	_add(nodes, "nightstalker", "First Blood", "major", {"Critical Chance": 0.08, "Bleed Chance": 8.0}, ["nightstalker_first_blood", "asc:nightstalker_first_blood"], [])
	_add(nodes, "nightstalker", "Red Trail", "major", {"Ailment Damage": 14.0}, ["nightstalker_red_trail", "asc:nightstalker_red_trail"], ["nightstalker_first_blood"])
	_add(nodes, "nightstalker", "Execution Mark", "major", {"Critical Multiplier": 20.0}, ["nightstalker_execution_mark", "asc:nightstalker_execution_mark"], ["nightstalker_red_trail"])
	_add(nodes, "nightstalker", "Vanish Step", "major", {"Movement Speed": 0.05}, ["nightstalker_vanish_step", "asc:nightstalker_vanish_step"], ["nightstalker_execution_mark"])
	_add_minor_chain(nodes, "nightstalker", "Dark Arrow", {"Bleed Chance": 4.0, "Critical Chance": 0.02})
	return nodes

static func _add(nodes: Dictionary, asc_id: String, title: String, node_type: String, stats: Dictionary, rules: Array, requires: Array) -> void:
	var id: String = asc_id + "_" + title.to_lower().replace("'", "").replace(" ", "_").replace("-", "_")
	nodes[id] = {
		"id": id,
		"ascendancy_id": asc_id,
		"display_name": title,
		"title": title,
		"type": node_type,
		"stats": stats,
		"rules": rules,
		"requires": requires,
		"cost": 1 if node_type == "minor" else 2,
		"description": title + "\n" + node_type.capitalize() + " ascendancy node.",
	}

static func _add_minor_chain(nodes: Dictionary, asc_id: String, base_title: String, stats: Dictionary) -> void:
	var prev: String = ""
	for i: int in range(0, 4):
		var title: String = base_title + " " + str(i + 1)
		var reqs: Array[String] = []
		if prev != "":
			reqs.append(prev)
		_add(nodes, asc_id, title, "minor", stats, ["asc:" + asc_id + "_minor"], reqs)
		prev = asc_id + "_" + title.to_lower().replace("'", "").replace(" ", "_").replace("-", "_")

static func ascendancy_data(id: String) -> Dictionary:
	if ASCENDANCIES.has(id):
		return Dictionary(ASCENDANCIES[id]).duplicate(true)
	return {}

static func ascendancies_for_class(class_id: String) -> Array:
	var result: Array = []
	for id_value: Variant in ASCENDANCIES.keys():
		var data: Dictionary = Dictionary(ASCENDANCIES[id_value])
		if str(data.get("class_id", "")) == class_id:
			result.append(data.duplicate(true))
	return result

static func node(id: String) -> Dictionary:
	var nodes: Dictionary = all_nodes()
	if nodes.has(id):
		return Dictionary(nodes[id]).duplicate(true)
	return {}

static func nodes_for_ascendancy(asc_id: String) -> Array:
	var result: Array = []
	var nodes: Dictionary = all_nodes()
	for id_value: Variant in nodes.keys():
		var n: Dictionary = Dictionary(nodes[id_value])
		if str(n.get("ascendancy_id", "")) == asc_id:
			result.append(n)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
	return result

static func bundle_for_allocations(allocated: Dictionary) -> Dictionary:
	var stats: Dictionary = {}
	var rules: Array[String] = []
	for id_value: Variant in allocated.keys():
		if not bool(allocated[id_value]):
			continue
		var n: Dictionary = node(str(id_value))
		if n.is_empty():
			continue
		for stat_key: Variant in Dictionary(n.get("stats", {})).keys():
			var key: String = str(stat_key)
			stats[key] = float(stats.get(key, 0.0)) + float(Dictionary(n.get("stats", {}))[stat_key])
		for rule: Variant in Array(n.get("rules", [])):
			var r: String = str(rule)
			if r != "" and not rules.has(r):
				rules.append(r)
	return {"stats": stats, "rules": rules}
