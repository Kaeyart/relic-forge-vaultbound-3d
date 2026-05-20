extends RefCounted
class_name RVEnemyModifierSystem3D

const RARITY_NORMAL: String = "normal"
const RARITY_MAGIC: String = "magic"
const RARITY_RARE: String = "rare"


static func rarity_for_roll(map_tier: int = 1) -> String:
	var tier: int = clampi(map_tier, 1, 15)
	var magic_chance: float = 0.16 + float(tier) * 0.006
	var rare_chance: float = 0.035 + float(tier) * 0.003
	var roll: float = randf()

	if roll < rare_chance:
		return RARITY_RARE
	if roll < rare_chance + magic_chance:
		return RARITY_MAGIC
	return RARITY_NORMAL


static func modifier_count_for_rarity(rarity: String, map_tier: int = 1) -> int:
	var r: String = rarity.strip_edges().to_lower()
	var tier: int = clampi(map_tier, 1, 15)

	if r == RARITY_MAGIC:
		return 1

	if r == RARITY_RARE:
		if tier >= 10:
			return 5
		if tier >= 6:
			return 4
		return 3

	return 0


static func pick_modifier_ids(rarity: String, map_tier: int = 1) -> Array:
	var count: int = modifier_count_for_rarity(rarity, map_tier)
	var pool: Array = modifier_pool()
	var result: Array = []

	while result.size() < count and not pool.is_empty():
		var index: int = randi_range(0, pool.size() - 1)
		var mod_id: String = str(pool[index])
		pool.remove_at(index)
		result.append(mod_id)

	return result


static func modifier_pool() -> Array:
	return [
		"more_life",
		"more_damage",
		"swift",
		"armored",
		"elemental_resistant",
		"crit_immune",
		"slow_immune",
		"empowers_nearby",
		"regenerating",
		"shielded",
		"burning_aura",
		"frost_aura",
		"storm_aura",
		"explodes_on_death",
		"projectile_resistant",
		"summons_aid",
		"frenzied",
	]


static func modifier_data(mod_id: String) -> Dictionary:
	match mod_id:
		"more_life":
			return {"id": "more_life", "name": "More Life", "short": "Life", "description": "Substantially increased maximum health.", "hp_mult": 1.65, "xp_mult": 1.16}
		"more_damage":
			return {"id": "more_damage", "name": "More Damage", "short": "Dmg", "description": "Deals increased damage.", "damage_mult": 1.35, "xp_mult": 1.14}
		"swift":
			return {"id": "swift", "name": "Swift", "short": "Fast", "description": "Moves and attacks faster.", "speed_mult": 1.28, "xp_mult": 1.10}
		"armored":
			return {"id": "armored", "name": "Armored", "short": "Armor", "description": "Takes reduced physical pressure.", "armor_bonus": 25, "damage_taken_mult": 0.88, "xp_mult": 1.10}
		"elemental_resistant":
			return {"id": "elemental_resistant", "name": "Elemental Resistant", "short": "Res", "description": "Resists elemental damage.", "resistance_bonus": 35, "xp_mult": 1.12}
		"crit_immune":
			return {"id": "crit_immune", "name": "Immune to Crits", "short": "NoCrit", "description": "Cannot be critically hit.", "crit_immune": true, "xp_mult": 1.16}
		"slow_immune":
			return {"id": "slow_immune", "name": "Cannot Be Slowed", "short": "NoSlow", "description": "Unaffected by slow and chill style effects.", "slow_immune": true, "xp_mult": 1.14}
		"empowers_nearby":
			return {"id": "empowers_nearby", "name": "Empowers Nearby", "short": "Aura+", "description": "Nearby monsters are empowered.", "aura": "empower", "xp_mult": 1.18}
		"regenerating":
			return {"id": "regenerating", "name": "Regenerating", "short": "Regen", "description": "Recovers health over time.", "regen_percent": 2, "xp_mult": 1.12}
		"shielded":
			return {"id": "shielded", "name": "Shielded", "short": "Shield", "description": "Starts with a temporary barrier.", "barrier_mult": 0.35, "xp_mult": 1.14}
		"burning_aura":
			return {"id": "burning_aura", "name": "Burning Aura", "short": "Burn", "description": "Threatens nearby players with fire pressure.", "aura": "fire", "xp_mult": 1.16}
		"frost_aura":
			return {"id": "frost_aura", "name": "Frost Aura", "short": "Frost", "description": "Threatens nearby players with frost pressure.", "aura": "frost", "xp_mult": 1.16}
		"storm_aura":
			return {"id": "storm_aura", "name": "Storm Aura", "short": "Storm", "description": "Threatens nearby players with lightning pressure.", "aura": "storm", "xp_mult": 1.16}
		"explodes_on_death":
			return {"id": "explodes_on_death", "name": "Explodes on Death", "short": "Boom", "description": "Creates a death explosion.", "death_explosion": true, "xp_mult": 1.18}
		"projectile_resistant":
			return {"id": "projectile_resistant", "name": "Projectile Resistant", "short": "ProjRes", "description": "Takes less pressure from projectile hits.", "projectile_resistant": true, "xp_mult": 1.12}
		"summons_aid":
			return {"id": "summons_aid", "name": "Summons Aid", "short": "Adds", "description": "Can call additional monsters.", "summons": true, "xp_mult": 1.16}
		"frenzied":
			return {"id": "frenzied", "name": "Frenzied", "short": "Rage", "description": "Gains pressure as combat continues.", "frenzy": true, "damage_mult": 1.16, "speed_mult": 1.14, "xp_mult": 1.14}
		_:
			return {"id": mod_id, "name": mod_id.capitalize(), "short": mod_id.substr(0, min(6, mod_id.length())), "description": "Unknown modifier.", "xp_mult": 1.0}


