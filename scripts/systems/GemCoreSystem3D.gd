extends RefCounted

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

const GEM_ACTIVE: String = "active"
const GEM_SUPPORT: String = "support"
const GEM_SPIRIT: String = "spirit"
const STARTING_SUPPORT_SOCKETS: int = 2
const MAX_SUPPORT_SOCKETS: int = 5
const SOCKET_INTERVAL: int = 4
const MAX_ACTIVE_SLOTS: int = 4
const DEFAULT_ACTIVE_IDS: Array = ["fireball", "storm_lance", "arc_slash", "void_rift"]
const ACTIVE_DATA: Dictionary = {}
const SUPPORT_DATA: Dictionary = {}
const SPIRIT_DATA: Dictionary = {}

static func ensure_defaults(state: Object) -> void:
	SkillGemSystemScript.ensure_defaults(state)

static func ensure_starter_gem_items(state: Object) -> void:
	SkillGemSystemScript.ensure_starter_gem_items(state)

static func gem_type(item: Dictionary) -> String:
	return SkillGemSystemScript.gem_type(item)

static func is_gem_item(item: Dictionary) -> bool:
	return gem_type(item) != ""

static func gem_id(d: Dictionary) -> String:
	return SkillGemSystemScript.gem_id(d)

static func gem_data(type: String, id: String) -> Dictionary:
	return SkillGemSystemScript.gem_data(type, id)

static func active_instance(id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	return SkillGemSystemScript.active_instance(id, level, xp, quality, supports)

static func normalize_active(slot: Dictionary) -> Dictionary:
	return SkillGemSystemScript.normalize_active(slot)

static func normalize_support_value(value: Variant) -> Dictionary:
	return SkillGemSystemScript.normalize_support_value(value)

static func normalize_support(support: Dictionary) -> Dictionary:
	return SkillGemSystemScript.normalize_support(support)

static func normalize_spirit(spirit: Dictionary) -> Dictionary:
	return SkillGemSystemScript.normalize_spirit(spirit)

static func make_gem_item(type: String, id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	return SkillGemSystemScript.make_gem_item(type, id, level, xp, quality, supports)

static func make_gem_item_from_drop(drop_kind: String, gem_id: String) -> Dictionary:
	return SkillGemSystemScript.make_gem_item_from_drop(drop_kind, gem_id)

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
	SkillGemSystemScript.award_selected_active_xp(state, amount)

static func xp_to_next(level: int) -> int:
	return SkillGemSystemScript.xp_to_next(level)

static func unlocked_support_sockets(level: int) -> int:
	return SkillGemSystemScript.unlocked_support_sockets(level)

static func recompute_spirit_reservation(state: Object) -> void:
	SkillGemSystemScript.recompute_spirit_reservation(state)

static func quality_effect_text(type: String, id: String, quality: int) -> String:
	return "Quality +" + str(clampi(quality, 0, 100)) + "%: improves damage/effect scaling."

static func active_quality_effects(id: String, quality: int) -> Dictionary:
	return {"damage_multiplier": 1.0 + float(clampi(quality, 0, 100)) * 0.01, "extra_projectiles": 0}

static func active_quality_extra_projectiles(id: String, quality: int) -> int:
	return 0

static func active_display_name(active: Dictionary) -> String:
	return SkillGemSystemScript.active_display_name(active)

static func support_display_name(support: Dictionary) -> String:
	return SkillGemSystemScript.support_display_name(support)

static func spirit_display_name(spirit: Dictionary) -> String:
	return SkillGemSystemScript.spirit_display_name(spirit)

static func gem_detail_text(d: Dictionary, assumed_type: String = "") -> String:
	return SkillGemSystemScript.gem_detail_text(d, assumed_type)

static func roll_gem_drop_to_backpack(state: Object, force: bool = false) -> bool:
	return SkillGemSystemScript.roll_gem_drop_to_backpack(state, force)

static func install_active_from_inventory(state: Object, backpack_index: int, slot_index: int) -> String:
	return SkillGemSystemScript.install_active_from_inventory(state, backpack_index, slot_index)

static func install_support_from_inventory_to_active(state: Object, backpack_index: int, active_index: int) -> String:
	return SkillGemSystemScript.install_support_from_inventory_to_active(state, backpack_index, active_index)

static func install_support_from_inventory_to_spirit(state: Object, backpack_index: int, spirit_index: int) -> String:
	return SkillGemSystemScript.install_support_from_inventory_to_spirit(state, backpack_index, spirit_index)

static func install_spirit_from_inventory(state: Object, backpack_index: int) -> String:
	return SkillGemSystemScript.install_spirit_from_inventory(state, backpack_index)

static func collect_spirit_bundle(state: Object) -> Dictionary:
	return SkillGemSystemScript.collect_spirit_bundle(state)
