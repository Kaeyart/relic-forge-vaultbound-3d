class_name RVSkillGemSystem3D
extends RefCounted

const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

static func ensure_defaults(state: Object) -> void:
	if state == null: return
	var actives: Dictionary = Dictionary(state.get("active_gems_owned"))
	for id: String in ["fireball", "storm_lance", "arc_slash", "void_rift"]:
		actives[id] = true
	state.set("active_gems_owned", actives)
	var supports: Dictionary = Dictionary(state.get("support_gems_owned"))
	for sid: String in ["controlled_power", "efficient_casting", "greater_area", "split_projectile", "chain_current", "ignition"]:
		if not supports.has(sid): supports[sid] = 1
	state.set("support_gems_owned", supports)
	var spirits: Dictionary = Dictionary(state.get("spirit_gems_owned"))
	for spid: String in ["clarity", "vitality"]:
		if not spirits.has(spid): spirits[spid] = false
	state.set("spirit_gems_owned", spirits)
	var slots: Array = Array(state.get("active_skill_slots"))
	if slots.is_empty():
		slots = [
			{"active":"fireball", "supports":["controlled_power", "ignition"]},
			{"active":"storm_lance", "supports":["chain_current"]},
			{"active":"arc_slash", "supports":[]},
			{"active":"void_rift", "supports":[]}
		]
	while slots.size() < 4:
		slots.append({"active":"fireball", "supports":[]})
	state.set("active_skill_slots", slots)

static func selected_slot(state: Object) -> Dictionary:
	ensure_defaults(state)
	if state == null:
		return {"active_id": "fireball", "supports": []}

	var slots: Array = []
	var slots_value: Variant = state.get("active_skill_slots")
	if typeof(slots_value) == TYPE_ARRAY:
		for slot_value: Variant in Array(slots_value):
			if typeof(slot_value) == TYPE_DICTIONARY:
				var slot: Dictionary = Dictionary(slot_value).duplicate(true)
				if not slot.has("active_id"):
					slot["active_id"] = str(slot.get("active_gem_id", slot.get("gem_id", "fireball")))
				if not slot.has("supports") or typeof(slot.get("supports")) != TYPE_ARRAY:
					slot["supports"] = []
				slots.append(slot)

	if slots.is_empty():
		slots = [
			{"active_id": "fireball", "supports": []},
			{"active_id": "storm_lance", "supports": []},
			{"active_id": "arc_slash", "supports": []},
			{"active_id": "void_rift", "supports": []},
		]
		state.set("active_skill_slots", slots)

	var selected_value: Variant = state.get("selected_skill_slot")
	var index: int = 0
	if typeof(selected_value) == TYPE_INT:
		index = selected_value
	elif typeof(selected_value) == TYPE_FLOAT:
		index = int(selected_value)
	elif typeof(selected_value) == TYPE_STRING and str(selected_value).is_valid_int():
		index = int(str(selected_value))
	index = clampi(index, 0, max(0, slots.size() - 1))
	state.set("selected_skill_slot", index)
	return Dictionary(slots[index]).duplicate(true)
static func selected_cast_data(state: Object) -> Dictionary:
	ensure_defaults(state)
	var slot: Dictionary = selected_slot(state)
	if slot.is_empty():
		return {}
	return cast_data_for_slot(state, slot)

static func cast_data_for_slot(state: Object, slot: Dictionary) -> Dictionary:
	var active_id: String = str(slot.get("active", "fireball"))
	var active: Dictionary = GemDBScript.active(active_id)
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
			if rule != "" and not rules.has(rule): rules.append(rule)
	var stats: Dictionary = Dictionary(state.get("build_stats"))
	if tags.has("spell"): damage *= 1.0 + float(stats.get("Spell Damage", 0.0))
	if tags.has("attack"): damage *= 1.0 + float(stats.get("Attack Damage", 0.0))
	if tags.has("fire"): damage *= 1.0 + float(stats.get("Fire Damage", 0.0))
	if tags.has("lightning"): damage *= 1.0 + float(stats.get("Lightning Damage", 0.0))
	if tags.has("void"): damage *= 1.0 + float(stats.get("Void Damage", 0.0))
	if tags.has("projectile"): damage *= 1.0 + float(stats.get("Projectile Damage", 0.0))
	return {
		"active_id": active_id,
		"name": str(active.get("name", active_id)),
		"tags": tags,
		"damage": damage,
		"mana_cost": mana_cost,
		"area_mult": area_mult,
		"extra_projectiles": extra_projectiles,
		"chain": chain,
		"echo_count": echo_count,
		"rules": rules
	}

