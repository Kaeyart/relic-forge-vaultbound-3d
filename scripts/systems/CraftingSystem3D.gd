class_name RVCraftingSystem3D
extends RefCounted
const C := preload("res://scripts/systems/ItemCraftingSystem3D.gd")
const I := preload("res://scripts/systems/ItemizationSystem3D.gd")
static func craft_selected(state:Object, action:String)->bool: return C.craft_selected(state, action)
static func apply_to_selected(state:Object, action:String)->bool: return C.apply_to_selected(state, action)
static func panel_text(state:Object)->String:
	var item:Dictionary = {}
	if state != null and state.has_method("selected_backpack_item"): item = Dictionary(state.call("selected_backpack_item"))
	return I.item_detail_text(item)