static func build_enemy_roll(map_tier: int = 1) -> Dictionary:
	var rarity: String = rarity_for_roll(map_tier)
	var mods: Array = pick_modifier_ids(rarity, map_tier)
	return {"rarity": rarity, "modifiers": mods, "map_tier": clampi(map_tier, 1, 15), "xp_mult": xp_multiplier_for(rarity, mods)}


static func xp_multiplier_for(rarity: String, modifier_ids: Array) -> float:
	var result: float = 1.0
	match rarity:
		RARITY_MAGIC:
			result = 1.75
		RARITY_RARE:
			result = 4.0
		_:
			result = 1.0

	for value: Variant in modifier_ids:
		var data: Dictionary = modifier_data(str(value))
		result *= _to_float(data.get("xp_mult", 1.0), 1.0)

	return result


static func display_name_for_rarity(rarity: String) -> String:
	match rarity.strip_edges().to_lower():
		RARITY_MAGIC:
			return "Magic"
		RARITY_RARE:
			return "Rare"
		_:
			return "Normal"


static func rarity_color(rarity: String) -> Color:
	match rarity.strip_edges().to_lower():
		RARITY_MAGIC:
			return Color(0.35, 0.55, 1.0, 1.0)
		RARITY_RARE:
			return Color(1.0, 0.74, 0.18, 1.0)
		_:
			return Color(0.85, 0.85, 0.80, 1.0)


static func apply_roll_to_enemy(enemy: Object, roll: Dictionary) -> void:
	if enemy == null:
		return

	var rarity: String = str(roll.get("rarity", RARITY_NORMAL))
	var modifiers: Array = _as_array(roll.get("modifiers", []))

	enemy.set_meta("rv_enemy_rarity", rarity)
	enemy.set_meta("rv_enemy_modifiers", modifiers)
	enemy.set_meta("rv_enemy_modifier_roll", roll)

	var hp_mult: float = 1.0
	var damage_mult: float = 1.0
	var speed_mult: float = 1.0
	var xp_mult: float = _to_float(roll.get("xp_mult", 1.0), 1.0)
	var armor_bonus: int = 0
	var resistance_bonus: int = 0
	var barrier_mult: float = 0.0

	match rarity:
		RARITY_MAGIC:
			hp_mult *= 1.45
			damage_mult *= 1.12
		RARITY_RARE:
			hp_mult *= 2.55
			damage_mult *= 1.28
		_:
			pass

	for value: Variant in modifiers:
		var data: Dictionary = modifier_data(str(value))
		hp_mult *= _to_float(data.get("hp_mult", 1.0), 1.0)
		damage_mult *= _to_float(data.get("damage_mult", 1.0), 1.0)
		speed_mult *= _to_float(data.get("speed_mult", 1.0), 1.0)
		armor_bonus += _to_int(data.get("armor_bonus", 0), 0)
		resistance_bonus += _to_int(data.get("resistance_bonus", 0), 0)
		barrier_mult += _to_float(data.get("barrier_mult", 0.0), 0.0)

		if bool(data.get("crit_immune", false)):
			enemy.set_meta("rv_crit_immune", true)
		if bool(data.get("slow_immune", false)):
			enemy.set_meta("rv_slow_immune", true)
		if bool(data.get("death_explosion", false)):
			enemy.set_meta("rv_death_explosion", true)
		if bool(data.get("projectile_resistant", false)):
			enemy.set_meta("rv_projectile_resistant", true)
		if bool(data.get("summons", false)):
			enemy.set_meta("rv_summons_aid", true)
		if str(data.get("aura", "")) != "":
			enemy.set_meta("rv_enemy_aura", str(data.get("aura", "")))

	_scale_float_property(enemy, "max_hp", hp_mult)
	_scale_float_property(enemy, "hp", hp_mult)
	_scale_float_property(enemy, "health", hp_mult)
	_scale_float_property(enemy, "current_hp", hp_mult)
	_scale_float_property(enemy, "damage", damage_mult)
	_scale_float_property(enemy, "attack_damage", damage_mult)
	_scale_float_property(enemy, "move_speed", speed_mult)
	_scale_float_property(enemy, "speed", speed_mult)
	_scale_float_property(enemy, "xp_reward", xp_mult)
	_scale_float_property(enemy, "xp_value", xp_mult)

	_add_int_property(enemy, "armor", armor_bonus)
	_add_int_property(enemy, "fire_resistance", resistance_bonus)
	_add_int_property(enemy, "cold_resistance", resistance_bonus)
	_add_int_property(enemy, "lightning_resistance", resistance_bonus)

	if barrier_mult > 0.0:
		enemy.set_meta("rv_barrier_mult", barrier_mult)


static func _scale_float_property(enemy: Object, prop: String, mult: float) -> void:
	if mult == 1.0:
		return
	if not _has_property(enemy, prop):
		return
	var current: Variant = enemy.get(prop)
	var value: float = _to_float(current, 0.0)
	enemy.set(prop, value * mult)


static func _add_int_property(enemy: Object, prop: String, amount: int) -> void:
	if amount == 0:
		return
	if not _has_property(enemy, prop):
		return
	var current: Variant = enemy.get(prop)
	enemy.set(prop, _to_int(current, 0) + amount)


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
