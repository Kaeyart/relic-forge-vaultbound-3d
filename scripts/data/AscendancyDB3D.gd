class_name RVAscendancyDB3D
extends RefCounted

static func ascendancies() -> Dictionary:
	return {
		"blood_mage": {"id":"blood_mage", "class_id":"sorceress", "name":"Blood Mage", "description":"Uses life as a casting resource and turns danger into spell power."},
		"elementalist": {"id":"elementalist", "class_id":"sorceress", "name":"Elementalist", "description":"Cycles and amplifies elemental damage, ailments, and exposure."},
		"chronomancer": {"id":"chronomancer", "class_id":"sorceress", "name":"Chronomancer", "description":"Repeats spells, manipulates cooldowns, slows enemies, and cheats death."},
		"titan": {"id":"titan", "class_id":"warrior", "name":"Titan", "description":"Huge mace hits, slams, stun pressure, and aftershocks."},
		"juggernaut": {"id":"juggernaut", "class_id":"warrior", "name":"Juggernaut", "description":"Armor, block, Ward, and unstoppable defensive momentum."},
		"warbringer": {"id":"warbringer", "class_id":"warrior", "name":"Warbringer", "description":"Warcries, rage, explosions, and empowered heavy attacks."},
		"deadeye": {"id":"deadeye", "class_id":"huntress", "name":"Deadeye", "description":"Bow and projectile mastery: range, chain, pierce, crit, and marks."},
		"warden": {"id":"warden", "class_id":"huntress", "name":"Warden", "description":"Traps, snares, survival, terrain control, and decoys."},
		"nightstalker": {"id":"nightstalker", "class_id":"huntress", "name":"Nightstalker", "description":"Crit, bleed, poison, execution windows, and ambush movement."},
	}

