extends RefCounted

const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

const MAX_ACTIVE_SLOTS: int = 4
const MAX_SUPPORT_SOCKETS: int = 6
const STARTING_SUPPORT_SOCKETS: int = 2
const SOCKET_LEVEL_INTERVAL: int = 5

static func is_gem_item(item: Dictionary) -> bool:
	return gem_type(item) != ""

static func gem_type(item: Dictionary) -> String:
	if item.is_empty():
		return ""

	var explicit_type: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).strip_edges().to_lower()
	if explicit_type == "active" or explicit_type == "support" or explicit_type == "spirit":
		return explicit_type

	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).strip_edges().to_lower()
	match kind:
		"active_gem", "active_skill_gem", "skill_active", "skill_gem_active":
			return "active"
		"support_gem", "skill_support", "skill_gem_support":
			return "support"
		"spirit_gem", "reservation_gem", "skill_spirit", "skill_gem_spirit":
			return "spirit"

	var slot: String = str(item.get("slot", "")).strip_edges().to_lower()
	match slot:
		"active_gem":
			return "active"
		"support_gem":
			return "support"
		"spirit_gem":
			return "spirit"

	var tags: Array = Array(item.get("tags", []))
	var lowered: Array[String] = []
	for tag_value: Variant in tags:
		lowered.append(str(tag_value).strip_edges().to_lower())
	if lowered.has("active_gem") or (lowered.has("gem") and lowered.has("active")):
		return "active"
	if lowered.has("support_gem") or (lowered.has("gem") and lowered.has("support")):
		return "support"
	if lowered.has("spirit_gem") or (lowered.has("gem") and lowered.has("spirit")):
		return "spirit"

	return ""

static func gem_id(item: Dictionary) -> String:
	var candidates: Array[String] = [
		"gem_id",
		"skill_id",
		"active_id",
		"support_id",
		"spirit_id",
		"base_gem_id",
		"base_id",
		"id"
	]
	for key: String in candidates:
		var value: String = str(item.get(key, "")).strip_edges()
		if value != "":
			return value
	return str(item.get("name", "unknown_gem")).strip_edges().to_lower().replace(" ", "_")

