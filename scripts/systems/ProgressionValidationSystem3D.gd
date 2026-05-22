extends RefCounted
class_name RVProgressionValidationSystem3D

const ClassDBScript := preload("res://scripts/data/ClassDB3D.gd")
const PassiveTreeSystemScript := preload("res://scripts/systems/PassiveTreeSystem3D.gd")
const AscendancySystemScript := preload("res://scripts/systems/AscendancySystem3D.gd")

static func validate(state: Object) -> Array[String]:
	var warnings: Array[String] = []
	if state == null:
		return ["State is null."]
	var class_id: String = str(state.get("class_id"))
	if not ClassDBScript.is_valid_class(class_id):
		warnings.append("Invalid class_id: " + class_id)
	warnings.append_array(PassiveTreeSystemScript.validate(state))
	warnings.append_array(AscendancySystemScript.validate(state))
	return warnings

static func report_text(state: Object) -> String:
	var warnings: Array[String] = validate(state)
	if warnings.is_empty():
		return "Progression validation passed."
	var text: String = "Progression validation warnings:\n"
	for warning: String in warnings:
		text += "- " + warning + "\n"
	return text
