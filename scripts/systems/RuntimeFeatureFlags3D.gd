extends RefCounted
class_name RVRuntimeFeatureFlags3D

const DEFAULT_FLAGS: Dictionary = {
	"visual_foundation_layer": true,
	"hub_greybox_layer": false,
	"combat_arena_greybox_layer": true,
	"skill_vfx_layer": true,
	"enemy_readability_layer": true,
	"loot_presentation_layer": true,
	"combat_feedback_layer": true,
	"combat_director_layer": true,
	"vertical_slice_debug_overlay": true,
	"combat_feel_layer": true,
	"hub_station_layer": true,
	"game_flow_director": true,
}


static func default_flags() -> Dictionary:
	return DEFAULT_FLAGS.duplicate(true)


static func ensure_defaults(state: Object) -> Dictionary:
	var flags: Dictionary = default_flags()

	if state != null:
		var existing_value: Variant = state.get("runtime_feature_flags")
		if typeof(existing_value) == TYPE_DICTIONARY:
			var existing: Dictionary = Dictionary(existing_value)
			for key_value: Variant in existing.keys():
				flags[str(key_value)] = bool(existing[key_value])

		state.set("runtime_feature_flags", flags)

	return flags


static func is_enabled(state: Object, flag_name: String, fallback: bool = true) -> bool:
	if flag_name == "":
		return fallback

	var flags: Dictionary = default_flags()
	if state != null:
		var existing_value: Variant = state.get("runtime_feature_flags")
		if typeof(existing_value) == TYPE_DICTIONARY:
			var existing: Dictionary = Dictionary(existing_value)
			for key_value: Variant in existing.keys():
				flags[str(key_value)] = bool(existing[key_value])

	if flags.has(flag_name):
		return bool(flags[flag_name])

	return fallback


static func set_flag(state: Object, flag_name: String, enabled: bool) -> void:
	if state == null or flag_name == "":
		return

	var flags: Dictionary = ensure_defaults(state)
	flags[flag_name] = enabled
	state.set("runtime_feature_flags", flags)


static func toggle_flag(state: Object, flag_name: String) -> bool:
	var current: bool = is_enabled(state, flag_name, true)
	set_flag(state, flag_name, not current)
	return not current


static func summary(state: Object) -> String:
	var flags: Dictionary = ensure_defaults(state)
	var enabled: Array[String] = []
	var disabled: Array[String] = []

	for key_value: Variant in flags.keys():
		var key: String = str(key_value)
		if bool(flags[key]):
			enabled.append(key)
		else:
			disabled.append(key)

	return "Enabled: " + str(enabled.size()) + " · Disabled: " + str(disabled.size())


static func layer_flag_for_name(layer_name: String) -> String:
	match layer_name:
		"VisualFoundationLayer096A":
			return "visual_foundation_layer"
		"HubGreyboxPass096B":
			return "hub_greybox_layer"
		"CombatArenaGreyboxPass096C":
			return "combat_arena_greybox_layer"
		"SkillVFXLayer096D":
			return "skill_vfx_layer"
		"EnemyReadabilityLayer096E":
			return "enemy_readability_layer"
		"LootPresentationLayer096F":
			return "loot_presentation_layer"
		"CombatFeedbackLayer096G":
			return "combat_feedback_layer"
		"CombatDirectorLayer097A":
			return "combat_director_layer"
		"VerticalSliceDebugOverlay098A":
			return "vertical_slice_debug_overlay"
		"CombatFeelLayer098B":
			return "combat_feel_layer"
		"HubStationLayer098C":
			return "hub_station_layer"
		"GameFlowDirector099A":
			return "game_flow_director"
		_:
			return ""
