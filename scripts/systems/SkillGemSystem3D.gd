class_name RVSkillGemSystem3D
extends RefCounted

const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

static func ensure_loadout_defaults(state: Object) -> void:
	if state == null:
		return
	var loadout: Array = Array(state.get("skill_loadout"))
	while loadout.size() < 4:
		var active_uid: String = ""
		var active_inventory: Array = Array(state.get("active_gem_inventory"))
		if loadout.size() < active_inventory.size():
			active_uid = str(Dictionary(active_inventory[loadout.size()]).get("uid", ""))
		loadout.append({"active_uid": active_uid, "support_uids": []})
	state.set("skill_loadout", loadout)
	state.set("selected_skill_slot", clampi(int(state.get("selected_skill_slot")), 0, loadout.size() - 1))
	state.set("skill_panel_selected_slot", clampi(int(state.get("skill_panel_selected_slot")), 0, loadout.size() - 1))
	_recompute_spirit_reserved(state)

static func active_gem_for_slot(state: Object, slot_index: int) -> Dictionary:
	var loadout: Array = Array(state.get("skill_loadout"))
	if slot_index < 0 or slot_index >= loadout.size():
		return {}
	var uid: String = str(Dictionary(loadout[slot_index]).get("active_uid", ""))
	return _find_by_uid(Array(state.get("active_gem_inventory")), uid)

