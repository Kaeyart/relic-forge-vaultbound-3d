extends RefCounted
class_name RVGemProgressionSystem3D

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

static func ensure_progression_defaults(state: Object) -> void:
	if state == null:
		return

	SkillGemSystemScript.ensure_defaults(state)


static func ensure_starter_gem_items(state: Object) -> void:
	if state == null:
		return

	SkillGemSystemScript.ensure_defaults(state)


static func award_selected_skill_xp(state: Object, amount: int) -> void:
	if state == null:
		return

	SkillGemSystemScript.ensure_defaults(state)
