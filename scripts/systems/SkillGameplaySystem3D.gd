extends RefCounted
class_name RVSkillGameplaySystem3D

const GemProgressionSystemScript := preload("res://scripts/systems/GemProgressionSystem3D.gd")

static func enrich_cast_data(state: Object, raw_cast: Dictionary) -> Dictionary:
	var cast: Dictionary = raw_cast.duplicate(true)
	var active_id: String = str(cast.get("active_id", cast.get("active", "fireball")))
	var area_mult: float = max(0.1, _to_float(cast.get("area_mult", 1.0), 1.0))
	var damage: float = max(0.0, _to_float(cast.get("damage", 1.0), 1.0))
	var extra_projectiles: int = max(0, _to_int(cast.get("extra_projectiles", 0), 0))
	var chain_count: int = max(0, _to_int(cast.get("chain", 0), 0))
	var echo_count: int = max(0, _to_int(cast.get("echo_count", 0), 0))
	var rules: Array = _as_array(cast.get("rules", []))
	var tags: Array = _as_array(cast.get("tags", []))

	cast["active_id"] = active_id
	cast["active"] = active_id
	cast["damage"] = damage
	cast["area_mult"] = area_mult
	cast["rules"] = rules
	cast["tags"] = tags
	cast["chain"] = chain_count
	cast["echo_count"] = echo_count
	cast["identity"] = identity_for_active(active_id)

	match active_id:
		"fireball":
			cast["projectile_count"] = 1 + extra_projectiles
			cast["projectile_speed"] = 13.5
			cast["projectile_radius"] = 0.42
			cast["projectile_spread"] = 0.22
			cast["impact_radius"] = 1.10 * area_mult
			cast["impact_damage_mult"] = 0.46
			cast["status_on_hit"] = "ignite" if _has_fire_pressure(cast, state) else ""
			cast["status_dps_mult"] = 0.22
			cast["status_duration"] = 2.8

		"storm_lance":
			cast["line_length"] = 9.0 + float(chain_count) * 1.75
			cast["line_width"] = 0.72 + float(chain_count) * 0.08
			cast["pierce"] = true
			cast["chain_count"] = chain_count
			cast["status_on_hit"] = "shock"
			cast["status_duration"] = 2.2
			cast["shock_damage_taken_mult"] = 1.08 + float(chain_count) * 0.03

		"arc_slash":
			cast["cone_range"] = 2.75 * area_mult
			cast["cone_width"] = 1.55 * area_mult
			cast["cleave_damage_falloff"] = 0.86
			cast["status_on_hit"] = "bleed" if rules.has("bleed") else ""
			cast["status_dps_mult"] = 0.18
			cast["status_duration"] = 3.4

		"void_rift":
			cast["zone_radius"] = 2.15 * area_mult
			cast["zone_duration"] = 2.25 + float(echo_count) * 0.35
			cast["zone_tick_rate"] = 0.45
			cast["zone_tick_damage_mult"] = 0.42
			cast["status_on_hit"] = "void_slow"
			cast["status_duration"] = 1.7
			cast["slow_mult"] = 0.72
			cast["echo_count"] = echo_count

		"ember_mine":
			cast["mine_arm_time"] = 0.42
			cast["mine_trigger_radius"] = 2.35
			cast["mine_explosion_radius"] = 2.05 * area_mult
			cast["mine_duration"] = 8.0
			cast["status_on_hit"] = "ignite" if _has_fire_pressure(cast, state) else ""
			cast["status_dps_mult"] = 0.26
			cast["status_duration"] = 3.0

		_:
			cast["projectile_count"] = 1
			cast["projectile_speed"] = 12.0
			cast["projectile_radius"] = 0.38

	return cast


static func identity_for_active(active_id: String) -> String:
	match active_id:
		"fireball":
			return "Projectile / AoE / Burn"
		"storm_lance":
			return "Beam / Pierce / Shock"
		"arc_slash":
			return "Cleave / Close Range / Bleed"
		"void_rift":
			return "Zone / Control / Slow"
		"ember_mine":
			return "Mine / Setup / Burst"
		_:
			return "Generic Skill"


static func cast_xp(state: Object, cast: Dictionary) -> void:
	_award_xp(state, 2)


static func hit_xp(state: Object, cast: Dictionary) -> void:
	_award_xp(state, 1)


static func kill_xp(state: Object, cast: Dictionary) -> void:
	_award_xp(state, 5)


static func resolve_hit_damage(enemy: Object, base_damage: float, state: Object, tags: Array, cast: Dictionary) -> Dictionary:
	var damage: float = max(0.0, base_damage)
	var crit: bool = false
	var can_crit: bool = true

	if enemy != null and enemy.has_meta("rv_crit_immune"):
		can_crit = not bool(enemy.get_meta("rv_crit_immune"))

	var crit_chance: float = 0.05
	var crit_mult: float = 1.5
	if state != null:
		var stats_value: Variant = state.get("build_stats")
		if typeof(stats_value) == TYPE_DICTIONARY:
			var stats: Dictionary = Dictionary(stats_value)
			crit_chance += _to_float(stats.get("Critical Chance", 0.0), 0.0)
			crit_mult += _to_float(stats.get("Critical Damage", 0.0), 0.0)

	if can_crit and randf() < clampf(crit_chance, 0.0, 0.85):
		crit = true
		damage *= max(1.0, crit_mult)

	if enemy != null and enemy.has_meta("rv_projectile_resistant") and tags.has("projectile"):
		damage *= 0.72

	if enemy != null and enemy.has_meta("rv_status_effects"):
		var effects_value: Variant = enemy.get_meta("rv_status_effects")
		if typeof(effects_value) == TYPE_DICTIONARY:
			var effects: Dictionary = Dictionary(effects_value)
			if effects.has("shock"):
				var shock: Dictionary = Dictionary(effects.get("shock", {}))
				damage *= _to_float(shock.get("damage_taken_mult", 1.08), 1.08)

	return {"damage": damage, "crit": crit}


