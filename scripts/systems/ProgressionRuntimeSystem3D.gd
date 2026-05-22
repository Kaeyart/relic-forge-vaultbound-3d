class_name RVProgressionRuntimeSystem3D
extends RefCounted

const ELEMENT_TAGS: Array[String] = ["fire", "lightning", "void", "cold"]

static func ensure_runtime_defaults(state: Object) -> void:
	if state == null:
		return
	var runtime: Dictionary = _dict(state.get("progression_runtime"))
	if runtime.is_empty():
		runtime = {
			"blood_charges": 0,
			"life_spent_recent": 0.0,
			"last_element": "",
			"confluence_stacks": 0,
			"echo_ready_at": 0,
			"rage": 0,
			"execution_marks": 0,
		}
	state.set("progression_runtime", runtime)


static func enhance_cast_data(state: Object, cast_data: Dictionary) -> Dictionary:
	if state == null or cast_data.is_empty():
		return cast_data
	ensure_runtime_defaults(state)
	var out: Dictionary = cast_data.duplicate(true)
	var tags: Array = Array(out.get("tags", []))
	var rules: Dictionary = Dictionary(out.get("rules", {}))
	var build_rules: Array[String] = _state_rules(state)

	_apply_blood_mage(state, out, rules, tags, build_rules)
	_apply_elementalist(state, out, rules, tags, build_rules)
	_apply_chronomancer(state, out, rules, tags, build_rules)
	_apply_titan(state, out, rules, tags, build_rules)
	_apply_juggernaut(state, out, rules, tags, build_rules)
	_apply_warbringer(state, out, rules, tags, build_rules)
	_apply_deadeye(state, out, rules, tags, build_rules)
	_apply_warden(state, out, rules, tags, build_rules)
	_apply_nightstalker(state, out, rules, tags, build_rules)

	out["rules"] = rules
	out["progression_power_applied"] = true
	return out


static func after_player_hit(state: Object, enemy: Node, damage: float, tags: Array, rules: Dictionary) -> void:
	if state == null:
		return
	ensure_runtime_defaults(state)
	var build_rules: Array[String] = _state_rules(state)
	var runtime: Dictionary = _dict(state.get("progression_runtime"))
	if _has_any_rule(build_rules, ["warbringer_rage", "rage_furnace"]) and (_has_tag(tags, "melee") or _has_tag(tags, "attack")):
		runtime["rage"] = clampi(int(runtime.get("rage", 0)) + 1, 0, 30)
	if bool(rules.get("execution_mark", false)) and enemy != null:
		runtime["execution_marks"] = int(runtime.get("execution_marks", 0)) + 1
	state.set("progression_runtime", runtime)


static func player_damage_taken(state: Object, incoming: float, damage_type: String = "physical") -> float:
	if state == null:
		return incoming
	var rules: Array[String] = _state_rules(state)
	var out: float = maxf(0.0, incoming)
	if _has_any_rule(rules, ["juggernaut_iron_blood", "stone_oath"]):
		if damage_type != "physical":
			var armor: float = maxf(0.0, float(state.get("armor")))
			out *= 1.0 - clampf(armor / (armor + 240.0) * 0.35, 0.0, 0.35)
	if _has_any_rule(rules, ["juggernaut_unbroken", "unbroken_guard"]):
		out *= 0.92
	if _has_any_rule(rules, ["warden_field_warden"]):
		out *= 0.94
	return maxf(0.0, out)


static func progression_summary(state: Object) -> String:
	if state == null:
		return "No progression runtime."
	ensure_runtime_defaults(state)
	var runtime: Dictionary = _dict(state.get("progression_runtime"))
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Progression Runtime")
	lines.append("Blood Charges: " + str(runtime.get("blood_charges", 0)))
	lines.append("Confluence: " + str(runtime.get("confluence_stacks", 0)) + " / last " + str(runtime.get("last_element", "—")))
	lines.append("Rage: " + str(runtime.get("rage", 0)))
	lines.append("Execution Marks: " + str(runtime.get("execution_marks", 0)))
	return "\n".join(lines)


