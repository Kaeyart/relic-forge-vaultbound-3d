class_name RVCurrencyDB3D
extends RefCounted
const ItemizationScript := preload("res://scripts/systems/ItemizationSystem3D.gd")
static func label(id: String) -> String: return ItemizationScript.material_label(id)
static func starter_counts() -> Dictionary: return ItemizationScript.STARTER_COUNTS
