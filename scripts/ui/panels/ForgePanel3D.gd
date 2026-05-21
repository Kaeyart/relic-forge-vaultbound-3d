extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const CraftingSystemScript: GDScript = preload("res://scripts/systems/CraftingSystem3D.gd")

var _actions: Array[Dictionary] = [
	{"id": "seal", "name": "Add Crafted Affix", "desc": "Add or improve a controlled crafted modifier."},
	{"id": "reforge", "name": "Reforge", "desc": "Reroll part of the item within its current identity."},
	{"id": "polish", "name": "Polish Quality", "desc": "Improve item quality when materials allow."},
	{"id": "socket", "name": "Add Socket", "desc": "Future: add a gear augment socket."},
	{"id": "lock", "name": "Lock Affix", "desc": "Future: protect one affix from change."},
	{"id": "risky", "name": "Risky Forge", "desc": "Future: high-risk item transformation."}
]

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(10)
	_set_expand(root, true, true)
	add_child(root)
	var item_panel: PanelContainer = _panel("ITEM TO FORGE")
	_set_expand(item_panel, true, true)
	root.add_child(item_panel)
	_build_item(_panel_content(item_panel))
	var center_panel: PanelContainer = _panel("FORGE PREVIEW")
	_set_expand(center_panel, true, true)
	root.add_child(center_panel)
	_build_preview(_panel_content(center_panel))
	var actions_panel: PanelContainer = _panel("FORGING ACTIONS · CLICK ACTION")
	_set_expand(actions_panel, true, true)
	root.add_child(actions_panel)
	_build_actions(_panel_content(actions_panel))

func _build_item(box: VBoxContainer) -> void:
	var item: Dictionary = _selected_backpack_item()
	box.add_child(_label(_item_summary(item)))
	box.add_child(_button("Open Inventory", self, "_open_inventory", [], Vector2(190, 34)))

func _build_preview(box: VBoxContainer) -> void:
	var action: String = str(_state_get("forge_action", "seal"))
	var item: Dictionary = _selected_backpack_item()
	var potential: int = _to_int(item.get("forge_potential", 0))
	box.add_child(_label("[center][font_size=42]⚒[/font_size]\n[color=#c59b4a][b]" + action.capitalize() + "[/b][/color]\nForge Potential: " + str(potential) + "\n\n[color=#8f8777]Final art target: central anvil / molten ritual forge with preview deltas.[/color][/center]"))
	box.add_child(_label(_materials_text()))
	box.add_child(_button("Confirm Forge", self, "_confirm_forge", [], Vector2(230, 44)))

func _build_actions(box: VBoxContainer) -> void:
	var active: String = str(_state_get("forge_action", "seal"))
	for action: Dictionary in _actions:
		var id: String = str(action.get("id", ""))
		var text: String = ("▶ " if id == active else "") + str(action.get("name", id.capitalize())) + "\n" + str(action.get("desc", ""))
		var b: Button = _button(text, self, "_select_action", [id], Vector2(250, 62))
		if id == active:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		box.add_child(b)

func _materials_text() -> String:
	var materials: Dictionary = _as_dict(_state_get("materials", {}))
	if materials.is_empty():
		return "[color=#8f8777]Materials: none[/color]"
	var parts: PackedStringArray = PackedStringArray()
	for key: Variant in materials.keys():
		parts.append(str(key) + ": " + str(materials[key]))
	return "Materials: " + ", ".join(parts)

func _select_action(id: String) -> void:
	_state_set("forge_action", id)
	refresh_panel()

func _confirm_forge() -> void:
	var action: String = str(_state_get("forge_action", "seal"))
	if action not in ["seal", "reforge", "polish"]:
		_notice("This forge action is planned but not live yet: " + action)
		return
	if CraftingSystemScript.has_method("craft_selected"):
		CraftingSystemScript.call("craft_selected", state_ref, action)
	else:
		_notice("Crafting system does not expose craft_selected.")
	refresh_panel()

func _open_inventory() -> void:
	_open_panel("inventory")
