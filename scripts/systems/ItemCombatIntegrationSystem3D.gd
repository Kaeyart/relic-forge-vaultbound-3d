class_name RVItemCombatIntegrationSystem3D
extends RefCounted

const DAMAGE_STAT_BY_TAG: Dictionary = {
	"fire": "Fire Damage",
	"lightning": "Lightning Damage",
	"void": "Void Damage",
	"physical": "Physical Damage",
	"spell": "Spell Damage",
	"attack": "Attack Damage",
	"projectile": "Projectile Damage",
	"area": "Area Damage",
	"melee": "Melee Damage",
	"minion": "Minion Damage",
	"bleed": "Bleed Damage",
}

const RESIST_STAT_BY_TYPE: Dictionary = {
	"fire": "Fire Resistance",
	"lightning": "Lightning Resistance",
	"void": "Void Resistance",
	"physical": "Physical Reduction",
}

const STAT_ALIASES: Dictionary = {
	"max_health": "Maximum Life",
	"health": "Maximum Life",
	"life": "Maximum Life",
	"maximum_life": "Maximum Life",
	"max_hp": "Maximum Life",
	"max_mana": "Maximum Mana",
	"mana": "Maximum Mana",
	"maximum_mana": "Maximum Mana",
	"spirit": "Maximum Spirit",
	"spirit_max": "Maximum Spirit",
	"maximum_spirit": "Maximum Spirit",
	"fire_damage": "Fire Damage",
	"lightning_damage": "Lightning Damage",
	"void_damage": "Void Damage",
	"physical_damage": "Physical Damage",
	"spell_damage": "Spell Damage",
	"attack_damage": "Attack Damage",
	"projectile_damage": "Projectile Damage",
	"area_damage": "Area Damage",
	"melee_damage": "Melee Damage",
	"minion_damage": "Minion Damage",
	"cast_speed": "Cast Speed",
	"attack_speed": "Attack Speed",
	"crit_chance": "Critical Chance",
	"critical_chance": "Critical Chance",
	"crit_multi": "Critical Multiplier",
	"critical_multiplier": "Critical Multiplier",
	"ignite_chance": "Ignite Chance",
	"shock_chance": "Shock Chance",
	"bleed_chance": "Bleed Chance",
	"chain_bonus": "Chain Bonus",
	"extra_projectiles": "Extra Projectiles",
	"projectile_speed": "Projectile Speed",
	"area_radius": "Area Radius",
	"mana_cost": "Mana Cost",
	"mana_cost_reduction": "Mana Cost Reduction",
	"life_on_hit": "Life On Hit",
	"mana_on_hit": "Mana On Hit",
	"life_leech": "Life Leech",
	"mana_leech": "Mana Leech",
	"armor": "Armor",
	"block_chance": "Block Chance",
	"ward": "Ward",
	"runic_ward": "Runic Ward",
	"fire_resistance": "Fire Resistance",
	"lightning_resistance": "Lightning Resistance",
	"void_resistance": "Void Resistance",
	"physical_reduction": "Physical Reduction",
	"movement_speed": "Movement Speed",
	"item_rarity": "Item Rarity",
	"item_quantity": "Item Quantity",
	"forge_potential": "Forge Potential",
}

static func canonical_stat_key(key: String) -> String:
	var lower_key: String = key.strip_edges().to_lower().replace(" ", "_")
	if STAT_ALIASES.has(lower_key):
		return str(STAT_ALIASES[lower_key])
	return key.strip_edges().replace("_", " ").capitalize()


