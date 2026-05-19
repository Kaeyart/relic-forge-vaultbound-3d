extends RefCounted

const GEM_ACTIVE: String = "active"
const GEM_SUPPORT: String = "support"
const GEM_SPIRIT: String = "spirit"

const STARTING_SUPPORT_SOCKETS: int = 2
const MAX_SUPPORT_SOCKETS: int = 6
const SOCKET_INTERVAL: int = 5
const MAX_ACTIVE_SLOTS: int = 4

const DEFAULT_ACTIVE_IDS: Array[String] = ["fireball", "storm_lance", "arc_slash", "void_rift"]

const ACTIVE_DATA: Dictionary = {
	"fireball": {"name": "Fireball", "color": "red", "tags": ["spell", "projectile", "fire"]},
	"storm_lance": {"name": "Storm Lance", "color": "blue", "tags": ["spell", "projectile", "lightning"]},
	"arc_slash": {"name": "Arc Slash", "color": "red", "tags": ["attack", "melee"]},
	"void_rift": {"name": "Void Rift", "color": "blue", "tags": ["spell", "area", "void"]},
	"ember_mine": {"name": "Ember Mine", "color": "red", "tags": ["spell", "mine", "fire"]},
}

const SUPPORT_DATA: Dictionary = {
	"pierce": {"name": "Pierce Support", "color": "green", "tags": ["projectile"]},
	"chain": {"name": "Chain Support", "color": "blue", "tags": ["projectile"]},
	"echo": {"name": "Echo Support", "color": "blue", "tags": ["spell"]},
	"ignite": {"name": "Ignite Support", "color": "red", "tags": ["fire"]},
	"overload": {"name": "Overload Support", "color": "red", "tags": ["damage"]},
	"swift_casting": {"name": "Swift Casting Support", "color": "green", "tags": ["cast_speed"]},
}

const SPIRIT_DATA: Dictionary = {
	"ember_aura": {"name": "Ember Aura", "color": "red", "reservation": 25, "tags": ["aura", "fire"]},
	"storm_focus": {"name": "Storm Focus", "color": "blue", "reservation": 25, "tags": ["aura", "lightning"]},
	"void_pact": {"name": "Void Pact", "color": "blue", "reservation": 30, "tags": ["aura", "void"]},
	"comet_oath": {"name": "Comet Oath", "color": "blue", "reservation": 35, "tags": ["trigger", "cold", "comet"]},
}

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return

	var slots: Array = Array(_get_state(state, "active_skill_slots", []))
	while slots.size() < MAX_ACTIVE_SLOTS:
		var default_id: String = DEFAULT_ACTIVE_IDS[slots.size() % DEFAULT_ACTIVE_IDS.size()]
		slots.append(active_instance(default_id))

	for i: int in range(slots.size()):
		if typeof(slots[i]) == TYPE_DICTIONARY:
			slots[i] = normalize_active(Dictionary(slots[i]))
		else:
			slots[i] = active_instance(DEFAULT_ACTIVE_IDS[i % DEFAULT_ACTIVE_IDS.size()])

	state.set("active_skill_slots", slots)

	var selected: int = clampi(_to_int(_get_state(state, "selected_skill_slot", 0), 0), 0, max(0, slots.size() - 1))
	state.set("selected_skill_slot", selected)

	var spirits: Array = Array(_get_state(state, "spirit_gem_slots", []))
	for j: int in range(spirits.size()):
		if typeof(spirits[j]) == TYPE_DICTIONARY:
			spirits[j] = normalize_spirit(Dictionary(spirits[j]))

	state.set("spirit_gem_slots", spirits)

	if _get_state(state, "spirit_max", null) == null:
		state.set("spirit_max", 100)

	recompute_spirit_reservation(state)