static func _apply_blood_mage(state: Object, out: Dictionary, rules: Dictionary, tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["blood_mage", "blood_price", "crimson_casting", "blood_mage_life_costs"]):
		return
	if not (_has_tag(tags, "spell") or _has_tag(tags, "hit")):
		return
	var runtime: Dictionary = _dict(state.get("progression_runtime"))
	var mana_cost: float = float(out.get("mana_cost", 0.0))
	var life_part: float = mana_cost * 0.30
	out["mana_cost"] = mana_cost - life_part
	out["life_cost"] = float(out.get("life_cost", 0.0)) + life_part
	rules["life_cost"] = float(rules.get("life_cost", 0.0)) + life_part
	runtime["life_spent_recent"] = float(runtime.get("life_spent_recent", 0.0)) + life_part
	runtime["blood_charges"] = clampi(int(runtime.get("blood_charges", 0)) + 1, 0, 5)
	var charge_damage: float = float(runtime.get("blood_charges", 0)) * 0.04
	out["damage"] = float(out.get("damage", 1.0)) * (1.0 + charge_damage)
	if int(runtime.get("blood_charges", 0)) >= 5:
		runtime["blood_charges"] = 0
		out["echo_count"] = int(out.get("echo_count", 0)) + 1
		rules["life_leech"] = maxf(float(rules.get("life_leech", 0.0)), 0.04)
		_add_note(out, "Blood Mage: Blood Charges empowered this skill.")
	state.set("progression_runtime", runtime)
	_add_note(out, "Blood Mage: part of the cost is paid with life.")


static func _apply_elementalist(state: Object, out: Dictionary, rules: Dictionary, tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["elementalist", "elemental_confluence", "exposure_engine"]):
		return
	var element: String = _first_element(tags)
	if element == "":
		return
	var runtime: Dictionary = _dict(state.get("progression_runtime"))
	var last: String = str(runtime.get("last_element", ""))
	var stacks: int = int(runtime.get("confluence_stacks", 0))
	if last != "" and last != element:
		stacks = clampi(stacks + 1, 0, 3)
	else:
		stacks = maxi(stacks, 1)
	runtime["last_element"] = element
	runtime["confluence_stacks"] = stacks
	state.set("progression_runtime", runtime)
	out["damage"] = float(out.get("damage", 1.0)) * (1.0 + float(stacks) * 0.06)
	if element == "fire":
		rules["ignite_chance"] = maxf(float(rules.get("ignite_chance", 0.0)), 0.20 + float(stacks) * 0.05)
	elif element == "lightning":
		rules["shock_chance"] = maxf(float(rules.get("shock_chance", 0.0)), 0.18 + float(stacks) * 0.05)
	_add_note(out, "Elementalist: Confluence stacks " + str(stacks) + ".")


static func _apply_chronomancer(state: Object, out: Dictionary, rules: Dictionary, tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["chronomancer", "echo_window", "fractured_moment"]):
		return
	if not _has_tag(tags, "spell"):
		return
	var runtime: Dictionary = _dict(state.get("progression_runtime"))
	var now: int = Time.get_ticks_msec()
	var ready_at: int = int(runtime.get("echo_ready_at", 0))
	if now >= ready_at:
		out["echo_count"] = int(out.get("echo_count", 0)) + 1
		out["damage"] = float(out.get("damage", 1.0)) * 1.05
		runtime["echo_ready_at"] = now + 4200
		_add_note(out, "Chronomancer: Echo Window repeated this spell.")
	out["cooldown"] = maxf(0.03, float(out.get("cooldown", 0.0)) * 0.92)
	state.set("progression_runtime", runtime)


static func _apply_titan(_state: Object, out: Dictionary, rules: Dictionary, tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["titan", "aftershock", "earthsplitter", "faultline"]):
		return
	if _has_tag(tags, "slam") or _has_tag(tags, "melee") or _has_tag(tags, "area"):
		rules["aftershock"] = true
		out["area_mult"] = float(out.get("area_mult", 1.0)) * 1.18
		out["damage"] = float(out.get("damage", 1.0)) * 1.10
		_add_note(out, "Titan: slam/melee aftershock enabled.")


