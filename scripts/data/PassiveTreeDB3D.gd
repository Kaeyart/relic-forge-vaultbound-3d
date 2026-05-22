class_name RVPassiveTreeDB3D
extends RefCounted

static func nodes() -> Dictionary:
	var out: Dictionary = {}
	_add_lane(out, "sorc_fire", "Sorceress · Fire / Ignite / Projectile", "north_arcane", "sorceress", "fire_ignite_projectile", [
		{"name":"Ember Primer", "stats":{"Fire Damage":0.06}, "tags":["fire", "spell"]},
		{"name":"Projectile Formula", "stats":{"Projectile Damage":0.05, "Projectile Speed":0.04}, "tags":["projectile"]},
		{"name":"Kindling Theory", "type":"notable", "stats":{"Ignite Chance":8.0, "Fire Damage":0.08}, "rules":["passive:kindling_theory"], "description":"Fire hits are better at starting ignites. Ignited enemies are preferred targets for fire relic rules."},
		{"name":"Ashen Costing", "stats":{"Mana Cost":-0.03, "Maximum Mana":8.0}, "tags":["mana"]},
		{"name":"Cinder Velocity", "stats":{"Cast Speed":0.04, "Projectile Speed":0.07}, "tags":["spell", "projectile"]},
		{"name":"Cinder Equation", "type":"notable", "stats":{"Fire Damage":0.12, "Ignite Damage":0.12}, "rules":["passive:cinder_equation"], "description":"Ignite scaling becomes a real damage lane instead of incidental ailment text."},
		{"name":"Forked Flame", "stats":{"Projectile Damage":0.06, "Extra Projectiles":1.0}, "tags":["projectile"]},
		{"name":"Burning Geometry", "type":"notable", "stats":{"Area Radius":0.06, "Fire Damage":0.10}, "rules":["passive:burning_geometry"], "description":"Fire projectile skills gain better area payoff when supported or relic-modified."},
		{"name":"Spell Furnace", "stats":{"Spell Damage":0.08, "Cast Speed":0.03}, "tags":["spell"]},
		{"name":"Pyroclastic Thesis", "type":"notable", "stats":{"Fire Damage":0.16, "Ignite Chance":10.0}, "rules":["passive:fireball_identity"], "description":"Fireball and fire projectile builds get a strong identity hook for relics and item rules."},
	])
	_add_lane(out, "sorc_storm", "Sorceress · Lightning / Chain / Shock", "north_arcane", "sorceress", "lightning_chain_shock", [
		{"name":"Static Study", "stats":{"Lightning Damage":0.06}, "tags":["lightning"]},
		{"name":"Conductive Path", "stats":{"Shock Chance":6.0, "Projectile Speed":0.04}, "tags":["shock"]},
		{"name":"Chain Geometry", "type":"notable", "stats":{"Chain Bonus":1.0, "Lightning Damage":0.08}, "rules":["passive:chain_geometry"], "description":"Lightning projectiles prefer chain-based supports and item affixes."},
		{"name":"Storm Reservoir", "stats":{"Maximum Mana":12.0, "Mana Regeneration":2.0}, "tags":["mana"]},
		{"name":"Quick Discharge", "stats":{"Cast Speed":0.05}, "tags":["spell"]},
		{"name":"Arc Lattice", "type":"notable", "stats":{"Lightning Damage":0.12, "Shock Chance":8.0}, "rules":["passive:arc_lattice"], "description":"Shock and chain effects become mutually reinforcing."},
		{"name":"Charged Focus", "stats":{"Critical Chance":0.04, "Spell Damage":0.05}, "tags":["crit"]},
		{"name":"Thunder Memory", "type":"notable", "stats":{"Lightning Damage":0.10, "Cooldown Recovery":0.06}, "rules":["passive:thunder_memory"], "description":"Repeated lightning casting improves tempo and cooldown-oriented supports."},
		{"name":"Stormglass Mind", "stats":{"Maximum Mana":18.0, "Spell Damage":0.06}, "tags":["mana"]},
		{"name":"Volt Crown", "type":"notable", "stats":{"Lightning Damage":0.16, "Chain Bonus":1.0}, "rules":["passive:storm_lance_identity"], "description":"Storm Lance and lightning projectile builds gain a major identity hook."},
	])
	_add_lane(out, "sorc_arcane", "Sorceress · Mana / Spirit / Chronomancy", "north_arcane", "sorceress", "mana_spirit_time", [
		{"name":"Reservoir Mind", "stats":{"Maximum Mana":14.0}, "tags":["mana"]},
		{"name":"Spirit Circuit", "stats":{"Maximum Spirit":5.0}, "tags":["spirit"]},
		{"name":"Efficient Incantation", "type":"notable", "stats":{"Mana Cost":-0.06, "Cast Speed":0.04}, "rules":["passive:efficient_incantation"], "description":"Mana economy becomes a build axis rather than only a flask problem."},
		{"name":"Cooldown Diagram", "stats":{"Cooldown Recovery":0.06}, "tags":["cooldown"]},
		{"name":"Time Needle", "stats":{"Cast Speed":0.04, "Spell Damage":0.06}, "tags":["spell"]},
		{"name":"Echo Discipline", "type":"notable", "stats":{"Spell Damage":0.10, "Cooldown Recovery":0.06}, "rules":["passive:echo_discipline"], "description":"Repeat/echo-style spells and relic effects gain support."},
		{"name":"Spirit Efficiency", "stats":{"Spirit Reservation Efficiency":0.06, "Maximum Spirit":5.0}, "tags":["spirit"]},
		{"name":"Temporal Ward", "type":"notable", "stats":{"Runic Ward":24.0, "Maximum Mana":18.0}, "rules":["passive:temporal_ward"], "description":"Mana and ward begin to overlap as a defensive mage lane."},
		{"name":"Focused Channel", "stats":{"Spell Damage":0.08, "Mana Regeneration":3.0}, "tags":["spell"]},
		{"name":"Arcane Continuum", "type":"notable", "stats":{"Maximum Mana":30.0, "Cooldown Recovery":0.10}, "rules":["passive:arcane_continuum"], "description":"The main Sorceress mana/time capstone before keystones and ascendancy."},
	])
	_add_lane(out, "war_slam", "Warrior · Mace / Slam / Stun", "west_martial", "warrior", "mace_slam_stun", [
		{"name":"Heavy Grip", "stats":{"Attack Damage":0.06}, "tags":["attack"]},
		{"name":"Mace Weight", "stats":{"Mace Damage":0.08, "Stun Buildup":0.05}, "tags":["mace", "stun"]},
		{"name":"Slam Foundation", "type":"notable", "stats":{"Slam Damage":0.10, "Area Radius":0.06}, "rules":["passive:slam_foundation"], "description":"Slam skills get enough area and weight to feel like the Warrior identity."},
		{"name":"Crushing Angle", "stats":{"Stun Buildup":0.08, "Physical Damage":0.05}, "tags":["stun"]},
		{"name":"Broad Impact", "stats":{"Area Damage":0.07, "Area Radius":0.05}, "tags":["area"]},
		{"name":"Aftershock Training", "type":"notable", "stats":{"Slam Damage":0.12, "Area Radius":0.08}, "rules":["passive:slam_aftershock_training"], "description":"Slam builds gain a hook for aftershock effects from items and ascendancy."},
		{"name":"Skullbreaker", "stats":{"Physical Damage":0.08, "Stun Buildup":0.08}, "tags":["physical"]},
		{"name":"Stun Engine", "type":"notable", "stats":{"Stun Buildup":0.16}, "rules":["passive:stun_identity"], "description":"Stunned enemies become a payoff state, not just incidental crowd control."},
		{"name":"Two-Handed Leverage", "stats":{"Mace Damage":0.12, "Attack Speed":-0.02}, "tags":["mace"]},
		{"name":"Faultline Method", "type":"notable", "stats":{"Slam Damage":0.16, "Area Damage":0.10}, "rules":["passive:faultline_method"], "description":"The Warrior's slam route prepares for Titan aftershocks and shockwaves."},
	])
	_add_lane(out, "war_guard", "Warrior · Armor / Block / Ward", "west_martial", "warrior", "armor_block_ward", [
		{"name":"Layered Plate", "stats":{"Armor":24.0}, "tags":["armor"]},
		{"name":"Blooded Frame", "stats":{"Maximum Life":16.0}, "tags":["life"]},
		{"name":"Guarded Advance", "type":"notable", "stats":{"Block Chance":4.0, "Armor":20.0}, "rules":["passive:guarded_advance"], "description":"Blocking and armor start to reinforce aggressive melee positioning."},
		{"name":"Iron Breath", "stats":{"Maximum Life":12.0, "Physical Reduction":0.02}, "tags":["defense"]},
		{"name":"Shield Weight", "stats":{"Block Chance":3.0, "Armor":18.0}, "tags":["block"]},
		{"name":"Unbreakable Frame", "type":"notable", "stats":{"Maximum Life":22.0, "Armor":38.0}, "rules":["passive:armor_identity"], "description":"Armor identity lane for Juggernaut, ward runes, and defensive item builds."},
		{"name":"Vault Plating", "stats":{"Runic Ward":20.0, "Armor":18.0}, "tags":["ward"]},
		{"name":"Emergency Guard", "type":"notable", "stats":{"Runic Ward":38.0, "Block Chance":4.0}, "rules":["passive:emergency_guard"], "description":"Low-life emergency protection becomes a Warrior defensive style."},
		{"name":"Iron March", "stats":{"Movement Speed":0.02, "Armor":24.0}, "tags":["armor"]},
		{"name":"Bastion Doctrine", "type":"notable", "stats":{"Armor":55.0, "Physical Reduction":0.04}, "rules":["passive:bastion_doctrine"], "description":"Main tank route before Juggernaut and Stone Oath."},
	])
	_add_lane(out, "war_rage", "Warrior · Rage / Warcry / Explosions", "west_martial", "warrior", "rage_warcry_explode", [
		{"name":"Battle Tempo", "stats":{"Attack Speed":0.04}, "tags":["attack"]},
		{"name":"War Echo", "stats":{"Attack Damage":0.07}, "rules":["passive:warcry_identity"], "tags":["warcry"]},
		{"name":"Roaring Setup", "type":"notable", "stats":{"Attack Damage":0.10, "Cooldown Recovery":0.05}, "rules":["passive:roaring_setup"], "description":"Warcry-like effects empower the next committed attack."},
		{"name":"Rage Heat", "stats":{"Attack Speed":0.05, "Physical Damage":0.04}, "tags":["rage"]},
		{"name":"Blood Pressure", "stats":{"Maximum Life":10.0, "Attack Damage":0.05}, "tags":["life"]},
		{"name":"Rage Furnace", "type":"notable", "stats":{"Attack Speed":0.07, "Physical Damage":0.08}, "rules":["passive:rage_furnace"], "description":"Taking and dealing melee damage can become a tempo engine."},
		{"name":"Crackling Kill", "stats":{"Physical Damage":0.08, "Area Damage":0.05}, "tags":["area"]},
		{"name":"Corpse Breaker", "type":"notable", "stats":{"Area Damage":0.12}, "rules":["passive:heavy_kill_explosion"], "description":"Heavy kills become a clear-speed route for melee."},
		{"name":"Banner Pressure", "stats":{"Stun Buildup":0.10, "Attack Damage":0.06}, "tags":["stun"]},
		{"name":"Ruin Chant", "type":"notable", "stats":{"Attack Damage":0.14, "Cooldown Recovery":0.08}, "rules":["passive:ruin_chant"], "description":"The Warbringer lane's pre-ascendancy identity."},
	])
	_add_lane(out, "hunt_proj", "Huntress · Bow / Projectile / Far Shot", "east_hunt", "huntress", "bow_projectile_farshot", [
		{"name":"Clean Draw", "stats":{"Projectile Damage":0.06}, "tags":["projectile"]},
		{"name":"Bowstring Tension", "stats":{"Bow Damage":0.08, "Projectile Speed":0.05}, "tags":["bow"]},
		{"name":"Piercing Lesson", "type":"notable", "stats":{"Projectile Pierce":1.0, "Projectile Damage":0.06}, "rules":["passive:pierce_identity"], "description":"Pierce becomes a build route for bow and projectile skills."},
		{"name":"Long Angle", "stats":{"Projectile Speed":0.08, "Critical Chance":0.03}, "tags":["projectile"]},
		{"name":"Light Step", "stats":{"Movement Speed":0.04}, "tags":["speed"]},
		{"name":"Far Shot Discipline", "type":"notable", "stats":{"Projectile Damage":0.12, "Projectile Speed":0.12}, "rules":["passive:far_shot_identity"], "description":"Distance becomes a damage axis."},
		{"name":"Arrow Split", "stats":{"Extra Projectiles":1.0, "Projectile Damage":0.04}, "tags":["projectile"]},
		{"name":"Perfect Line", "type":"notable", "stats":{"Critical Chance":0.05, "Projectile Damage":0.10}, "rules":["passive:perfect_line"], "description":"Pierce, chain, and crit can share one projectile identity."},
		{"name":"Windstring", "stats":{"Attack Speed":0.06, "Movement Speed":0.03}, "tags":["speed"]},
		{"name":"Horizon Kill", "type":"notable", "stats":{"Projectile Damage":0.16, "Projectile Speed":0.14}, "rules":["passive:horizon_kill"], "description":"The main Deadeye-style route before ascendancy."},
	])
	_add_lane(out, "hunt_mark", "Huntress · Marks / Crit / Execution", "east_hunt", "huntress", "mark_crit_execute", [
		{"name":"Sure Aim", "stats":{"Critical Chance":0.04}, "tags":["crit"]},
		{"name":"Marked Prey", "stats":{"Mark Effect":0.10}, "tags":["mark"]},
		{"name":"Predator's Step", "type":"notable", "stats":{"Movement Speed":0.05, "Critical Chance":0.04}, "rules":["passive:mobility_identity"], "description":"Movement and targeting reinforce each other."},
		{"name":"Weak Point", "stats":{"Critical Multiplier":0.14}, "tags":["crit"]},
		{"name":"Red Trail", "stats":{"Bleed Chance":8.0, "Bleed Damage":0.08}, "tags":["bleed"]},
		{"name":"Marked Execution", "type":"notable", "stats":{"Critical Multiplier":0.20, "Execute More":0.10}, "rules":["passive:marked_execution"], "description":"Low-life marked enemies become kill targets."},
		{"name":"Ambush Tempo", "stats":{"Attack Speed":0.05, "Movement Speed":0.03}, "tags":["speed"]},
		{"name":"First Blood Rule", "type":"notable", "stats":{"Critical Chance":0.06, "Bleed Chance":8.0}, "rules":["passive:first_blood_rule"], "description":"First hits and opening windows gain real value."},
		{"name":"Execution Math", "stats":{"Execute More":0.12, "Projectile Damage":0.06}, "tags":["execute"]},
		{"name":"Killing Angle", "type":"notable", "stats":{"Critical Multiplier":0.24, "Mark Effect":0.12}, "rules":["passive:killing_angle"], "description":"Nightstalker-style execution route."},
	])
	_add_lane(out, "hunt_trap", "Huntress · Traps / Control / Evasion", "east_hunt", "huntress", "trap_control_evasion", [
		{"name":"Trapcraft", "stats":{"Trap Damage":0.08}, "tags":["trap"]},
		{"name":"Evasive Hunt", "stats":{"Evasion":20.0, "Movement Speed":0.02}, "tags":["evasion"]},
		{"name":"Snare Geometry", "type":"notable", "stats":{"Trap Damage":0.12, "Cooldown Recovery":0.04}, "rules":["passive:trap_identity"], "description":"Traps and snares become a control lane."},
		{"name":"Poison Barb", "stats":{"Poison Chance":8.0, "Damage Over Time":0.08}, "tags":["poison"]},
		{"name":"Control Distance", "stats":{"Projectile Damage":0.05, "Evasion":18.0}, "tags":["evasion"]},
		{"name":"Predator Ground", "type":"notable", "stats":{"Trap Damage":0.12, "Projectile Damage":0.08}, "rules":["passive:predator_ground"], "description":"Enemies affected by slows, roots, or traps become better projectile targets."},
		{"name":"Reflex Pattern", "stats":{"Evasion":28.0, "Movement Speed":0.03}, "tags":["evasion"]},
		{"name":"Field Warden", "type":"notable", "stats":{"Evasion":36.0, "Physical Reduction":0.03}, "rules":["passive:field_warden"], "description":"Survival improves around controlled ground."},
		{"name":"Quick Reset", "stats":{"Cooldown Recovery":0.08, "Trap Damage":0.06}, "tags":["cooldown"]},
		{"name":"Hunter's Net", "type":"notable", "stats":{"Trap Damage":0.16, "Evasion":30.0}, "rules":["passive:hunters_net"], "description":"Warden-style trap/survival route."},
	])
	_add_center_clusters(out)
	_add_keystones(out)
	return out

