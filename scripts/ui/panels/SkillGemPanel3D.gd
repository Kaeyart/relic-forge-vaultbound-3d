extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

const SkillGemSystemScript: GDScript = preload("res://scripts/systems/SkillGemSystem3D.gd")

func refresh_panel() -> void:
	_clear()
	if state_ref != null:
		_call_skill_system("ensure_defaults")
	var root: HBoxContainer = _hbox(10)
	_set_expand(root, true, true)
	add_child(root)
	var hotbar_panel: PanelContainer = _panel("HOTBAR · CLICK SLOT")
	_set_expand(hotbar_panel, false, true)
	hotbar_panel.custom_minimum_size = Vector2(220, 0)
	root.add_child(hotbar_panel)
	_build_hotbar(_panel_content(hotbar_panel))
	var gem_page_panel: PanelContainer = _panel("EQUIPPED GEM PAGE · CLICK GEM")
	_set_expand(gem_page_panel, true, true)
	root.add_child(gem_page_panel)
	_build_gem_page(_panel_content(gem_page_panel))
	var detail_panel: PanelContainer = _panel("SELECTED GEM / SUPPORTS")
	_set_expand(detail_panel, true, true)
	detail_panel.custom_minimum_size = Vector2(380, 0)
	root.add_child(detail_panel)
	_build_detail(_panel_content(detail_panel))

func _build_hotbar(box: VBoxContainer) -> void:
	var hotbar: Array = _as_array(_state_get("hotbar_slots", []))
	if hotbar.is_empty():
		hotbar = _as_array(_state_get("active_skill_slots", []))
	var selected: int = _to_int(_state_get("selected_hotbar_slot", _state_get("selected_skill_slot", 0)))
	for i: int in range(5):
		var label_text: String = "Empty"
		if i < hotbar.size():
			var value: Variant = hotbar[i]
			if typeof(value) == TYPE_DICTIONARY:
				label_text = _gem_display(Dictionary(value))
			else:
				label_text = str(value)
		var b: Button = _button(("▶ " if i == selected else "") + str(i + 1) + " · " + _short(label_text, 20), self, "_select_hotbar", [i], Vector2(200, 46))
		if i == selected:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		box.add_child(b)
	box.add_child(_button("Cycle Active ←", self, "_cycle_active", [-1], Vector2(200, 34)))
	box.add_child(_button("Cycle Active →", self, "_cycle_active", [1], Vector2(200, 34)))

func _build_gem_page(box: VBoxContainer) -> void:
	var gems: Array = _as_array(_state_get("equipped_skill_gems", []))
	if gems.is_empty():
		gems = _as_array(_state_get("active_skill_slots", []))
	if gems.is_empty():
		box.add_child(_label("[color=#8f8777]No equipped gems found. Use uncut gems or starter defaults.[/color]"))
		return
	var selected_row: int = _to_int(_state_get("selected_gem_row", 0))
	for i: int in range(gems.size()):
		if typeof(gems[i]) != TYPE_DICTIONARY:
			continue
		var gem: Dictionary = Dictionary(gems[i])
		var supports: Array = _as_array(gem.get("supports", gem.get("support_sockets", [])))
		var socket_count: int = _to_int(gem.get("support_socket_count", gem.get("unlocked_support_sockets", 2)))
		var text: String = ("▶ " if i == selected_row else "") + str(i + 1) + ". " + _gem_display(gem) + "\nLv " + str(_to_int(gem.get("level", 1))) + " · Supports " + str(supports.size()) + "/" + str(socket_count)
		var b: Button = _button(text, self, "_select_gem_row", [i], Vector2(300, 54))
		if i == selected_row:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		box.add_child(b)

