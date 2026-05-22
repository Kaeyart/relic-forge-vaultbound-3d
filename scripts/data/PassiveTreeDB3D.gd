extends RefCounted
class_name RVPassiveTreeDB3D

const CLASS_START_NODES: Dictionary = {
	"sorceress": "sorc_fire_00",
	"warrior": "war_slam_00",
	"huntress": "hunt_projectile_00",
}

static func all_nodes() -> Dictionary:
	var nodes: Dictionary = {}
	_add_lane(nodes, "sorc_fire", "Sorceress / Fire", "sorceress", "Fire Projectile", "spell", "fire", "Fire Damage", "Ignite Chance", ["fire", "spell", "projectile", "ignite"], "kindling_heart")
	_add_lane(nodes, "sorc_storm", "Sorceress / Storm", "sorceress", "Storm Chain", "spell", "lightning", "Lightning Damage", "Shock Chance", ["lightning", "spell", "chain", "shock"], "storm_loop")
	_add_lane(nodes, "sorc_mana_time", "Sorceress / Mana-Time", "sorceress", "Mana-Time", "spell", "mana", "Maximum Mana", "Cast Speed", ["mana", "spirit", "cooldown", "echo"], "borrowed_minute")
	_add_lane(nodes, "war_slam", "Warrior / Slam", "warrior", "Mace Slam", "attack", "slam", "Slam Damage", "Stun Buildup", ["mace", "slam", "stun", "aftershock"], "earth_breaker")
	_add_lane(nodes, "war_armor", "Warrior / Armor", "warrior", "Armor Guard", "defense", "armor", "Armor", "Block Chance", ["armor", "block", "ward", "mitigation"], "stone_oath")
	_add_lane(nodes, "war_rage", "Warrior / Rage", "warrior", "Rage Warcry", "attack", "rage", "Physical Damage", "Rage Gain", ["rage", "warcry", "shockwave", "physical"], "red_furnace")
	_add_lane(nodes, "hunt_projectile", "Huntress / Projectile", "huntress", "Bow Projectile", "attack", "projectile", "Projectile Damage", "Projectile Speed", ["bow", "projectile", "chain", "farshot"], "overdraw")
	_add_lane(nodes, "hunt_mark", "Huntress / Mark", "huntress", "Mark Crit", "attack", "mark", "Critical Chance", "Critical Multiplier", ["mark", "crit", "execute", "precision"], "marked_quarry")
	_add_lane(nodes, "hunt_trap", "Huntress / Trap", "huntress", "Trap Control", "utility", "trap", "Trap Damage", "Trap Arming Speed", ["trap", "snare", "slow", "control"], "predators_ground")
	_add_center(nodes)
	return nodes

static func _add_lane(nodes: Dictionary, prefix: String, region: String, class_id: String, lane_name: String, skill_kind: String, element_tag: String, stat_a: String, stat_b: String, tags: Array, keystone_suffix: String) -> void:
	var prev: String = ""
	for i: int in range(0, 8):
		var node_id: String = prefix + "_" + str(i).pad_zeros(2)
		var node_type: String = "small"
		var stats: Dictionary = {}
		var rules: Array[String] = []
		var title: String = lane_name + " " + str(i + 1)
		if i % 2 == 0:
			stats[stat_a] = 5.0 + float(i)
		else:
			stats[stat_b] = 3.0 + float(i)
		if i == 3 or i == 6:
			node_type = "notable"
			stats[stat_a] = 12.0 + float(i * 2)
			stats[stat_b] = 8.0 + float(i)
			rules.append("passive:" + prefix + "_notable_" + str(i))
			title = lane_name + " Notable " + str(i)
		var requires: Array[String] = []
		if prev != "":
			requires.append(prev)
		nodes[node_id] = _node(node_id, title, region, class_id, lane_name, node_type, stats, rules, requires, tags)
		prev = node_id
	var key_id: String = "keystone_" + keystone_suffix
	var key_stats: Dictionary = {}
	var key_rules: Array[String] = ["keystone:" + keystone_suffix]
	match keystone_suffix:
		"kindling_heart":
			key_stats = {"Fire Damage": 18.0, "Ignite Chance": 12.0, "Maximum Mana": -8.0}
		"storm_loop":
			key_stats = {"Lightning Damage": 16.0, "Chain Bonus": 1.0, "Mana Cost": 8.0}
		"borrowed_minute":
			key_stats = {"Cast Speed": 0.08, "Maximum Mana": 18.0, "Armor": -8.0}
		"earth_breaker":
			key_stats = {"Slam Damage": 20.0, "Stun Buildup": 15.0, "Attack Speed": -0.05}
		"stone_oath":
			key_stats = {"Armor": 30.0, "Elemental Mitigation": 0.06, "Movement Speed": -0.04}
		"red_furnace":
			key_stats = {"Rage Gain": 1.0, "Physical Damage": 12.0, "Maximum Mana": -10.0}
		"overdraw":
			key_stats = {"Projectile Damage": 18.0, "Projectile Speed": 12.0, "Armor": -8.0}
		"marked_quarry":
			key_stats = {"Critical Chance": 0.08, "Critical Multiplier": 18.0, "Maximum Life": -8.0}
		"predators_ground":
			key_stats = {"Trap Damage": 18.0, "Trap Arming Speed": 0.12, "Movement Speed": -0.03}
		_:
			key_stats = {stat_a: 16.0}
	nodes[key_id] = _node(key_id, lane_name + " Keystone", region, class_id, lane_name, "keystone", key_stats, key_rules, [prev], tags)

