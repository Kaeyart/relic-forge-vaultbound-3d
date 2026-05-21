extends RefCounted

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

static func active_ids() -> Array:
	return SkillGemSystemScript.ACTIVE_ORDER.duplicate()

static func support_ids() -> Array:
	return SkillGemSystemScript.SUPPORT_ORDER.duplicate()

static func spirit_ids() -> Array:
	return SkillGemSystemScript.SPIRIT_ORDER.duplicate()

static func active_data(id: String) -> Dictionary:
	return SkillGemSystemScript.active_data(id)

static func support_data(id: String) -> Dictionary:
	return SkillGemSystemScript.support_data(id)

static func spirit_data(id: String) -> Dictionary:
	return SkillGemSystemScript.spirit_data(id)

static func gem_data(type: String, id: String) -> Dictionary:
	return SkillGemSystemScript.gem_data(type, id)

static func make_gem_item(type: String, id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	return SkillGemSystemScript.make_gem_item(type, id, level, xp, quality, supports)
