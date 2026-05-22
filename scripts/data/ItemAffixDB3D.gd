class_name RVItemAffixDB3D
extends RefCounted
const ItemizationScript := preload("res://scripts/systems/ItemizationSystem3D.gd")
static func affixes() -> Array[Dictionary]: return ItemizationScript.AFFIXES
