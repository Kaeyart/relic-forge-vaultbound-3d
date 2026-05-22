class_name RVAtlasSystem3D
extends RefCounted

const START_NODE_ID: String = "node_0_0"

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return

	var nodes: Dictionary = _dict(state.get("atlas_nodes"))
	if nodes.is_empty():
		nodes = _starter_nodes()
		state.set("atlas_nodes", nodes)

	# Make sure at least the start and first ring are reachable.
	for node_id: String in nodes.keys():
		var node: Dictionary = Dictionary(nodes[node_id])
		if not node.has("state"):
			node["state"] = "locked"
		if not node.has("revealed"):
			node["revealed"] = node_id == START_NODE_ID
		nodes[node_id] = node

	if nodes.has(START_NODE_ID):
		var start_node: Dictionary = Dictionary(nodes[START_NODE_ID])
		start_node["state"] = str(start_node.get("state", "available"))
		if str(start_node["state"]) == "locked":
			start_node["state"] = "available"
		start_node["revealed"] = true
		nodes[START_NODE_ID] = start_node

	state.set("atlas_nodes", nodes)

	var selected: String = str(state.get("selected_atlas_node_id"))
	if selected == "" or not nodes.has(selected):
		state.set("selected_atlas_node_id", _first_available_node_id(nodes))

	if str(state.get("atlas_origin_node_id")) == "":
		state.set("atlas_origin_node_id", START_NODE_ID)

	if typeof(state.get("atlas_completed_nodes")) != TYPE_DICTIONARY:
		state.set("atlas_completed_nodes", {})
	if typeof(state.get("atlas_failed_nodes")) != TYPE_DICTIONARY:
		state.set("atlas_failed_nodes", {})


static func node_list(state: Object) -> Array[Dictionary]:
	ensure_defaults(state)
	var nodes: Dictionary = _dict(state.get("atlas_nodes"))
	var out: Array[Dictionary] = []
	for node_id: String in nodes.keys():
		var node: Dictionary = Dictionary(nodes[node_id])
		if bool(node.get("revealed", false)):
			out.append(node)
	return out


static func selected_node(state: Object) -> Dictionary:
	ensure_defaults(state)
	var nodes: Dictionary = _dict(state.get("atlas_nodes"))
	var selected: String = str(state.get("selected_atlas_node_id"))
	if selected != "" and nodes.has(selected):
		return Dictionary(nodes[selected])
	var fallback: String = _first_available_node_id(nodes)
	state.set("selected_atlas_node_id", fallback)
	return Dictionary(nodes.get(fallback, {}))


static func select_node(state: Object, node_id: String) -> bool:
	ensure_defaults(state)
	var nodes: Dictionary = _dict(state.get("atlas_nodes"))
	if not nodes.has(node_id):
		return false
	var node: Dictionary = Dictionary(nodes[node_id])
	if not bool(node.get("revealed", false)):
		return false
	state.set("selected_atlas_node_id", node_id)
	return true


static func can_run_node(state: Object, node_id: String) -> bool:
	ensure_defaults(state)
	var nodes: Dictionary = _dict(state.get("atlas_nodes"))
	if not nodes.has(node_id):
		return false
	var node: Dictionary = Dictionary(nodes[node_id])
	var node_state: String = str(node.get("state", "locked"))
	return bool(node.get("revealed", false)) and (node_state == "available" or node_state == "failed" or node_state == "completed")


static func mark_attempted(state: Object, node_id: String) -> void:
	ensure_defaults(state)
	var nodes: Dictionary = _dict(state.get("atlas_nodes"))
	if not nodes.has(node_id):
		return
	var node: Dictionary = Dictionary(nodes[node_id])
	node["last_attempted"] = true
	nodes[node_id] = node
	state.set("atlas_nodes", nodes)
	state.set("active_map_node_id", node_id)