static func node(node_id: String) -> Dictionary:
	var all: Dictionary = nodes()
	if all.has(node_id):
		return Dictionary(all[node_id]).duplicate(true)
	return {}

static func node_ids() -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in nodes().keys():
		ids.append(str(key))
	ids.sort()
	return ids

static func regions() -> Array[String]:
	return ["all", "class", "north_arcane", "west_martial", "east_hunt", "center_core", "keystone"]

static func _add_lane(out: Dictionary, prefix: String, label: String, region: String, class_bias: String, lane: String, entries: Array) -> void:
	for i: int in range(entries.size()):
		var e: Dictionary = Dictionary(entries[i])
		var id: String = prefix + "_" + str(i + 1).pad_zeros(2)
		var requires: Array = Array(e.get("requires", []))
		if i > 0 and requires.is_empty():
			requires.append(prefix + "_" + str(i).pad_zeros(2))
		var ntype: String = str(e.get("type", "small"))
		out[id] = {
			"id": id,
			"name": str(e.get("name", label + " Node")),
			"region": region,
			"lane": lane,
			"lane_label": label,
			"class_bias": class_bias,
			"type": ntype,
			"tier": int(e.get("tier", i + 1)),
			"cost": int(e.get("cost", 1)),
			"requires": requires.duplicate(true),
			"stats": Dictionary(e.get("stats", {})).duplicate(true),
			"rules": Array(e.get("rules", [])).duplicate(true),
			"tags": Array(e.get("tags", [])).duplicate(true),
			"description": str(e.get("description", "")),
		}

static func _add_center_clusters(out: Dictionary) -> void:
	_add_lane(out, "core_life", "Center · Life / Recovery", "center_core", "any", "life_recovery", [
		{"name":"Survival Training", "stats":{"Maximum Life":10.0}},
		{"name":"Deep Breath", "stats":{"Maximum Life":14.0}},
		{"name":"Recovery Form", "type":"notable", "stats":{"Life Regeneration":2.0, "Maximum Life":16.0}, "rules":["passive:recovery_form"], "description":"Early generic sustain path."},
		{"name":"Thick Nerves", "stats":{"Maximum Life":12.0, "Block Chance":2.0}},
		{"name":"Last Reserve", "type":"notable", "stats":{"Runic Ward":30.0, "Maximum Life":10.0}, "rules":["passive:last_reserve"]},
	])
	_add_lane(out, "core_resource", "Center · Mana / Spirit", "center_core", "any", "resource", [
		{"name":"Reservoir", "stats":{"Maximum Mana":10.0}},
		{"name":"Spirit Vessel", "stats":{"Maximum Spirit":5.0}},
		{"name":"Efficient Form", "type":"notable", "stats":{"Mana Cost":-0.04, "Spirit Reservation Efficiency":0.04}, "rules":["passive:resource_efficiency"]},
		{"name":"Deep Circuit", "stats":{"Maximum Mana":14.0, "Mana Regeneration":2.0}},
		{"name":"Voltaic Vessel", "type":"notable", "stats":{"Maximum Spirit":8.0, "Maximum Mana":18.0}, "rules":["passive:voltaic_vessel"]},
	])
	_add_lane(out, "core_attribute", "Center · Attributes / Travel", "center_core", "any", "attributes", [
		{"name":"Strength Travel", "stats":{"Strength":5.0}},
		{"name":"Dexterity Travel", "stats":{"Dexterity":5.0}},
		{"name":"Intelligence Travel", "stats":{"Intelligence":5.0}},
		{"name":"Cross Training", "type":"notable", "stats":{"Strength":5.0, "Dexterity":5.0, "Intelligence":5.0}, "rules":["passive:cross_training"]},
		{"name":"Adaptive Combatant", "type":"notable", "stats":{"Attack Damage":0.04, "Spell Damage":0.04, "Projectile Damage":0.04}, "rules":["passive:adaptive_combatant"]},
	])
	_add_lane(out, "core_forge", "Center · Forge / Runes / Loot", "center_core", "any", "forge_rune_loot", [
		{"name":"Relic Handling", "stats":{"Forge Potential Bonus":1.0}, "rules":["passive:forge_handling"]},
		{"name":"Socket Discipline", "stats":{"Rune Effect":0.06}, "rules":["passive:rune_identity"]},
		{"name":"Seal Literacy", "type":"notable", "stats":{"Essence Effect":0.08}, "rules":["passive:seal_literacy"], "description":"Essence/Seal crafts become a deliberate progression lane."},
		{"name":"Scavenger's Eye", "stats":{"Item Rarity":0.05, "Salvage Yield":0.08}, "rules":["passive:loot_instinct"]},
		{"name":"Vault Artisan", "type":"notable", "stats":{"Forge Potential Bonus":2.0, "Rune Effect":0.08}, "rules":["passive:vault_artisan"], "description":"Generic crafting route for item-project builds."},
	])

