class_name RVSkillGemSystem3D
extends RefCounted

const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

const DEFAULT_ACTIVE_SLOTS: Array = [
	{"active": "fireball", "supports": ["controlled_power", "ignition"]},
	{"active": "storm_lance", "supports": ["chain_current"]},
	{"active": "arc_slash", "supports": []},
	{"active": "void_rift", "supports": []},
]

const DEFAULT_ACTIVE_OWNED: Array[String] = ["fireball", "storm_lance", "arc_slash", "void_rift"]
const DEFAULT_SUPPORT_OWNED: Array[String] = ["controlled_power", "efficient_casting", "greater_area", "split_projectile", "chain_current", "ignition"]
const DEFAULT_SPIRIT_OWNED: Array[String] = ["clarity", "vitality"]

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return

	var actives: Dictionary = _state_dict(state, "active_gems_owned")
	for active_id: String in DEFAULT_ACTIVE_OWNED:
		actives[active_id] = true
	_state_set(state, "active_gems_owned", actives)

	var supports: Dictionary = _state_dict(state, "support_gems_owned")
	for support_id: String in DEFAULT_SUPPORT_OWNED:
		if not supports.has(support_id):
			supports[support_id] = 1
	_state_set(state, "support_gems_owned", supports)

	var spirits: Dictionary = _state_dict(state, "spirit_gems_owned")
	for spirit_id: String in DEFAULT_SPIRIT_OWNED:
		if not spirits.has(spirit_id):
			spirits[spirit_id] = false
	_state_set(state, "spirit_gems_owned", spirits)

	var slots: Array = _normalized_slots(_state_array(state, "active_skill_slots"))
	if slots.is_empty():
		slots = _default_slots()
	while slots.size() < 4:
		slots.append({"active": "fireball", "supports": []})
	_state_set(state, "active_skill_slots", slots)

	var selected: int = _safe_int(_state_get(state, "selected_skill_slot", 0), 0)
	selected = _safe_index(selected, slots.size())
	_state_set(state, "selected_skill_slot", selected)

	var support_cursor: int = _safe_int(_state_get(state, "selected_support_cursor", 0), 0)
	_state_set(state, "selected_support_cursor", max(0, support_cursor))
	var spirit_cursor: int = _safe_int(_state_get(state, "selected_spirit_cursor", 0), 0)
	_state_set(state, "selected_spirit_cursor", max(0, spirit_cursor))

static func selected_slot(state: Object) -> Dictionary:
	ensure_defaults(state)
	if state == null:
		return {"active": "fireball", "supports": []}

	var slots: Array = _normalized_slots(_state_array(state, "active_skill_slots"))
	if slots.is_empty():
		slots = _default_slots()
		_state_set(state, "active_skill_slots", slots)

	var index: int = _safe_index(_safe_int(_state_get(state, "selected_skill_slot", 0), 0), slots.size())
	_state_set(state, "selected_skill_slot", index)
	if slots.is_empty():
		return {"active": "fireball", "supports": []}
	return Dictionary(slots[index]).duplicate(true)

static func selected_cast_data(state: Object) -> Dictionary:
	ensure_defaults(state)
	var slot: Dictionary = selected_slot(state)
	if slot.is_empty():
		return {}
	return cast_data_for_slot(state, slot)

