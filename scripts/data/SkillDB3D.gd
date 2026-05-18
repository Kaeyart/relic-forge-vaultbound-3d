class_name RVSkillDB3D
extends RefCounted

static func core(skill_id: String) -> Dictionary:
	return Dictionary(cores().get(skill_id, cores()["fireball"])).duplicate(true)

static func cores() -> Dictionary:
	return {
		"fireball": {
			"name": "Fireball",
			"kind": "projectile",
			"tags": ["spell", "fire", "projectile"],
			"cost": 12.0,
			"damage": 34.0,
			"speed": 17.0,
			"radius": 0.35,
			"cooldown": 0.18,
			"range": 24.0
		},
		"storm_lance": {
			"name": "Storm Lance",
			"kind": "lance",
			"tags": ["spell", "lightning", "line"],
			"cost": 16.0,
			"damage": 28.0,
			"radius": 0.65,
			"cooldown": 0.28,
			"range": 12.5
		},
		"arc_slash": {
			"name": "Arc Slash",
			"kind": "area",
			"tags": ["attack", "melee", "physical"],
			"cost": 8.0,
			"damage": 42.0,
			"radius": 2.25,
			"cooldown": 0.24,
			"range": 2.3
		},
		"void_rift": {
			"name": "Void Rift",
			"kind": "area_target",
			"tags": ["spell", "void", "area"],
			"cost": 24.0,
			"damage": 50.0,
			"radius": 2.6,
			"cooldown": 0.65,
			"range": 14.0
		}
	}

static func mod_data(mod_id: String) -> Dictionary:
	return Dictionary(mods().get(mod_id, {})).duplicate(true)

static func mods() -> Dictionary:
	return {
		"burning_core": {"name": "Burning Core", "tags": ["fire"], "damage_more": 0.12, "adds_tag": "burn"},
		"heavy_orb": {"name": "Heavy Orb", "tags": ["projectile"], "damage_more": 0.22, "speed_more": -0.18, "radius_more": 0.20},
		"forking_ember": {"name": "Forking Ember", "tags": ["projectile"], "extra_projectiles": 2, "damage_more": -0.18},
		"conductive_lance": {"name": "Conductive Lance", "tags": ["lightning"], "chain_count": 1, "damage_more": 0.05},
		"wide_arc": {"name": "Wide Arc", "tags": ["melee", "area"], "radius_more": 0.28, "damage_more": -0.08}
	}

static func compute_skill(state: Object, skill_id: String) -> Dictionary:
	var data: Dictionary = core(skill_id)
	var tags: Array = Array(data.get("tags", [])).duplicate(true)
	var damage: float = float(data.get("damage", 1.0))
	var speed: float = float(data.get("speed", 0.0))
	var radius: float = float(data.get("radius", 0.5))
	var cooldown: float = float(data.get("cooldown", 0.2))
	var cost: float = float(data.get("cost", 0.0))
	var extra_projectiles: int = 0
	var chain_count: int = 0
	var build_stats: Dictionary = _collect_build_stats(state)

	# Flat additive power. Early 3D itemization intentionally uses flat values so changes are visible.
	damage += float(build_stats.get("generic_damage", 0.0))
	if tags.has("spell"):
		damage += float(build_stats.get("spell_damage", 0.0))
	if tags.has("attack"):
		damage += float(build_stats.get("attack_damage", 0.0))
	if tags.has("projectile"):
		damage += float(build_stats.get("projectile_damage", 0.0))
	if tags.has("fire"):
		damage += float(build_stats.get("fire_damage", 0.0))
	if tags.has("lightning"):
		damage += float(build_stats.get("lightning_damage", 0.0))
	if tags.has("void"):
		damage += float(build_stats.get("void_damage", 0.0))

	# Speed/cooldown stats are fractional bonuses.
	if tags.has("spell"):
		cooldown /= max(0.25, 1.0 + float(build_stats.get("cast_speed", 0.0)))
	if tags.has("attack"):
		cooldown /= max(0.25, 1.0 + float(build_stats.get("attack_speed", 0.0)))
	cooldown /= max(0.25, 1.0 + float(build_stats.get("cooldown_recovery", 0.0)))

	var mods_for_skill: Array = []
	if state != null:
		var all_mods: Dictionary = Dictionary(state.get("skill_mods"))
		mods_for_skill = Array(all_mods.get(skill_id, []))
	for mod_value: Variant in mods_for_skill:
		var mod: Dictionary = mod_data(str(mod_value))
		if mod.is_empty():
			continue
		damage *= 1.0 + float(mod.get("damage_more", 0.0))
		speed *= 1.0 + float(mod.get("speed_more", 0.0))
		radius *= 1.0 + float(mod.get("radius_more", 0.0))
		extra_projectiles += int(mod.get("extra_projectiles", 0))
		chain_count += int(mod.get("chain_count", 0))
		var adds_tag: String = str(mod.get("adds_tag", ""))
		if adds_tag != "" and not tags.has(adds_tag):
			tags.append(adds_tag)
	data["damage"] = max(1.0, damage)
	data["speed"] = max(0.0, speed)
	data["radius"] = max(0.1, radius)
	data["cooldown"] = max(0.05, cooldown)
	data["cost"] = max(0.0, cost)
	data["tags"] = tags
	data["extra_projectiles"] = extra_projectiles
	data["chain_count"] = chain_count
	return data

static func _collect_build_stats(state: Object) -> Dictionary:
	if state == null:
		return {}
	var direct: Variant = state.get("build_stats")
	if typeof(direct) == TYPE_DICTIONARY and not Dictionary(direct).is_empty():
		return Dictionary(direct).duplicate(true)
	var result: Dictionary = {}
	var equipped: Dictionary = Dictionary(state.get("equipped"))
	for slot_value: Variant in equipped.values():
		if typeof(slot_value) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(slot_value)
		var stats: Dictionary = Dictionary(item.get("total_stats", item.get("stats", {})))
		for stat_value: Variant in stats.keys():
			var stat: String = str(stat_value)
			result[stat] = float(result.get(stat, 0.0)) + float(stats[stat_value])
	return result
