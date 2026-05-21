class_name RVGemProgressionSystem3D
extends RefCounted

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

static func ensure_progression_defaults(state: Object) -> void:
	if state == null:
		return
	SkillGemSystemScript.ensure_defaults(state)

static func ensure_starter_gem_items(state: Object) -> void:
	if state == null:
		return
	SkillGemSystemScript.ensure_starter_gem_items(state)

static func award_selected_skill_xp(state: Object, amount: int) -> void:
	if state == null:
		return
	SkillGemSystemScript.award_selected_active_xp(state, amount)

static func award_selected_active_xp(state: Object, amount: int) -> void:
	if state == null:
		return
	SkillGemSystemScript.award_selected_active_xp(state, amount)

static func award_all_equipped_xp(state: Object, amount: int) -> void:
	if state == null:
		return
	SkillGemSystemScript.award_all_enabled_gem_xp(state, amount)