static func cast_data_for_slot(state: Object, slot: Dictionary) -> Dictionary:
	var active_id: String = _slot_active_id(slot)
	if active_id == "":
		active_id = "fireball"
	var active: Dictionary = GemDBScript.active(active_id)
	if active.is_empty() and active_id != "fireball":
		active_id = "fireball"
		active = GemDBScript.active(active_id)

	var tags: Array = Array(active.get("tags", [])).duplicate(true)
	var damage: float = float(active.get("damage", 1.0))
	var mana_cost: float = float(active.get("mana_cost", 1.0))
	var area_mult: float = 1.0
	var extra_projectiles: int = 0
	var chain: int = 0
	var echo_count: int = 0
	var rules: Array[String] = []

	for support_id_value: Variant in Array(slot.get("supports", [])):
		var support_id: String = str(support_id_value)
		if support_id == "":
			continue
		if not GemDBScript.support_compatible(active_id, support_id):
			continue
		var support: Dictionary = GemDBScript.support(support_id)
		damage *= float(support.get("damage_mult", 1.0))
		mana_cost *= float(support.get("cost_mult", 1.0))
		area_mult *= float(support.get("area_mult", 1.0))
		extra_projectiles += int(support.get("extra_projectiles", 0))
		chain += int(support.get("chain", 0))
		echo_count += int(support.get("echo_count", 0))
		for rule_value: Variant in Array(support.get("rules", [])):
			var rule: String = str(rule_value)
			if rule != "" and not rules.has(rule):
				rules.append(rule)

	var stats: Dictionary = {}
	if state != null:
		stats = _state_dict(state, "build_stats")
	if tags.has("spell"):
		damage *= 1.0 + float(stats.get("Spell Damage", 0.0))
	if tags.has("attack"):
		damage *= 1.0 + float(stats.get("Attack Damage", 0.0))
	if tags.has("fire"):
		damage *= 1.0 + float(stats.get("Fire Damage", 0.0))
	if tags.has("lightning"):
		damage *= 1.0 + float(stats.get("Lightning Damage", 0.0))
	if tags.has("void"):
		damage *= 1.0 + float(stats.get("Void Damage", 0.0))
	if tags.has("projectile"):
		damage *= 1.0 + float(stats.get("Projectile Damage", 0.0))

	return {
		"active_id": active_id,
		"active": active_id,
		"name": str(active.get("name", active_id)),
		"tags": tags,
		"damage": damage,
		"mana_cost": mana_cost,
		"area_mult": area_mult,
		"extra_projectiles": extra_projectiles,
		"chain": chain,
		"echo_count": echo_count,
		"rules": rules,
	}

static func collect_spirit_bundle(state: Object) -> Dictionary:
	if state == null:
		return {"stats": {}, "rules": [], "reserved": 0}
	ensure_defaults(state)
	var stats: Dictionary = {}
	var rules: Array[String] = []
	var reserved: int = 0
	var spirits: Dictionary = _state_dict(state, "spirit_gems_owned")
	for key_value: Variant in spirits.keys():
		var id: String = str(key_value)
		if not bool(spirits[key_value]):
			continue
		var data: Dictionary = GemDBScript.spirit(id)
		reserved += int(data.get("reservation", 0))
		var spirit_stats: Dictionary = Dictionary(data.get("stats", {}))
		for stat_key: Variant in spirit_stats.keys():
			var key: String = str(stat_key)
			stats[key] = float(stats.get(key, 0.0)) + float(spirit_stats[stat_key])
		for rule_value: Variant in Array(data.get("rules", [])):
			var rule: String = str(rule_value)
			if rule != "" and not rules.has(rule):
				rules.append(rule)
	return {"stats": stats, "rules": rules, "reserved": reserved}

static func add_gem_drop_to_state(state: Object, kind: String, gem_id: String) -> void:
	if state == null or gem_id == "":
		return
	ensure_defaults(state)
	if kind == "active_gem":
		var actives: Dictionary = _state_dict(state, "active_gems_owned")
		actives[gem_id] = true
		_state_set(state, "active_gems_owned", actives)
	elif kind == "support_gem":
		var supports: Dictionary = _state_dict(state, "support_gems_owned")
		supports[gem_id] = int(supports.get(gem_id, 0)) + 1
		_state_set(state, "support_gems_owned", supports)
	elif kind == "spirit_gem":
		var spirits: Dictionary = _state_dict(state, "spirit_gems_owned")
		if not spirits.has(gem_id):
			spirits[gem_id] = false
		_state_set(state, "spirit_gems_owned", spirits)