static func install_gem_from_backpack(state: Object, backpack_index: int) -> String:
	if state == null:
		return "No state"

	var backpack: Array = Array(_state_get(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No gem selected"

	var item: Dictionary = Dictionary(backpack[backpack_index])
	var kind: String = gem_type(item)
	match kind:
		"active":
			return _install_active_from_backpack(state, backpack_index, item)
		"support":
			return _install_support_from_backpack(state, backpack_index, item)
		"spirit":
			return _install_spirit_from_backpack(state, backpack_index, item)
		_:
			return "Not a gem item"

static func gem_inventory_text(item: Dictionary) -> String:
	var kind: String = gem_type(item)
	if kind == "":
		return ""

	var id: String = gem_id(item)
	var level: int = max(1, _safe_int(item.get("level", item.get("gem_level", 1)), 1))
	var xp: int = max(0, _safe_int(item.get("xp", item.get("gem_xp", 0)), 0))
	var quality: int = clampi(_safe_int(item.get("quality", item.get("gem_quality", 0)), 0), 0, 100)
	var label: String = "Gem"
	match kind:
		"active":
			label = "Active Skill Gem"
		"support":
			label = "Support Gem"
		"spirit":
			label = "Spirit Gem"
	return "[b]" + label + "[/b]\nGem: " + id + "\nLevel " + str(level) + " · XP " + str(xp) + " · Quality +" + str(quality) + "%\nRight-click/double-click to install."

static func _install_active_from_backpack(state: Object, backpack_index: int, item: Dictionary) -> String:
	var backpack: Array = Array(_state_get(state, "backpack", []))
	var active_slots: Array = Array(_state_get(state, "active_skill_slots", []))
	_ensure_active_slots(active_slots)

	var selected: int = clampi(_safe_int(_state_get(state, "selected_skill_slot", 0), 0), 0, max(0, active_slots.size() - 1))
	var incoming: Dictionary = _active_instance_from_item(item)
	var previous: Dictionary = Dictionary(active_slots[selected]) if typeof(active_slots[selected]) == TYPE_DICTIONARY else {}

	var stash: Dictionary = _gem_stash(state)
	var active_stash: Array = Array(stash.get("active", []))
	if not previous.is_empty():
		active_stash.append(previous)

	active_slots[selected] = incoming
	backpack.remove_at(backpack_index)
	stash["active"] = active_stash

	state.set("active_skill_slots", active_slots)
	state.set("gem_stash", stash)
	state.set("backpack", backpack)
	state.set("selected_skill_slot", selected)
	state.set("inventory_cursor", clampi(backpack_index, 0, max(0, backpack.size() - 1)))

	return "Installed active gem into slot " + str(selected + 1)

static func _install_support_from_backpack(state: Object, backpack_index: int, item: Dictionary) -> String:
	var backpack: Array = Array(_state_get(state, "backpack", []))
	var support: Dictionary = _support_instance_from_item(item)
	var support_id: String = str(support.get("gem_id", ""))

	var active_slots: Array = Array(_state_get(state, "active_skill_slots", []))
	_ensure_active_slots(active_slots)
	var selected: int = clampi(_safe_int(_state_get(state, "selected_skill_slot", 0), 0), 0, max(0, active_slots.size() - 1))
	var slot: Dictionary = Dictionary(active_slots[selected]) if typeof(active_slots[selected]) == TYPE_DICTIONARY else {}
	var active_id: String = str(slot.get("gem_id", slot.get("active", slot.get("active_id", ""))))
	var supports: Array = Array(slot.get("supports", []))

	backpack.remove_at(backpack_index)
	state.set("backpack", backpack)
	state.set("inventory_cursor", clampi(backpack_index, 0, max(0, backpack.size() - 1)))

	if active_id != "" and GemDBScript.support_compatible(active_id, support_id) and supports.size() < _unlocked_sockets(slot):
		supports.append(support)
		slot["supports"] = supports
		active_slots[selected] = slot
		state.set("active_skill_slots", active_slots)
		return "Socketed support into selected skill"

	var stash: Dictionary = _gem_stash(state)
	var support_stash: Array = Array(stash.get("support", []))
	support_stash.append(support)
	stash["support"] = support_stash
	state.set("gem_stash", stash)

	if active_id == "":
		return "Moved support gem to stash"
	if not GemDBScript.support_compatible(active_id, support_id):
		return "Support incompatible; moved to stash"
	return "No unlocked socket; moved support to stash"

static func _install_spirit_from_backpack(state: Object, backpack_index: int, item: Dictionary) -> String:
	var backpack: Array = Array(_state_get(state, "backpack", []))
	var spirit_slots: Array = Array(_state_get(state, "spirit_gem_slots", []))
	var spirit: Dictionary = _spirit_instance_from_item(item)
	spirit["enabled"] = false
	spirit_slots.append(spirit)

	backpack.remove_at(backpack_index)
	state.set("backpack", backpack)
	state.set("inventory_cursor", clampi(backpack_index, 0, max(0, backpack.size() - 1)))
	state.set("spirit_gem_slots", spirit_slots)
	_recompute_spirit_reservation(state)

	return "Installed spirit gem disabled"

static func _active_instance_from_item(item: Dictionary) -> Dictionary:
	var id: String = gem_id(item)
	return {
		"kind": "active",
		"gem_id": id,
		"active": id,
		"active_id": id,
		"level": max(1, _safe_int(item.get("level", item.get("gem_level", 1)), 1)),
		"xp": max(0, _safe_int(item.get("xp", item.get("gem_xp", 0)), 0)),
		"quality": clampi(_safe_int(item.get("quality", item.get("gem_quality", 0)), 0), 0, 100),
		"supports": Array(item.get("supports", []))
	}

static func _support_instance_from_item(item: Dictionary) -> Dictionary:
	return {
		"kind": "support",
		"gem_id": gem_id(item),
		"level": max(1, _safe_int(item.get("level", item.get("gem_level", 1)), 1)),
		"xp": max(0, _safe_int(item.get("xp", item.get("gem_xp", 0)), 0)),
		"quality": clampi(_safe_int(item.get("quality", item.get("gem_quality", 0)), 0), 0, 100)
	}

static func _spirit_instance_from_item(item: Dictionary) -> Dictionary:
	return {
		"kind": "spirit",
		"gem_id": gem_id(item),
		"enabled": false,
		"level": max(1, _safe_int(item.get("level", item.get("gem_level", 1)), 1)),
		"xp": max(0, _safe_int(item.get("xp", item.get("gem_xp", 0)), 0)),
		"quality": clampi(_safe_int(item.get("quality", item.get("gem_quality", 0)), 0), 0, 100),
		"supports": Array(item.get("supports", []))
	}

static func _ensure_active_slots(active_slots: Array) -> void:
	var defaults: Array[String] = ["fireball", "storm_lance", "arc_slash", "void_rift"]
	while active_slots.size() < MAX_ACTIVE_SLOTS:
		var id: String = defaults[active_slots.size() % defaults.size()]
		active_slots.append({
			"kind": "active",
			"gem_id": id,
			"active": id,
			"active_id": id,
			"level": 1,
			"xp": 0,
			"quality": 0,
			"supports": []
		})

static func _unlocked_sockets(active_instance: Dictionary) -> int:
	var level: int = max(1, _safe_int(active_instance.get("level", 1), 1))
	return clampi(STARTING_SUPPORT_SOCKETS + int(floor(float(level) / float(SOCKET_LEVEL_INTERVAL))), STARTING_SUPPORT_SOCKETS, MAX_SUPPORT_SOCKETS)

static func _gem_stash(state: Object) -> Dictionary:
	var stash_value: Variant = _state_get(state, "gem_stash", {})
	var stash: Dictionary = Dictionary(stash_value) if typeof(stash_value) == TYPE_DICTIONARY else {}
	if not stash.has("active"):
		stash["active"] = []
	if not stash.has("support"):
		stash["support"] = []
	if not stash.has("spirit"):
		stash["spirit"] = []
	return stash

static func _recompute_spirit_reservation(state: Object) -> void:
	var spirits: Array = Array(_state_get(state, "spirit_gem_slots", []))
	var total: int = 0
	for value: Variant in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = Dictionary(value)
		if bool(spirit.get("enabled", false)):
			var data: Dictionary = GemDBScript.spirit(str(spirit.get("gem_id", "")))
			var base: int = _safe_int(data.get("reservation", data.get("spirit_reservation", 25)), 25)
			var supports: Array = Array(spirit.get("supports", []))
			total += int(round(float(base) * (1.0 + float(supports.size()) * 0.20)))
	state.set("spirit_reserved", total)

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			return s.to_int() if s.is_valid_int() else fallback
		_:
			return fallback