static func _add_center(nodes: Dictionary) -> void:
	var center_lanes: Array = [
		["center_life", "Center / Life", "Life", "Maximum Life", "Armor", ["life", "defense"]],
		["center_resource", "Center / Resource", "Resource", "Maximum Mana", "Maximum Spirit", ["mana", "spirit"]],
		["center_attributes", "Center / Attributes", "Attributes", "Strength", "Dexterity", ["attribute", "travel"]],
		["center_forge", "Center / Forge", "Forge", "Forge Potential Bonus", "Rune Effect", ["forge", "rune", "crafting"]],
	]
	for lane_value: Variant in center_lanes:
		var lane: Array = Array(lane_value)
		var prefix: String = str(lane[0])
		var region: String = str(lane[1])
		var lane_name: String = str(lane[2])
		var stat_a: String = str(lane[3])
		var stat_b: String = str(lane[4])
		var tags: Array = Array(lane[5])
		var prev: String = ""
		for i: int in range(0, 6):
			var node_id: String = prefix + "_" + str(i).pad_zeros(2)
			var stats: Dictionary = {}
			stats[stat_a] = 5.0 + float(i)
			if i % 2 == 1:
				stats[stat_b] = 4.0 + float(i)
			var node_type: String = "travel" if prefix == "center_attributes" else "small"
			var rules: Array[String] = []
			if i == 4:
				node_type = "notable"
				rules.append("passive:" + prefix + "_notable")
			var requires: Array[String] = []
			if prev != "":
				requires.append(prev)
			nodes[node_id] = _node(node_id, lane_name + " " + str(i + 1), region, "center", lane_name, node_type, stats, rules, requires, tags)
			prev = node_id

static func _node(id: String, title: String, region: String, class_id: String, lane: String, node_type: String, stats: Dictionary, rules: Array, requires: Array, tags: Array) -> Dictionary:
	return {
		"id": id,
		"title": title,
		"display_name": title,
		"region": region,
		"class_id": class_id,
		"lane": lane,
		"type": node_type,
		"stats": stats,
		"rules": rules,
		"requires": requires,
		"tags": tags,
		"cost": 1,
		"description": _description(title, node_type, stats, rules),
	}

static func _description(title: String, node_type: String, stats: Dictionary, rules: Array) -> String:
	var text: String = title + "\n" + node_type.capitalize() + " node."
	for key: Variant in stats.keys():
		text += "\n" + str(key) + ": " + str(stats[key])
	for rule: Variant in rules:
		text += "\nRule: " + str(rule)
	return text

static func node(id: String) -> Dictionary:
	var nodes: Dictionary = all_nodes()
	if nodes.has(id):
		return Dictionary(nodes[id]).duplicate(true)
	return {}

static func has_node(id: String) -> bool:
	return all_nodes().has(id)

static func node_ids() -> Array:
	return all_nodes().keys()

static func class_start_node(class_id: String) -> String:
	return str(CLASS_START_NODES.get(class_id, "sorc_fire_00"))

static func nodes_for_class(class_id: String, include_center: bool = true) -> Array:
	var result: Array = []
	var nodes: Dictionary = all_nodes()
	for id_value: Variant in nodes.keys():
		var n: Dictionary = Dictionary(nodes[id_value])
		var owner: String = str(n.get("class_id", ""))
		if owner == class_id or (include_center and owner == "center"):
			result.append(n)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
	return result

static func available(node_id: String, allocated: Dictionary, class_id: String) -> bool:
	if allocated.has(node_id):
		return false
	var n: Dictionary = node(node_id)
	if n.is_empty():
		return false
	var owner: String = str(n.get("class_id", ""))
	if owner != class_id and owner != "center":
		return false
	var requires: Array = Array(n.get("requires", []))
	if requires.is_empty():
		return true
	for req: Variant in requires:
		if allocated.has(str(req)):
			return true
	return false

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
