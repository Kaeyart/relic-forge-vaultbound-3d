extends RefCounted
class_name RVSliceChecklistSystem3D

const RuntimeDetectionSystemScript := preload("res://scripts/systems/RuntimeDetectionSystem3D.gd")
const RuntimeFeatureFlagsScript := preload("res://scripts/systems/RuntimeFeatureFlags3D.gd")

static func report(root: Node, state: Object = null) -> Dictionary:
	var scene_data: Dictionary = {}
	if root != null:
		scene_data = RuntimeDetectionSystemScript.scene_report(root)

	var mode: String = _state_string(state, "mode", "")
	var panel_mode: String = _state_string(state, "panel_mode", "")
	var active_map: Dictionary = _active_map(state)
	var enemy_count: int = int(scene_data.get("enemy_count", 0))
	var loot_count: int = int(scene_data.get("loot_count", 0))
	var generated_visual_count: int = int(scene_data.get("generated_visual_count", 0))
	var warnings: Array = Array(scene_data.get("warnings", []))

	if mode == "":
		warnings.append("State mode is empty. Expected hub or combat.")
	if mode == "combat" and active_map.is_empty():
		warnings.append("Combat mode has no active map.")
	if mode == "combat" and enemy_count <= 0 and loot_count <= 0:
		warnings.append("Combat mode has no enemies and no loot. Check map start/clear state.")

	var checks: Dictionary = {
		"state_exists": state != null,
		"hub_or_combat_mode": mode == "hub" or mode == "combat" or mode == "town" or mode == "base",
		"has_active_map_if_combat": mode != "combat" or not active_map.is_empty(),
		"enemy_count_sane": enemy_count >= 0 and enemy_count < 120,
		"loot_count_sane": loot_count >= 0 and loot_count < 120,
		"generated_visuals_sane": generated_visual_count < 800,
		"feature_flags_present": _state_has_dict(state, "runtime_feature_flags"),
	}

	var passed: int = 0
	for key_value: Variant in checks.keys():
		if bool(checks[key_value]):
			passed += 1

	return {
		"mode": mode,
		"panel_mode": panel_mode,
		"active_map": _map_label(active_map),
		"enemy_count": enemy_count,
		"loot_count": loot_count,
		"generated_visual_count": generated_visual_count,
		"feature_flags": RuntimeFeatureFlagsScript.summary(state),
		"checks": checks,
		"passed": passed,
		"total": checks.size(),
		"warnings": warnings,
	}


static func report_text(root: Node, state: Object = null) -> String:
	var data: Dictionary = report(root, state)
	var lines: Array[String] = []
	lines.append("Milestone 0.1 Playable Slice Report")
	lines.append("------------------------------------")
	lines.append("Mode: " + str(data.get("mode", "")) + " · Panel: " + str(data.get("panel_mode", "")))
	lines.append("Map: " + str(data.get("active_map", "")))
	lines.append("Enemies: " + str(data.get("enemy_count", 0)) + " · Loot: " + str(data.get("loot_count", 0)) + " · Generated visuals: " + str(data.get("generated_visual_count", 0)))
	lines.append("Feature flags: " + str(data.get("feature_flags", "")))
	lines.append("Checks: " + str(data.get("passed", 0)) + "/" + str(data.get("total", 0)))

	var checks: Dictionary = Dictionary(data.get("checks", {}))
	for key_value: Variant in checks.keys():
		var key: String = str(key_value)
		var mark: String = "PASS" if bool(checks[key]) else "FAIL"
		lines.append("[" + mark + "] " + key)

	var warnings: Array = Array(data.get("warnings", []))
	if not warnings.is_empty():
		lines.append("")
		lines.append("Warnings:")
		for value: Variant in warnings:
			lines.append(" - " + str(value))

	return "\n".join(lines)


static func _active_map(state: Object) -> Dictionary:
	if state == null:
		return {}

	var value: Variant = state.get("active_map_item")
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)

	value = state.get("current_map_activity")
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)

	return {}


static func _map_label(map_item: Dictionary) -> String:
	if map_item.is_empty():
		return "none"

	var name: String = str(map_item.get("display_name", map_item.get("name", "Map")))
	var tier: String = str(map_item.get("tier", map_item.get("map_tier", 1)))
	var rarity: String = str(map_item.get("rarity", "normal")).capitalize()
	return name + " T" + tier + " " + rarity


static func _state_string(state: Object, key: String, fallback: String) -> String:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return str(value)


static func _state_has_dict(state: Object, key: String) -> bool:
	if state == null:
		return false
	return typeof(state.get(key)) == TYPE_DICTIONARY
