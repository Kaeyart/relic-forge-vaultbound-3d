class_name RVPassiveTreeDB3D
extends RefCounted

static func nodes() -> Dictionary:
	var out: Dictionary = {}
	_add_class_cluster(out, "sorc", "Sorceress", "north_arcane", "sorceress", [
		{"name":"Arcane Spark", "stats":{"Spell Damage":0.06}},
		{"name":"Mana Channel", "stats":{"Maximum Mana":10.0}},
		{"name":"Ember Study", "stats":{"Fire Damage":0.07}},
		{"name":"Storm Study", "stats":{"Lightning Damage":0.07}},
		{"name":"Projectile Formula", "stats":{"Projectile Damage":0.06}},
		{"name":"Ailment Theory", "stats":{"Ignite Chance":5.0, "Shock Chance":5.0}},
		{"name":"Spirit Circuit", "stats":{"Maximum Spirit":5.0}},
		{"name":"Quick Incantation", "stats":{"Cast Speed":0.04}},
		{"name":"Elemental Scholar", "stats":{"Elemental Damage":0.10}, "rules":["passive:elemental_scholar"]},
		{"name":"Conduit Mind", "stats":{"Mana Cost":-0.05, "Maximum Mana":18.0}, "rules":["passive:conduit_mind"]},
		{"name":"Pyroclastic Method", "stats":{"Fire Damage":0.12, "Ignite Chance":8.0}, "rules":["passive:fire_identity"]},
		{"name":"Lightning Geometry", "stats":{"Lightning Damage":0.12, "Chain Bonus":1.0}, "rules":["passive:chain_identity"]}
	])
	_add_class_cluster(out, "war", "Warrior", "west_martial", "warrior", [
		{"name":"Heavy Grip", "stats":{"Attack Damage":0.06}},
		{"name":"Thick Plate", "stats":{"Armor":18.0}},
		{"name":"Blooded Frame", "stats":{"Maximum Life":12.0}},
		{"name":"Mace Weight", "stats":{"Mace Damage":0.08, "Stun Buildup":0.05}},
		{"name":"Slam Arc", "stats":{"Area Damage":0.07, "Area Radius":0.05}},
		{"name":"Crushing Rhythm", "stats":{"Attack Speed":0.04}},
		{"name":"Guarded Advance", "stats":{"Block Chance":3.0, "Armor":10.0}},
		{"name":"Physical Mastery", "stats":{"Physical Damage":0.08}},
		{"name":"Aftershock Training", "stats":{"Slam Damage":0.12, "Area Radius":0.08}, "rules":["passive:slam_aftershock_training"]},
		{"name":"Unbreakable Frame", "stats":{"Maximum Life":20.0, "Armor":35.0}, "rules":["passive:armor_identity"]},
		{"name":"Stun Engine", "stats":{"Stun Buildup":0.15}, "rules":["passive:stun_identity"]},
		{"name":"War Echo", "stats":{"Attack Damage":0.10}, "rules":["passive:warcry_identity"]}
	])
	_add_class_cluster(out, "hunt", "Huntress", "east_hunt", "huntress", [
		{"name":"Clean Draw", "stats":{"Projectile Damage":0.06}},
		{"name":"Light Step", "stats":{"Movement Speed":0.03}},
		{"name":"Sure Aim", "stats":{"Critical Chance":0.03}},
		{"name":"Bowstring Tension", "stats":{"Bow Damage":0.08}},
		{"name":"Piercing Lesson", "stats":{"Projectile Pierce":1.0}},
		{"name":"Marked Prey", "stats":{"Mark Effect":0.10}},
		{"name":"Evasive Hunt", "stats":{"Evasion":18.0}},
		{"name":"Trapcraft", "stats":{"Trap Damage":0.08, "Cooldown Recovery":0.04}},
		{"name":"Far Shot Discipline", "stats":{"Projectile Damage":0.12, "Projectile Speed":0.12}, "rules":["passive:far_shot_identity"]},
		{"name":"Predator's Step", "stats":{"Movement Speed":0.06, "Critical Chance":0.04}, "rules":["passive:mobility_identity"]},
		{"name":"Marked Execution", "stats":{"Critical Multiplier":0.20}, "rules":["passive:marked_execution"]},
		{"name":"Snare Geometry", "stats":{"Trap Damage":0.12, "Projectile Damage":0.06}, "rules":["passive:trap_identity"]}
	])
	_add_generic_cluster(out)
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

