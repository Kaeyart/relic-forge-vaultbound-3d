class_name RVSkillDB3D
extends RefCounted

static var _cache_ready: bool = false
static var _skills: Dictionary = {}
static var _mods: Dictionary = {}

static func skill(skill_id: String) -> Dictionary:
	_ensure_cache()
	return Dictionary(_skills.get(skill_id, {})).duplicate(true)

static func mod_data(mod_id: String) -> Dictionary:
	_ensure_cache()
	return Dictionary(_mods.get(mod_id, {})).duplicate(true)

static func all_skills() -> Dictionary:
	_ensure_cache()
	return _skills

static func all_mods() -> Dictionary:
	_ensure_cache()
	return _mods

static func skill_damage(state: Object, skill_id: String) -> float:
	var data: Dictionary = skill(skill_id)
	var base_damage: float = float(data.get("base_damage", 10.0))
	var tags: Array = Array(data.get("tags", []))
	var build_stats: Dictionary = {}
	if state != null:
		for slot_name: Variant in Dictionary(state.get("equipped")).keys():
			var item_value: Variant = Dictionary(state.get("equipped")).get(slot_name, {})
			if typeof(item_value) != TYPE_DICTIONARY:
				continue
			var stats: Dictionary = Dictionary(Dictionary(item_value).get("stats", {}))
			for stat_key: Variant in stats.keys():
				build_stats[str(stat_key)] = float(build_stats.get(str(stat_key), 0.0)) + float(stats[stat_key])
	var multiplier: float = 1.0
	if tags.has("spell"):
		multiplier += float(build_stats.get("spell_damage_pct", 0.0)) / 100.0
	if tags.has("attack"):
		multiplier += float(build_stats.get("attack_damage_pct", 0.0)) / 100.0
	if tags.has("fire"):
		multiplier += float(build_stats.get("fire_damage_pct", 0.0)) / 100.0
	if tags.has("lightning"):
		multiplier += float(build_stats.get("lightning_damage_pct", 0.0)) / 100.0
	if tags.has("void"):
		multiplier += float(build_stats.get("void_damage_pct", 0.0)) / 100.0
	return base_damage * multiplier

static func _ensure_cache() -> void:
	if _cache_ready:
		return
	_cache_ready = true
	_skills = {
		"fireball": {"id":"fireball", "name":"Fireball", "kind":"projectile", "tags":["spell","fire","projectile"], "base_damage":22.0, "mana_cost":12.0, "cooldown":0.35, "projectile_speed":22.0, "radius":0.35, "description":"Launch a fire projectile that damages the first enemy hit."},
		"storm_lance": {"id":"storm_lance", "name":"Storm Lance", "kind":"line", "tags":["spell","lightning","projectile"], "base_damage":18.0, "mana_cost":14.0, "cooldown":0.55, "range":14.0, "description":"Fire a fast piercing lance of lightning."},
		"rift_pulse": {"id":"rift_pulse", "name":"Rift Pulse", "kind":"area", "tags":["spell","void","area"], "base_damage":28.0, "mana_cost":18.0, "cooldown":1.15, "radius":2.8, "description":"Detonate a void pulse at the target point."},
		"arc_slash": {"id":"arc_slash", "name":"Arc Slash", "kind":"melee", "tags":["attack","melee","physical"], "base_damage":20.0, "mana_cost":6.0, "cooldown":0.45, "range":2.2, "arc_degrees":85.0, "description":"A short frontal slash for close combat."}
	}
	_mods = {
		"burning_core": {"id":"burning_core", "name":"Burning Core", "allowed_tags":["fire"], "effects":["ignite"], "damage_more":0.10, "mana_more":0.10},
		"forking_ember": {"id":"forking_ember", "name":"Forking Ember", "allowed_tags":["projectile"], "effects":["split_projectile"], "damage_more":-0.12, "mana_more":0.18},
		"conductive_lance": {"id":"conductive_lance", "name":"Conductive Lance", "allowed_tags":["lightning"], "effects":["shock"], "damage_more":0.08, "mana_more":0.12},
		"void_echo": {"id":"void_echo", "name":"Void Echo", "allowed_tags":["void"], "effects":["repeat_area"], "damage_more":-0.08, "mana_more":0.20}
	}
