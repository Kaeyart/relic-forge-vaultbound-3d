extends RefCounted
class_name RVAscendancySystem3D

const ClassDBScript := preload("res://scripts/data/ClassDB3D.gd")
const AscendancyDBScript := preload("res://scripts/data/AscendancyDB3D.gd")
const StatRegistryScript := preload("res://scripts/data/ProgressionStatRegistry3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	_state_ensure_dict(state, "allocated_ascendancy_nodes")
	if state.get("selected_ascendancy_id") == null:
		_state_set(state, "selected_ascendancy_id", "")
	if state.get("ascendancy_points") == null:
		_state_set(state, "ascendancy_points", 0)
	if state.get("selected_ascendancy_node_id") == null:
		_state_set(state, "selected_ascendancy_node_id", "")
	if not bool(Dictionary(_state_get(state, "materials", {})).get("_asc_depth_seeded_037", false)):
		var materials: Dictionary = Dictionary(_state_get(state, "materials", {}))
		materials["_asc_depth_seeded_037"] = true
		_state_set(state, "materials", materials)
		_state_set(state, "ascendancy_points", int(_state_get(state, "ascendancy_points", 0)) + 8)

static func choose_ascendancy(state: Object, asc_id: String) -> Dictionary:
	ensure_defaults(state)
	var current: String = str(_state_get(state, "selected_ascendancy_id", ""))
	var class_id: String = str(_state_get(state, "class_id", "sorceress"))
	if current != "" and current != asc_id:
		return _result(false, "Ascendancy already chosen. Respec later, not in this prototype pass.")
	if not ClassDBScript.ascendancy_ids(class_id).has(asc_id):
		return _result(false, "Ascendancy does not belong to current class.")
	_state_set(state, "selected_ascendancy_id", asc_id)
	_recompute(state)
	return _result(true, "Chosen ascendancy: " + str(AscendancyDBScript.ascendancy_data(asc_id).get("display_name", asc_id)))

static func allocate_node(state: Object, node_id: String) -> Dictionary:
	ensure_defaults(state)
	var asc_id: String = str(_state_get(state, "selected_ascendancy_id", ""))
	if asc_id == "":
		return _result(false, "Choose an ascendancy first.")
	var node: Dictionary = AscendancyDBScript.node(node_id)
	if node.is_empty():
		return _result(false, "Unknown ascendancy node.")
	if str(node.get("ascendancy_id", "")) != asc_id:
		return _result(false, "Node belongs to another ascendancy.")
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_ascendancy_nodes", {}))
	if allocated.has(node_id):
		return _result(false, "Already allocated.")
	var cost: int = int(node.get("cost", 1))
	if int(_state_get(state, "ascendancy_points", 0)) < cost:
		return _result(false, "Not enough ascendancy points.")
	for req_value: Variant in Array(node.get("requires", [])):
		var req: String = str(req_value)
		if req != "" and not allocated.has(req):
			return _result(false, "Locked. Requires " + req + ".")
	allocated[node_id] = true
	_state_set(state, "allocated_ascendancy_nodes", allocated)
	_state_set(state, "ascendancy_points", int(_state_get(state, "ascendancy_points", 0)) - cost)
	_state_set(state, "selected_ascendancy_node_id", node_id)
	_recompute(state)
	return _result(true, "Allocated " + str(node.get("display_name", node_id)) + ".")

static func refund_node(state: Object, node_id: String) -> Dictionary:
	ensure_defaults(state)
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_ascendancy_nodes", {}))
	if not allocated.has(node_id):
		return _result(false, "Node is not allocated.")
	var dependent: String = _first_dependent_allocated(node_id, allocated)
	if dependent != "":
		return _result(false, "Cannot refund: " + dependent + " depends on this node.")
	var node: Dictionary = AscendancyDBScript.node(node_id)
	allocated.erase(node_id)
	_state_set(state, "allocated_ascendancy_nodes", allocated)
	_state_set(state, "ascendancy_points", int(_state_get(state, "ascendancy_points", 0)) + int(node.get("cost", 1)))
	_state_set(state, "selected_ascendancy_node_id", node_id)
	_recompute(state)
	return _result(true, "Refunded " + str(node.get("display_name", node_id)) + ".")

static func set_selected_node(state: Object, node_id: String) -> void:
	ensure_defaults(state)
	_state_set(state, "selected_ascendancy_node_id", node_id)

static func visible_ascendancies(state: Object) -> Array:
	ensure_defaults(state)
	return AscendancyDBScript.ascendancies_for_class(str(_state_get(state, "class_id", "sorceress")))

static func visible_nodes(state: Object) -> Array:
	ensure_defaults(state)
	var asc_id: String = str(_state_get(state, "selected_ascendancy_id", ""))
	if asc_id == "":
		var asc: Array = visible_ascendancies(state)
		if asc.is_empty():
			return []
		asc_id = str(Dictionary(asc[0]).get("id", ""))
	return AscendancyDBScript.nodes_for_ascendancy(asc_id)

static func node_state(state: Object, node_id: String) -> String:
	ensure_defaults(state)
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_ascendancy_nodes", {}))
	if allocated.has(node_id):
		return "allocated"
	var node: Dictionary = AscendancyDBScript.node(node_id)
	if node.is_empty():
		return "locked"
	for req_value: Variant in Array(node.get("requires", [])):
		var req: String = str(req_value)
		if req != "" and not allocated.has(req):
			return "locked"
	return "available"

static func bundle(state: Object) -> Dictionary:
	ensure_defaults(state)
	return AscendancyDBScript.bundle_for_allocations(Dictionary(_state_get(state, "allocated_ascendancy_nodes", {})))

static func validate(state: Object) -> Array[String]:
	ensure_defaults(state)
	var warnings: Array[String] = []
	var class_id: String = str(_state_get(state, "class_id", "sorceress"))
	var asc_id: String = str(_state_get(state, "selected_ascendancy_id", ""))
	if asc_id != "" and not ClassDBScript.ascendancy_ids(class_id).has(asc_id):
		warnings.append("Selected ascendancy does not belong to class: " + asc_id)
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_ascendancy_nodes", {}))
	for id_value: Variant in allocated.keys():
		var id: String = str(id_value)
		var node: Dictionary = AscendancyDBScript.node(id)
		if node.is_empty():
			warnings.append("Unknown ascendancy node: " + id)
			continue
		if asc_id != "" and str(node.get("ascendancy_id", "")) != asc_id:
			warnings.append("Allocated ascendancy node belongs to another ascendancy: " + id)
		for stat_key: Variant in Dictionary(node.get("stats", {})).keys():
			if not StatRegistryScript.is_known_stat(str(stat_key)):
				warnings.append("Unknown ascendancy stat: " + str(stat_key) + " on " + id)
		for rule_value: Variant in Array(node.get("rules", [])):
			if not StatRegistryScript.is_known_rule(str(rule_value)):
				warnings.append("Unknown ascendancy rule: " + str(rule_value) + " on " + id)
	return warnings

static func _first_dependent_allocated(node_id: String, allocated: Dictionary) -> String:
	var nodes: Dictionary = AscendancyDBScript.all_nodes()
	for id_value: Variant in allocated.keys():
		var id: String = str(id_value)
		if id == node_id:
			continue
		var n: Dictionary = Dictionary(nodes.get(id, {}))
		if Array(n.get("requires", [])).has(node_id):
			return id
	return ""

static func _recompute(state: Object) -> void:
	if state != null and state.has_method("recompute_stats"):
		state.call("recompute_stats")

static func _result(ok: bool, message: String) -> Dictionary:
	return {"ok": ok, "message": message}

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _state_set(state: Object, key: String, value: Variant) -> void:
	if state != null:
		state.set(key, value)

static func _state_ensure_dict(state: Object, key: String) -> void:
	if state == null:
		return
	if typeof(state.get(key)) != TYPE_DICTIONARY:
		state.set(key, {})
