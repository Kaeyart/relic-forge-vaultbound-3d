class_name RVItemSocketSystem3D
extends RefCounted
const C := preload("res://scripts/systems/ItemCraftingSystem3D.gd")
static func add_socket_selected(s:Object)->bool: return C.apply_to_selected(s,"socket")
static func socket_ash_rune_selected(s:Object)->bool: return C.apply_to_selected(s,"rune_ash")
static func socket_iron_rune_selected(s:Object)->bool: return C.apply_to_selected(s,"rune_iron")
static func socket_vault_rune_selected(s:Object)->bool: return C.apply_to_selected(s,"rune_vault")
