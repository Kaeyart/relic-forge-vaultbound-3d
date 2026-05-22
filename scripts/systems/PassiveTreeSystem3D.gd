extends RefCounted
class_name RVPassiveTreeSystem3D

const PassiveTreeDBScript := preload("res://scripts/data/PassiveTreeDB3D.gd")
const StatRegistryScript := preload("res://scripts/data/ProgressionStatRegistry3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	_state_ensure_dict(state, "allocated_passive_nodes")
	if state.get("passive_points") == null:
		_state_set(state, "passive_points", 0)
	if state.get("passive_tree_filter") == null:
		_state_set(state, "passive_tree_filter", "current_class")
	if state.get("passive_tree_search") == null:
		_state_set(state, "passive_tree_search", "")
	if state.get("selected_passive_node_id") == null:
		_state_set(state, "selected_passive_node_id", PassiveTreeDBScript.class_start_node(str(_state_get(state, "class_id", "sorceress"))))
	if not bool(Dictionary(_state_get(state, "materials", {})).get("_passive_depth_seeded_037", false)):
		var materials: Dictionary = Dictionary(_state_get(state, "materials", {}))
		materials["_passive_depth_seeded_037"] = true
		_state_set(state, "materials", materials)
		_state_set(state, "passive_points", int(_state_get(state, "passive_points", 0)) + 18)

static func allocate_node(state: Object, node_id: String) -> Dictionary:
	ensure_defaults(state)
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_passive_nodes", {}))
	var class_id: String = str(_state_get(state, "class_id", "sorceress"))
	var node: Dictionary = PassiveTreeDBScript.node(node_id)
	if node.is_empty():
		return _result(false, "Unknown passive node: " + node_id)
	if allocated.has(node_id):
		return _result(false, "Already allocated: " + str(node.get("display_name", node_id)))
	if int(_state_get(state, "passive_points", 0)) < int(node.get("cost", 1)):
		return _result(false, "Not enough passive points.")
	if not PassiveTreeDBScript.available(node_id, allocated, class_id):
		return _result(false, "Passive node is locked or belongs to another class region.")
	allocated[node_id] = true
	_state_set(state, "allocated_passive_nodes", allocated)
	_state_set(state, "passive_points", int(_state_get(state, "passive_points", 0)) - int(node.get("cost", 1)))
	_state_set(state, "selected_passive_node_id", node_id)
	_recompute(state)
	return _result(true, "Allocated " + str(node.get("display_name", node_id)) + ".")

static func refund_node(state: Object, node_id: String) -> Dictionary:
	ensure_defaults(state)
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_passive_nodes", {}))
	if not allocated.has(node_id):
		return _result(false, "Node is not allocated.")
	var dependent: String = _first_dependent_allocated(node_id, allocated)
	if dependent != "":
		return _result(false, "Cannot refund: " + dependent + " depends on this node.")
	var node: Dictionary = PassiveTreeDBScript.node(node_id)
	allocated.erase(node_id)
	_state_set(state, "allocated_passive_nodes", allocated)
	_state_set(state, "passive_points", int(_state_get(state, "passive_points", 0)) + int(node.get("cost", 1)))
	_state_set(state, "selected_passive_node_id", node_id)
	_recompute(state)
	return _result(true, "Refunded " + str(node.get("display_name", node_id)) + ".")

static func set_selected_node(state: Object, node_id: String) -> void:
	ensure_defaults(state)
	_state_set(state, "selected_passive_node_id", node_id)

static func set_filter(state: Object, filter_id: String) -> void:
	ensure_defaults(state)
	_state_set(state, "passive_tree_filter", filter_id)

static func set_search(state: Object, search_text: String) -> void:
	ensure_defaults(state)
	_state_set(state, "passive_tree_search", search_text)

static func visible_nodes(state: Object) -> Array:
	ensure_defaults(state)
	var class_id: String = str(_state_get(state, "class_id", "sorceress"))
	var filter_id: String = str(_state_get(state, "passive_tree_filter", "current_class"))
	var search_text: String = str(_state_get(state, "passive_tree_search", "")).to_lower()
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_passive_nodes", {}))
	var source: Array = PassiveTreeDBScript.nodes_for_class(class_id, true)
	var result: Array = []
	for value: Variant in source:
		var n: Dictionary = Dictionary(value)
		var id: String = str(n.get("id", ""))
		var include: bool = true
		match filter_id:
			"available":
				include = PassiveTreeDBScript.available(id, allocated, class_id)
			"allocated":
				include = allocated.has(id)
			"keystone":
				include = str(n.get("type", "")) == "keystone"
			"notable":
				include = str(n.get("type", "")) == "notable"
			"center":
				include = str(n.get("class_id", "")) == "center"
			_:
				include = true
		if include and search_text != "":
			var hay: String = (str(n.get("display_name", "")) + " " + str(n.get("lane", "")) + " " + str(n.get("tags", []))).to_lower()
			include = hay.find(search_text) >= 0
		if include:
			result.append(n)
	return result

static func node_state(state: Object, node_id: String) -> String:
	ensure_defaults(state)
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_passive_nodes", {}))
	if allocated.has(node_id):
		return "allocated"
	if PassiveTreeDBScript.available(node_id, allocated, str(_state_get(state, "class_id", "sorceress"))):
		return "available"
	return "locked"

static func bundle(state: Object) -> Dictionary:
	ensure_defaults(state)
	return PassiveTreeDBScript.bundle_for_allocations(Dictionary(_state_get(state, "allocated_passive_nodes", {})))

static func validate(state: Object) -> Array[String]:
	ensure_defaults(state)
	var warnings: Array[String] = []
	var allocated: Dictionary = Dictionary(_state_get(state, "allocated_passive_nodes", {}))
	for id_value: Variant in allocated.keys():
		var id: String = str(id_value)
		var node: Dictionary = PassiveTreeDBScript.node(id)
		if node.is_empty():
			warnings.append("Unknown allocated passive node: " + id)
			continue
		for stat_key: Variant in Dictionary(node.get("stats", {})).keys():
			var key: String = str(stat_key)
			if not StatRegistryScript.is_known_stat(key):
				warnings.append("Unknown passive stat: " + key + " on " + id)
		for rule_value: Variant in Array(node.get("rules", [])):
			var rule: String = str(rule_value)
			if not StatRegistryScript.is_known_rule(rule):
				warnings.append("Unknown passive rule: " + rule + " on " + id)
		for req_value: Variant in Array(node.get("requires", [])):
			var req: String = str(req_value)
			if req != "" and not allocated.has(req):
				warnings.append("Allocated node missing required path: " + id + " requires " + req)
	return warnings

static func _first_dependent_allocated(node_id: String, allocated: Dictionary) -> String:
	var nodes: Dictionary = PassiveTreeDBScript.all_nodes()
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
