class_name RVEssenceDB3D
extends RefCounted
static func seal_tag(action: String) -> String:
	match action:
		"essence_ember": return "fire"
		"essence_iron": return "defence"
		"essence_arcanist": return "caster"
		_: return ""