static func ensure_starter_gem_items(state: Object) -> void:
	if state == null:
		return
	if bool(_get_state(state, "gem_progression_seeded", false)):
		return

	var backpack: Array = Array(_get_state(state, "backpack", []))
	var starter_specs: Array = [
		[GEM_ACTIVE, "storm_lance"],
		[GEM_ACTIVE, "arc_slash"],
		[GEM_SUPPORT, "pierce"],
		[GEM_SUPPORT, "chain"],
		[GEM_SUPPORT, "echo"],
		[GEM_SUPPORT, "ignite"],
		[GEM_SPIRIT, "ember_aura"],
		[GEM_SPIRIT, "storm_focus"],
		[GEM_SPIRIT, "comet_oath"],
	]

	for data: Array in starter_specs:
		backpack.append(make_gem_item(str(data[0]), str(data[1])))

	state.set("backpack", backpack)
	state.set("gem_progression_seeded", true)

static func gem_type(item: Dictionary) -> String:
	var t: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower()
	if t == GEM_ACTIVE or t == GEM_SUPPORT or t == GEM_SPIRIT:
		return t

	var k: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	if k == "active_gem" or k == "active_skill_gem":
		return GEM_ACTIVE
	if k == "support_gem":
		return GEM_SUPPORT
	if k == "spirit_gem":
		return GEM_SPIRIT

	var s: String = str(item.get("slot", "")).to_lower()
	if s == "active_gem":
		return GEM_ACTIVE
	if s == "support_gem":
		return GEM_SUPPORT
	if s == "spirit_gem":
		return GEM_SPIRIT

	return ""

static func is_gem_item(item: Dictionary) -> bool:
	return gem_type(item) != ""

static func gem_id(d: Dictionary) -> String:
	for key: String in ["gem_id", "active_id", "support_id", "spirit_id", "base_id", "id"]:
		var value: String = str(d.get(key, ""))
		if value != "":
			if value.begins_with("gem_"):
				return str(d.get("base_id", value))
			return value
	return str(d.get("name", "unknown_gem")).to_lower().replace(" ", "_")

static func gem_data(type: String, id: String) -> Dictionary:
	match type:
		GEM_ACTIVE:
			return Dictionary(ACTIVE_DATA.get(id, {"name": id.capitalize(), "color": "blue", "tags": []}))
		GEM_SUPPORT:
			return Dictionary(SUPPORT_DATA.get(id, {"name": id.capitalize() + " Support", "color": "green", "tags": []}))
		GEM_SPIRIT:
			return Dictionary(SPIRIT_DATA.get(id, {"name": id.capitalize(), "color": "blue", "reservation": 25, "tags": []}))
		_:
			return {"name": id.capitalize(), "color": "blue", "tags": []}

