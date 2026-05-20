extends RefCounted
class_name RVEnemyModifierRuntimeSystem3D

static func update_enemies(enemies: Array, delta: float) -> void:
	var valid: Array = []
	for value: Variant in enemies:
		if value == null or not is_instance_valid(value):
			continue
		if not (value is Node3D):
			continue
		valid.append(value)

	for value: Variant in valid:
		var enemy: Node3D = value as Node3D
		_update_single(enemy, delta)

	_apply_empower_auras(valid)


static func _update_single(enemy: Node3D, delta: float) -> void:
	var mods: Array = _as_array(_meta(enemy, "rv_enemy_modifiers", []))
	var hp: float = _read_hp(enemy)
	var max_hp: float = _read_max_hp(enemy, hp)

	if mods.has("regenerating") and hp > 0.0 and hp < max_hp:
		_write_hp(enemy, min(max_hp, hp + max_hp * 0.02 * delta))

	if mods.has("shielded") and not enemy.has_meta("rv_shield_initialized"):
		enemy.set_meta("rv_shield_initialized", true)
		enemy.set_meta("rv_barrier", max_hp * 0.35)

	if mods.has("frenzied"):
		var t: float = _to_float(_meta(enemy, "rv_frenzy_time", 0.0), 0.0) + delta
		enemy.set_meta("rv_frenzy_time", t)
		if t >= 8.0 and not enemy.has_meta("rv_frenzy_applied"):
			enemy.set_meta("rv_frenzy_applied", true)
			_scale_float_property(enemy, "move_speed", 1.16)
			_scale_float_property(enemy, "speed", 1.16)
			_scale_float_property(enemy, "damage", 1.18)
			_scale_float_property(enemy, "attack_damage", 1.18)

	if hp <= 0.0 and mods.has("explodes_on_death") and not enemy.has_meta("rv_death_explosion_armed"):
		enemy.set_meta("rv_death_explosion_armed", true)


static func _apply_empower_auras(enemies: Array) -> void:
	for source_value: Variant in enemies:
		var source: Node3D = source_value as Node3D
		if source == null or not is_instance_valid(source):
			continue
		var source_mods: Array = _as_array(_meta(source, "rv_enemy_modifiers", []))
		if not source_mods.has("empowers_nearby"):
			continue

		for target_value: Variant in enemies:
			var target: Node3D = target_value as Node3D
			if target == null or target == source or not is_instance_valid(target):
				continue
			if target.has_meta("rv_empowered_by_aura"):
				continue
			if source.global_position.distance_to(target.global_position) > 5.5:
				continue
			target.set_meta("rv_empowered_by_aura", true)
			_scale_float_property(target, "max_hp", 1.18)
			_scale_float_property(target, "hp", 1.18)
			_scale_float_property(target, "health", 1.18)
			_scale_float_property(target, "damage", 1.12)
			_scale_float_property(target, "attack_damage", 1.12)
			_scale_float_property(target, "move_speed", 1.08)
			_scale_float_property(target, "speed", 1.08)


static func _read_hp(enemy: Object) -> float:
	for prop: String in ["hp", "current_hp", "health", "current_health"]:
		if _has_property(enemy, prop):
			return _to_float(enemy.get(prop), 1.0)
	return 1.0


static func _write_hp(enemy: Object, value: float) -> void:
	for prop: String in ["hp", "current_hp", "health", "current_health"]:
		if _has_property(enemy, prop):
			enemy.set(prop, value)
			return


static func _read_max_hp(enemy: Object, fallback: float) -> float:
	for prop: String in ["max_hp", "health_max", "max_health"]:
		if _has_property(enemy, prop):
			return max(1.0, _to_float(enemy.get(prop), fallback))
	return max(1.0, fallback)


static func _scale_float_property(enemy: Object, prop: String, mult: float) -> void:
	if not _has_property(enemy, prop):
		return
	enemy.set(prop, _to_float(enemy.get(prop), 0.0) * mult)


static func _has_property(obj: Object, prop: String) -> bool:
	if obj == null:
		return false
	var props: Array = obj.get_property_list()
	for value: Variant in props:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = value
		if str(data.get("name", "")) == prop:
			return true
	return false


static func _meta(obj: Object, key: String, fallback: Variant) -> Variant:
	if obj == null:
		return fallback
	if obj.has_meta(key):
		return obj.get_meta(key)
	return fallback


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