func _build_detail(box: VBoxContainer) -> void:
	var selected_cast: Dictionary = _call_selected_cast_data()
	box.add_child(_label("[font_size=16][color=#c59b4a][b]" + str(selected_cast.get("name", "Selected Skill")) + "[/b][/color][/font_size]\nDamage " + str(int(round(_to_float(selected_cast.get("damage", 0.0))))) + " · Mana " + str(int(round(_to_float(selected_cast.get("mana_cost", 0.0))))) + " · Cooldown " + str(snappedf(_to_float(selected_cast.get("cooldown", 0.0)), 0.01)) + "\nTags: " + ", ".join(_array_to_strings(_as_array(selected_cast.get("tags", []))))))
	box.add_child(_button("Add Compatible Support", self, "_add_support", [], Vector2(240, 38)))
	box.add_child(_button("Remove Last Support", self, "_remove_support", [], Vector2(240, 34)))
	box.add_child(_button("Toggle Spirit", self, "_toggle_spirit", [], Vector2(240, 34)))
	box.add_child(_button("Carve Uncut Active", self, "_carve_active", [], Vector2(240, 34)))
	box.add_child(_button("Carve Uncut Support", self, "_carve_support", [], Vector2(240, 34)))
	box.add_child(_button("Carve Uncut Spirit", self, "_carve_spirit", [], Vector2(240, 34)))
	box.add_child(_label(_spirit_text() + "\n\n[color=#8f8777]Mouse rule: hotbar slots, gem rows, supports, spirit toggles, and carving actions are all clickable.[/color]", 12))

func _gem_display(gem: Dictionary) -> String:
	var id: String = str(gem.get("gem_id", gem.get("active", gem.get("active_id", gem.get("id", "gem")))))
	return id.replace("_", " ").capitalize()

func _spirit_text() -> String:
	var reserved: int = _to_int(_state_get("spirit_reserved", 0))
	var max_spirit: int = _to_int(_state_get("spirit_max", 100))
	var spirits: Array = _as_array(_state_get("spirit_gem_slots", []))
	return "Spirit: " + str(max_spirit - reserved) + "/" + str(max_spirit) + " available · " + str(spirits.size()) + " spirit gems installed"

func _select_hotbar(index: int) -> void:
	_state_set("selected_hotbar_slot", index)
	_state_set("selected_skill_slot", index)
	refresh_panel()

func _select_gem_row(index: int) -> void:
	_state_set("selected_gem_row", index)
	refresh_panel()

func _cycle_active(dir: int) -> void:
	if not _call_skill_system("cycle_active_slot_gem", [dir]):
		_notice("Cycle active skill function unavailable.")
	refresh_panel()

func _add_support() -> void:
	if not _call_skill_system("add_next_valid_support"):
		_notice("Add support function unavailable.")
	refresh_panel()

func _remove_support() -> void:
	if not _call_skill_system("remove_last_support"):
		_notice("Remove support function unavailable.")
	refresh_panel()

func _toggle_spirit() -> void:
	if not _call_skill_system("toggle_next_spirit"):
		_notice("Toggle spirit function unavailable.")
	refresh_panel()

func _carve_active() -> void:
	if not _call_first_available(["carve_first_uncut_active", "carve_first_uncut_active_gem", "carve_uncut_active"]):
		_notice("No active carving helper found yet.")
	refresh_panel()

func _carve_support() -> void:
	if not _call_first_available(["carve_first_uncut_support", "carve_first_uncut_support_gem", "carve_uncut_support"]):
		_notice("No support carving helper found yet.")
	refresh_panel()

func _carve_spirit() -> void:
	if not _call_first_available(["carve_first_uncut_spirit", "carve_first_uncut_spirit_gem", "carve_uncut_spirit"]):
		_notice("No spirit carving helper found yet.")
	refresh_panel()

func _call_first_available(names: Array[String]) -> bool:
	for method_name: String in names:
		if _call_skill_system(method_name):
			return true
	return false

func _call_skill_system(method_name: String, args: Array = []) -> bool:
	if state_ref == null:
		return false
	if not SkillGemSystemScript.has_method(method_name):
		return false
	var call_args: Array = [state_ref]
	for value: Variant in args:
		call_args.append(value)
	SkillGemSystemScript.callv(method_name, call_args)
	return true

func _call_selected_cast_data() -> Dictionary:
	if state_ref == null:
		return {}
	if SkillGemSystemScript.has_method("selected_cast_data"):
		var value: Variant = SkillGemSystemScript.call("selected_cast_data", state_ref)
		if typeof(value) == TYPE_DICTIONARY:
			return Dictionary(value)
	return {}