static func active_instance(id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	return normalize_active({
		"kind": GEM_ACTIVE,
		"gem_id": id,
		"active": id,
		"active_id": id,
		"level": level,
		"xp": xp,
		"quality": quality,
		"supports": supports,
	})

static func normalize_active(slot: Dictionary) -> Dictionary:
	var id: String = str(slot.get("gem_id", slot.get("active", slot.get("active_id", "fireball"))))
	var level: int = max(1, _to_int(slot.get("level", 1), 1))
	var xp: int = max(0, _to_int(slot.get("xp", 0), 0))
	var quality: int = clampi(_to_int(slot.get("quality", 0), 0), 0, 100)
	var supports: Array = []

	for support_value: Variant in Array(slot.get("supports", [])):
		supports.append(normalize_support_value(support_value))

	return {
		"kind": GEM_ACTIVE,
		"gem_id": id,
		"active": id,
		"active_id": id,
		"level": level,
		"xp": xp,
		"quality": quality,
		"supports": supports,
		"unlocked_support_sockets": unlocked_support_sockets(level),
	}

static func normalize_support_value(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return normalize_support(Dictionary(value))
	return normalize_support({
		"gem_id": str(value),
		"support_id": str(value),
		"level": 1,
		"xp": 0,
		"quality": 0,
	})

static func normalize_support(support: Dictionary) -> Dictionary:
	var id: String = gem_id(support)
	var level: int = max(1, _to_int(support.get("level", 1), 1))
	var xp: int = max(0, _to_int(support.get("xp", 0), 0))
	var quality: int = clampi(_to_int(support.get("quality", 0), 0), 0, 100)
	return {
		"kind": GEM_SUPPORT,
		"gem_id": id,
		"support_id": id,
		"level": level,
		"xp": xp,
		"quality": quality,
	}

static func normalize_spirit(spirit: Dictionary) -> Dictionary:
	var id: String = str(spirit.get("gem_id", spirit.get("spirit_id", "ember_aura")))
	var level: int = max(1, _to_int(spirit.get("level", 1), 1))
	var xp: int = max(0, _to_int(spirit.get("xp", 0), 0))
	var quality: int = clampi(_to_int(spirit.get("quality", 0), 0), 0, 100)
	var enabled: bool = bool(spirit.get("enabled", false))
	var supports: Array = []

	for support_value: Variant in Array(spirit.get("supports", [])):
		supports.append(normalize_support_value(support_value))

	return {
		"kind": GEM_SPIRIT,
		"gem_id": id,
		"spirit_id": id,
		"enabled": enabled,
		"level": level,
		"xp": xp,
		"quality": quality,
		"supports": supports,
		"unlocked_support_sockets": unlocked_support_sockets(level),
	}

static func make_gem_item(type: String, id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	var data: Dictionary = gem_data(type, id)
	var kind: String = type + "_gem"
	var clamped_quality: int = clampi(quality, 0, 100)
	return {
		"id": "gem_" + id + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 99999),
		"base_id": id,
		"gem_id": id,
		"name": str(data.get("name", id.capitalize())),
		"display_name": str(data.get("name", id.capitalize())),
		"kind": kind,
		"item_kind": kind,
		"category": "skill_gem",
		"slot": kind,
		"rarity": "magic",
		"gem_type": type,
		"skill_gem_type": type,
		"base_color": str(data.get("color", "blue")),
		"gem_color": str(data.get("color", "blue")),
		"carved": true,
		"level": max(1, level),
		"gem_level": max(1, level),
		"xp": max(0, xp),
		"gem_xp": max(0, xp),
		"quality": clamped_quality,
		"gem_quality": clamped_quality,
		"supports": supports.duplicate(true),
		"tags": ["gem", kind, type],
		"grid_w": 1,
		"grid_h": 1,
	}

static func install_active_from_inventory(state: Object, backpack_index: int, slot_index: int) -> String:
	ensure_defaults(state)

	var backpack: Array = Array(_get_state(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No active gem selected."

	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_ACTIVE:
		return "That is not an active gem."

	var slots: Array = Array(_get_state(state, "active_skill_slots", []))
	slot_index = clampi(slot_index, 0, max(0, slots.size() - 1))

	var previous: Dictionary = {}
	if typeof(slots[slot_index]) == TYPE_DICTIONARY:
		previous = normalize_active(Dictionary(slots[slot_index]))

	var incoming: Dictionary = active_instance(
		gem_id(item),
		_to_int(item.get("level", item.get("gem_level", 1)), 1),
		_to_int(item.get("xp", item.get("gem_xp", 0)), 0),
		_to_int(item.get("quality", item.get("gem_quality", 0)), 0),
		Array(item.get("supports", []))
	)

	backpack.remove_at(backpack_index)
	if not previous.is_empty():
		backpack.append(active_to_item(previous))

	slots[slot_index] = incoming
	state.set("active_skill_slots", slots)
	state.set("backpack", backpack)
	state.set("selected_skill_slot", slot_index)
	return "Installed active gem into slot " + str(slot_index + 1) + "."

static func install_support_from_inventory_to_active(state: Object, backpack_index: int, active_index: int) -> String:
	ensure_defaults(state)

	var backpack: Array = Array(_get_state(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No support gem selected."

	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_SUPPORT:
		return "That is not a support gem."

	var slots: Array = Array(_get_state(state, "active_skill_slots", []))
	if active_index < 0 or active_index >= slots.size() or typeof(slots[active_index]) != TYPE_DICTIONARY:
		return "No active target."

	var active: Dictionary = normalize_active(Dictionary(slots[active_index]))
	var supports: Array = Array(active.get("supports", []))
	var socket_limit: int = unlocked_support_sockets(_to_int(active.get("level", 1), 1))

	if supports.size() >= socket_limit:
		return "No unlocked support socket."

	supports.append(normalize_support({
		"gem_id": gem_id(item),
		"level": _to_int(item.get("level", item.get("gem_level", 1)), 1),
		"xp": _to_int(item.get("xp", item.get("gem_xp", 0)), 0),
		"quality": _to_int(item.get("quality", item.get("gem_quality", 0)), 0),
	}))

	active["supports"] = supports
	slots[active_index] = active
	backpack.remove_at(backpack_index)

	state.set("active_skill_slots", slots)
	state.set("backpack", backpack)
	state.set("selected_skill_slot", active_index)
	return "Socketed support into " + active_display_name(active) + "."

static func install_support_from_inventory_to_spirit(state: Object, backpack_index: int, spirit_index: int) -> String:
	ensure_defaults(state)

	var backpack: Array = Array(_get_state(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No support gem selected."

	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_SUPPORT:
		return "That is not a support gem."

	var spirits: Array = Array(_get_state(state, "spirit_gem_slots", []))
	if spirit_index < 0 or spirit_index >= spirits.size() or typeof(spirits[spirit_index]) != TYPE_DICTIONARY:
		return "No spirit target."

	var spirit: Dictionary = normalize_spirit(Dictionary(spirits[spirit_index]))
	var supports: Array = Array(spirit.get("supports", []))
	var socket_limit: int = unlocked_support_sockets(_to_int(spirit.get("level", 1), 1))

	if supports.size() >= socket_limit:
		return "No unlocked support socket."

	supports.append(normalize_support({
		"gem_id": gem_id(item),
		"level": _to_int(item.get("level", item.get("gem_level", 1)), 1),
		"xp": _to_int(item.get("xp", item.get("gem_xp", 0)), 0),
		"quality": _to_int(item.get("quality", item.get("gem_quality", 0)), 0),
	}))

	spirit["supports"] = supports
	spirits[spirit_index] = spirit
	backpack.remove_at(backpack_index)

	state.set("spirit_gem_slots", spirits)
	state.set("backpack", backpack)
	recompute_spirit_reservation(state)
	return "Socketed support into " + spirit_display_name(spirit) + "."

static func install_spirit_from_inventory(state: Object, backpack_index: int) -> String:
	ensure_defaults(state)

	var backpack: Array = Array(_get_state(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No spirit gem selected."

	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_SPIRIT:
		return "That is not a spirit gem."

	var spirits: Array = Array(_get_state(state, "spirit_gem_slots", []))
	var spirit: Dictionary = normalize_spirit({
		"gem_id": gem_id(item),
		"enabled": false,
		"level": _to_int(item.get("level", item.get("gem_level", 1)), 1),
		"xp": _to_int(item.get("xp", item.get("gem_xp", 0)), 0),
		"quality": _to_int(item.get("quality", item.get("gem_quality", 0)), 0),
		"supports": Array(item.get("supports", [])),
	})

	spirits.append(spirit)
	backpack.remove_at(backpack_index)

	state.set("spirit_gem_slots", spirits)
	state.set("backpack", backpack)
	recompute_spirit_reservation(state)
	return "Installed spirit gem disabled."

static func active_to_item(active: Dictionary) -> Dictionary:
	var normalized: Dictionary = normalize_active(active)
	return make_gem_item(
		GEM_ACTIVE,
		str(normalized.get("gem_id", "fireball")),
		_to_int(normalized.get("level", 1), 1),
		_to_int(normalized.get("xp", 0), 0),
		_to_int(normalized.get("quality", 0), 0),
		Array(normalized.get("supports", []))
	)

static func support_to_item(support: Dictionary) -> Dictionary:
	var normalized: Dictionary = normalize_support(support)
	return make_gem_item(
		GEM_SUPPORT,
		str(normalized.get("gem_id", "pierce")),
		_to_int(normalized.get("level", 1), 1),
		_to_int(normalized.get("xp", 0), 0),
		_to_int(normalized.get("quality", 0), 0),
		[]
	)

static func spirit_to_item(spirit: Dictionary) -> Dictionary:
	var normalized: Dictionary = normalize_spirit(spirit)
	return make_gem_item(
		GEM_SPIRIT,
		str(normalized.get("gem_id", "ember_aura")),
		_to_int(normalized.get("level", 1), 1),
		_to_int(normalized.get("xp", 0), 0),
		_to_int(normalized.get("quality", 0), 0),
		Array(normalized.get("supports", []))
	)

static func award_selected_active_xp(state: Object, amount: int) -> void:
	ensure_defaults(state)

	var slots: Array = Array(_get_state(state, "active_skill_slots", []))
	if slots.is_empty():
		return

	var index: int = clampi(_to_int(_get_state(state, "selected_skill_slot", 0), 0), 0, slots.size() - 1)
	var active: Dictionary = normalize_active(Dictionary(slots[index]))
	var level: int = _to_int(active.get("level", 1), 1)
	var xp: int = _to_int(active.get("xp", 0), 0) + max(0, amount)
	var leveled: bool = false

	while xp >= xp_to_next(level):
		xp -= xp_to_next(level)
		level += 1
		leveled = true

	active["level"] = level
	active["xp"] = xp
	active["unlocked_support_sockets"] = unlocked_support_sockets(level)

	slots[index] = active
	state.set("active_skill_slots", slots)

	if leveled and state.has_method("add_notice"):
		state.call("add_notice", active_display_name(active) + " reached level " + str(level) + ".")

static func xp_to_next(level: int) -> int:
	return max(80, level * 100)

static func unlocked_support_sockets(level: int) -> int:
	var socket_steps: int = int(floor(float(max(1, level)) / float(SOCKET_INTERVAL)))
	return clampi(STARTING_SUPPORT_SOCKETS + socket_steps, STARTING_SUPPORT_SOCKETS, MAX_SUPPORT_SOCKETS)

static func recompute_spirit_reservation(state: Object) -> void:
	if state == null:
		return

	var total: int = 0
	var spirit_slots: Array = Array(_get_state(state, "spirit_gem_slots", []))

	for value: Variant in spirit_slots:
		if typeof(value) != TYPE_DICTIONARY:
			continue

		var spirit: Dictionary = normalize_spirit(Dictionary(value))
		if not bool(spirit.get("enabled", false)):
			continue

		var data: Dictionary = gem_data(GEM_SPIRIT, str(spirit.get("gem_id", "")))
		var base: int = _to_int(data.get("reservation", 25), 25)
		var support_count: int = Array(spirit.get("supports", [])).size()
		var quality: int = _to_int(spirit.get("quality", 0), 0)
		var support_multiplier: float = 1.0 + float(support_count) * 0.20
		var quality_multiplier: float = max(0.70, 1.0 - float(quality) * 0.005)
		var reservation: float = float(base) * support_multiplier * quality_multiplier

		total += int(ceil(reservation))

	state.set("spirit_reserved", total)

static func quality_effect_text(type: String, id: String, quality: int) -> String:
	var clamped_quality: int = clampi(quality, 0, 100)
	if clamped_quality <= 0:
		return "Quality: no bonus."

	if type == GEM_ACTIVE:
		var extra_projectiles: int = active_quality_extra_projectiles(id, clamped_quality)
		var text: String = "Quality: +" + str(clamped_quality) + "% damage"
		if extra_projectiles > 0:
			text += ", +" + str(extra_projectiles) + " projectile(s)"
		return text

	if type == GEM_SPIRIT:
		return "Quality: reservation efficiency and passive strength."

	return "Quality: support effect scaling."

static func active_quality_effects(id: String, quality: int) -> Dictionary:
	var clamped_quality: int = clampi(quality, 0, 100)
	return {
		"damage_multiplier": 1.0 + float(clamped_quality) * 0.01,
		"extra_projectiles": active_quality_extra_projectiles(id, clamped_quality),
	}

static func active_quality_extra_projectiles(id: String, quality: int) -> int:
	var tags: Array = Array(gem_data(GEM_ACTIVE, id).get("tags", []))
	if not tags.has("projectile"):
		return 0
	return int(floor(float(clampi(quality, 0, 100)) / 20.0))

static func active_display_name(active: Dictionary) -> String:
	var id: String = str(active.get("gem_id", "fireball"))
	return str(gem_data(GEM_ACTIVE, id).get("name", id.capitalize()))

static func support_display_name(support: Dictionary) -> String:
	var id: String = str(support.get("gem_id", support.get("support_id", "support")))
	return str(gem_data(GEM_SUPPORT, id).get("name", id.capitalize()))

static func spirit_display_name(spirit: Dictionary) -> String:
	var id: String = str(spirit.get("gem_id", spirit.get("spirit_id", "spirit")))
	return str(gem_data(GEM_SPIRIT, id).get("name", id.capitalize()))

static func gem_detail_text(d: Dictionary, assumed_type: String = "") -> String:
	var type: String = assumed_type if assumed_type != "" else gem_type(d)
	var id: String = gem_id(d)
	var level: int = _to_int(d.get("level", d.get("gem_level", 1)), 1)
	var xp: int = _to_int(d.get("xp", d.get("gem_xp", 0)), 0)
	var quality: int = _to_int(d.get("quality", d.get("gem_quality", 0)), 0)

	var lines: PackedStringArray = []
	lines.append(str(gem_data(type, id).get("name", id.capitalize())) + " [" + type.capitalize() + "]")
	lines.append("Level " + str(level) + " · XP " + str(xp) + "/" + str(xp_to_next(level)) + " · Quality +" + str(quality) + "%")

	if type == GEM_ACTIVE or type == GEM_SPIRIT:
		var unlocked: int = unlocked_support_sockets(level)
		lines.append("Sockets: " + str(unlocked) + "/" + str(MAX_SUPPORT_SOCKETS))
		if unlocked < MAX_SUPPORT_SOCKETS:
			var next_level: int = (int(floor(float(level) / float(SOCKET_INTERVAL))) + 1) * SOCKET_INTERVAL
			lines.append("Next socket at level " + str(next_level))

	lines.append(quality_effect_text(type, id, quality))
	return "\n".join(lines)

static func roll_gem_drop_to_backpack(state: Object, force: bool = false) -> bool:
	if state == null:
		return false
	if not force and randf() > 0.18:
		return false

	var pool: Array = [
		[GEM_ACTIVE, "void_rift"],
		[GEM_ACTIVE, "ember_mine"],
		[GEM_SUPPORT, "overload"],
		[GEM_SUPPORT, "swift_casting"],
		[GEM_SUPPORT, "pierce"],
		[GEM_SPIRIT, "void_pact"],
		[GEM_SPIRIT, "comet_oath"],
	]

	var pick: Array = Array(pool[randi() % pool.size()])
	var type: String = str(pick[0])
	var id: String = str(pick[1])
	var quality: int = 0
	if randf() < 0.20:
		quality = 5 + int(randi() % 16)

	var backpack: Array = Array(_get_state(state, "backpack", []))
	backpack.append(make_gem_item(type, id, 1, 0, quality))
	state.set("backpack", backpack)

	if state.has_method("add_notice"):
		state.call("add_notice", "Gem found: " + str(gem_data(type, id).get("name", id)))

	return true

static func _get_state(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

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