static func _apply_juggernaut(state: Object, out: Dictionary, rules: Dictionary, _tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["juggernaut", "unbroken", "iron_blood", "vault_ward"]):
		return
	rules["juggernaut_guard"] = true
	state.set("runic_ward_max", maxf(float(state.get("runic_ward_max")), 20.0 + float(state.get("level")) * 2.0))
	_add_note(out, "Juggernaut: guard/ward rules active.")


static func _apply_warbringer(state: Object, out: Dictionary, rules: Dictionary, tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["warbringer", "rage", "battle_roar", "rage_furnace"]):
		return
	if not (_has_tag(tags, "attack") or _has_tag(tags, "melee")):
		return
	var runtime: Dictionary = _dict(state.get("progression_runtime"))
	var rage: int = clampi(int(runtime.get("rage", 0)) + 1, 0, 30)
	runtime["rage"] = rage
	state.set("progression_runtime", runtime)
	out["damage"] = float(out.get("damage", 1.0)) * (1.0 + float(rage) * 0.01)
	if rage >= 10:
		rules["on_hit_burst"] = true
		_add_note(out, "Warbringer: Rage shockwave primed.")


static func _apply_deadeye(_state: Object, out: Dictionary, rules: Dictionary, tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["deadeye", "far_shot", "ricochet", "perfect_angle"]):
		return
	if not _has_tag(tags, "projectile"):
		return
	out["projectile_speed"] = float(out.get("projectile_speed", 13.0)) * 1.22
	out["chain"] = int(out.get("chain", 0)) + 1
	rules["far_shot"] = true
	_add_note(out, "Deadeye: projectile speed and ricochet improved.")


static func _apply_warden(_state: Object, out: Dictionary, rules: Dictionary, tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["warden", "snarecraft", "predator_ground"]):
		return
	if _has_tag(tags, "trap") or _has_tag(tags, "mine") or _has_tag(tags, "projectile"):
		rules["slow_on_hit"] = true
		rules["root_chance"] = maxf(float(rules.get("root_chance", 0.0)), 0.12)
		_add_note(out, "Warden: hits slow and control prey.")


static func _apply_nightstalker(_state: Object, out: Dictionary, rules: Dictionary, tags: Array, build_rules: Array[String]) -> void:
	if not _has_any_rule(build_rules, ["nightstalker", "execution", "first_blood", "red_trail"]):
		return
	if _has_tag(tags, "projectile") or _has_tag(tags, "attack") or _has_tag(tags, "bleed"):
		rules["execution_mark"] = true
		rules["execute_more"] = maxf(float(rules.get("execute_more", 0.0)), 0.35)
		rules["bleed_chance"] = maxf(float(rules.get("bleed_chance", 0.0)), 0.25)
		_add_note(out, "Nightstalker: execution mark enabled.")


static func _state_rules(state: Object) -> Array[String]:
	var out: Array[String] = []
	if state == null:
		return out
	var value: Variant = state.get("build_rules")
	if typeof(value) == TYPE_ARRAY:
		for raw: Variant in Array(value):
			var rule: String = str(raw)
			if rule != "" and not out.has(rule):
				out.append(rule)
	return out


static func _has_any_rule(rules: Array[String], needles: Array[String]) -> bool:
	for rule: String in rules:
		var r: String = rule.to_lower()
		for needle: String in needles:
			if r.find(needle.to_lower()) >= 0:
				return true
	return false


static func _has_tag(tags: Array, tag: String) -> bool:
	for value: Variant in tags:
		if str(value).to_lower() == tag.to_lower():
			return true
	return false


static func _first_element(tags: Array) -> String:
	for element: String in ELEMENT_TAGS:
		if _has_tag(tags, element):
			return element
	return ""


static func _add_note(cast_data: Dictionary, note: String) -> void:
	var notes: Array = Array(cast_data.get("progression_notes", []))
	if not notes.has(note):
		notes.append(note)
	cast_data["progression_notes"] = notes


static func _dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}
