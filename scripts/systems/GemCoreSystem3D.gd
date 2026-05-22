extends RefCounted
class_name RVGemCoreSystem3D

const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

const GEM_ACTIVE: String = "active"
const GEM_SUPPORT: String = "support"
const GEM_SPIRIT: String = "spirit"
const STARTING_SUPPORT_SOCKETS: int = 2
const MAX_SUPPORT_SOCKETS: int = 6
const SOCKET_INTERVAL: int = 5
const MAX_ACTIVE_SLOTS: int = 9
const DEFAULT_ACTIVE_IDS: Array = ["fireball", "storm_lance", "arc_slash", "void_rift"]

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	if typeof(state.get("active_skill_slots")) != TYPE_ARRAY:
		state.set("active_skill_slots", [])
	var slots: Array = Array(state.get("active_skill_slots"))
	while slots.size() < 4:
		var id: String = str(DEFAULT_ACTIVE_IDS[min(slots.size(), DEFAULT_ACTIVE_IDS.size() - 1)])
		slots.append(active_instance(id, 1))
	state.set("active_skill_slots", slots)

static func ensure_starter_gem_items(state: Object) -> void:
	ensure_defaults(state)

static func gem_type(item: Dictionary) -> String:
	if item.is_empty():
		return ""
	var explicit_type: String = str(item.get("gem_type", item.get("skill_gem_type", ""))).strip_edges().to_lower()
	if explicit_type in ["active", "support", "spirit"]:
		return explicit_type
	var kind: String = str(item.get("kind", item.get("item_kind", item.get("category", "")))).strip_edges().to_lower()
	match kind:
		"active_gem", "active_skill_gem", "skill_gem":
			return GEM_ACTIVE
		"support_gem":
			return GEM_SUPPORT
		"spirit_gem":
			return GEM_SPIRIT
		_:
			return ""

static func is_gem_item(item: Dictionary) -> bool:
	return gem_type(item) != ""

static func gem_id(d: Dictionary) -> String:
	return str(d.get("gem_id", d.get("skill_id", d.get("id", "fireball"))))

static func gem_data(type: String, id: String) -> Dictionary:
	return GemDBScript.gem_data(type, id)

static func active_instance(id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	return {
		"uid": "active_" + id + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000),
		"kind": "active_gem",
		"gem_id": id,
		"level": maxi(1, level),
		"xp": maxi(0, xp),
		"quality": clampi(quality, 0, 100),
		"supports": supports.duplicate(true),
		"support_sockets": supports.duplicate(true),
	}

static func normalize_active(slot: Dictionary) -> Dictionary:
	if slot.is_empty():
		return active_instance("fireball")
	if not slot.has("gem_id"):
		slot["gem_id"] = str(slot.get("active", slot.get("active_id", "fireball")))
	if not slot.has("level"):
		slot["level"] = 1
	if not slot.has("supports"):
		slot["supports"] = Array(slot.get("support_sockets", []))
	return slot