static func collect_spirit_bundle(state: Object) -> Dictionary:
	if state == null: return {"stats":{}, "rules":[], "reserved":0}
	var stats: Dictionary = {}
	var rules: Array[String] = []
	var reserved: int = 0
	var spirits: Dictionary = Dictionary(state.get("spirit_gems_owned"))
	for key_value: Variant in spirits.keys():
		var id: String = str(key_value)
		if not bool(spirits[key_value]): continue
		var data: Dictionary = GemDBScript.spirit(id)
		reserved += int(data.get("reservation", 0))
		for stat_key: Variant in Dictionary(data.get("stats", {})).keys():
			var key: String = str(stat_key)
			stats[key] = float(stats.get(key, 0.0)) + float(Dictionary(data.get("stats", {}))[stat_key])
		for rule_value: Variant in Array(data.get("rules", [])):
			var rule: String = str(rule_value)
			if rule != "" and not rules.has(rule): rules.append(rule)
	return {"stats":stats, "rules":rules, "reserved":reserved}

static func add_gem_drop_to_state(state: Object, kind: String, gem_id: String) -> void:
	if state == null or gem_id == "": return
	if kind == "active_gem":
		var actives: Dictionary = Dictionary(state.get("active_gems_owned"))
		actives[gem_id] = true
		state.set("active_gems_owned", actives)
	elif kind == "support_gem":
		var supports: Dictionary = Dictionary(state.get("support_gems_owned"))
		supports[gem_id] = int(supports.get(gem_id, 0)) + 1
		state.set("support_gems_owned", supports)
	elif kind == "spirit_gem":
		var spirits: Dictionary = Dictionary(state.get("spirit_gems_owned"))
		if not spirits.has(gem_id): spirits[gem_id] = false
		state.set("spirit_gems_owned", spirits)

static func cycle_active_slot_gem(state: Object, direction: int) -> void:
	ensure_defaults(state)
	var owned: Array = Dictionary(state.get("active_gems_owned")).keys()
	if owned.is_empty(): return
	var slots: Array = Array(state.get("active_skill_slots"))
	var index: int = clampi(int(state.get("selected_skill_slot")), 0, slots.size() - 1)
	var slot: Dictionary = Dictionary(slots[index])
	var current: String = str(slot.get("active", "fireball"))
	var current_index: int = max(0, owned.find(current))
	current_index = wrapi(current_index + direction, 0, owned.size())
	slot["active"] = str(owned[current_index])
	slot["supports"] = []
	slots[index] = slot
	state.set("active_skill_slots", slots)
	state.call("add_notice", "Active: " + str(GemDBScript.active(str(owned[current_index])).get("name", owned[current_index])))

static func add_next_valid_support(state: Object) -> void:
	ensure_defaults(state)
	var slots: Array = Array(state.get("active_skill_slots"))
	var index: int = clampi(int(state.get("selected_skill_slot")), 0, slots.size() - 1)
	var slot: Dictionary = Dictionary(slots[index])
	var active_id: String = str(slot.get("active", "fireball"))
	var equipped: Array = Array(slot.get("supports", []))
	if equipped.size() >= 3:
		state.call("add_notice", "Support slots full")
		return
	var owned: Dictionary = Dictionary(state.get("support_gems_owned"))
	var keys: Array = owned.keys()
	var cursor: int = int(state.get("selected_support_cursor"))
	for step: int in range(max(1, keys.size())):
		var key: String = str(keys[wrapi(cursor + step, 0, keys.size())])
		if equipped.has(key): continue
		if GemDBScript.support_compatible(active_id, key):
			equipped.append(key)
			slot["supports"] = equipped
			slots[index] = slot
			state.set("active_skill_slots", slots)
			state.set("selected_support_cursor", wrapi(cursor + step + 1, 0, keys.size()))
			state.call("add_notice", "Added support: " + str(GemDBScript.support(key).get("name", key)))
			return
	state.call("add_notice", "No valid support found")

