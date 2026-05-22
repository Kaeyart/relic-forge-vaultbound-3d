class_name RVClassProgressionSystem3D
extends RefCounted

const ClassSystemScript: GDScript = preload("res://scripts/systems/CharacterClassSystem3D.gd")
const PassiveTreeSystemScript: GDScript = preload("res://scripts/systems/PassiveTreeSystem3D.gd")
const AscendancySystemScript: GDScript = preload("res://scripts/systems/AscendancySystem3D.gd")

static func ensure_progression_defaults(state: Object) -> void:
	if state == null:
		return
	ClassSystemScript.ensure_defaults(state)
	PassiveTreeSystemScript.ensure_defaults(state)
	AscendancySystemScript.ensure_defaults(state)
	_seed_demo_progression_once(state)

static func _seed_demo_progression_once(state: Object) -> void:
	# Store the patch marker in materials because older GameState builds do not declare a dedicated field yet.
	var materials_value: Variant = state.get("materials")
	if typeof(materials_value) != TYPE_DICTIONARY:
		return
	var materials: Dictionary = Dictionary(materials_value)
	if bool(materials.get("_class_identity_seeded_034", false)):
		return
	materials["_class_identity_seeded_034"] = true
	state.set("materials", materials)
	if int(state.get("passive_points")) < 12:
		state.set("passive_points", 12)
	if int(state.get("ascendancy_points")) < 4:
		state.set("ascendancy_points", 4)
	if state.has_method("add_notice"):
		state.call("add_notice", "Passive Tree expanded. Prototype points granted for testing.")

static func award_level_rewards(state: Object, new_level: int) -> void:
	if state == null:
		return
	# Main passive points are still awarded by GameState.add_xp(); this only handles ascendancy gates.
	if new_level == 5:
		if state.has_method("add_notice"):
			state.call("add_notice", "Ascendancy available. Open the Ascendancy screen.")
	elif new_level == 8 or new_level == 12 or new_level == 16 or new_level == 20:
		state.set("ascendancy_points", int(state.get("ascendancy_points")) + 2)
		if state.has_method("add_notice"):
			state.call("add_notice", "+2 Ascendancy Points")

static func set_class_for_testing(state: Object, class_id: String) -> String:
	if state == null:
		return "No state."
	var result: String = ClassSystemScript.set_class(state, class_id)
	PassiveTreeSystemScript.ensure_defaults(state)
	AscendancySystemScript.ensure_defaults(state)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	return result

static func full_progression_bundle(state: Object) -> Dictionary:
	var result: Dictionary = {"stats": {}, "rules": []}
	if state == null:
		return result
	ensure_progression_defaults(state)
	_merge_bundle(result, PassiveTreeSystemScript.bundle(state))
	_merge_bundle(result, AscendancySystemScript.bundle(state))
	return result

static func validation_report(state: Object) -> String:
	if state == null:
		return "No state."
	return PassiveTreeSystemScript.validation_report(state) + "\n" + AscendancySystemScript.validation_report(state)

static func _merge_bundle(result: Dictionary, bundle: Dictionary) -> void:
	var stats: Dictionary = Dictionary(result.get("stats", {}))
	for key: Variant in Dictionary(bundle.get("stats", {})).keys():
		var stat_key: String = str(key)
		stats[stat_key] = float(stats.get(stat_key, 0.0)) + float(Dictionary(bundle.get("stats", {}))[key])
	result["stats"] = stats
	var rules: Array = Array(result.get("rules", []))
	for value: Variant in Array(bundle.get("rules", [])):
		var rule: String = str(value)
		if rule != "" and not rules.has(rule):
			rules.append(rule)
	result["rules"] = rules