static func complete_node(state: Object, node_id: String) -> Dictionary:
	ensure_defaults(state)
	var result: Dictionary = {"completed": false, "unlocked": [], "revealed": []}
	var nodes: Dictionary = _dict(state.get("atlas_nodes"))
	if not nodes.has(node_id):
		return result

	var node: Dictionary = Dictionary(nodes[node_id])
	node["state"] = "completed"
	node["completed"] = true
	node["revealed"] = true
	nodes[node_id] = node

	var completed: Dictionary = _dict(state.get("atlas_completed_nodes"))
	completed[node_id] = true
	state.set("atlas_completed_nodes", completed)

	var unlocked: Array[String] = []
	var revealed: Array[String] = []
	for neighbor_value: Variant in Array(node.get("neighbors", [])):
		var neighbor_id: String = str(neighbor_value)
		if not nodes.has(neighbor_id):
			continue
		var neighbor: Dictionary = Dictionary(nodes[neighbor_id])
		if not bool(neighbor.get("revealed", false)):
			neighbor["revealed"] = true
			revealed.append(neighbor_id)
		if str(neighbor.get("state", "locked")) == "locked":
			neighbor["state"] = "available"
			unlocked.append(neighbor_id)
		nodes[neighbor_id] = neighbor

	if str(node.get("node_type", "normal")) == "tower":
		for extra_id: String in _nearby_node_ids(nodes, node):
			var extra: Dictionary = Dictionary(nodes[extra_id])
			if not bool(extra.get("revealed", false)):
				extra["revealed"] = true
				revealed.append(extra_id)
			if str(extra.get("state", "locked")) == "locked":
				extra["state"] = "available"
				unlocked.append(extra_id)
			nodes[extra_id] = extra

	state.set("atlas_nodes", nodes)
	result["completed"] = true
	result["unlocked"] = unlocked
	result["revealed"] = revealed
	return result


static func fail_node(state: Object, node_id: String) -> void:
	ensure_defaults(state)
	var nodes: Dictionary = _dict(state.get("atlas_nodes"))
	if not nodes.has(node_id):
		return
	var node: Dictionary = Dictionary(nodes[node_id])
	if str(node.get("state", "locked")) != "completed":
		node["state"] = "failed"
	nodes[node_id] = node
	state.set("atlas_nodes", nodes)
	var failed: Dictionary = _dict(state.get("atlas_failed_nodes"))
	failed[node_id] = true
	state.set("atlas_failed_nodes", failed)


static func node_display_name(node: Dictionary) -> String:
	return str(node.get("display_name", node.get("name", node.get("id", "Atlas Node"))))


static func node_type_label(node: Dictionary) -> String:
	match str(node.get("node_type", "normal")):
		"tower":
			return "Survey Spire"
		"powerful_boss":
			return "Powerful Boss"
		"citadel":
			return "Citadel"
		_:
			return "Map"


