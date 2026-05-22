class_name RVItemSalvageSystem3D
extends RefCounted
const C := preload("res://scripts/systems/ItemCraftingSystem3D.gd")
static func sell_selected(s:Object)->bool: return C.apply_to_selected(s,"sell")
static func disenchant_selected(s:Object)->bool: return C.apply_to_selected(s,"disenchant")
static func salvage_selected(s:Object)->bool: return C.apply_to_selected(s,"salvage")
