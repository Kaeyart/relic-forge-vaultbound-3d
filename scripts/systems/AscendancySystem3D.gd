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
	var data: Dictionary = AscDBScript.ascendancy_data(asc_id)
	if data.is_empty():
		return "Unknown ascendancy."
	if str(data.get("class_id", "")) != str(state.get("class_id")):
		return "That ascendancy does not belong to this class."
	var current: String = str(state.get("selected_ascendancy_id"))
	if current != "" and current != asc_id:
		return "Ascendancy already chosen: " + current + "."
	state.set("selected_ascendancy_id", asc_id)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Ascendancy chosen: " + str(data.get("name", asc_id.capitalize())) + "."

static func can_allocate(state: Object, node_id: String) -> bool:
	if state == null:
		return false
	ensure_defaults(state)
	var asc_id: String = str(state.get("selected_ascendancy_id"))
	if asc_id == "":
		return false
	var node: Dictionary = AscDBScript.node(node_id)
	if node.is_empty():
		return false
	if str(node.get("ascendancy_id", "")) != asc_id:
		return false
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	if allocated.has(node_id):
		return false
	var cost: int = int(node.get("cost", 2))
	if int(state.get("ascendancy_points")) < cost:
		return false
	for req: Variant in Array(node.get("requires", [])):
		if not allocated.has(str(req)):
			return false
	return true

static func allocate(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var node: Dictionary = AscDBScript.node(node_id)
	if node.is_empty():
		return "Unknown ascendancy node."
	if not can_allocate(state, node_id):
		return "Cannot allocate " + str(node.get("name", node_id)) + "."
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	allocated[node_id] = true
	state.set("allocated_ascendancy_nodes", allocated)
	state.set("ascendancy_points", maxi(0, int(state.get("ascendancy_points")) - int(node.get("cost", 2))))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Allocated " + str(node.get("name", node_id)) + "."

static func refund(state: Object, node_id: String) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var allocated: Dictionary = Dictionary(state.get("allocated_ascendancy_nodes"))
	if not allocated.has(node_id):
		return "Node is not allocated."
	allocated.erase(node_id)
	state.set("allocated_ascendancy_nodes", allocated)
	var node: Dictionary = AscDBScript.node(node_id)
	state.set("ascendancy_points", int(state.get("ascendancy_points")) + int(node.get("cost", 2)))
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
		out.append(n)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
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