static func nodes() -> Dictionary:
	var out: Dictionary = {}
	_add_nodes(out, "blood_mage", [
		{"id":"crimson_casting", "name":"Crimson Casting", "stats":{"Spell Damage":0.12}, "rules":["asc:blood_life_costs"], "description":"30% of mana costs are paid with life. Spells gain power from life spent recently."},
		{"id":"sanguine_overflow", "name":"Sanguine Overflow", "requires":["blood_mage_crimson_casting"], "stats":{"Cast Speed":0.05}, "rules":["asc:blood_charges"]},
		{"id":"leeching_arcanum", "name":"Leeching Arcanum", "requires":["blood_mage_sanguine_overflow"], "stats":{"Spell Leech":0.02, "Maximum Life":22.0}, "rules":["asc:spell_life_leech"]},
		{"id":"last_heartbeat", "name":"Last Heartbeat", "requires":["blood_mage_leeching_arcanum"], "stats":{"Spell Damage":0.18}, "rules":["asc:last_heartbeat"]},
	])
	_add_nodes(out, "elementalist", [
		{"id":"elemental_confluence", "name":"Elemental Confluence", "stats":{"Elemental Damage":0.12}, "rules":["asc:elemental_confluence"]},
		{"id":"ash_and_thunder", "name":"Ash and Thunder", "requires":["elementalist_elemental_confluence"], "stats":{"Ignite Chance":10.0, "Shock Chance":10.0}, "rules":["asc:ash_and_thunder"]},
		{"id":"exposure_engine", "name":"Exposure Engine", "requires":["elementalist_ash_and_thunder"], "stats":{"Elemental Penetration":0.08}, "rules":["asc:exposure_engine"]},
		{"id":"primordial_core", "name":"Primordial Core", "requires":["elementalist_exposure_engine"], "stats":{"Fire Damage":0.10, "Lightning Damage":0.10, "Void Damage":0.10}, "rules":["asc:primordial_core"]},
	])
	_add_nodes(out, "chronomancer", [
		{"id":"echo_window", "name":"Echo Window", "stats":{"Cast Speed":0.05}, "rules":["asc:spell_echo_window"]},
		{"id":"borrowed_second", "name":"Borrowed Second", "requires":["chronomancer_echo_window"], "stats":{"Maximum Mana":20.0}, "rules":["asc:borrowed_second"]},
		{"id":"time_dilation", "name":"Time Dilation", "requires":["chronomancer_borrowed_second"], "stats":{"Cooldown Recovery":0.08}, "rules":["asc:time_dilation"]},
		{"id":"fractured_moment", "name":"Fractured Moment", "requires":["chronomancer_time_dilation"], "stats":{"Cooldown Recovery":0.12, "Spell Damage":0.08}, "rules":["asc:fractured_moment"]},
	])
	_add_nodes(out, "titan", [
		{"id":"earthsplitter", "name":"Earthsplitter", "stats":{"Area Damage":0.12, "Area Radius":0.10}, "rules":["asc:slam_aftershocks"]},
		{"id":"colossal_impact", "name":"Colossal Impact", "requires":["titan_earthsplitter"], "stats":{"Stun Buildup":0.18}, "rules":["asc:stunned_enemy_damage"]},
		{"id":"two_handed_dominion", "name":"Two-Handed Dominion", "requires":["titan_colossal_impact"], "stats":{"Mace Damage":0.20, "Attack Speed":-0.04}, "rules":["asc:two_handed_mace"]},
		{"id":"faultline", "name":"Faultline", "requires":["titan_two_handed_dominion"], "stats":{"Slam Damage":0.16}, "rules":["asc:third_slam_shockwave"]},
	])
	_add_nodes(out, "juggernaut", [
		{"id":"unbroken", "name":"Unbroken", "stats":{"Armor":42.0}, "rules":["asc:unstoppable"]},
		{"id":"iron_blood", "name":"Iron Blood", "requires":["juggernaut_unbroken"], "stats":{"Armor":32.0, "Elemental Reduction":0.04}, "rules":["asc:armor_vs_elemental"]},
		{"id":"vault_ward", "name":"Vault Ward", "requires":["juggernaut_iron_blood"], "stats":{"Runic Ward":40.0}, "rules":["asc:vault_ward"]},
		{"id":"immovable", "name":"Immovable", "requires":["juggernaut_vault_ward"], "stats":{"Block Chance":8.0, "Physical Reduction":0.06}, "rules":["asc:standing_mitigation"]},
	])
	_add_nodes(out, "warbringer", [
		{"id":"battle_roar", "name":"Battle Roar", "stats":{"Attack Damage":0.10}, "rules":["asc:warcry_empowers_slam"]},
		{"id":"rage_furnace", "name":"Rage Furnace", "requires":["warbringer_battle_roar"], "stats":{"Attack Speed":0.06}, "rules":["asc:rage"]},
		{"id":"corpse_breaker", "name":"Corpse Breaker", "requires":["warbringer_rage_furnace"], "stats":{"Physical Damage":0.12}, "rules":["asc:heavy_kill_explosion"]},
		{"id":"banner_of_ruin", "name":"Banner of Ruin", "requires":["warbringer_corpse_breaker"], "stats":{"Stun Buildup":0.10}, "rules":["asc:banner_of_ruin"]},
	])
	_add_nodes(out, "deadeye", [
		{"id":"far_shot", "name":"Far Shot", "stats":{"Projectile Damage":0.12, "Projectile Speed":0.10}, "rules":["asc:far_shot"]},
		{"id":"ricochet", "name":"Ricochet", "requires":["deadeye_far_shot"], "stats":{"Chain Bonus":1.0}, "rules":["asc:ricochet"]},
		{"id":"perfect_angle", "name":"Perfect Angle", "requires":["deadeye_ricochet"], "stats":{"Critical Chance":0.06, "Projectile Damage":0.06}, "rules":["asc:perfect_angle"]},
		{"id":"marked_quarry", "name":"Marked Quarry", "requires":["deadeye_perfect_angle"], "stats":{"Mark Effect":0.18}, "rules":["asc:marked_quarry"]},
	])
	_add_nodes(out, "warden", [
		{"id":"snarecraft", "name":"Snarecraft", "stats":{"Trap Damage":0.12, "Cooldown Recovery":0.06}, "rules":["asc:snarecraft"]},
		{"id":"field_warden", "name":"Field Warden", "requires":["warden_snarecraft"], "stats":{"Evasion":35.0, "Physical Reduction":0.03}, "rules":["asc:field_warden"]},
		{"id":"beastcall", "name":"Beastcall", "requires":["warden_field_warden"], "stats":{"Maximum Life":16.0}, "rules":["asc:beastcall"]},
		{"id":"predators_ground", "name":"Predator's Ground", "requires":["warden_beastcall"], "stats":{"Projectile Damage":0.12}, "rules":["asc:predators_ground"]},
	])
	_add_nodes(out, "nightstalker", [
		{"id":"first_blood", "name":"First Blood", "stats":{"Critical Chance":0.08}, "rules":["asc:first_blood"]},
		{"id":"red_trail", "name":"Red Trail", "requires":["nightstalker_first_blood"], "stats":{"Bleed Chance":12.0, "Bleed Damage":0.14}, "rules":["asc:red_trail"]},
		{"id":"execution_mark", "name":"Execution Mark", "requires":["nightstalker_red_trail"], "stats":{"Execute More":0.18}, "rules":["asc:execution_mark"]},
		{"id":"vanish_step", "name":"Vanish Step", "requires":["nightstalker_execution_mark"], "stats":{"Movement Speed":0.06, "Critical Multiplier":0.18}, "rules":["asc:vanish_step"]},
	])
	return out

static func _add_nodes(out: Dictionary, asc_id: String, entries: Array) -> void:
	for i: int in range(entries.size()):
		var e: Dictionary = Dictionary(entries[i])
		var id: String = asc_id + "_" + str(e.get("id", str(i)))
		out[id] = {
			"id": id,
			"ascendancy_id": asc_id,
			"name": str(e.get("name", id.capitalize())),
			"type": "major",
			"cost": 2,
			"requires": Array(e.get("requires", [])).duplicate(true),
			"stats": Dictionary(e.get("stats", {})).duplicate(true),
			"rules": Array(e.get("rules", [])).duplicate(true),
			"description": str(e.get("description", "")),
		}

static func ascendancies_for_class(class_id: String) -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in ascendancies().keys():
		var data: Dictionary = Dictionary(ascendancies()[key])
		if str(data.get("class_id", "")) == class_id:
			ids.append(str(key))
	ids.sort()
	return ids

static func ascendancy_data(asc_id: String) -> Dictionary:
	var all: Dictionary = ascendancies()
	if all.has(asc_id):
		return Dictionary(all[asc_id]).duplicate(true)
	return {}

static func node(node_id: String) -> Dictionary:
	var all: Dictionary = nodes()
	if all.has(node_id):
		return Dictionary(all[node_id]).duplicate(true)
	return {}
