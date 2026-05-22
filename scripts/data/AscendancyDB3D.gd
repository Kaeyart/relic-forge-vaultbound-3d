class_name RVAscendancyDB3D
extends RefCounted

static func ascendancies() -> Dictionary:
	return {
		"blood_mage": {"id":"blood_mage", "class_id":"sorceress", "name":"Blood Mage", "description":"Life-as-power spellcaster. Spends life, builds Blood Charges, and leeches through spell violence."},
		"elementalist": {"id":"elementalist", "class_id":"sorceress", "name":"Elementalist", "description":"Elemental cycling, ailment chains, exposure, and fire/lightning/void pressure."},
		"chronomancer": {"id":"chronomancer", "class_id":"sorceress", "name":"Chronomancer", "description":"Echo casts, cooldown compression, slows, delayed effects, and one dangerous second chance."},
		"titan": {"id":"titan", "class_id":"warrior", "name":"Titan", "description":"Mace slams, stun, aftershocks, huge commitment hits, and ground-breaking impacts."},
		"juggernaut": {"id":"juggernaut", "class_id":"warrior", "name":"Juggernaut", "description":"Armor, block, ward, anti-stun pressure, and unstoppable survival momentum."},
		"warbringer": {"id":"warbringer", "class_id":"warrior", "name":"Warbringer", "description":"Warcries, rage, explosions, banners, and melee tempo escalation."},
		"deadeye": {"id":"deadeye", "class_id":"huntress", "name":"Deadeye", "description":"Bow and projectile mastery: distance, pierce, chain, extra projectiles, crit, and marks."},
		"warden": {"id":"warden", "class_id":"huntress", "name":"Warden", "description":"Traps, snares, survival ground, decoys, roots, and controlled kill zones."},
		"nightstalker": {"id":"nightstalker", "class_id":"huntress", "name":"Nightstalker", "description":"Crit, bleed, poison, execution marks, and ambush movement windows."},
	}

