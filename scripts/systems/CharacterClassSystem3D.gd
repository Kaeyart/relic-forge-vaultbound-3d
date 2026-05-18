class_name RVCharacterClassSystem3D
extends RefCounted

static var _classes: Dictionary = {
	"sorceress": {"id":"sorceress", "name":"Sorceress", "identity":"Elemental spellcaster", "max_mana":24.0, "max_hp":-5.0, "move_speed":0.0, "starter_skills":["fireball","storm_lance","rift_pulse","arc_slash"], "tags":["spell","fire","lightning","void","mana"]},
	"warden": {"id":"warden", "name":"Warden", "identity":"Melee armor bruiser", "max_mana":-10.0, "max_hp":24.0, "move_speed":-0.15, "starter_skills":["arc_slash","fireball","storm_lance","rift_pulse"], "tags":["melee","armor","bleed","life"]},
	"voidbinder": {"id":"voidbinder", "name":"Voidbinder", "identity":"Void and sacrifice caster", "max_mana":16.0, "max_hp":0.0, "move_speed":0.0, "starter_skills":["rift_pulse","fireball","storm_lance","arc_slash"], "tags":["void","spell","curse","mana"]},
	"machinist": {"id":"machinist", "name":"Machinist", "identity":"Trap and projectile engineer", "max_mana":6.0, "max_hp":8.0, "move_speed":0.05, "starter_skills":["storm_lance","fireball","arc_slash","rift_pulse"], "tags":["projectile","trap","cooldown","device"]}
}

static func class_data(class_id: String) -> Dictionary:
	return Dictionary(_classes.get(class_id, _classes["sorceress"])).duplicate(true)

static func all_classes() -> Dictionary:
	return _classes

static func apply_to_state(state: Object) -> void:
	if state == null:
		return
	var data: Dictionary = class_data(str(state.get("class_id")))
	if state.get("active_skill_slots") == null or Array(state.get("active_skill_slots")).is_empty():
		state.set("active_skill_slots", Array(data.get("starter_skills", [])).duplicate(true))