static func _starter_nodes() -> Dictionary:
	return {
		"node_0_0": _node("node_0_0", 0, 0, "Vault Mouth", "ash_vault", "normal", true, "available", ["node_1_0", "node_0_1", "node_-1_0", "node_0_-1"]),
		"node_1_0": _node("node_1_0", 1, 0, "Ash Foundry", "ash_foundry", "normal", true, "available", ["node_0_0", "node_2_0", "node_1_1"]),
		"node_0_1": _node("node_0_1", 0, 1, "Bone Archive", "bone_archive", "normal", true, "available", ["node_0_0", "node_1_1", "node_0_2"]),
		"node_-1_0": _node("node_-1_0", -1, 0, "Cinder Court", "cinder_court", "powerful_boss", true, "available", ["node_0_0", "node_-2_0"]),
		"node_0_-1": _node("node_0_-1", 0, -1, "Watchtower Ruin", "watchtower_ruin", "tower", true, "available", ["node_0_0", "node_1_-1", "node_-1_-1"]),
		"node_2_0": _node("node_2_0", 2, 0, "Ember Depths", "ember_depths", "normal", false, "locked", ["node_1_0", "node_3_0"]),
		"node_1_1": _node("node_1_1", 1, 1, "Marrow Gate", "marrow_gate", "normal", false, "locked", ["node_1_0", "node_0_1"]),
		"node_0_2": _node("node_0_2", 0, 2, "Ossuary Fold", "ossuary_fold", "normal", false, "locked", ["node_0_1"]),
		"node_-2_0": _node("node_-2_0", -2, 0, "Red Warden Seat", "red_warden_seat", "powerful_boss", false, "locked", ["node_-1_0"]),
		"node_1_-1": _node("node_1_-1", 1, -1, "Smoldering Causeway", "smoldering_causeway", "normal", false, "locked", ["node_0_-1"]),
		"node_-1_-1": _node("node_-1_-1", -1, -1, "Surveyed Furnace", "surveyed_furnace", "normal", false, "locked", ["node_0_-1"]),
		"node_3_0": _node("node_3_0", 3, 0, "Reliquary Gate", "reliquary_gate", "citadel", false, "locked", ["node_2_0"]),
	}


static func _node(id: String, x: int, y: int, display_name: String, biome: String, node_type: String, revealed: bool, state: String, neighbors: Array) -> Dictionary:
	return {
		"id": id,
		"x": x,
		"y": y,
		"display_name": display_name,
		"biome": biome,
		"layout": "ring" if node_type == "powerful_boss" else "box_blockers",
		"node_type": node_type,
		"revealed": revealed,
		"state": state,
		"neighbors": neighbors,
		"boss_name": _boss_name(display_name, node_type),
		"implicit_mods": _implicit_mods(node_type),
	}


static func _boss_name(display_name: String, node_type: String) -> String:
	if node_type == "tower":
		return "The Survey Warden"
	if node_type == "powerful_boss":
		return "High Warden of " + display_name
	if node_type == "citadel":
		return "Citadel Sealkeeper"
	return "Vault Warden of " + display_name


static func _implicit_mods(node_type: String) -> Array[Dictionary]:
	match node_type:
		"tower":
			return [{"id": "tower_survey", "display_name": "Tower: reveals nearby nodes and drops a Tablet", "stats": {"Tablet Chance": 1.0}}]
		"powerful_boss":
			return [{"id": "powerful_boss", "display_name": "Powerful Map Boss: harder boss, better rewards", "stats": {"Boss Damage": 0.20, "Boss Life": 0.30, "Item Rarity": 0.30}}]
		"citadel":
			return [{"id": "citadel", "display_name": "Citadel: sealed endgame gate", "stats": {"Boss Damage": 0.40, "Boss Life": 0.60, "Item Quantity": 0.45}}]
		_:
			return []


static func _first_available_node_id(nodes: Dictionary) -> String:
	for node_id: String in nodes.keys():
		var node: Dictionary = Dictionary(nodes[node_id])
		if bool(node.get("revealed", false)) and str(node.get("state", "locked")) != "locked":
			return node_id
	return START_NODE_ID


static func _nearby_node_ids(nodes: Dictionary, node: Dictionary) -> Array[String]:
	var out: Array[String] = []
	var x: int = int(node.get("x", 0))
	var y: int = int(node.get("y", 0))
	for node_id: String in nodes.keys():
		var other: Dictionary = Dictionary(nodes[node_id])
		var dist: int = abs(int(other.get("x", 0)) - x) + abs(int(other.get("y", 0)) - y)
		if dist <= 2 and node_id != str(node.get("id", "")):
			out.append(node_id)
	return out


static func _sort_nodes(a: Dictionary, b: Dictionary) -> bool:
	var ay: int = int(a.get("y", 0))
	var by: int = int(b.get("y", 0))
	if ay == by:
		return int(a.get("x", 0)) < int(b.get("x", 0))
	return ay < by


static func _dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}
