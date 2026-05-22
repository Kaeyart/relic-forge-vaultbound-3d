class_name RVMapLoopSystem3D
extends RefCounted

const AtlasSystemScript := preload("res://scripts/systems/AtlasSystem3D.gd")
const WaystoneSystemScript := preload("res://scripts/systems/WaystoneSystem3D.gd")
const TabletSystemScript := preload("res://scripts/systems/PrecursorTabletSystem3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	AtlasSystemScript.ensure_defaults(state)
	WaystoneSystemScript.ensure_defaults(state)
	TabletSystemScript.ensure_defaults(state)


static func selected_or_default_map(state: Object) -> Dictionary:
	return preview_selected_activity(state)


static func preview_selected_activity(state: Object) -> Dictionary:
	if state == null:
		return {}
	ensure_defaults(state)
	var node: Dictionary = AtlasSystemScript.selected_node(state)
	var waystone: Dictionary = WaystoneSystemScript.selected_waystone(state)
	var tablets: Array[Dictionary] = TabletSystemScript.selected_tablets(state)
	if node.is_empty() or waystone.is_empty():
		return {}
	return _build_activity(state, node, waystone, tablets, false)


static func start_selected_map(state: Object) -> Dictionary:
	if state == null:
		return {}
	ensure_defaults(state)
	var node: Dictionary = AtlasSystemScript.selected_node(state)
	if node.is_empty():
		_notice(state, "No Atlas node selected.")
		return {}
	var node_id: String = str(node.get("id", ""))
	if not AtlasSystemScript.can_run_node(state, node_id):
		_notice(state, "Atlas node is locked.")
		return {}
	var waystone: Dictionary = WaystoneSystemScript.consume_selected_waystone(state)
	if waystone.is_empty():
		_notice(state, "No Waystone selected.")
		return {}
	var tablets: Array[Dictionary] = TabletSystemScript.consume_selected_tablets(state)
	var activity: Dictionary = _build_activity(state, node, waystone, tablets, true)
	AtlasSystemScript.mark_attempted(state, node_id)
	state.set("current_map_activity", activity.duplicate(true))
	state.set("active_map_item", activity.duplicate(true))
	state.set("active_map_node_id", node_id)
	state.set("active_map_seed", int(activity.get("seed", 0)))
	state.set("active_map_tier", int(waystone.get("tier", 1)))
	state.set("active_map_rarity", str(waystone.get("rarity", "normal")))
	state.set("active_map_entries", 1)
	_notice(state, "Opened " + str(activity.get("display_name", "Map")) + " · kill the boss to complete.")
	return activity


static func complete_current_map(state: Object) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var activity: Dictionary = _dict(state.get("current_map_activity"))
	var node_id: String = str(activity.get("atlas_node_id", state.get("active_map_node_id")))
	if node_id == "":
		return
	var result: Dictionary = AtlasSystemScript.complete_node(state, node_id)
	_grant_completion_rewards(state, activity, result)
	state.set("maps_completed", int(state.get("maps_completed")) + 1)
	state.set("active_map_entries", 0)
	_notice(state, "Map complete: " + str(activity.get("display_name", "Map")) + ". New Atlas paths may be available.")


static func fail_current_map(state: Object) -> void:
	if state == null:
		return
	var activity: Dictionary = _dict(state.get("current_map_activity"))
	var node_id: String = str(activity.get("atlas_node_id", state.get("active_map_node_id")))
	if node_id != "":
		AtlasSystemScript.fail_node(state, node_id)


static func panel_text(state: Object) -> String:
	var activity: Dictionary = preview_selected_activity(state)
	if activity.is_empty():
		return "Map Device unavailable."
	return str(activity.get("display_name", "Map")) + " · Danger " + str(activity.get("danger_score", 0)) + " · Reward " + str(activity.get("reward_score", 0))


static func _build_activity(state: Object, node: Dictionary, waystone: Dictionary, tablets: Array[Dictionary], launched: bool) -> Dictionary:
	var node_mods: Array = Array(node.get("implicit_mods", []))
	var waystone_mods: Array = Array(waystone.get("mods", []))
	var tablet_mods: Array = []
	for tablet: Dictionary in tablets:
		for mod_value: Variant in Array(tablet.get("mods", [])):
			if typeof(mod_value) == TYPE_DICTIONARY:
				tablet_mods.append(Dictionary(mod_value))
	var all_mods: Array = []
	all_mods.append_array(node_mods)
	all_mods.append_array(waystone_mods)
	all_mods.append_array(tablet_mods)
	var tier: int = int(waystone.get("tier", 1))
	var danger: int = WaystoneSystemScript.danger_score(waystone) + TabletSystemScript.danger_score(tablets) + _node_danger(node)
	var reward: int = WaystoneSystemScript.reward_score(waystone) + TabletSystemScript.reward_score(tablets) + _node_reward(node)
	var seed: int = int(Time.get_ticks_msec()) if launched else int(str(node.get("id", "0")).hash())
	return {
		"kind": "map_activity",
		"atlas_node_id": str(node.get("id", "")),
		"display_name": AtlasSystemScript.node_display_name(node),
		"biome": str(node.get("biome", "ash_vault")),
		"layout": str(node.get("layout", "box_blockers")),
		"node_type": str(node.get("node_type", "normal")),
		"node_type_label": AtlasSystemScript.node_type_label(node),
		"boss_name": str(node.get("boss_name", "Vault Warden")),
		"tier": tier,
		"map_level": int(waystone.get("area_level", 64 + tier)),
		"area_level": int(waystone.get("area_level", 64 + tier)),
		"rarity": str(waystone.get("rarity", "normal")),
		"waystone_uid": str(waystone.get("uid", "")),
		"waystone_name": str(waystone.get("display_name", "Waystone")),
		"tablet_names": _tablet_names(tablets),
		"mods": all_mods,
		"danger_score": danger,
		"reward_score": reward,
		"tablet_slots": WaystoneSystemScript.tablet_slots_for_waystone(waystone),
		"seed": seed,
		"completion_rule": "Kill the map boss",
	}


static func _grant_completion_rewards(state: Object, activity: Dictionary, result: Dictionary) -> void:
	var rng: RandomNumberGenerator = _rng(state)
	var tier: int = int(activity.get("tier", 1))
	var node_type: String = str(activity.get("node_type", "normal"))
	var reward_score: int = int(activity.get("reward_score", 1))
	var next_tier: int = tier + (1 if rng.randf() < 0.28 + float(reward_score) * 0.015 else 0)
	WaystoneSystemScript.add_waystone(state, WaystoneSystemScript.make_random_waystone(rng, clampi(next_tier, 1, 16), node_type == "powerful_boss"))
	if node_type == "tower" or rng.randf() < 0.20 + float(reward_score) * 0.02:
		var types: Array[String] = ["gem", "forge", "boss", "breach"]
		TabletSystemScript.add_tablet(state, TabletSystemScript.make_tablet(types[rng.randi_range(0, types.size() - 1)], rng.randi_range(3, 6)))
	if state.has_method("add_material"):
		state.call("add_material", "shards", rng.randi_range(2, 5) + reward_score)
		state.call("add_material", "embers", rng.randi_range(4, 8) + reward_score)
	var unlocked: Array = Array(result.get("unlocked", []))
	if not unlocked.is_empty():
		_notice(state, "Atlas unlocked: " + ", ".join(_strings(unlocked)))


static func _node_danger(node: Dictionary) -> int:
	match str(node.get("node_type", "normal")):
		"tower":
			return 1
		"powerful_boss":
			return 4
		"citadel":
			return 8
		_:
			return 0


static func _node_reward(node: Dictionary) -> int:
	match str(node.get("node_type", "normal")):
		"tower":
			return 4
		"powerful_boss":
			return 5
		"citadel":
			return 8
		_:
			return 1


static func _tablet_names(tablets: Array[Dictionary]) -> Array[String]:
	var out: Array[String] = []
	for tablet: Dictionary in tablets:
		out.append(str(tablet.get("display_name", "Tablet")))
	return out


static func _strings(values: Array) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for value: Variant in values:
		out.append(str(value))
	return out


static func _notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)


static func _dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


static func _rng(state: Object) -> RandomNumberGenerator:
	if state != null:
		var value: Variant = state.get("rng")
		if value is RandomNumberGenerator:
			return value as RandomNumberGenerator
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng
