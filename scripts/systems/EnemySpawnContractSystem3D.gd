extends RefCounted
class_name RVEnemySpawnContractSystem3D

const EnemyModifierSystemScript := preload("res://scripts/systems/EnemyModifierSystem3D.gd")
const MapThreatSystemScript := preload("res://scripts/systems/MapThreatSystem3D.gd")

static func apply_to_existing_enemies(enemies: Array, state: Object) -> Dictionary:
	var tier: int = MapThreatSystemScript.active_tier(state)
	var profile: Dictionary = MapThreatSystemScript.profile_for_tier(tier)
	var fresh: Array = []

	for value: Variant in enemies:
		if value == null or not is_instance_valid(value):
			continue
		if not (value is Node3D):
			continue
		var enemy: Node3D = value as Node3D
		if enemy.has_meta("rv_encounter_assigned"):
			continue
		fresh.append(enemy)

	if fresh.is_empty():
		return {"assigned": 0, "normal": 0, "magic": 0, "rare": 0, "packs": 0}

	fresh.shuffle()

	var assigned_normal: int = 0
	var assigned_magic: int = 0
	var assigned_rare: int = 0
	var pack_count: int = 0

	var rare_count: int = _rare_count_for(fresh.size(), profile)
	for i: int in range(rare_count):
		if fresh.is_empty():
			break
		var enemy: Node3D = fresh.pop_back()
		_assign_rare(enemy, tier, profile)
		assigned_rare += 1

	while not fresh.is_empty():
		var chance: float = _to_float(profile.get("magic_pack_chance", 0.4), 0.4)
		var should_magic: bool = fresh.size() >= 2 and randf() < chance

		if should_magic:
			var pack_id: String = "magic_pack_" + str(Time.get_ticks_msec()) + "_" + str(pack_count)
			var pack_size: int = randi_range(_to_int(profile.get("magic_pack_min", 2), 2), _to_int(profile.get("magic_pack_max", 5), 5))
			pack_size = clampi(pack_size, 1, fresh.size())

			var mod_ids: Array = EnemyModifierSystemScript.pick_modifier_ids("magic", tier)
			var shared_mod: String = "more_life"
			if not mod_ids.is_empty():
				shared_mod = str(mod_ids[0])

			for j: int in range(pack_size):
				if fresh.is_empty():
					break
				var member: Node3D = fresh.pop_back()
				_assign_magic(member, tier, profile, pack_id, shared_mod)
				assigned_magic += 1

			pack_count += 1
		else:
			var normal_enemy: Node3D = fresh.pop_back()
			_assign_normal(normal_enemy, tier, profile)
			assigned_normal += 1

	return {"assigned": assigned_normal + assigned_magic + assigned_rare, "normal": assigned_normal, "magic": assigned_magic, "rare": assigned_rare, "packs": pack_count}


static func _rare_count_for(enemy_count: int, profile: Dictionary) -> int:
	if enemy_count <= 0:
		return 0
	var rare_chance: float = _to_float(profile.get("rare_chance", 0.20), 0.20)
	var rare_max: int = _to_int(profile.get("rare_max", 1), 1)
	var count: int = 0
	if randf() < rare_chance:
		count = 1
	if enemy_count >= 12 and rare_max > 1 and randf() < rare_chance * 0.45:
		count += 1
	return clampi(count, 0, min(rare_max, enemy_count))


static func _assign_normal(enemy: Node3D, tier: int, profile: Dictionary) -> void:
	var roll: Dictionary = {"rarity": "normal", "modifiers": [], "map_tier": tier, "xp_mult": _to_float(profile.get("normal_xp_mult", 1.0), 1.0)}
	EnemyModifierSystemScript.apply_roll_to_enemy(enemy, roll)
	enemy.set_meta("rv_encounter_assigned", true)
	enemy.set_meta("rv_enemy_role", "fodder")


static func _assign_magic(enemy: Node3D, tier: int, profile: Dictionary, pack_id: String, shared_mod: String) -> void:
	var roll: Dictionary = {"rarity": "magic", "modifiers": [shared_mod], "map_tier": tier, "xp_mult": _to_float(profile.get("magic_xp_mult", 1.75), 1.75)}
	EnemyModifierSystemScript.apply_roll_to_enemy(enemy, roll)
	enemy.set_meta("rv_encounter_assigned", true)
	enemy.set_meta("rv_enemy_role", "magic_pack")
	enemy.set_meta("rv_magic_pack_id", pack_id)
	enemy.set_meta("rv_magic_pack_modifier", shared_mod)


static func _assign_rare(enemy: Node3D, tier: int, profile: Dictionary) -> void:
	var mod_count: int = _to_int(profile.get("rare_mod_count", MapThreatSystemScript.rare_modifier_count_for_tier(tier)), 3)
	var mods: Array = []
	var pool: Array = EnemyModifierSystemScript.modifier_pool()
	pool.shuffle()
	for value: Variant in pool:
		if mods.size() >= mod_count:
			break
		mods.append(str(value))

	var roll: Dictionary = {"rarity": "rare", "modifiers": mods, "map_tier": tier, "xp_mult": _to_float(profile.get("rare_xp_mult", 4.0), 4.0)}
	EnemyModifierSystemScript.apply_roll_to_enemy(enemy, roll)
	enemy.set_meta("rv_encounter_assigned", true)
	enemy.set_meta("rv_enemy_role", "rare_standalone")


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