static func _add_keystones(out: Dictionary) -> void:
	var keys: Array = [
		{"id":"key_blood_price", "name":"Blood Price", "class_bias":"sorceress", "region":"keystone", "lane":"blood_magic", "requires":["sorc_arcane_10"], "stats":{"Spell Damage":0.12}, "rules":["keystone:blood_price"], "description":"Skills may spend life if mana is insufficient. Life flask recovery is reduced."},
		{"id":"key_elemental_pact", "name":"Elemental Pact", "class_bias":"sorceress", "region":"keystone", "lane":"elemental", "requires":["sorc_fire_10", "sorc_storm_10"], "stats":{"Elemental Damage":0.18}, "rules":["keystone:elemental_pact"], "description":"Alternating elements grants power. Repeating the same element too often is less efficient."},
		{"id":"key_arcane_debt", "name":"Arcane Debt", "class_bias":"sorceress", "region":"keystone", "lane":"mana", "requires":["sorc_arcane_10"], "stats":{"Maximum Mana":45.0, "Mana Cost":0.08}, "rules":["keystone:arcane_debt"], "description":"More mana and stronger mana scaling, but skills cost more."},
		{"id":"key_stone_oath", "name":"Stone Oath", "class_bias":"warrior", "region":"keystone", "lane":"armor", "requires":["war_guard_10"], "stats":{"Armor":70.0, "Movement Speed":-0.04}, "rules":["keystone:stone_oath"], "description":"Armor helps against elemental hits. You move slower."},
		{"id":"key_colossus", "name":"Colossus", "class_bias":"warrior", "region":"keystone", "lane":"slam", "requires":["war_slam_10"], "stats":{"Slam Damage":0.22, "Attack Speed":-0.06}, "rules":["keystone:colossus"], "description":"Slams become slower but much more destructive."},
		{"id":"key_battle_furnace", "name":"Battle Furnace", "class_bias":"warrior", "region":"keystone", "lane":"rage", "requires":["war_rage_10"], "stats":{"Attack Damage":0.14, "Physical Reduction":-0.03}, "rules":["keystone:battle_furnace"], "description":"Rage and aggression scale harder, but you are more vulnerable while overextended."},
		{"id":"key_overdraw", "name":"Overdraw", "class_bias":"huntress", "region":"keystone", "lane":"projectile", "requires":["hunt_proj_10"], "stats":{"Projectile Damage":0.18, "Projectile Speed":0.14}, "rules":["keystone:overdraw"], "description":"Projectiles gain power at range, but close-range damage is reduced."},
		{"id":"key_predator_mark", "name":"Predator Mark", "class_bias":"huntress", "region":"keystone", "lane":"mark", "requires":["hunt_mark_10"], "stats":{"Mark Effect":0.20, "Execute More":0.12}, "rules":["keystone:predator_mark"], "description":"Marks become execution engines instead of basic target labels."},
		{"id":"key_silent_field", "name":"Silent Field", "class_bias":"huntress", "region":"keystone", "lane":"trap", "requires":["hunt_trap_10"], "stats":{"Trap Damage":0.18, "Movement Speed":-0.03}, "rules":["keystone:silent_field"], "description":"Traps and control zones become stronger, but direct mobility is lower."},
		{"id":"key_volatile_spirit", "name":"Volatile Spirit", "class_bias":"any", "region":"keystone", "lane":"spirit", "requires":["core_resource_05"], "stats":{"Maximum Spirit":12.0, "Maximum Mana":-12.0}, "rules":["keystone:volatile_spirit"], "description":"Spirit effects are stronger. Maximum mana is reduced."},
		{"id":"key_relic_greed", "name":"Relic Greed", "class_bias":"any", "region":"keystone", "lane":"forge", "requires":["core_forge_05"], "stats":{"Item Rarity":0.10, "Forge Potential Bonus":2.0}, "rules":["keystone:relic_greed"], "description":"Better item-project potential, but risky forge outcomes become more tempting."},
		{"id":"key_glass_cannon", "name":"Glass Cannon", "class_bias":"any", "region":"keystone", "lane":"damage", "requires":["core_attribute_05"], "stats":{"Attack Damage":0.10, "Spell Damage":0.10, "Maximum Life":-18.0}, "rules":["keystone:glass_cannon"], "description":"All damage improves, but maximum life is lower."},
	]
	for e: Dictionary in keys:
		var id: String = str(e.get("id", ""))
		out[id] = {
			"id": id,
			"name": str(e.get("name", id.capitalize())),
			"region": str(e.get("region", "keystone")),
			"lane": str(e.get("lane", "keystone")),
			"lane_label": "Keystones",
			"class_bias": str(e.get("class_bias", "any")),
			"type": "keystone",
			"tier": 99,
			"cost": int(e.get("cost", 1)),
			"requires": Array(e.get("requires", [])).duplicate(true),
			"stats": Dictionary(e.get("stats", {})).duplicate(true),
			"rules": Array(e.get("rules", [])).duplicate(true),
			"tags": Array(e.get("tags", [])).duplicate(true),
			"description": str(e.get("description", "")),
		}