static func normalize_support_value(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return normalize_support(Dictionary(value))
	return normalize_support({"gem_id": str(value)})

static func normalize_support(support: Dictionary) -> Dictionary:
	if not support.has("gem_id"):
		support["gem_id"] = str(support.get("support_id", "controlled_power"))
	if not support.has("level"):
		support["level"] = 1
	return support

static func normalize_spirit(spirit: Dictionary) -> Dictionary:
	if not spirit.has("gem_id"):
		spirit["gem_id"] = str(spirit.get("spirit_id", "clarity"))
	if not spirit.has("level"):
		spirit["level"] = 1
	if not spirit.has("enabled"):
		spirit["enabled"] = false
	if not spirit.has("supports"):
		spirit["supports"] = []
	return spirit

static func make_gem_item(type: String, id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	return GemDBScript.make_gem_item(type, id, level, xp, quality, supports)

static func make_gem_item_from_drop(drop_kind: String, gem_id_value: String) -> Dictionary:
	var type: String = GEM_ACTIVE
	match drop_kind:
		"support_gem":
			type = GEM_SUPPORT
		"spirit_gem":
			type = GEM_SPIRIT
		_:
			type = GEM_ACTIVE
	return make_gem_item(type, gem_id_value)

static func active_to_item(active: Dictionary) -> Dictionary:
	var normalized: Dictionary = normalize_active(active)
	return make_gem_item(GEM_ACTIVE, str(normalized.get("gem_id", "fireball")), int(normalized.get("level", 1)), int(normalized.get("xp", 0)), int(normalized.get("quality", 0)), Array(normalized.get("supports", [])))

static func support_to_item(support: Dictionary) -> Dictionary:
	var normalized: Dictionary = normalize_support(support)
	return make_gem_item(GEM_SUPPORT, str(normalized.get("gem_id", "controlled_power")), int(normalized.get("level", 1)), int(normalized.get("xp", 0)), int(normalized.get("quality", 0)))

static func spirit_to_item(spirit: Dictionary) -> Dictionary:
	var normalized: Dictionary = normalize_spirit(spirit)
	return make_gem_item(GEM_SPIRIT, str(normalized.get("gem_id", "clarity")), int(normalized.get("level", 1)), int(normalized.get("xp", 0)), int(normalized.get("quality", 0)), Array(normalized.get("supports", [])))

static func award_selected_active_xp(state: Object, amount: int) -> void:
	if state == null:
		return
	var slots: Array = Array(state.get("active_skill_slots"))
	if slots.is_empty():
		return
	var selected: int = clampi(int(state.get("selected_skill_slot")), 0, max(0, slots.size() - 1))
	var active: Dictionary = normalize_active(Dictionary(slots[selected]))
	active["xp"] = int(active.get("xp", 0)) + maxi(0, amount)
	while int(active.get("xp", 0)) >= xp_to_next(int(active.get("level", 1))):
		active["xp"] = int(active.get("xp", 0)) - xp_to_next(int(active.get("level", 1)))
		active["level"] = int(active.get("level", 1)) + 1
	slots[selected] = active
	state.set("active_skill_slots", slots)

static func xp_to_next(level: int) -> int:
	return 100 + maxi(1, level) * 50

static func unlocked_support_sockets(level: int) -> int:
	return clampi(STARTING_SUPPORT_SOCKETS + int(maxi(0, level - 1) / SOCKET_INTERVAL), STARTING_SUPPORT_SOCKETS, MAX_SUPPORT_SOCKETS)

static func recompute_spirit_reservation(state: Object) -> void:
	if state == null:
		return
	var bundle: Dictionary = collect_spirit_bundle(state)
	state.set("spirit_reserved", int(bundle.get("reserved", 0)))

static func quality_effect_text(type: String, id: String, quality: int) -> String:
	return "Quality +" + str(clampi(quality, 0, 100)) + "%: improves damage/effect scaling."

static func active_quality_effects(id: String, quality: int) -> Dictionary:
	return {"damage_multiplier": 1.0 + float(clampi(quality, 0, 100)) * 0.01, "extra_projectiles": 0}

static func active_quality_extra_projectiles(id: String, quality: int) -> int:
	return 0

static func active_display_name(active: Dictionary) -> String:
	var normalized: Dictionary = normalize_active(active)
	return str(GemDBScript.active_data(str(normalized.get("gem_id", "fireball"))).get("name", "Active Gem"))

static func support_display_name(support: Dictionary) -> String:
	var normalized: Dictionary = normalize_support(support)
	return str(GemDBScript.support_data(str(normalized.get("gem_id", "controlled_power"))).get("name", "Support Gem"))

static func spirit_display_name(spirit: Dictionary) -> String:
	var normalized: Dictionary = normalize_spirit(spirit)
	return str(GemDBScript.spirit_data(str(normalized.get("gem_id", "clarity"))).get("name", "Spirit Gem"))

static func gem_detail_text(d: Dictionary, assumed_type: String = "") -> String:
	var type: String = assumed_type if assumed_type != "" else gem_type(d)
	var id: String = gem_id(d)
	var data: Dictionary = GemDBScript.gem_data(type, id)
	return "[b]" + str(data.get("name", id.capitalize())) + "[/b]\n" + ", ".join(Array(data.get("tags", [])))

static func roll_gem_drop_to_backpack(state: Object, force: bool = false) -> bool:
	if state == null:
		return false
	var item: Dictionary = make_gem_item(GEM_SUPPORT, "controlled_power", 1)
	state.call("add_backpack_item", item)
	return true

static func install_active_from_inventory(state: Object, backpack_index: int, slot_index: int) -> String:
	if state == null:
		return "No state"
	var backpack: Array = Array(state.get("backpack"))
	if backpack_index < 0 or backpack_index >= backpack.size():
		return "No gem selected"
	var item: Dictionary = Dictionary(backpack[backpack_index])
	ensure_defaults(state)
	var slots: Array = Array(state.get("active_skill_slots"))
	var target: int = clampi(slot_index, 0, max(0, slots.size() - 1))
	slots[target] = active_instance(gem_id(item), int(item.get("level", 1)))
	backpack.remove_at(backpack_index)
	state.set("backpack", backpack)
	state.set("active_skill_slots", slots)
	return "Installed active gem."

static func install_support_from_inventory_to_active(state: Object, backpack_index: int, active_index: int) -> String:
	return "Use the Skill Gem screen to socket supports."

static func install_support_from_inventory_to_spirit(state: Object, backpack_index: int, spirit_index: int) -> String:
	return "Use the Skill Gem screen to socket supports."

static func install_spirit_from_inventory(state: Object, backpack_index: int) -> String:
	if state == null:
		return "No state"
	var backpack: Array = Array(state.get("backpack"))
	if backpack_index < 0 or backpack_index >= backpack.size():
		return "No spirit gem selected"
	var item: Dictionary = Dictionary(backpack[backpack_index])
	var spirits: Array = Array(state.get("spirit_gem_slots"))
	spirits.append(normalize_spirit({"gem_id": gem_id(item), "level": int(item.get("level", 1)), "enabled": false, "supports": []}))
	backpack.remove_at(backpack_index)
	state.set("backpack", backpack)
	state.set("spirit_gem_slots", spirits)
	recompute_spirit_reservation(state)
	return "Installed spirit gem."

static func collect_spirit_bundle(state: Object) -> Dictionary:
	var bundle: Dictionary = {"reserved": 0, "stats": {}, "rules": []}
	if state == null:
		return bundle
	var spirits: Array = Array(state.get("spirit_gem_slots"))
	for value: Variant in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = normalize_spirit(Dictionary(value))
		if not bool(spirit.get("enabled", false)):
			continue
		var data: Dictionary = GemDBScript.spirit_data(str(spirit.get("gem_id", "clarity")))
		var reservation: int = int(data.get("reservation", 25))
		bundle["reserved"] = int(bundle.get("reserved", 0)) + reservation
		var stats: Dictionary = Dictionary(data.get("stats", {}))
		for key: Variant in stats.keys():
			var stat_key: String = str(key)
			Dictionary(bundle["stats"])[stat_key] = float(Dictionary(bundle["stats"]).get(stat_key, 0.0)) + float(stats[key])
		Array(bundle["rules"]).append("spirit:" + str(spirit.get("gem_id", "")))
	return bundle
