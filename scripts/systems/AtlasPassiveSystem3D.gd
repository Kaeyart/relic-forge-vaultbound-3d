class_name RVAtlasPassiveSystem3D
extends RefCounted

const DB := preload("res://scripts/data/AtlasPassiveDB3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	if state.get("allocated_atlas_passive_nodes") == null:
		state.set("allocated_atlas_passive_nodes", {})
	if state.get("atlas_passive_points") == null:
		state.set("atlas_passive_points", 0)
	_seed_demo_points_once(state)

static func _seed_demo_points_once(state: Object) -> void:
	var materials: Dictionary = _dict(state.get("materials"))
	if bool(materials.get("_atlas_passive_seeded_035", false)):
		return
	materials["_atlas_passive_seeded_035"] = true
	state.set("materials", materials)
	if int(_state_get(state, "atlas_passive_points", 0)) < 8:
		state.set("atlas_passive_points", 8)

static func allocated(state: Object) -> Dictionary:
	if state == null:
		return {}
	ensure_defaults(state)
	return _dict(state.get("allocated_atlas_passive_nodes"))

static func can_allocate(state: Object, node_id: String) -> bool:
	if state == null:
		return false
	ensure_defaults(state)
	var node: Dictionary = DB.node(node_id)
	if node.is_empty():
		return false
	var alloc: Dictionary = allocated(state)
	if alloc.has(node_id):
		return false
	if int(_state_get(state, "atlas_passive_points", 0)) <= 0:
		return false
	var req: Array = Array(node.get("requires", []))
	for value: Variant in req:
		if not alloc.has(str(value)):
			return false
	return true

static func allocate(state: Object, node_id: String) -> String:
	if not can_allocate(state, node_id):
		return "Cannot allocate Atlas node."
	var alloc: Dictionary = allocated(state)
	alloc[node_id] = true
	state.set("allocated_atlas_passive_nodes", alloc)
	state.set("atlas_passive_points", max(0, int(_state_get(state, "atlas_passive_points", 0)) - 1))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Allocated Atlas passive: " + str(DB.node(node_id).get("name", node_id))

static func can_refund(state: Object, node_id: String) -> bool:
	var alloc: Dictionary = allocated(state)
	if not alloc.has(node_id):
		return false
	for id: Variant in alloc.keys():
		var n: Dictionary = DB.node(str(id))
		if Array(n.get("requires", [])).has(node_id):
			return false
	return true

static func refund(state: Object, node_id: String) -> String:
	if not can_refund(state, node_id):
		return "Cannot refund Atlas node: another node depends on it."
	var alloc: Dictionary = allocated(state)
	alloc.erase(node_id)
	state.set("allocated_atlas_passive_nodes", alloc)
	state.set("atlas_passive_points", int(_state_get(state, "atlas_passive_points", 0)) + 1)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return "Refunded Atlas passive."

static func bundle(state: Object) -> Dictionary:
	var result: Dictionary = {"stats": {}, "rules": []}
	if state == null:
		return result
	var alloc: Dictionary = allocated(state)
	for id: Variant in alloc.keys():
		var node: Dictionary = DB.node(str(id))
		_merge_stats(result, _dict(node.get("stats")))
		_merge_rules(result, Array(node.get("rules", [])))
	return result

static func apply_to_activity(state: Object, activity: Dictionary) -> Dictionary:
	if state == null or activity.is_empty():
		return activity
	var out: Dictionary = activity.duplicate(true)
	var b: Dictionary = bundle(state)
	var stats: Dictionary = _dict(b.get("stats"))
	out["danger_score"] = max(0, int(out.get("danger_score", 0)) + int(round(float(stats.get("Map Monster Damage", 0.0)) / 4.0)) - int(round(float(stats.get("Map Danger Reduction", 0.0)) / 4.0)))
	out["reward_score"] = max(0, int(out.get("reward_score", 0)) + int(round(float(stats.get("Item Quantity", 0.0)) / 5.0)) + int(round(float(stats.get("Item Rarity", 0.0)) / 8.0)))
	out["atlas_passive_stats"] = stats
	out["atlas_passive_rules"] = Array(b.get("rules", []))
	return out

static func completion_rewards(state: Object, activity: Dictionary) -> Dictionary:
	var b: Dictionary = bundle(state)
	var stats: Dictionary = _dict(b.get("stats"))
	return {
		"waystone_chance": float(stats.get("Waystone Drop Chance", 0.0)) / 100.0,
		"tablet_chance": float(stats.get("Tablet Drop Chance", 0.0)) / 100.0,
		"uncut_gem_chance": float(stats.get("Uncut Gem Chance", 0.0)) / 100.0,
		"forge_material_chance": float(stats.get("Forge Material Chance", 0.0)) / 100.0,
		"boss_relic_chance": float(stats.get("Boss Relic Chance", 0.0)) / 100.0,
		"rules": Array(b.get("rules", [])),
	}

static func validation_report(state: Object) -> String:
	if state == null:
		return "Atlas passives: no state."
	var lines: PackedStringArray = PackedStringArray()
	var alloc: Dictionary = allocated(state)
	var bad: int = 0
	for id: Variant in alloc.keys():
		var node: Dictionary = DB.node(str(id))
		if node.is_empty():
			bad += 1
			lines.append("Missing Atlas node: " + str(id))
		else:
			for req: Variant in Array(node.get("requires", [])):
				if not alloc.has(str(req)):
					bad += 1
					lines.append("Atlas node " + str(id) + " missing requirement " + str(req))
	if bad == 0:
		return "Atlas passives: OK (" + str(alloc.size()) + " allocated)."
	return "\n".join(lines)

static func _merge_stats(result: Dictionary, stats: Dictionary) -> void:
	var out: Dictionary = _dict(result.get("stats"))
	for key: Variant in stats.keys():
		var stat_key: String = str(key)
		out[stat_key] = float(out.get(stat_key, 0.0)) + float(stats[key])
	result["stats"] = out

static func _merge_rules(result: Dictionary, rules: Array) -> void:
	var out: Array = Array(result.get("rules", []))
	for value: Variant in rules:
		var rule: String = str(value)
		if rule != "" and not out.has(rule):
			out.append(rule)
	result["rules"] = out

static func _dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value
