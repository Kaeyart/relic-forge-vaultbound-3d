class_name RVRuneDB3D
extends RefCounted
const ItemizationScript := preload("res://scripts/systems/ItemizationSystem3D.gd")
static func rune_data(id: String) -> Dictionary: return Dictionary(ItemizationScript.RUNE_DATA.get(id, {})).duplicate(true)