static func canonicalize_stats(stats: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for raw_key: Variant in stats.keys():
		var key: String = canonical_stat_key(str(raw_key))
		out[key] = float(out.get(key, 0.0)) + float(stats[raw_key])
	return out


static func stat_value(state: Object, key: String) -> float:
	if state == null:
		return 0.0
	var target: String = canonical_stat_key(key)
	var total: float = 0.0
	var stats_value: Variant = state.get("build_stats")
	if typeof(stats_value) == TYPE_DICTIONARY:
		var stats: Dictionary = Dictionary(stats_value)
		for raw_key: Variant in stats.keys():
			if canonical_stat_key(str(raw_key)) == target:
				total += float(stats[raw_key])
	return total


static func state_rules(state: Object) -> Array[String]:
	var rules: Array[String] = []
	if state == null:
		return rules
	var direct_rules: Variant = state.get("build_rules")
	if typeof(direct_rules) == TYPE_ARRAY:
		for value: Variant in Array(direct_rules):
			var rule: String = str(value)
			if rule != "" and not rules.has(rule):
				rules.append(rule)
	var equipped_value: Variant = state.get("equipped")
	if typeof(equipped_value) == TYPE_DICTIONARY:
		var equipped: Dictionary = Dictionary(equipped_value)
		for slot_key: Variant in equipped.keys():
			var raw_item: Variant = equipped[slot_key]
			if typeof(raw_item) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = Dictionary(raw_item)
			var item_rules: Variant = item.get("build_rules", item.get("rules", []))
			if typeof(item_rules) == TYPE_ARRAY:
				for value: Variant in Array(item_rules):
					var rule: String = str(value)
					if rule != "" and not rules.has(rule):
						rules.append(rule)
	return rules


static func has_rule_containing(state: Object, needle: String) -> bool:
	var lower_needle: String = needle.to_lower()
	for rule: String in state_rules(state):
		if rule.to_lower().find(lower_needle) >= 0:
			return true
	return false


static func enhance_cast_data(state: Object, cast_data: Dictionary) -> Dictionary:
	if state == null or cast_data.is_empty():
		return cast_data
	var out: Dictionary = cast_data.duplicate(true)
	var tags: Array = Array(out.get("tags", []))
	var active_id: String = str(out.get("active_id", ""))
	var damage_mult: float = 1.0

	for tag_value: Variant in tags:
		var tag: String = str(tag_value).to_lower()
		if DAMAGE_STAT_BY_TAG.has(tag):
			damage_mult += stat_value(state, str(DAMAGE_STAT_BY_TAG[tag])) / 100.0

	damage_mult += stat_value(state, "Global Damage") / 100.0

	var level_bonus: int = int(round(stat_value(state, "All Skill Level")))
	if _has_tag(tags, "fire"):
		level_bonus += int(round(stat_value(state, "Fire Skill Level")))
	if _has_tag(tags, "lightning"):
		level_bonus += int(round(stat_value(state, "Lightning Skill Level")))
	if _has_tag(tags, "void"):
		level_bonus += int(round(stat_value(state, "Void Skill Level")))
	if _has_tag(tags, "spell"):
		level_bonus += int(round(stat_value(state, "Spell Skill Level")))
	if _has_tag(tags, "projectile"):
		level_bonus += int(round(stat_value(state, "Projectile Skill Level")))
	if _has_tag(tags, "area"):
		level_bonus += int(round(stat_value(state, "Area Skill Level")))
	if _has_tag(tags, "melee"):
		level_bonus += int(round(stat_value(state, "Melee Skill Level")))

	if level_bonus > 0:
		out["level"] = int(out.get("level", 1)) + level_bonus
		damage_mult += float(level_bonus) * 0.08

	out["damage"] = maxf(1.0, float(out.get("damage", 1.0)) * damage_mult)
	out["mana_cost"] = maxf(0.0, float(out.get("mana_cost", 0.0)) * _mana_cost_multiplier(state, tags))

	var cast_speed_bonus: float = stat_value(state, "Cast Speed") / 100.0
	var attack_speed_bonus: float = stat_value(state, "Attack Speed") / 100.0
	var speed_bonus: float = cast_speed_bonus if _has_tag(tags, "spell") else attack_speed_bonus
	if speed_bonus > 0.0:
		out["cooldown"] = maxf(0.03, float(out.get("cooldown", 0.0)) / (1.0 + speed_bonus))
		out["cast_time"] = maxf(0.03, float(out.get("cast_time", 0.0)) / (1.0 + speed_bonus))

	out["ignite_chance"] = clampf(float(out.get("ignite_chance", 0.0)) + stat_value(state, "Ignite Chance") / 100.0, 0.0, 1.0)
	out["shock_chance"] = clampf(float(out.get("shock_chance", 0.0)) + stat_value(state, "Shock Chance") / 100.0, 0.0, 1.0)
	out["bleed_chance"] = clampf(float(out.get("bleed_chance", 0.0)) + stat_value(state, "Bleed Chance") / 100.0, 0.0, 1.0)

	if _has_tag(tags, "projectile"):
		out["projectile_count"] = maxi(1, int(out.get("projectile_count", 1)) + int(round(stat_value(state, "Extra Projectiles"))))
		out["projectile_speed"] = float(out.get("projectile_speed", 13.0)) * (1.0 + stat_value(state, "Projectile Speed") / 100.0)
	if _has_tag(tags, "area"):
		out["area_mult"] = maxf(0.15, float(out.get("area_mult", 1.0)) * (1.0 + stat_value(state, "Area Radius") / 100.0))
	out["chain"] = maxi(0, int(out.get("chain", 0)) + int(round(stat_value(state, "Chain Bonus"))))

	var rules: Dictionary = Dictionary(out.get("rules", {}))
	rules["ignite_chance"] = maxf(float(rules.get("ignite_chance", 0.0)), float(out.get("ignite_chance", 0.0)))
	rules["shock_chance"] = maxf(float(rules.get("shock_chance", 0.0)), float(out.get("shock_chance", 0.0)))
	rules["bleed_chance"] = maxf(float(rules.get("bleed_chance", 0.0)), float(out.get("bleed_chance", 0.0)))
	rules["life_leech"] = maxf(float(rules.get("life_leech", 0.0)), stat_value(state, "Life Leech") / 100.0)
	rules["mana_leech"] = maxf(float(rules.get("mana_leech", 0.0)), stat_value(state, "Mana Leech") / 100.0)
	rules["execute_more"] = maxf(float(rules.get("execute_more", 0.0)), stat_value(state, "Execute More") / 100.0)

	_apply_relic_rule_cast_mods(state, out, rules, active_id, tags)

	out["rules"] = rules
	out["item_power_applied"] = true
	return out


static func _apply_relic_rule_cast_mods(state: Object, out: Dictionary, rules: Dictionary, active_id: String, tags: Array) -> void:
	if active_id == "fireball" and has_rule_containing(state, "burning ground"):
		rules["on_hit_burst"] = true
		rules["ignite_chance"] = maxf(float(rules.get("ignite_chance", 0.0)), 0.35)
		out["ignite_chance"] = maxf(float(out.get("ignite_chance", 0.0)), 0.35)
		_append_cast_note(out, "Relic: Fireball leaves burning ground / burst damage.")
	if active_id == "storm_lance" and has_rule_containing(state, "storm lance chains"):
		out["chain"] = int(out.get("chain", 0)) + 1
		rules["shock_chance"] = maxf(float(rules.get("shock_chance", 0.0)), 0.28)
		_append_cast_note(out, "Relic: Storm Lance gains +1 chain.")
	if active_id == "void_rift" and has_rule_containing(state, "void rift repeats"):
		out["echo_count"] = int(out.get("echo_count", 0)) + 1
		out["mana_cost"] = float(out.get("mana_cost", 0.0)) * 1.12
		_append_cast_note(out, "Relic: Void Rift repeats.")
	if (_has_tag(tags, "melee") or _has_tag(tags, "attack")) and has_rule_containing(state, "every fifth melee hit"):
		rules["trigger_bone_spear"] = true
		_append_cast_note(out, "Relic: every fifth melee hit stores a Bone Spear trigger.")
	if _has_tag(tags, "bleed") and has_rule_containing(state, "bleeding enemies explode"):
		rules["bleed_explode"] = true
		_append_cast_note(out, "Relic: bleeding enemies explode on death.")
	if has_rule_containing(state, "4+ supports") or has_rule_containing(state, "4 supports"):
		out["mana_cost"] = float(out.get("mana_cost", 0.0)) * 0.92


static func _append_cast_note(cast_data: Dictionary, note: String) -> void:
	var notes: Array = Array(cast_data.get("item_rule_notes", []))
	if not notes.has(note):
		notes.append(note)
	cast_data["item_rule_notes"] = notes


static func _mana_cost_multiplier(state: Object, tags: Array) -> float:
	var mult: float = 1.0
	mult += stat_value(state, "Mana Cost") / 100.0
	mult -= stat_value(state, "Mana Cost Reduction") / 100.0
	if _has_tag(tags, "fire") and has_rule_containing(state, "first craft"):
		# Small reward for the forge/support relic archetype; harmless if rule text is present.
		mult -= 0.02
	return maxf(0.05, mult)


static func skill_damage_to_enemy(state: Object, damage: float, tags: Array, rules: Dictionary, enemy: Node) -> float:
	var final_damage: float = maxf(0.0, damage)
	if enemy != null and bool(enemy.get("is_boss")):
		final_damage *= 1.0 + stat_value(state, "Boss Damage") / 100.0
		if has_rule_containing(state, "boss relic"):
			final_damage *= 1.08
	if float(rules.get("execute_more", 0.0)) > 0.0 and enemy != null and enemy.has_method("health_ratio") and float(enemy.call("health_ratio")) <= 0.35:
		final_damage *= 1.0 + float(rules.get("execute_more", 0.0))
	return maxf(0.0, final_damage)


static func after_player_hit(state: Object, enemy: Node, damage: float, tags: Array, rules: Dictionary) -> void:
	if state == null or damage <= 0.0:
		return
	var life_gain: float = stat_value(state, "Life On Hit") + damage * maxf(0.0, float(rules.get("life_leech", 0.0)))
	var mana_gain: float = stat_value(state, "Mana On Hit") + damage * maxf(0.0, float(rules.get("mana_leech", 0.0)))
	if life_gain > 0.0:
		state.set("player_hp", minf(float(state.get("max_hp")), float(state.get("player_hp")) + life_gain))
	if mana_gain > 0.0:
		state.set("player_mana", minf(float(state.get("max_mana")), float(state.get("player_mana")) + mana_gain))

	if bool(rules.get("trigger_bone_spear", false)):
		var count: int = int(state.get("melee_hit_counter")) + 1
		state.set("melee_hit_counter", count)
		if count >= 5:
			state.set("melee_hit_counter", 0)
			# This is a lightweight gameplay hook until full trigger gems exist.
			if enemy != null and enemy.has_method("take_damage"):
				enemy.call("take_damage", maxf(1.0, damage * 0.35))
			if state.has_method("add_notice"):
				state.call("add_notice", "Relic trigger: Bone Spear")


static func player_damage_taken(state: Object, raw_damage_per_second: float, damage_type: String = "physical", delta: float = 1.0) -> float:
	if state == null:
		return maxf(0.0, raw_damage_per_second * delta)
	var incoming: float = maxf(0.0, raw_damage_per_second * delta)
	if incoming <= 0.0:
		return 0.0
	var armor: float = maxf(0.0, float(state.get("armor")) + stat_value(state, "Armor"))
	var mitigation: float = armor / (armor + 160.0)
	if damage_type == "physical":
		mitigation += clampf(stat_value(state, "Physical Reduction") / 100.0, 0.0, 0.75)
	else:
		var resist_key: String = str(RESIST_STAT_BY_TYPE.get(damage_type, damage_type.capitalize() + " Resistance"))
		mitigation += clampf(stat_value(state, resist_key) / 100.0, -0.5, 0.75)
	mitigation = clampf(mitigation, -0.5, 0.85)
	var after_mitigation: float = incoming * (1.0 - mitigation)

	var block_chance: float = clampf(stat_value(state, "Block Chance") / 100.0, 0.0, 0.75)
	if block_chance > 0.0:
		# Average block reduction for continuous contact damage. Real hit-block can come later.
		after_mitigation *= 1.0 - block_chance * 0.55

	var ward_max: float = maxf(stat_value(state, "Runic Ward"), stat_value(state, "Ward"))
	if ward_max > 0.0:
		var current_ward: float = float(state.get("runic_ward_current"))
		if current_ward <= 0.0 and float(state.get("player_hp")) - after_mitigation <= 1.0:
			current_ward = ward_max
		var absorbed: float = minf(current_ward, after_mitigation)
		current_ward -= absorbed
		after_mitigation -= absorbed
		state.set("runic_ward_current", current_ward)
		state.set("runic_ward_max", ward_max)

	return maxf(0.0, after_mitigation)


static func apply_character_defense_stats(state: Object) -> void:
	if state == null:
		return
	var ward_max: float = maxf(stat_value(state, "Runic Ward"), stat_value(state, "Ward"))
	state.set("runic_ward_max", ward_max)
	if state.get("runic_ward_current") == null:
		state.set("runic_ward_current", ward_max)
	else:
		state.set("runic_ward_current", clampf(float(state.get("runic_ward_current")), 0.0, ward_max))


static func can_equip_item(state: Object, item: Dictionary) -> bool:
	return invalid_equip_reasons(state, item).is_empty()


static func invalid_equip_reasons(state: Object, item: Dictionary) -> Array[String]:
	var reasons: Array[String] = []
	if state == null or item.is_empty():
		return reasons
	var required_level: int = int(item.get("required_level", item.get("level_req", 0)))
	if required_level > int(state.get("level")):
		reasons.append("Requires Level " + str(required_level))
	var req_value: Variant = item.get("requirements", item.get("req", {}))
	if typeof(req_value) == TYPE_DICTIONARY:
		var req: Dictionary = Dictionary(req_value)
		for key: Variant in req.keys():
			var stat_name: String = str(key).replace("_", " ").capitalize()
			var have: float = 10.0 + stat_value(state, stat_name)
			var need: float = float(req[key])
			if need > have:
				reasons.append("Requires " + str(int(need)) + " " + stat_name + " (have " + str(int(have)) + ")")
	return reasons


static func selected_skill_impact_text(state: Object, item: Dictionary) -> String:
	if state == null or item.is_empty():
		return ""
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a]Build Impact[/color]")
	var item_stats: Dictionary = canonicalize_stats(Dictionary(item.get("total_stats", item.get("stats", {}))))
	var relevant: PackedStringArray = PackedStringArray()
	for key: Variant in item_stats.keys():
		var stat_key: String = str(key)
		if stat_key.find("Damage") >= 0 or stat_key.find("Skill Level") >= 0 or stat_key in ["Chain Bonus", "Extra Projectiles", "Area Radius", "Cast Speed", "Attack Speed", "Maximum Spirit", "Mana Cost Reduction"]:
			relevant.append("• " + stat_key + ": " + _signed(float(item_stats[key])))
	if relevant.is_empty():
		lines.append("No direct selected-skill stats detected. Defensive/resource value may still matter.")
	else:
		for line: String in relevant:
			lines.append(line)
	var item_rules: Variant = item.get("build_rules", item.get("rules", []))
	if typeof(item_rules) == TYPE_ARRAY and not Array(item_rules).is_empty():
		lines.append("[color=#8f8777]Rules[/color]")
		for rule: Variant in Array(item_rules):
			lines.append("• " + str(rule))
	return "\n".join(lines)


static func _signed(value: float) -> String:
	if value >= 0.0:
		return "+" + str(snappedf(value, 0.1))
	return str(snappedf(value, 0.1))


static func _has_tag(tags: Array, tag: String) -> bool:
	for value: Variant in tags:
		if str(value).to_lower() == tag.to_lower():
			return true
	return false
