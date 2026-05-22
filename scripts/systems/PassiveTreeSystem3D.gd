class_name RVPassiveTreeSystem3D
extends RefCounted

const PassiveDBScript: GDScript = preload("res://scripts/data/PassiveTreeDB3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	if state.get("allocated_passive_nodes") == null or typeof(state.get("allocated_passive_nodes")) != TYPE_DICTIONARY:
		state.set("allocated_passive_nodes", {})
	if state.get("weapon_set_index") == null:
		state.set("weapon_set_index", 0)
	if state.get("weapon_set_passive_points") == null:
		state.set("weapon_set_passive_points", 0)
	if state.get("allocated_weapon_set_nodes_1") == null or typeof(state.get("allocated_weapon_set_nodes_1")) != TYPE_DICTIONARY:
		state.set("allocated_weapon_set_nodes_1", {})
	if state.get("allocated_weapon_set_nodes_2") == null or typeof(state.get("allocated_weapon_set_nodes_2")) != TYPE_DICTIONARY:
		state.set("allocated_weapon_set_nodes_2", {})
	if state.get("passive_points") == null:
		state.set("passive_points", 0)

static func allocated(state: Object) -> Dictionary:
	ensure_defaults(state)
	return Dictionary(state.get("allocated_passive_nodes"))

static func can_allocate(state: Object, node_id: String) -> bool:
	if state == null:
		return false
	ensure_defaults(state)
	var node: Dictionary = PassiveDBScript.node(node_id)
	if node.is_empty():
		return false
	var allocated_nodes: Dictionary = allocated(state)
	if allocated_nodes.has(node_id):
		return false
	var cost: int = int(node.get("cost", 1))
	if int(state.get("passive_points")) < cost:
		return false
	var class_bias: String = str(node.get("class_bias", "any"))
	if class_bias != "any" and class_bias != str(state.get("class_id")):
		# Cross-class nodes are still allowed if requirements are satisfied; this preserves POE-style freedom.
		pass
	var reqs: Array = Array(node.get("requires", []))
	for req: Variant in reqs:
		if not allocated_nodes.has(str(req)):
			return false
	return true

static func allocate(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var node: Dictionary = PassiveDBScript.node(node_id)
	if node.is_empty():
		return "Unknown passive node."
	if not can_allocate(state, node_id):
		return "Cannot allocate " + str(node.get("name", node_id)) + "."
	var allocated_nodes: Dictionary = allocated(state)
	allocated_nodes[node_id] = true
	state.set("allocated_passive_nodes", allocated_nodes)
	state.set("passive_points", maxi(0, int(state.get("passive_points")) - int(node.get("cost", 1))))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Allocated " + str(node.get("name", node_id)) + "."

static func refund(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var allocated_nodes: Dictionary = allocated(state)
	if not allocated_nodes.has(node_id):
		return "Node is not allocated."
	allocated_nodes.erase(node_id)
	state.set("allocated_passive_nodes", allocated_nodes)
	var node: Dictionary = PassiveDBScript.node(node_id)
	state.set("passive_points", int(state.get("passive_points")) + int(node.get("cost", 1)))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Refunded " + str(node.get("name", node_id)) + "."

static func bundle(state: Object) -> Dictionary:
	var result: Dictionary = {"stats": {}, "rules": []}
	if state == null:
		return result
	ensure_defaults(state)
	var all_nodes: Dictionary = PassiveDBScript.nodes()
	for node_key: Variant in allocated(state).keys():
		var id: String = str(node_key)
		if not all_nodes.has(id):
			continue
		var node: Dictionary = Dictionary(all_nodes[id])
		_merge_stats(result, Dictionary(node.get("stats", {})))
		_merge_rules(result, Array(node.get("rules", [])))
	return result

static func sorted_nodes_for_ui(state: Object) -> Array[Dictionary]:
	ensure_defaults(state)
	var out: Array[Dictionary] = []
	var allocated_nodes: Dictionary = allocated(state)
	var class_id: String = str(state.get("class_id"))
	for id: String in PassiveDBScript.node_ids():
		var n: Dictionary = PassiveDBScript.node(id)
		n["allocated"] = allocated_nodes.has(id)
		n["can_allocate"] = can_allocate(state, id)
		n["is_class_region"] = str(n.get("class_bias", "any")) == class_id or str(n.get("class_bias", "any")) == "any"
		out.append(n)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var aa: String = str(a.get("region", "")) + str(a.get("class_bias", "")) + str(a.get("id", ""))
		var bb: String = str(b.get("region", "")) + str(b.get("class_bias", "")) + str(b.get("id", ""))
		return aa < bb
	)
	return out

static func summary_text(state: Object) -> String:
	ensure_defaults(state)
	var text: String = "Passive Points: " + str(int(state.get("passive_points"))) + "\n"
	text += "Allocated: " + str(allocated(state).size()) + "\n"
	var b: Dictionary = bundle(state)
	text += "Rules: " + ", ".join(Array(b.get("rules", [])))
	return text

static func _merge_stats(result: Dictionary, stats: Dictionary) -> void:
	var target: Dictionary = Dictionary(result.get("stats", {}))
	for key: Variant in stats.keys():
		var stat_key: String = str(key)
		target[stat_key] = float(target.get(stat_key, 0.0)) + float(stats[key])
	result["stats"] = target

static func _merge_rules(result: Dictionary, rules: Array) -> void:
	var target: Array = Array(result.get("rules", []))
	for value: Variant in rules:
		var rule: String = str(value)
		if rule != "" and not target.has(rule):
			target.append(rule)
	result["rules"] = target
