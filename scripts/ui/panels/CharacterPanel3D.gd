extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

var _sections: Array[String] = ["overview", "offense", "defense", "resources", "build rules"]

func refresh_panel() -> void:
	_clear()
	var root: HBoxContainer = _hbox(10)
	_set_expand(root, true, true)
	add_child(root)
	var nav: PanelContainer = _panel("CHARACTER SECTIONS")
	nav.custom_minimum_size = Vector2(190, 0)
	root.add_child(nav)
	_build_nav(_panel_content(nav))
	var center: PanelContainer = _panel("CHARACTER")
	_set_expand(center, true, true)
	root.add_child(center)
	_build_center(_panel_content(center))
	var stats: PanelContainer = _panel("SELECTED STATS")
	_set_expand(stats, true, true)
	root.add_child(stats)
	_build_stats(_panel_content(stats))

func _build_nav(box: VBoxContainer) -> void:
	var selected: String = str(_state_get("character_section", "overview"))
	for section: String in _sections:
		box.add_child(_button(("▶ " if section == selected else "") + section.capitalize(), self, "_select_section", [section], Vector2(170, 36)))
	box.add_child(_button("Open Inventory", self, "_open_inventory", [], Vector2(170, 36)))
	box.add_child(_button("Open Skills", self, "_open_skills", [], Vector2(170, 36)))

func _build_center(box: VBoxContainer) -> void:
	var class_display: String = str(_state_get("class_display_name", _state_get("class_name", "Vaultbound")))
	var level: int = _to_int(_state_get("level", 1))
	var xp: int = _to_int(_state_get("xp", 0))
	var next_xp: int = 100
	if state_ref != null and state_ref.has_method("xp_to_next"):
		next_xp = maxi(1, _to_int(state_ref.call("xp_to_next")))
	box.add_child(_label("[center][font_size=22][color=#c59b4a]" + class_display + "[/color][/font_size]\nLevel " + str(level) + " · XP " + str(xp) + "/" + str(next_xp) + "\n\n[font_size=48]♜[/font_size]\n\n[color=#8f8777]Final art target: paper-doll character with equipment orbit slots.[/color][/center]"))
	var equipped: Dictionary = _as_dict(_state_get("equipped", {}))
	var slot_grid: GridContainer = _grid(2, 5)
	box.add_child(slot_grid)
	for key: Variant in equipped.keys():
		if typeof(equipped[key]) == TYPE_DICTIONARY:
			var item: Dictionary = Dictionary(equipped[key])
			slot_grid.add_child(_button(str(key) + "\n" + _short(_item_name(item), 18), self, "_select_equipped", [str(key)], Vector2(150, 52)))

func _build_stats(box: VBoxContainer) -> void:
	var section: String = str(_state_get("character_section", "overview"))
	box.add_child(_label("[font_size=16][color=#c59b4a]" + section.capitalize() + "[/color][/font_size]"))
	match section:
		"offense":
			box.add_child(_label(_stat_lines(["attack_damage", "spell_damage", "fire_damage", "lightning_damage", "void_damage", "crit_chance", "crit_damage"])))
		"defense":
			box.add_child(_label(_stat_lines(["armor", "block_chance", "dodge_chance", "fire_resistance", "lightning_resistance", "void_resistance"])))
		"resources":
			box.add_child(_label(_stat_lines(["max_hp", "player_hp", "max_mana", "player_mana", "spirit_max", "spirit_reserved"])))
		"build rules":
			box.add_child(_label(_build_rules_text()))
		_:
			box.add_child(_label(_stat_lines(["max_hp", "max_mana", "armor", "move_speed", "gold"])))

func _stat_lines(keys: Array[String]) -> String:
	var lines: PackedStringArray = PackedStringArray()
	var build_stats: Dictionary = _as_dict(_state_get("build_stats", {}))
	for key: String in keys:
		var value: Variant = _state_get(key, build_stats.get(key, "—"))
		lines.append("• " + key.replace("_", " ").capitalize() + ": " + str(value))
	return "\n".join(lines)

func _build_rules_text() -> String:
	var rules: Array = _as_array(_state_get("build_rules", []))
	if rules.is_empty():
		return "[color=#8f8777]No special build rules currently active.[/color]"
	var lines: PackedStringArray = PackedStringArray()
	for rule: Variant in rules:
		lines.append("• " + str(rule))
	return "\n".join(lines)

func _select_section(section: String) -> void:
	_state_set("character_section", section)
	refresh_panel()

func _select_equipped(slot_name: String) -> void:
	_state_set("selected_equipment_slot", slot_name)
	_notice("Selected " + slot_name.replace("_", " ").capitalize())

func _open_inventory() -> void:
	_open_panel("inventory")

func _open_skills() -> void:
	_open_panel("skills")