static func cycle_active_slot_gem(state: Object, direction: int) -> void:
	ensure_defaults(state)
	if state == null:
		return
	var owned: Array = _truthy_keys(_state_dict(state, "active_gems_owned"))
	if owned.is_empty():
		return
	var slots: Array = _normalized_slots(_state_array(state, "active_skill_slots"))
	if slots.is_empty():
		slots = _default_slots()
	var index: int = _safe_index(_safe_int(_state_get(state, "selected_skill_slot", 0), 0), slots.size())
	if slots.is_empty():
		return
	var slot: Dictionary = Dictionary(slots[index]).duplicate(true)
	var current: String = _slot_active_id(slot)
	var current_index: int = owned.find(current)
	if current_index < 0:
		current_index = 0
	current_index = wrapi(current_index + direction, 0, owned.size())
	var next_active: String = str(owned[current_index])
	slot["active"] = next_active
	slot["active_id"] = next_active
	slot["supports"] = []
	slots[index] = slot
	_state_set(state, "active_skill_slots", slots)
	_state_set(state, "selected_skill_slot", index)
	_state_notice(state, "Active: " + str(GemDBScript.active(next_active).get("name", next_active)))

static func add_next_valid_support(state: Object) -> void:
	ensure_defaults(state)
	if state == null:
		return
	var slots: Array = _normalized_slots(_state_array(state, "active_skill_slots"))
	if slots.is_empty():
		slots = _default_slots()
	var index: int = _safe_index(_safe_int(_state_get(state, "selected_skill_slot", 0), 0), slots.size())
	if slots.is_empty():
		return
	var slot: Dictionary = Dictionary(slots[index]).duplicate(true)
	var active_id: String = _slot_active_id(slot)
	var equipped: Array = Array(slot.get("supports", [])).duplicate(true)
	if equipped.size() >= 3:
		_state_notice(state, "Support slots full")
		return
	var owned: Dictionary = _state_dict(state, "support_gems_owned")
	var keys: Array = _positive_keys(owned)
	if keys.is_empty():
		_state_notice(state, "No support gems owned")
		return
	var cursor: int = _safe_int(_state_get(state, "selected_support_cursor", 0), 0)
	cursor = wrapi(cursor, 0, keys.size())
	for step: int in range(keys.size()):
		var key: String = str(keys[wrapi(cursor + step, 0, keys.size())])
		if equipped.has(key):
			continue
		if GemDBScript.support_compatible(active_id, key):
			equipped.append(key)
			slot["supports"] = equipped
			slots[index] = slot
			_state_set(state, "active_skill_slots", slots)
			_state_set(state, "selected_support_cursor", wrapi(cursor + step + 1, 0, keys.size()))
			_state_notice(state, "Added support: " + str(GemDBScript.support(key).get("name", key)))
			return
	_state_notice(state, "No valid support found")

static func remove_last_support(state: Object) -> void:
	ensure_defaults(state)
	if state == null:
		return
	var slots: Array = _normalized_slots(_state_array(state, "active_skill_slots"))
	if slots.is_empty():
		return
	var index: int = _safe_index(_safe_int(_state_get(state, "selected_skill_slot", 0), 0), slots.size())
	var slot: Dictionary = Dictionary(slots[index]).duplicate(true)
	var supports: Array = Array(slot.get("supports", [])).duplicate(true)
	if supports.is_empty():
		return
	supports.pop_back()
	slot["supports"] = supports
	slots[index] = slot
	_state_set(state, "active_skill_slots", slots)

static func toggle_next_spirit(state: Object) -> void:
	ensure_defaults(state)
	if state == null:
		return
	var spirits: Dictionary = _state_dict(state, "spirit_gems_owned")
	var keys: Array = spirits.keys()
	if keys.is_empty():
		return
	var cursor: int = _safe_int(_state_get(state, "selected_spirit_cursor", 0), 0)
	cursor = wrapi(cursor, 0, keys.size())
	var id: String = str(keys[cursor])
	spirits[id] = not bool(spirits[id])
	_state_set(state, "spirit_gems_owned", spirits)
	_state_set(state, "selected_spirit_cursor", wrapi(cursor + 1, 0, keys.size()))
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	if _safe_int(_state_get(state, "spirit_reserved", 0), 0) > _safe_int(_state_get(state, "spirit_max", 0), 0):
		spirits[id] = false
		_state_set(state, "spirit_gems_owned", spirits)
		if state.has_method("recompute_stats"):
			state.call("recompute_stats")
		_state_notice(state, "Not enough Spirit")
	else:
		_state_notice(state, "Spirit: " + str(GemDBScript.spirit(id).get("name", id)))

