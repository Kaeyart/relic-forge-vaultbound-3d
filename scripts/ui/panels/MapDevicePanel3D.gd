extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(10)
	_set_expand(root, true, true)
	add_child(root)
	var list_panel: PanelContainer = _panel("AVAILABLE MAPS · CLICK MAP")
	_set_expand(list_panel, true, true)
	root.add_child(list_panel)
	_build_map_list(_panel_content(list_panel))
	var center_panel: PanelContainer = _panel("MAP DEVICE")
	_set_expand(center_panel, true, true)
	root.add_child(center_panel)
	_build_center(_panel_content(center_panel))
	var detail_panel: PanelContainer = _panel("MAP DETAILS")
	_set_expand(detail_panel, true, true)
	root.add_child(detail_panel)
	_build_details(_panel_content(detail_panel))

func _selected_map() -> Dictionary:
	var maps: Array = _as_array(_state_get("map_stash", []))
	var cursor: int = _to_int(_state_get("map_cursor", 0))
	if cursor >= 0 and cursor < maps.size() and typeof(maps[cursor]) == TYPE_DICTIONARY:
		return Dictionary(maps[cursor])
	return {}

func _build_map_list(box: VBoxContainer) -> void:
	var maps: Array = _as_array(_state_get("map_stash", []))
	var cursor: int = _to_int(_state_get("map_cursor", 0))
	if maps.is_empty():
		box.add_child(_label("[color=#8f8777]No maps in stash. Run starter content or generate maps.[/color]"))
		return
	for i: int in range(maps.size()):
		if typeof(maps[i]) != TYPE_DICTIONARY:
			continue
		var map_item: Dictionary = Dictionary(maps[i])
		var name: String = str(map_item.get("display_name", map_item.get("name", "Map")))
		var tier: int = _to_int(map_item.get("tier", 1))
		var level: int = _to_int(map_item.get("area_level", map_item.get("level", 1)))
		var b: Button = _button(("▶ " if i == cursor else "") + name + "\nTier " + str(tier) + " · Area " + str(level), self, "_select_map", [i], Vector2(260, 58))
		if i == cursor:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		box.add_child(b)

func _build_center(box: VBoxContainer) -> void:
	var selected: Dictionary = _selected_map()
	var title: String = str(selected.get("display_name", selected.get("name", "No Map Selected")))
	box.add_child(_label("[center][font_size=20][color=#c59b4a]" + title + "[/color][/font_size]\n\n[font_size=42]◇ ◈ ◇[/font_size]\n\n[color=#8f8777]Final art target: ritual map device / portal centerpiece.[/color][/center]", 15))
	box.add_child(_button("Launch Selected Map", self, "_launch_map", [], Vector2(260, 44)))
	box.add_child(_button("Previous Map", self, "_step_map", [-1], Vector2(260, 34)))
	box.add_child(_button("Next Map", self, "_step_map", [1], Vector2(260, 34)))

func _build_details(box: VBoxContainer) -> void:
	var selected: Dictionary = _selected_map()
	if selected.is_empty():
		box.add_child(_label("No map selected."))
		return
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[font_size=17][color=#c59b4a][b]" + str(selected.get("display_name", selected.get("name", "Map"))) + "[/b][/color][/font_size]")
	lines.append("Tier " + str(_to_int(selected.get("tier", 1))) + " · Area Level " + str(_to_int(selected.get("area_level", selected.get("level", 1)))) )
	lines.append("\n[color=#8f8777]Modifiers[/color]")
	var mods: Array = _as_array(selected.get("mods", []))
	if mods.is_empty():
		lines.append("• No explicit modifiers")
	else:
		for mod_value: Variant in mods:
			if typeof(mod_value) == TYPE_DICTIONARY:
				var mod: Dictionary = Dictionary(mod_value)
				lines.append("• " + str(mod.get("display_name", mod.get("id", "modifier"))))
			else:
				lines.append("• " + str(mod_value))
	lines.append("\nDanger: " + str(_to_int(selected.get("danger", selected.get("tier", 1)))) + "/10")
	lines.append("Rewards: loot, gems, forge materials, maps")
	box.add_child(_label("\n".join(lines)))

func _select_map(index: int) -> void:
	_state_set("map_cursor", index)
	refresh_panel()

func _step_map(dir: int) -> void:
	var maps: Array = _as_array(_state_get("map_stash", []))
	if maps.is_empty():
		return
	var cursor: int = _to_int(_state_get("map_cursor", 0))
	_state_set("map_cursor", wrapi(cursor + dir, 0, maps.size()))
	refresh_panel()

func _launch_map() -> void:
	_state_set("panel_mode", "")
	var scene: Node = get_tree().current_scene
	if scene != null and scene.has_method("_start_map"):
		scene.call("_start_map")
	else:
		_notice("Launch requested. Current scene has no _start_map method.")