static func support_gems_for_slot(state: Object, slot_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var loadout: Array = Array(state.get("skill_loadout"))
	if slot_index < 0 or slot_index >= loadout.size():
		return result
	var support_uids: Array = Array(Dictionary(loadout[slot_index]).get("support_uids", []))
	var inventory: Array = Array(state.get("support_gem_inventory"))
	for uid_value: Variant in support_uids:
		var gem: Dictionary = _find_by_uid(inventory, str(uid_value))
		if not gem.is_empty():
			result.append(gem)
	return result

static func set_active_for_slot(state: Object, slot_index: int, active_uid: String) -> bool:
	ensure_loadout_defaults(state)
	var loadout: Array = Array(state.get("skill_loadout"))
	if slot_index < 0 or slot_index >= loadout.size():
		return false
	var gem: Dictionary = _find_by_uid(Array(state.get("active_gem_inventory")), active_uid)
	if gem.is_empty():
		_notice(state, "Missing active gem")
		return false
	var entry: Dictionary = Dictionary(loadout[slot_index]).duplicate(true)
	entry["active_uid"] = active_uid
	entry["support_uids"] = _filter_valid_supports_for_active(state, str(gem.get("gem_id", "")), Array(entry.get("support_uids", [])))
	loadout[slot_index] = entry
	state.set("skill_loadout", loadout)
	_notice(state, "Slot " + str(slot_index + 1) + ": " + str(gem.get("name", "Skill")))
	return true

static func toggle_support_for_slot(state: Object, slot_index: int, support_uid: String) -> bool:
	ensure_loadout_defaults(state)
	var loadout: Array = Array(state.get("skill_loadout"))
	if slot_index < 0 or slot_index >= loadout.size():
		return false
	var active: Dictionary = active_gem_for_slot(state, slot_index)
	if active.is_empty():
		_notice(state, "Choose an active gem first")
		return false
	var support: Dictionary = _find_by_uid(Array(state.get("support_gem_inventory")), support_uid)
	if support.is_empty():
		return false
	if not GemDBScript.can_support(str(active.get("gem_id", "")), str(support.get("gem_id", ""))):
		_notice(state, "Support tags do not match")
		return false
	var entry: Dictionary = Dictionary(loadout[slot_index]).duplicate(true)
	var supports: Array = Array(entry.get("support_uids", []))
	if supports.has(support_uid):
		supports.erase(support_uid)
		_notice(state, "Removed " + str(support.get("name", "Support")))
	else:
		if supports.size() >= 3:
			_notice(state, "Support slots full")
			return false
		supports.append(support_uid)
		_notice(state, "Added " + str(support.get("name", "Support")))
	entry["support_uids"] = supports
	loadout[slot_index] = entry
	state.set("skill_loadout", loadout)
	return true

static func toggle_spirit_gem(state: Object, spirit_uid: String) -> bool:
	var spirits: Array = Array(state.get("spirit_gem_inventory"))
	for i: int in range(spirits.size()):
		var gem: Dictionary = Dictionary(spirits[i]).duplicate(true)
		if str(gem.get("uid", "")) != spirit_uid:
			continue
		var enabled_now: bool = not bool(gem.get("enabled", false))
		gem["enabled"] = enabled_now
		spirits[i] = gem
		state.set("spirit_gem_inventory", spirits)
		_recompute_spirit_reserved(state)
		if int(state.get("spirit_reserved")) > int(state.get("spirit_max")):
			gem["enabled"] = false
			spirits[i] = gem
			state.set("spirit_gem_inventory", spirits)
			_recompute_spirit_reserved(state)
			_notice(state, "Not enough Spirit")
			return false
		if state.has_method("recompute_stats"):
			state.call("recompute_stats")
		_notice(state, ("Enabled " if enabled_now else "Disabled ") + str(gem.get("name", "Spirit")))
		return true
	return false

static func apply_spirit_effects_to_state(state: Object) -> void:
	_recompute_spirit_reserved(state)
	var build_stats: Dictionary = Dictionary(state.get("build_stats"))
	var build_rules: Array = Array(state.get("build_rules"))
	for gem_value: Variant in Array(state.get("spirit_gem_inventory")):
		if typeof(gem_value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(gem_value)
		if not bool(gem.get("enabled", false)):
			continue
		var data: Dictionary = GemDBScript.spirit_data(str(gem.get("gem_id", "")))
		var level_mult: float = 1.0 + float(int(gem.get("level", 1)) - 1) * 0.08
		for key: Variant in Dictionary(data.get("stats", {})).keys():
			build_stats[str(key)] = float(build_stats.get(str(key), 0.0)) + float(data["stats"][key]) * level_mult
		for rule_value: Variant in Array(data.get("rules", [])):
			var rule: String = str(rule_value)
			if rule != "" and not build_rules.has(rule):
				build_rules.append(rule)
	state.set("build_stats", build_stats)
	state.set("build_rules", build_rules)

static func build_cast_data(state: Object, slot_index: int) -> Dictionary:
	ensure_loadout_defaults(state)
	var active: Dictionary = active_gem_for_slot(state, slot_index)
	if active.is_empty():
		return {}
	var active_id: String = str(active.get("gem_id", ""))
	var base: Dictionary = GemDBScript.active_data(active_id)
	var tags: Array = Array(base.get("tags", [])).duplicate(true)
	var damage: float = float(base.get("base_damage", 10.0)) * (1.0 + float(int(active.get("level", 1)) - 1) * 0.10)
	var mana_cost: float = float(base.get("mana_cost", 0.0))
	var cooldown: float = float(base.get("cooldown", 0.2))
	var area_mult: float = 1.0
	var extra_projectiles: int = 0
	var chain_count: int = 0
	var echo_count: int = 0
	var ignite_chance: float = 0.0
	var shock_chance: float = 0.0
	var bleed_chance: float = 0.0
	for support: Dictionary in support_gems_for_slot(state, slot_index):
		var sdata: Dictionary = GemDBScript.support_data(str(support.get("gem_id", "")))
		var level_bonus: float = 1.0 + float(int(support.get("level", 1)) - 1) * 0.05
		damage *= 1.0 + float(sdata.get("damage_more", 0.0)) * level_bonus
		mana_cost *= 1.0 + float(sdata.get("cost_more", 0.0))
		area_mult *= 1.0 + float(sdata.get("area_more", 0.0))
		extra_projectiles += int(sdata.get("extra_projectiles", 0))
		chain_count += int(sdata.get("chain_count", 0))
		echo_count += int(sdata.get("echo_count", 0))
		ignite_chance += float(sdata.get("ignite_chance", 0.0))
		shock_chance += float(sdata.get("shock_chance", 0.0))
		bleed_chance += float(sdata.get("bleed_chance", 0.0))
	var stats: Dictionary = Dictionary(state.get("build_stats"))
	if tags.has("spell"):
		damage *= 1.0 + float(stats.get("spell_damage", 0.0))
	if tags.has("attack"):
		damage *= 1.0 + float(stats.get("attack_damage", 0.0))
	if tags.has("fire"):
		damage *= 1.0 + float(stats.get("fire_damage", 0.0))
	if tags.has("lightning"):
		damage *= 1.0 + float(stats.get("lightning_damage", 0.0))
	if tags.has("void"):
		damage *= 1.0 + float(stats.get("void_damage", 0.0))
	if tags.has("projectile"):
		damage *= 1.0 + float(stats.get("projectile_damage", 0.0))
	if Array(state.get("build_rules")).has("spirit_fire_ignite") and tags.has("fire"):
		ignite_chance += 0.15
	if Array(state.get("build_rules")).has("spirit_lightning_shock") and tags.has("lightning"):
		shock_chance += 0.15
	return {
		"active_id": active_id,
		"name": str(base.get("name", active_id)),
		"tags": tags,
		"damage": max(1.0, damage),
		"mana_cost": max(0.0, mana_cost),
		"cooldown": max(0.05, cooldown),
		"area_mult": max(0.25, area_mult),
		"extra_projectiles": extra_projectiles,
		"chain_count": chain_count,
		"echo_count": echo_count,
		"ignite_chance": ignite_chance,
		"shock_chance": shock_chance,
		"bleed_chance": bleed_chance,
	}

static func pay_cost(state: Object, cast_data: Dictionary) -> bool:
	var cost: float = float(cast_data.get("mana_cost", 0.0))
	if float(state.get("player_mana")) < cost:
		_notice(state, "Not enough mana")
		return false
	state.set("player_mana", float(state.get("player_mana")) - cost)
	return true

static func award_equipped_gem_xp(state: Object, amount: float) -> void:
	var active_inventory: Array = Array(state.get("active_gem_inventory"))
	var support_inventory: Array = Array(state.get("support_gem_inventory"))
	var active_uids: Array = []
	var support_uids: Array = []
	for entry_value: Variant in Array(state.get("skill_loadout")):
		var entry: Dictionary = Dictionary(entry_value)
		var auid: String = str(entry.get("active_uid", ""))
		if auid != "" and not active_uids.has(auid):
			active_uids.append(auid)
		for suid_value: Variant in Array(entry.get("support_uids", [])):
			var suid: String = str(suid_value)
			if suid != "" and not support_uids.has(suid):
				support_uids.append(suid)
		
	_level_gems_by_uid(active_inventory, active_uids, amount)
	_level_gems_by_uid(support_inventory, support_uids, amount * 0.85)
	var spirits: Array = Array(state.get("spirit_gem_inventory"))
	var spirit_uids: Array = []
	for spirit: Variant in spirits:
		if typeof(spirit) == TYPE_DICTIONARY and bool(Dictionary(spirit).get("enabled", false)):
			spirit_uids.append(str(Dictionary(spirit).get("uid", "")))
	_level_gems_by_uid(spirits, spirit_uids, amount * 0.65)
	state.set("active_gem_inventory", active_inventory)
	state.set("support_gem_inventory", support_inventory)
	state.set("spirit_gem_inventory", spirits)

static func _level_gems_by_uid(inventory: Array, uids: Array, amount: float) -> void:
	for i: int in range(inventory.size()):
		var gem: Dictionary = Dictionary(inventory[i]).duplicate(true)
		if not uids.has(str(gem.get("uid", ""))):
			continue
		gem["xp"] = float(gem.get("xp", 0.0)) + amount
		var need: float = 90.0 + float(int(gem.get("level", 1))) * 70.0
		while float(gem.get("xp", 0.0)) >= need:
			gem["xp"] = float(gem.get("xp", 0.0)) - need
			gem["level"] = int(gem.get("level", 1)) + 1
			need = 90.0 + float(int(gem.get("level", 1))) * 70.0
		inventory[i] = gem

static func skill_summary_text(state: Object) -> String:
	ensure_loadout_defaults(state)
	var text: String = "Skill Loadout\n"
	text += "Spirit: " + str(int(state.get("spirit_reserved"))) + " / " + str(int(state.get("spirit_max"))) + " reserved\n\n"
	for i: int in range(Array(state.get("skill_loadout")).size()):
		var marker: String = "> " if i == int(state.get("selected_skill_slot")) else "  "
		var active: Dictionary = active_gem_for_slot(state, i)
		text += marker + str(i + 1) + ". " + str(active.get("name", "Empty"))
		var supports: Array[Dictionary] = support_gems_for_slot(state, i)
		if not supports.is_empty():
			var names: Array[String] = []
			for support: Dictionary in supports:
				names.append(str(support.get("name", "Support")))
			text += " [" + ", ".join(PackedStringArray(names)) + "]"
		text += "\n"
	return text

static func _filter_valid_supports_for_active(state: Object, active_id: String, support_uids: Array) -> Array:
	var out: Array = []
	var inventory: Array = Array(state.get("support_gem_inventory"))
	for uid_value: Variant in support_uids:
		var support: Dictionary = _find_by_uid(inventory, str(uid_value))
		if not support.is_empty() and GemDBScript.can_support(active_id, str(support.get("gem_id", ""))):
			out.append(str(uid_value))
	return out

static func _recompute_spirit_reserved(state: Object) -> void:
	var reserved: int = 0
	for gem_value: Variant in Array(state.get("spirit_gem_inventory")):
		if typeof(gem_value) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(gem_value)
		if bool(gem.get("enabled", false)):
			reserved += int(gem.get("reservation", GemDBScript.spirit_data(str(gem.get("gem_id", ""))).get("reservation", 0)))
	state.set("spirit_reserved", reserved)

static func _find_by_uid(inventory: Array, uid: String) -> Dictionary:
	if uid == "":
		return {}
	for item_value: Variant in inventory:
		if typeof(item_value) == TYPE_DICTIONARY and str(Dictionary(item_value).get("uid", "")) == uid:
			return Dictionary(item_value)
	return {}

static func _notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)
