extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

func render(state: Object) -> void:
	_reset_columns()
	var core_box: VBoxContainer = _section("Character", 1.0)
	var offense_box: VBoxContainer = _section("Offense", 1.0)
	var defense_box: VBoxContainer = _section("Defense", 1.0)
	_add_line(core_box, "Level " + str(_state_get(state, "level", 1)), 18, RVUIStyle.color_gold())
	_add_line(core_box, "XP " + str(_state_get(state, "xp", 0)) + " / " + str(_state_get(state, "xp_to_next", "?")), 13, RVUIStyle.color_text())
	_add_line(core_box, "Gold " + str(_state_get(state, "gold", 0)), 13, RVUIStyle.color_text())
	_add_line(core_box, "", 4)
	_add_line(core_box, "Build stats are intentionally grouped here so power sources become readable.", 12, RVUIStyle.color_muted())
	var stats: Dictionary = _as_dict(_state_get(state, "build_stats", {}))
	var offense_keys: Array[String] = ["spell_damage", "attack_damage", "fire_damage", "lightning_damage", "void_damage", "projectile_damage", "crit_chance", "crit_damage"]
	for key: String in offense_keys:
		_add_line(offense_box, RVUIStyle.title_case(key) + ": " + str(stats.get(key, _state_get(state, key, 0))), 13, RVUIStyle.color_text())
	var defense_keys: Array[String] = ["max_health", "max_mana", "armor", "block_chance", "movement_speed", "health_regen", "mana_regen", "resistance"]
	for key2: String in defense_keys:
		_add_line(defense_box, RVUIStyle.title_case(key2) + ": " + str(stats.get(key2, _state_get(state, key2, 0))), 13, RVUIStyle.color_text())