static func nodes() -> Dictionary:
	var out: Dictionary = {}
	_add_tree(out, "blood_mage", [
		{"id":"blood_tithe", "name":"Blood Tithe", "type":"minor", "stats":{"Maximum Life":18.0}},
		{"id":"crimson_casting", "name":"Crimson Casting", "type":"major", "requires":["blood_mage_blood_tithe"], "stats":{"Spell Damage":0.12}, "rules":["asc:blood_life_costs"], "description":"Part of your mana costs can be paid with life. Life spent recently increases spell power."},
		{"id":"hematic_focus", "name":"Hematic Focus", "type":"minor", "requires":["blood_mage_crimson_casting"], "stats":{"Cast Speed":0.04, "Maximum Life":12.0}},
		{"id":"sanguine_overflow", "name":"Sanguine Overflow", "type":"major", "requires":["blood_mage_hematic_focus"], "stats":{"Spell Damage":0.10}, "rules":["asc:blood_charges"], "description":"Spending life on spells builds Blood Charges. At high charges, your next spell is empowered."},
		{"id":"red_recovery", "name":"Red Recovery", "type":"minor", "requires":["blood_mage_sanguine_overflow"], "stats":{"Life Regeneration":2.0, "Spell Leech":0.01}},
		{"id":"leeching_arcanum", "name":"Leeching Arcanum", "type":"major", "requires":["blood_mage_red_recovery"], "stats":{"Spell Leech":0.02, "Maximum Life":22.0}, "rules":["asc:spell_life_leech"], "description":"Spell damage leeches life. Leech is stronger against ailmented enemies."},
		{"id":"wounded_power", "name":"Wounded Power", "type":"minor", "requires":["blood_mage_leeching_arcanum"], "stats":{"Spell Damage":0.08, "Cast Speed":0.03}},
		{"id":"last_heartbeat", "name":"Last Heartbeat", "type":"major", "requires":["blood_mage_wounded_power"], "stats":{"Spell Damage":0.18}, "rules":["asc:last_heartbeat"], "description":"While low on life, your spell output spikes. This is intentionally dangerous."},
	])
	_add_tree(out, "elementalist", [
		{"id":"spark_and_ember", "name":"Spark and Ember", "type":"minor", "stats":{"Fire Damage":0.06, "Lightning Damage":0.06}},
		{"id":"elemental_confluence", "name":"Elemental Confluence", "type":"major", "requires":["elementalist_spark_and_ember"], "stats":{"Elemental Damage":0.12}, "rules":["asc:elemental_confluence"], "description":"Casting different elements in sequence builds Confluence."},
		{"id":"ailment_literacy", "name":"Ailment Literacy", "type":"minor", "requires":["elementalist_elemental_confluence"], "stats":{"Ignite Chance":8.0, "Shock Chance":8.0}},
		{"id":"ash_and_thunder", "name":"Ash and Thunder", "type":"major", "requires":["elementalist_ailment_literacy"], "stats":{"Ignite Chance":10.0, "Shock Chance":10.0}, "rules":["asc:ash_and_thunder"], "description":"Ignites and shocks help set up the next opposite element."},
		{"id":"elemental_cut", "name":"Elemental Cut", "type":"minor", "requires":["elementalist_ash_and_thunder"], "stats":{"Elemental Penetration":0.04}},
		{"id":"exposure_engine", "name":"Exposure Engine", "type":"major", "requires":["elementalist_elemental_cut"], "stats":{"Elemental Penetration":0.08}, "rules":["asc:exposure_engine"], "description":"Repeated elemental pressure applies and upgrades exposure."},
		{"id":"triple_spark", "name":"Triple Spark", "type":"minor", "requires":["elementalist_exposure_engine"], "stats":{"Fire Damage":0.08, "Lightning Damage":0.08, "Void Damage":0.08}},
		{"id":"primordial_core", "name":"Primordial Core", "type":"major", "requires":["elementalist_triple_spark"], "stats":{"Elemental Damage":0.20}, "rules":["asc:primordial_core"], "description":"Fire, lightning, and void/cold damage dealt recently unlocks a large elemental burst window."},
	])
	_add_tree(out, "chronomancer", [
		{"id":"quick_second", "name":"Quick Second", "type":"minor", "stats":{"Cast Speed":0.04}},
		{"id":"echo_window", "name":"Echo Window", "type":"major", "requires":["chronomancer_quick_second"], "stats":{"Cast Speed":0.05}, "rules":["asc:spell_echo_window"], "description":"Every few seconds, your next spell repeats at reduced effect."},
		{"id":"stored_moment", "name":"Stored Moment", "type":"minor", "requires":["chronomancer_echo_window"], "stats":{"Maximum Mana":18.0}},
		{"id":"borrowed_second", "name":"Borrowed Second", "type":"major", "requires":["chronomancer_stored_moment"], "stats":{"Maximum Mana":20.0}, "rules":["asc:borrowed_second"], "description":"A dangerous defensive rewind hook for later combat integration."},
		{"id":"slow_math", "name":"Slow Math", "type":"minor", "requires":["chronomancer_borrowed_second"], "stats":{"Cooldown Recovery":0.06}},
		{"id":"time_dilation", "name":"Time Dilation", "type":"major", "requires":["chronomancer_slow_math"], "stats":{"Cooldown Recovery":0.08}, "rules":["asc:time_dilation"], "description":"Your spells gain slow/time-dilation payoff hooks."},
		{"id":"fracture_study", "name":"Fracture Study", "type":"minor", "requires":["chronomancer_time_dilation"], "stats":{"Spell Damage":0.08, "Cooldown Recovery":0.04}},
		{"id":"fractured_moment", "name":"Fractured Moment", "type":"major", "requires":["chronomancer_fracture_study"], "stats":{"Cooldown Recovery":0.12, "Spell Damage":0.08}, "rules":["asc:fractured_moment"], "description":"Cooldown skills and repeated casts become the Chronomancer's end state."},
	])
	_add_tree(out, "titan", [
		{"id":"stone_shoulder", "name":"Stone Shoulder", "type":"minor", "stats":{"Slam Damage":0.08}},
		{"id":"earthsplitter", "name":"Earthsplitter", "type":"major", "requires":["titan_stone_shoulder"], "stats":{"Area Damage":0.12, "Area Radius":0.10}, "rules":["asc:slam_aftershocks"], "description":"Slam skills create aftershock hooks."},
		{"id":"stun_weight", "name":"Stun Weight", "type":"minor", "requires":["titan_earthsplitter"], "stats":{"Stun Buildup":0.10}},
		{"id":"colossal_impact", "name":"Colossal Impact", "type":"major", "requires":["titan_stun_weight"], "stats":{"Stun Buildup":0.18}, "rules":["asc:stunned_enemy_damage"], "description":"Stunned enemies become burst targets."},
		{"id":"giant_leverage", "name":"Giant Leverage", "type":"minor", "requires":["titan_colossal_impact"], "stats":{"Mace Damage":0.10, "Attack Speed":-0.02}},
		{"id":"two_handed_dominion", "name":"Two-Handed Dominion", "type":"major", "requires":["titan_giant_leverage"], "stats":{"Mace Damage":0.20, "Attack Speed":-0.04}, "rules":["asc:two_handed_mace"], "description":"Two-handed maces become slower but far heavier."},
		{"id":"fault_crack", "name":"Fault Crack", "type":"minor", "requires":["titan_two_handed_dominion"], "stats":{"Area Damage":0.08}},
		{"id":"faultline", "name":"Faultline", "type":"major", "requires":["titan_fault_crack"], "stats":{"Slam Damage":0.16}, "rules":["asc:third_slam_shockwave"], "description":"Every third Slam can become a shockwave hook."},
	])
	_add_tree(out, "juggernaut", [
		{"id":"iron_neck", "name":"Iron Neck", "type":"minor", "stats":{"Armor":32.0}},
		{"id":"unbroken", "name":"Unbroken", "type":"major", "requires":["juggernaut_iron_neck"], "stats":{"Armor":42.0}, "rules":["asc:unstoppable"], "description":"You become harder to interrupt under pressure."},
		{"id":"thick_blood", "name":"Thick Blood", "type":"minor", "requires":["juggernaut_unbroken"], "stats":{"Maximum Life":18.0}},
		{"id":"iron_blood", "name":"Iron Blood", "type":"major", "requires":["juggernaut_thick_blood"], "stats":{"Armor":32.0, "Elemental Reduction":0.04}, "rules":["asc:armor_vs_elemental"], "description":"Armor can help against elemental hit damage."},
		{"id":"warded_plate", "name":"Warded Plate", "type":"minor", "requires":["juggernaut_iron_blood"], "stats":{"Runic Ward":28.0}},
		{"id":"vault_ward", "name":"Vault Ward", "type":"major", "requires":["juggernaut_warded_plate"], "stats":{"Runic Ward":45.0}, "rules":["asc:vault_ward"], "description":"Low-life emergency ward becomes a Juggernaut hook."},
		{"id":"set_feet", "name":"Set Feet", "type":"minor", "requires":["juggernaut_vault_ward"], "stats":{"Block Chance":4.0}},
		{"id":"immovable", "name":"Immovable", "type":"major", "requires":["juggernaut_set_feet"], "stats":{"Block Chance":8.0, "Physical Reduction":0.06}, "rules":["asc:standing_mitigation"], "description":"Standing your ground becomes a defensive mechanic."},
	])
	_add_tree(out, "warbringer", [
		{"id":"deep_lung", "name":"Deep Lung", "type":"minor", "stats":{"Attack Damage":0.06}},
		{"id":"battle_roar", "name":"Battle Roar", "type":"major", "requires":["warbringer_deep_lung"], "stats":{"Attack Damage":0.10}, "rules":["asc:warcry_empowers_slam"], "description":"Warcry-like effects empower your next committed hit."},
		{"id":"heat_build", "name":"Heat Build", "type":"minor", "requires":["warbringer_battle_roar"], "stats":{"Attack Speed":0.04}},
		{"id":"rage_furnace", "name":"Rage Furnace", "type":"major", "requires":["warbringer_heat_build"], "stats":{"Attack Speed":0.06}, "rules":["asc:rage"], "description":"Melee action builds a rage tempo hook."},
		{"id":"red_crack", "name":"Red Crack", "type":"minor", "requires":["warbringer_rage_furnace"], "stats":{"Physical Damage":0.08}},
		{"id":"corpse_breaker", "name":"Corpse Breaker", "type":"major", "requires":["warbringer_red_crack"], "stats":{"Physical Damage":0.12}, "rules":["asc:heavy_kill_explosion"], "description":"Heavy kills can become explosions."},
		{"id":"banner_weight", "name":"Banner Weight", "type":"minor", "requires":["warbringer_corpse_breaker"], "stats":{"Stun Buildup":0.08}},
		{"id":"banner_of_ruin", "name":"Banner of Ruin", "type":"major", "requires":["warbringer_banner_weight"], "stats":{"Stun Buildup":0.10}, "rules":["asc:banner_of_ruin"], "description":"Warbringer pressure weakens enemies for physical punishment."},
	])
	_add_tree(out, "deadeye", [
		{"id":"clean_angle", "name":"Clean Angle", "type":"minor", "stats":{"Projectile Damage":0.08}},
		{"id":"far_shot", "name":"Far Shot", "type":"major", "requires":["deadeye_clean_angle"], "stats":{"Projectile Damage":0.12, "Projectile Speed":0.10}, "rules":["asc:far_shot"], "description":"Distance matters for projectile output."},
		{"id":"bounce_math", "name":"Bounce Math", "type":"minor", "requires":["deadeye_far_shot"], "stats":{"Projectile Speed":0.08}},
		{"id":"ricochet", "name":"Ricochet", "type":"major", "requires":["deadeye_bounce_math"], "stats":{"Chain Bonus":1.0}, "rules":["asc:ricochet"], "description":"Projectiles gain chain behavior."},
		{"id":"knife_angle", "name":"Knife Angle", "type":"minor", "requires":["deadeye_ricochet"], "stats":{"Critical Chance":0.04}},
		{"id":"perfect_angle", "name":"Perfect Angle", "type":"major", "requires":["deadeye_knife_angle"], "stats":{"Critical Chance":0.06, "Projectile Damage":0.06}, "rules":["asc:perfect_angle"], "description":"Pierce, chain, and crit share one aiming identity."},
		{"id":"hunter_mark", "name":"Hunter Mark", "type":"minor", "requires":["deadeye_perfect_angle"], "stats":{"Mark Effect":0.10}},
		{"id":"marked_quarry", "name":"Marked Quarry", "type":"major", "requires":["deadeye_hunter_mark"], "stats":{"Mark Effect":0.18}, "rules":["asc:marked_quarry"], "description":"Marked enemies become damage and reward targets."},
	])
	_add_tree(out, "warden", [
		{"id":"wire_hand", "name":"Wire Hand", "type":"minor", "stats":{"Trap Damage":0.08}},
		{"id":"snarecraft", "name":"Snarecraft", "type":"major", "requires":["warden_wire_hand"], "stats":{"Trap Damage":0.12, "Cooldown Recovery":0.06}, "rules":["asc:snarecraft"], "description":"Traps and snares arm faster and control more reliably."},
		{"id":"low_step", "name":"Low Step", "type":"minor", "requires":["warden_snarecraft"], "stats":{"Evasion":22.0}},
		{"id":"field_warden", "name":"Field Warden", "type":"major", "requires":["warden_low_step"], "stats":{"Evasion":35.0, "Physical Reduction":0.03}, "rules":["asc:field_warden"], "description":"Controlled ground improves your survival."},
		{"id":"decoy_whistle", "name":"Decoy Whistle", "type":"minor", "requires":["warden_field_warden"], "stats":{"Maximum Life":12.0}},
		{"id":"beastcall", "name":"Beastcall", "type":"major", "requires":["warden_decoy_whistle"], "stats":{"Maximum Life":16.0}, "rules":["asc:beastcall"], "description":"A future decoy/beast hook for emergency control."},
		{"id":"rooted_kill", "name":"Rooted Kill", "type":"minor", "requires":["warden_beastcall"], "stats":{"Projectile Damage":0.08}},
		{"id":"predators_ground", "name":"Predator's Ground", "type":"major", "requires":["warden_rooted_kill"], "stats":{"Projectile Damage":0.12}, "rules":["asc:predators_ground"], "description":"Slowed/rooted enemies become vulnerable to projectile punishment."},
	])
	_add_tree(out, "nightstalker", [
		{"id":"quiet_hand", "name":"Quiet Hand", "type":"minor", "stats":{"Critical Chance":0.04}},
		{"id":"first_blood", "name":"First Blood", "type":"major", "requires":["nightstalker_quiet_hand"], "stats":{"Critical Chance":0.08}, "rules":["asc:first_blood"], "description":"Opening hits become dangerous."},
		{"id":"red_step", "name":"Red Step", "type":"minor", "requires":["nightstalker_first_blood"], "stats":{"Bleed Chance":8.0}},
		{"id":"red_trail", "name":"Red Trail", "type":"major", "requires":["nightstalker_red_step"], "stats":{"Bleed Chance":12.0, "Bleed Damage":0.14}, "rules":["asc:red_trail"], "description":"Bleeding enemies become moving damage targets."},
		{"id":"finish_line", "name":"Finish Line", "type":"minor", "requires":["nightstalker_red_trail"], "stats":{"Execute More":0.10}},
		{"id":"execution_mark", "name":"Execution Mark", "type":"major", "requires":["nightstalker_finish_line"], "stats":{"Execute More":0.18}, "rules":["asc:execution_mark"], "description":"Low-life marked enemies are executed faster."},
		{"id":"vanish_angle", "name":"Vanish Angle", "type":"minor", "requires":["nightstalker_execution_mark"], "stats":{"Movement Speed":0.05}},
		{"id":"vanish_step", "name":"Vanish Step", "type":"major", "requires":["nightstalker_vanish_angle"], "stats":{"Movement Speed":0.06, "Critical Multiplier":0.18}, "rules":["asc:vanish_step"], "description":"Movement skills prime the next projectile for ambush behavior."},
	])
	return out

static func _add_tree(out: Dictionary, asc_id: String, entries: Array) -> void:
	for i: int in range(entries.size()):
		var e: Dictionary = Dictionary(entries[i])
		var id: String = asc_id + "_" + str(e.get("id", str(i)))
		var requires: Array = Array(e.get("requires", []))
		if i > 0 and requires.is_empty():
			requires.append(asc_id + "_" + str(Dictionary(entries[i - 1]).get("id", str(i - 1))))
		out[id] = {
			"id": id,
			"ascendancy_id": asc_id,
			"name": str(e.get("name", id.capitalize())),
			"type": str(e.get("type", "major")),
			"cost": int(e.get("cost", 1)),
			"requires": requires.duplicate(true),
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