static func panel_text(state: Object) -> String:
	ensure_defaults(state)
	var text: String = "SKILL LOADOUT\n"
	text += "1-4 Select Slot · A/D Change Active · S Add Support · W Remove Support · G Toggle Spirit\n\n"
	var slots: Array = _normalized_slots(_state_array(state, "active_skill_slots"))
	if slots.is_empty():
		slots = _default_slots()
	var selected: int = _safe_index(_safe_int(_state_get(state, "selected_skill_slot", 0), 0), slots.size())
	for i: int in range(slots.size()):
		var slot: Dictionary = Dictionary(slots[i])
		var active_id: String = _slot_active_id(slot)
		var marker: String = "> " if i == selected else "  "
		text += marker + str(i + 1) + ". " + str(GemDBScript.active(active_id).get("name", active_id)) + "\n"
		for sup_value: Variant in Array(slot.get("supports", [])):
			text += "     + " + str(GemDBScript.support(str(sup_value)).get("name", sup_value)) + "\n"
	var cast: Dictionary = selected_cast_data(state)
	text += "\nSelected: " + str(cast.get("name", "")) + " · Damage " + str(int(round(float(cast.get("damage", 0.0))))) + " · Mana " + str(int(round(float(cast.get("mana_cost", 0.0))))) + "\n"
	text += "Tags: " + ", ".join(PackedStringArray(_string_array(Array(cast.get("tags", []))))) + "\n\n"
	text += "SPIRIT " + str(_state_get(state, "spirit_reserved", 0)) + "/" + str(_state_get(state, "spirit_max", 0)) + "\n"
	var spirits: Dictionary = _state_dict(state, "spirit_gems_owned")
	for key_value: Variant in spirits.keys():
		var id: String = str(key_value)
		var on: String = "ON " if bool(spirits[key_value]) else "off"
		text += "  " + on + " — " + str(GemDBScript.spirit(id).get("name", id)) + "\n"
	return text

static func _default_slots() -> Array:
	var out: Array = []
	for slot_value: Variant in DEFAULT_ACTIVE_SLOTS:
		out.append(Dictionary(slot_value).duplicate(true))
	return out

static func _normalized_slots(raw_slots: Array) -> Array:
	var out: Array = []
	for slot_value: Variant in raw_slots:
		if typeof(slot_value) != TYPE_DICTIONARY:
			continue
		var slot: Dictionary = Dictionary(slot_value).duplicate(true)
		var active_id: String = _slot_active_id(slot)
		if active_id == "":
			active_id = "fireball"
		slot["active"] = active_id
		slot["active_id"] = active_id
		if not slot.has("supports") or typeof(slot.get("supports")) != TYPE_ARRAY:
			slot["supports"] = []
		else:
			slot["supports"] = Array(slot.get("supports", [])).duplicate(true)
		out.append(slot)
	return out

static func _slot_active_id(slot: Dictionary) -> String:
	return str(slot.get("active", slot.get("active_id", slot.get("active_gem_id", slot.get("gem_id", "fireball")))))

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _state_set(state: Object, key: String, value: Variant) -> void:
	if state != null:
		state.set(key, value)

static func _state_dict(state: Object, key: String) -> Dictionary:
	var value: Variant = _state_get(state, key, {})
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value).duplicate(true)
	return {}

static func _state_array(state: Object, key: String) -> Array:
	var value: Variant = _state_get(state, key, [])
	if typeof(value) == TYPE_ARRAY:
		return Array(value).duplicate(true)
	return []

static func _safe_int(value: Variant, fallback: int = 0) -> int:
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(value)
		TYPE_STRING:
			var text: String = str(value)
			if text.is_valid_int():
				return int(text)
	return fallback

static func _safe_index(index: int, size: int) -> int:
	if size <= 0:
		return 0
	return clampi(index, 0, size - 1)

static func _truthy_keys(dict: Dictionary) -> Array:
	var out: Array = []
	for key_value: Variant in dict.keys():
		if bool(dict[key_value]):
			out.append(str(key_value))
	return out

static func _positive_keys(dict: Dictionary) -> Array:
	var out: Array = []
	for key_value: Variant in dict.keys():
		if int(dict[key_value]) > 0:
			out.append(str(key_value))
	return out

static func _state_notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)

static func _string_array(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value: Variant in values:
		out.append(str(value))
	return out
