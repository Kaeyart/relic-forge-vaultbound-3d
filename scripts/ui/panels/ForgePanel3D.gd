extends "res://scripts/ui/panels/BaseTextPanel3D.gd"
const I := preload("res://scripts/systems/ItemizationSystem3D.gd")
const C := preload("res://scripts/systems/ItemCraftingSystem3D.gd")
var actions: Array[String] = ["transmute","augment","regal","exalt","chaos","annul","alchemy","quality","quality_armor","socket","rune_ash","rune_iron","rune_vault","essence_ember","essence_iron","essence_arcanist"]
func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(10); _set_expand(root,true,true); add_child(root)
	var left: PanelContainer = _panel("SELECTED ITEM"); left.custom_minimum_size = Vector2(330,0); root.add_child(left); _build_item(_panel_content(left))
	var mid: PanelContainer = _panel("CRAFTING VERBS"); _set_expand(mid,true,true); root.add_child(mid); _build_actions(_panel_content(mid))
	var right: PanelContainer = _panel("MATERIALS / SINKS"); right.custom_minimum_size = Vector2(290,0); root.add_child(right); _build_materials(_panel_content(right))
func _build_item(box:VBoxContainer)->void:
	box.add_child(_label(I.item_detail_text(I.normalize_item(_selected_backpack_item())),12))
	box.add_child(_button("Open Inventory", self, "_open_inventory", [], Vector2(170,34)))
func _build_actions(box:VBoxContainer)->void:
	var grid: GridContainer = _grid(2,6); box.add_child(grid)
	for a: String in actions:
		grid.add_child(_button(a.replace("_"," ").capitalize(), self, "_apply", [a], Vector2(170,40)))
func _build_materials(box:VBoxContainer)->void:
	var m: Dictionary = _as_dict(_state_get("materials", {})); var keys: Array = m.keys(); keys.sort(); var lines: PackedStringArray = PackedStringArray()
	for k: Variant in keys:
		var id: String = str(k)
		if id.begins_with("_") or int(m[k]) <= 0: continue
		lines.append(I.material_label(id) + ": " + str(m[k]))
	box.add_child(_label("\n".join(lines),12))
	box.add_child(_button("Sell", self, "_apply", ["sell"], Vector2(190,34)))
	box.add_child(_button("Disenchant", self, "_apply", ["disenchant"], Vector2(190,34)))
	box.add_child(_button("Salvage", self, "_apply", ["salvage"], Vector2(190,34)))
func _apply(a:String)->void: C.apply_to_selected(state_ref,a); refresh_panel()
func _open_inventory()->void: _open_panel("inventory")
