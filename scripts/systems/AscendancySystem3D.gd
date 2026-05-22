class_name RVAscendancySystem3D
extends RefCounted

const AscDBScript: GDScript = preload("res://scripts/data/AscendancyDB3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	if state.get("selected_ascendancy_id") == null:
		state.set("selected_ascendancy_id", "")
	if state.get("ascendancy_points") == null:
		state.set("ascendancy_points", 0)
	if state.get("allocated_ascendancy_nodes") == null or typeof(state.get("allocated_ascendancy_nodes")) != TYPE_DICTIONARY:
		state.set("allocated_ascendancy_nodes", {})
	var selected: String = str(state.get("selected_ascendancy_id"))
	if selected != "":
		var data: Dictionary = AscDBScript.ascendancy_data(selected)
		if data.is_empty() or str(data.get("class_id", "")) != str(state.get("class_id")):
			state.set("selected_ascendancy_id", "")
			state.set("allocated_ascendancy_nodes", {})

static func available_ascendancies(state: Object) -> Array[String]:
	if state == null:
		return []
	return AscDBScript.ascendancies_for_class(str(state.get("class_id")))

static func choose_ascendancy(state: Object, asc_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var current: String = str(state.get("selected_ascendancy_id"))
	if current != "" and current != asc_id:
		return "Ascendancy already chosen. Refund nodes later; switching subclass is locked for the demo."
	var data: Dictionary = AscDBScript.ascendancy_data(asc_id)
	if data.is_empty():
		return "Unknown ascendancy."
	if str(data.get("class_id", "")) != str(state.get("class_id")):
		return "This ascendancy does not belong to your class."
	state.set("selected_ascendancy_id", asc_id)
	state.set("allocated_ascendancy_nodes", Dictionary(state.get("allocated_ascendancy_nodes", {})))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Ascendancy chosen: " + str(data.get("name", asc_id.capitalize())) + "."

static func can_allocate(state: Object, node_id: String) -> bool:
	return allocation_error(state, node_id) == ""

static func allocation_error(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var asc_id: String = str(state.get("selected_ascendancy_id"))
	if asc_id == "":
		return "Choose an ascendancy first."
	var node: Dictionary = AscDBScript.node(node_id)
	if node.is_empty():
		return "Unknown ascendancy node."
	if str(node.get("ascendancy_id", "")) != asc_id:
		return "Node belongs to another ascendancy."
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	if allocated.has(node_id):
		return "Already allocated."
	var cost: int = int(node.get("cost", 1))
	if int(state.get("ascendancy_points")) < cost:
		return "Need " + str(cost) + " ascendancy point(s)."
	for req: Variant in Array(node.get("requires", [])):
		if not allocated.has(str(req)):
			var req_node: Dictionary = AscDBScript.node(str(req))
			return "Requires " + str(req_node.get("name", str(req))) + "."
	return ""

static func allocate(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var node: Dictionary = AscDBScript.node(node_id)
	if node.is_empty():
		return "Unknown ascendancy node."
	var err: String = allocation_error(state, node_id)
	if err != "":
		return "Cannot allocate " + str(node.get("name", node_id)) + ": " + err
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	allocated[node_id] = true
	state.set("allocated_ascendancy_nodes", allocated)
	state.set("ascendancy_points", maxi(0, int(state.get("ascendancy_points")) - int(node.get("cost", 1))))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Allocated " + str(node.get("name", node_id)) + "."

static func can_refund(state: Object, node_id: String) -> bool:
	return refund_error(state, node_id) == ""

static func refund_error(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	if not allocated.has(node_id):
		return "Node is not allocated."
	for other_key: Variant in allocated.keys():
		var other_id: String = str(other_key)
		if other_id == node_id:
			continue
		var other: Dictionary = AscDBScript.node(other_id)
		for req: Variant in Array(other.get("requires", [])):
			if str(req) == node_id:
				return "Refund would break " + str(other.get("name", other_id)) + "."
	return ""

static func refund(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var node: Dictionary = AscDBScript.node(node_id)
	var err: String = refund_error(state, node_id)
	if err != "":
		return "Cannot refund " + str(node.get("name", node_id)) + ": " + err
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	allocated.erase(node_id)
	state.set("allocated_ascendancy_nodes", allocated)
	state.set("ascendancy_points", int(state.get("ascendancy_points")) + int(node.get("cost", 1)))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Refunded " + str(node.get("name", node_id)) + "."

static func bundle(state: Object) -> Dictionary:
	var result: Dictionary = {"stats": {}, "rules": []}
	if state == null:
		return result
	ensure_defaults(state)
	var all_nodes: Dictionary = AscDBScript.nodes()
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	for node_key: Variant in allocated.keys():
		var id: String = str(node_key)
		if not all_nodes.has(id):
			continue
		var node: Dictionary = Dictionary(all_nodes[id])
		_merge_stats(result, Dictionary(node.get("stats", {})))
		_merge_rules(result, Array(node.get("rules", [])))
	return result

static func nodes_for_selected(state: Object) -> Array[Dictionary]:
	ensure_defaults(state)
	var out: Array[Dictionary] = []
	var selected: String = str(state.get("selected_ascendancy_id"))
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	for key: Variant in AscDBScript.nodes().keys():
		var n: Dictionary = AscDBScript.node(str(key))
		if str(n.get("ascendancy_id", "")) != selected:
			continue
		n["allocated"] = allocated.has(str(key))
		n["can_allocate"] = can_allocate(state, str(key))
		n["can_refund"] = can_refund(state, str(key))
		n["allocation_error"] = allocation_error(state, str(key))
		n["refund_error"] = refund_error(state, str(key)) if allocated.has(str(key)) else ""
		out.append(n)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var at: int = 0 if str(a.get("type", "")) == "minor" else 1
		var bt: int = 0 if str(b.get("type", "")) == "minor" else 1
		if at != bt:
			return at < bt
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return out

static func summary_text(state: Object) -> String:
	ensure_defaults(state)
	var selected: String = str(state.get("selected_ascendancy_id"))
	var text: String = "Ascendancy Points: " + str(int(state.get("ascendancy_points"))) + "\n"
	if selected == "":
		text += "No ascendancy selected."
	else:
		var data: Dictionary = AscDBScript.ascendancy_data(selected)
		text += "Selected: " + str(data.get("name", selected.capitalize())) + "\n"
		text += str(data.get("description", ""))
	return text

static func validation_report(state: Object) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var selected: String = str(state.get("selected_ascendancy_id"))
	var problems: Array[String] = []
	if selected != "":
		var data: Dictionary = AscDBScript.ascendancy_data(selected)
		if data.is_empty():
			problems.append("Selected ascendancy does not exist: " + selected)
		elif str(data.get("class_id", "")) != str(state.get("class_id")):
			problems.append("Selected ascendancy belongs to another class.")
	var all_nodes: Dictionary = AscDBScript.nodes()
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	for node_key: Variant in allocated.keys():
		var id: String = str(node_key)
		if not all_nodes.has(id):
			problems.append("Allocated missing ascendancy node: " + id)
			continue
		var node: Dictionary = Dictionary(all_nodes[id])
		if selected != "" and str(node.get("ascendancy_id", "")) != selected:
			problems.append("Allocated node from another ascendancy: " + id)
		for req: Variant in Array(node.get("requires", [])):
			if not allocated.has(str(req)):
				problems.append(str(node.get("name", id)) + " missing required node " + str(req))
	if problems.is_empty():
		return "Ascendancy validation: OK"
	return "Ascendancy validation:\n- " + "\n- ".join(problems)

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
