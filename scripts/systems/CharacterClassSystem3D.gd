class_name RVCharacterClassSystem3D
extends RefCounted

static func classes() -> Dictionary:
	return {
		"sorceress":{"name":"Sorceress", "tags":["spell","fire","lightning","mana"], "rules":["class_sorceress"], "stats":{"Spell Damage":0.10,"Maximum Mana":20.0}, "actives":["fireball","storm_lance","void_rift"]},
		"warden":{"name":"Warden", "tags":["attack","melee","armor","bleed"], "rules":["class_warden"], "stats":{"Attack Damage":0.10,"Maximum Life":24.0,"Armor":24.0}, "actives":["arc_slash","fireball"]},
		"voidbinder":{"name":"Voidbinder", "tags":["void","spell","sacrifice"], "rules":["class_voidbinder"], "stats":{"Void Damage":0.14,"Maximum Mana":12.0}, "actives":["void_rift","fireball"]},
		"machinist":{"name":"Machinist", "tags":["trap","projectile","cooldown"], "rules":["class_machinist"], "stats":{"Projectile Damage":0.10,"Cooldown Recovery":0.05}, "actives":["ember_mine","fireball","storm_lance"]}
	}

static func ensure_defaults(state: Object) -> void:
	if state == null: return
	var id: String = str(state.get("class_id"))
	if id == "" or not classes().has(id):
		id = "sorceress"
		state.set("class_id", id)
	var data: Dictionary = Dictionary(classes().get(id, {}))
	state.set("class_display_name", str(data.get("name", id.capitalize())))
	state.set("class_tags", Array(data.get("tags", [])).duplicate(true))
	state.set("class_rules", Array(data.get("rules", [])).duplicate(true))

static func class_bundle(state: Object) -> Dictionary:
	if state == null: return {}
	var id: String = str(state.get("class_id"))
	var data: Dictionary = Dictionary(classes().get(id, classes()["sorceress"]))
	return {"stats":Dictionary(data.get("stats", {})).duplicate(true), "rules":Array(data.get("rules", [])).duplicate(true)}
