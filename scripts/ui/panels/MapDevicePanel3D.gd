extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

func render(state: Object) -> void:
	_reset_columns()
	var list_box: VBoxContainer = _section("Maps", 1.1)
	var detail_box: VBoxContainer = _section("Selected Map", 1.25)
	var run_box: VBoxContainer = _section("Run Plan", 1.0)

	var maps: Array = _as_array(_state_get(state, "map_stash", []))
	var cursor: int = clampi(_to_int(_state_get(state, "map_cursor", 0)), 0, max(0, maps.size() - 1))
	if maps.is_empty():
		_add_line(list_box, "No maps in stash.", 13, RVUIStyle.color_muted())
	else:
		var shown: int = min(16, maps.size())
		for i: int in range(shown):
			if typeof(maps[i]) != TYPE_DICTIONARY:
				continue
			var map_item: Dictionary = Dictionary(maps[i])
			var name: String = str(map_item.get("display_name", map_item.get("name", "Map")))
			var tier: int = _to_int(map_item.get("tier", map_item.get("map_tier", 1)))
			var mods: Array = _as_array(map_item.get("mods", []))
			_add_button_like(list_box, name + " · T" + str(tier) + " · " + str(mods.size()) + " mods", i == cursor)

	var selected: Dictionary = {}
	if cursor >= 0 and cursor < maps.size() and typeof(maps[cursor]) == TYPE_DICTIONARY:
		selected = Dictionary(maps[cursor])
	if selected.is_empty():
		_add_line(detail_box, "No map selected.", 13, RVUIStyle.color_muted())
	else:
		_add_line(detail_box, str(selected.get("display_name", selected.get("name", "Map"))), 18, RVUIStyle.color_gold())
		_add_line(detail_box, "Tier " + str(selected.get("tier", selected.get("map_tier", 1))) + " · Area Level " + str(selected.get("area_level", selected.get("level", "?"))), 13, RVUIStyle.color_text())
		var mods: Array = _as_array(selected.get("mods", []))
		if mods.is_empty():
			_add_line(detail_box, "No explicit modifiers.", 13, RVUIStyle.color_muted())
		else:
			_add_line(detail_box, "Modifiers", 13, RVUIStyle.color_gold())
			for mod_value: Variant in mods:
				if typeof(mod_value) == TYPE_DICTIONARY:
					var mod: Dictionary = Dictionary(mod_value)
					_add_line(detail_box, "• " + str(mod.get("display_name", mod.get("id", "mod"))), 12, RVUIStyle.color_text())
				else:
					_add_line(detail_box, "• " + str(mod_value), 12, RVUIStyle.color_text())

	_add_line(run_box, "Goal", 12, RVUIStyle.color_gold())
	_add_line(run_box, "Pick a map, launch, clear packs, kill boss, loot, return to hub.", 13, RVUIStyle.color_text())
	_add_line(run_box, "", 4)
	_add_line(run_box, "Controls", 12, RVUIStyle.color_gold())
	_add_line(run_box, "[M] open/close device · [Enter/E] launch selected map · [Esc] close", 12, RVUIStyle.color_muted())
	var completed: Variant = _state_get(state, "completed_maps", {})
	_add_line(run_box, "Completed map data: " + str(completed), 11, RVUIStyle.color_muted())