static func _add_class_cluster(out: Dictionary, prefix: String, label: String, region: String, class_bias: String, entries: Array) -> void:
	var previous: String = ""
	for i: int in range(entries.size()):
		var e: Dictionary = Dictionary(entries[i])
		var id: String = prefix + "_" + str(i + 1).pad_zeros(2)
		var requires: Array[String] = []
		if previous != "":
			requires.append(previous)
		out[id] = {
			"id": id,
			"name": str(e.get("name", label + " Node")),
			"region": region,
			"class_bias": class_bias,
			"type": "notable" if i >= 8 else "small",
			"cost": 1,
			"requires": requires,
			"stats": Dictionary(e.get("stats", {})).duplicate(true),
			"rules": Array(e.get("rules", [])).duplicate(true),
			"description": str(e.get("description", "")),
		}
		previous = id

static func _add_generic_cluster(out: Dictionary) -> void:
	var generic: Array = [
		{"id":"core_life_01", "name":"Survival Training", "stats":{"Maximum Life":10.0}},
		{"id":"core_life_02", "name":"Deep Breath", "requires":["core_life_01"], "stats":{"Maximum Life":14.0}},
		{"id":"core_mana_01", "name":"Reservoir", "stats":{"Maximum Mana":10.0}},
		{"id":"core_mana_02", "name":"Efficient Casting", "requires":["core_mana_01"], "stats":{"Mana Cost":-0.04}},
		{"id":"core_speed_01", "name":"Combat Footwork", "stats":{"Movement Speed":0.03}},
		{"id":"core_armor_01", "name":"Layered Defense", "stats":{"Armor":16.0}},
		{"id":"core_damage_01", "name":"Killer Instinct", "stats":{"Attack Damage":0.04, "Spell Damage":0.04}},
		{"id":"core_crit_01", "name":"Vicious Timing", "stats":{"Critical Chance":0.03}},
		{"id":"core_spirit_01", "name":"Spirit Vessel", "stats":{"Maximum Spirit":5.0}},
		{"id":"core_forge_01", "name":"Relic Handling", "stats":{"Forge Potential Bonus":1.0}, "rules":["passive:forge_handling"]},
		{"id":"core_map_01", "name":"Vault Instinct", "stats":{"Item Rarity":0.05}, "rules":["passive:loot_instinct"]},
		{"id":"core_socket_01", "name":"Socket Discipline", "stats":{"Rune Effect":0.06}, "rules":["passive:rune_identity"]}
	]
	for e: Dictionary in generic:
		var id: String = str(e.get("id", ""))
		out[id] = {
			"id": id,
			"name": str(e.get("name", id.capitalize())),
			"region": "center_core",
			"class_bias": "any",
			"type": "notable" if Array(e.get("rules", [])).size() > 0 else "small",
			"cost": 1,
			"requires": Array(e.get("requires", [])).duplicate(true),
			"stats": Dictionary(e.get("stats", {})).duplicate(true),
			"rules": Array(e.get("rules", [])).duplicate(true),
			"description": str(e.get("description", "")),
		}

static func _add_keystones(out: Dictionary) -> void:
	var keys: Array = [
		{"id":"key_blood_price", "name":"Blood Price", "class_bias":"sorceress", "region":"north_arcane", "requires":["sorc_12"], "stats":{"Spell Damage":0.12}, "rules":["keystone:blood_price"], "description":"Skills may spend life when mana is insufficient. Life flask recovery is less effective."},
		{"id":"key_stone_oath", "name":"Stone Oath", "class_bias":"warrior", "region":"west_martial", "requires":["war_12"], "stats":{"Armor":50.0, "Movement Speed":-0.04}, "rules":["keystone:stone_oath"], "description":"Armor helps against elemental hits. You move slower."},
		{"id":"key_overdraw", "name":"Overdraw", "class_bias":"huntress", "region":"east_hunt", "requires":["hunt_12"], "stats":{"Projectile Damage":0.16, "Projectile Speed":0.12}, "rules":["keystone:overdraw"], "description":"Projectiles gain power at range, but close-range damage is reduced."},
		{"id":"key_volatile_spirit", "name":"Volatile Spirit", "class_bias":"any", "region":"center_core", "requires":["core_spirit_01"], "stats":{"Maximum Spirit":10.0, "Maximum Mana":-10.0}, "rules":["keystone:volatile_spirit"], "description":"Spirit effects are stronger. Maximum mana is reduced."}
	]
	for e: Dictionary in keys:
		var id: String = str(e.get("id", ""))
		out[id] = {
			"id": id,
			"name": str(e.get("name", id.capitalize())),
			"region": str(e.get("region", "center_core")),
			"class_bias": str(e.get("class_bias", "any")),
			"type": "keystone",
			"cost": 1,
			"requires": Array(e.get("requires", [])).duplicate(true),
			"stats": Dictionary(e.get("stats", {})).duplicate(true),
			"rules": Array(e.get("rules", [])).duplicate(true),
			"description": str(e.get("description", "")),
		}
