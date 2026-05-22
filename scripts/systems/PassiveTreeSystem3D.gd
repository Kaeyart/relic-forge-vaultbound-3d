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
	return allocation_error(state, node_id) == ""

static func allocation_error(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var node: Dictionary = PassiveDBScript.node(node_id)
	if node.is_empty():
		return "Unknown passive node."
	var allocated_nodes: Dictionary = allocated(state)
	if allocated_nodes.has(node_id):
		return "Already allocated."
	var cost: int = int(node.get("cost", 1))
	if int(state.get("passive_points")) < cost:
		return "Need " + str(cost) + " passive point(s)."
	for req: Variant in Array(node.get("requires", [])):
		if not allocated_nodes.has(str(req)):
			var req_node: Dictionary = PassiveDBScript.node(str(req))
			return "Requires " + str(req_node.get("name", str(req))) + "."
	return ""

static func allocate(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var node: Dictionary = PassiveDBScript.node(node_id)
	if node.is_empty():
		return "Unknown passive node."
	var err: String = allocation_error(state, node_id)
	if err != "":
		return "Cannot allocate " + str(node.get("name", node_id)) + ": " + err
	var allocated_nodes: Dictionary = allocated(state)
	allocated_nodes[node_id] = true
	state.set("allocated_passive_nodes", allocated_nodes)
	state.set("passive_points", maxi(0, int(state.get("passive_points")) - int(node.get("cost", 1))))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Allocated " + str(node.get("name", node_id)) + "."

static func can_refund(state: Object, node_id: String) -> bool:
	return refund_error(state, node_id) == ""

static func refund_error(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var allocated_nodes: Dictionary = allocated(state)
	if not allocated_nodes.has(node_id):
		return "Node is not allocated."
	for other_key: Variant in allocated_nodes.keys():
		var other_id: String = str(other_key)
		if other_id == node_id:
			continue
		var other: Dictionary = PassiveDBScript.node(other_id)
		for req: Variant in Array(other.get("requires", [])):
			if str(req) == node_id:
				return "Refund would break " + str(other.get("name", other_id)) + "."
	return ""

static func refund(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var node: Dictionary = PassiveDBScript.node(node_id)
	var err: String = refund_error(state, node_id)
	if err != "":
		return "Cannot refund " + str(node.get("name", node_id)) + ": " + err
	var allocated_nodes: Dictionary = allocated(state)
	allocated_nodes.erase(node_id)
	state.set("allocated_passive_nodes", allocated_nodes)
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

static func preview_node_bundle(node_id: String) -> Dictionary:
	var result: Dictionary = {"stats": {}, "rules": []}
	var node: Dictionary = PassiveDBScript.node(node_id)
	if node.is_empty():
		return result
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
		n["can_refund"] = can_refund(state, id)
		n["allocation_error"] = allocation_error(state, id)
		n["refund_error"] = refund_error(state, id) if allocated_nodes.has(id) else ""
		n["is_class_region"] = str(n.get("class_bias", "any")) == class_id or str(n.get("class_bias", "any")) == "any"
		out.append(n)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ar: int = _region_order(str(a.get("region", "")))
		var br: int = _region_order(str(b.get("region", "")))
		if ar != br:
			return ar < br
		var aa: String = str(a.get("lane", "")) + str(int(a.get("tier", 0))).pad_zeros(3) + str(a.get("id", ""))
		var bb: String = str(b.get("lane", "")) + str(int(b.get("tier", 0))).pad_zeros(3) + str(b.get("id", ""))
		return aa < bb
	)
	return out

static func nodes_for_ui_filtered(state: Object, filter_mode: String, search: String = "") -> Array[Dictionary]:
	var class_id: String = str(state.get("class_id")) if state != null else ""
	var q: String = search.to_lower().strip_edges()
	var out: Array[Dictionary] = []
	for n: Dictionary in sorted_nodes_for_ui(state):
		var include: bool = true
		match filter_mode:
			"class":
				include = str(n.get("class_bias", "any")) == class_id or str(n.get("class_bias", "any")) == "any"
			"sorceress", "warrior", "huntress":
				include = str(n.get("class_bias", "any")) == filter_mode
			"center":
				include = str(n.get("region", "")) == "center_core"
			"keystone":
				include = str(n.get("type", "")) == "keystone"
			"allocated":
				include = bool(n.get("allocated", false))
			"available":
				include = bool(n.get("can_allocate", false))
			_:
				include = true
		if include and q != "":
			var hay: String = (str(n.get("name", "")) + " " + str(n.get("lane_label", "")) + " " + str(n.get("description", "")) + " " + ",".join(Array(n.get("rules", []))) + " " + ",".join(Array(n.get("tags", [])))).to_lower()
			include = hay.find(q) >= 0
		if include:
			out.append(n)
	return out

static func summary_text(state: Object) -> String:
	ensure_defaults(state)
	var text: String = "Passive Points: " + str(int(state.get("passive_points"))) + "\n"
	text += "Allocated: " + str(allocated(state).size()) + "\n"
	var b: Dictionary = bundle(state)
	var rules: Array = Array(b.get("rules", []))
	text += "Rules: " + (", ".join(rules) if not rules.is_empty() else "none")
	return text

static func validation_report(state: Object) -> String:
	var problems: Array[String] = []
	if state == null:
		return "No state."
	ensure_defaults(state)
	var all_nodes: Dictionary = PassiveDBScript.nodes()
	var seen: Dictionary = {}
	for id_value: Variant in allocated(state).keys():
		var id: String = str(id_value)
		if seen.has(id):
			problems.append("Duplicate allocation: " + id)
		seen[id] = true
		if not all_nodes.has(id):
			problems.append("Allocated missing node: " + id)
			continue
		var node: Dictionary = Dictionary(all_nodes[id])
		for req: Variant in Array(node.get("requires", [])):
			if not seen.has(str(req)) and not allocated(state).has(str(req)):
				problems.append(str(node.get("name", id)) + " missing required node " + str(req))
	if problems.is_empty():
		return "Passive validation: OK"
	return "Passive validation:\n- " + "\n- ".join(problems)

static func _region_order(region: String) -> int:
	match region:
		"north_arcane":
			return 10
		"west_martial":
			return 20
		"east_hunt":
			return 30
		"center_core":
			return 40
		"keystone":
			return 50
		_:
			return 99

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
