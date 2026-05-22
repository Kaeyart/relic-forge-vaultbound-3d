class_name RVItemBaseDB3D
extends RefCounted
const ItemizationScript := preload("res://scripts/systems/ItemizationSystem3D.gd")
static func all_bases() -> Dictionary: return ItemizationScript.BASES
static func base_data(id: String) -> Dictionary: return Dictionary(ItemizationScript.BASES.get(id, ItemizationScript.BASES["ash_wand"])).duplicate(true)