static func apply_on_hit_status(enemy: Object, state: Object, cast: Dictionary, applied_damage: float) -> void:
	if enemy == null:
		return

	var status: String = str(cast.get("status_on_hit", ""))
	if status == "":
		return

	var effects: Dictionary = {}
	if enemy.has_meta("rv_status_effects"):
		var current: Variant = enemy.get_meta("rv_status_effects")
		if typeof(current) == TYPE_DICTIONARY:
			effects = Dictionary(current).duplicate(true)

	var duration: float = max(0.1, _to_float(cast.get("status_duration", 1.0), 1.0))
	var dps_mult: float = _to_float(cast.get("status_dps_mult", 0.0), 0.0)

	match status:
		"ignite":
			effects["ignite"] = {
				"remaining": duration,
				"tick_timer": 0.5,
				"tick_rate": 0.5,
				"dps": max(1.0, applied_damage * dps_mult),
			}
		"bleed":
			effects["bleed"] = {
				"remaining": duration,
				"tick_timer": 0.65,
				"tick_rate": 0.65,
				"dps": max(1.0, applied_damage * dps_mult),
			}
		"shock":
			effects["shock"] = {
				"remaining": duration,
				"damage_taken_mult": _to_float(cast.get("shock_damage_taken_mult", 1.08), 1.08),
			}
		"void_slow":
			effects["void_slow"] = {
				"remaining": duration,
				"slow_mult": _to_float(cast.get("slow_mult", 0.72), 0.72),
			}
			if _has_property(enemy, "speed") and not enemy.has_meta("rv_void_slow_base_speed"):
				enemy.set_meta("rv_void_slow_base_speed", _to_float(enemy.get("speed"), 1.0))
		_:
			pass

	enemy.set_meta("rv_status_effects", effects)


static func update_enemy_statuses(enemy: Object, state: Object, delta: float) -> bool:
	if enemy == null or not enemy.has_meta("rv_status_effects"):
		return false

	var effects_value: Variant = enemy.get_meta("rv_status_effects")
	if typeof(effects_value) != TYPE_DICTIONARY:
		return false

	var effects: Dictionary = Dictionary(effects_value).duplicate(true)
	var killed: bool = false
	var remove_keys: Array = []

	for key_value: Variant in effects.keys():
		var key: String = str(key_value)
		var data: Dictionary = Dictionary(effects[key])
		var remaining: float = _to_float(data.get("remaining", 0.0), 0.0) - delta
		data["remaining"] = remaining

		if key == "ignite" or key == "bleed":
			var tick_rate: float = max(0.05, _to_float(data.get("tick_rate", 0.5), 0.5))
			var timer: float = _to_float(data.get("tick_timer", tick_rate), tick_rate) - delta
			if timer <= 0.0:
				timer += tick_rate
				var dps: float = _to_float(data.get("dps", 0.0), 0.0)
				var amount: float = max(0.0, dps * tick_rate)
				if amount > 0.0 and enemy.has_method("take_damage"):
					if bool(enemy.call("take_damage", amount)):
						killed = true
			data["tick_timer"] = timer

		if key == "void_slow":
			if _has_property(enemy, "speed") and enemy.has_meta("rv_void_slow_base_speed"):
				var base_speed: float = _to_float(enemy.get_meta("rv_void_slow_base_speed"), _to_float(enemy.get("speed"), 1.0))
				enemy.set("speed", base_speed * _to_float(data.get("slow_mult", 0.72), 0.72))

		if remaining <= 0.0:
			remove_keys.append(key)
		else:
			effects[key] = data

	for key_to_remove: Variant in remove_keys:
		var k: String = str(key_to_remove)
		if k == "void_slow" and _has_property(enemy, "speed") and enemy.has_meta("rv_void_slow_base_speed"):
			enemy.set("speed", _to_float(enemy.get_meta("rv_void_slow_base_speed"), _to_float(enemy.get("speed"), 1.0)))
			enemy.remove_meta("rv_void_slow_base_speed")
		effects.erase(k)

	enemy.set_meta("rv_status_effects", effects)
	return killed


static func enemy_has_alive_flag(enemy: Object) -> bool:
	if enemy == null:
		return false
	if _has_property(enemy, "alive"):
		return bool(enemy.get("alive"))
	return true


static func _has_fire_pressure(cast: Dictionary, state: Object) -> bool:
	var rules: Array = _as_array(cast.get("rules", []))
	if rules.has("ignite") or rules.has("spirit_fire_ignite"):
		return true
	var tags: Array = _as_array(cast.get("tags", []))
	if not tags.has("fire"):
		return false
	if state == null:
		return false
	var spirits: Variant = state.get("spirit_gems_owned")
	if typeof(spirits) == TYPE_DICTIONARY:
		var spirit_dict: Dictionary = Dictionary(spirits)
		if bool(spirit_dict.get("ember_pact", false)):
			return true
	return false


static func _award_xp(state: Object, amount: int) -> void:
	if state == null:
		return
	if amount <= 0:
		return

	GemProgressionSystemScript.award_selected_skill_xp(state, amount)


static func _has_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false
	var props: Array = obj.get_property_list()
	for value: Variant in props:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(value)
		if str(data.get("name", "")) == prop:
			return true
	return false


static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value
	return []


static func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(int(value))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		_:
			return fallback


static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return fallback