static func remove_last_support(state: Object) -> void:
	var slots: Array = Array(state.get("active_skill_slots"))
	if slots.is_empty(): return
	var index: int = clampi(int(state.get("selected_skill_slot")), 0, slots.size() - 1)
	var slot: Dictionary = Dictionary(slots[index])
	var supports: Array = Array(slot.get("supports", []))
	if supports.is_empty(): return
	supports.pop_back()
	slot["supports"] = supports
	slots[index] = slot
	state.set("active_skill_slots", slots)

static func toggle_next_spirit(state: Object) -> void:
	ensure_defaults(state)
	var spirits: Dictionary = Dictionary(state.get("spirit_gems_owned"))
	var keys: Array = spirits.keys()
	if keys.is_empty(): return
	var cursor: int = wrapi(int(state.get("selected_spirit_cursor")), 0, keys.size())
	var id: String = str(keys[cursor])
	spirits[id] = not bool(spirits[id])
	state.set("spirit_gems_owned", spirits)
	state.set("selected_spirit_cursor", wrapi(cursor + 1, 0, keys.size()))
	state.call("recompute_stats")
	if int(state.get("spirit_reserved")) > int(state.get("spirit_max")):
		spirits[id] = false
		state.set("spirit_gems_owned", spirits)
		state.call("recompute_stats")
		state.call("add_notice", "Not enough Spirit")
	else:
		state.call("add_notice", "Spirit: " + str(GemDBScript.spirit(id).get("name", id)))

static func panel_text(state: Object) -> String:
	ensure_defaults(state)
	var text: String = "SKILL LOADOUT\n"
	text += "1-4 Select Slot · A/D Change Active · S Add Support · W Remove Support · G Toggle Spirit\n\n"
	var slots: Array = Array(state.get("active_skill_slots"))
	var selected: int = int(state.get("selected_skill_slot"))
	for i: int in range(slots.size()):
		var slot: Dictionary = Dictionary(slots[i])
		var active_id: String = str(slot.get("active", ""))
		var marker: String = "> " if i == selected else "  "
		text += marker + str(i + 1) + ". " + str(GemDBScript.active(active_id).get("name", active_id)) + "\n"
		for sup_value: Variant in Array(slot.get("supports", [])):
			text += "     + " + str(GemDBScript.support(str(sup_value)).get("name", sup_value)) + "\n"
	var cast: Dictionary = selected_cast_data(state)
	text += "\nSelected: " + str(cast.get("name", "")) + " · Damage " + str(int(round(float(cast.get("damage", 0.0))))) + " · Mana " + str(int(round(float(cast.get("mana_cost", 0.0))))) + "\n"
	text += "Tags: " + ", ".join(PackedStringArray(_string_array(Array(cast.get("tags", []))))) + "\n\n"
	text += "SPIRIT " + str(state.get("spirit_reserved")) + "/" + str(state.get("spirit_max")) + "\n"
	var spirits: Dictionary = Dictionary(state.get("spirit_gems_owned"))
	for key_value: Variant in spirits.keys():
		var id: String = str(key_value)
		var on: String = "ON " if bool(spirits[key_value]) else "off"
		text += "  " + on + " — " + str(GemDBScript.spirit(id).get("name", id)) + "\n"
	return text

static func _string_array(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value: Variant in values:
		out.append(str(value))
	return out
