extends "res://scripts/ui/panels/BaseTextPanel3D.gd"

func render(state: Object) -> void:
	_reset_columns()
	var active_box: VBoxContainer = _section("Active Skills", 1.1)
	var support_box: VBoxContainer = _section("Support Sockets", 1.25)
	var spirit_box: VBoxContainer = _section("Spirit / Breakdown", 1.35)

	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	var selected_index: int = clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, max(0, slots.size() - 1))
	if slots.is_empty():
		_add_line(active_box, "No active skill slots found.", 13, RVUIStyle.color_muted())
	else:
		for i: int in range(slots.size()):
			if typeof(slots[i]) != TYPE_DICTIONARY:
				continue
			var slot: Dictionary = Dictionary(slots[i])
			var id: String = str(slot.get("gem_id", slot.get("active", slot.get("active_id", "skill"))))
			var level: int = _to_int(slot.get("level", 1))
			var supports: Array = _as_array(slot.get("supports", []))
			var sockets: int = _to_int(slot.get("unlocked_support_sockets", 2))
			_add_button_like(active_box, str(i + 1) + ". " + RVUIStyle.title_case(id) + " · Lv " + str(level) + " · " + str(supports.size()) + "/" + str(sockets), i == selected_index)

	var selected: Dictionary = {}
	if selected_index >= 0 and selected_index < slots.size() and typeof(slots[selected_index]) == TYPE_DICTIONARY:
		selected = Dictionary(slots[selected_index])
	var selected_supports: Array = _as_array(selected.get("supports", []))
	if selected_supports.is_empty():
		_add_line(support_box, "Selected skill has no supports socketed.", 13, RVUIStyle.color_muted())
	else:
		for support_value: Variant in selected_supports:
			var support: Dictionary = _as_dict(support_value)
			var support_id: String = str(support.get("gem_id", support.get("support_id", support_value)))
			var level: int = _to_int(support.get("level", 1))
			_add_button_like(support_box, RVUIStyle.title_case(support_id) + " · Lv " + str(level), false)
	_add_line(support_box, "", 4)
	_add_line(support_box, "Controls", 12, RVUIStyle.color_gold())
	_add_line(support_box, "[A/D] change active · [S] add compatible support · [W] remove · [G] toggle spirit", 12, RVUIStyle.color_muted())

	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	_add_line(spirit_box, "Reserved: " + str(_state_get(state, "spirit_reserved", 0)) + " / " + str(_state_get(state, "spirit_max", 100)), 13, RVUIStyle.color_gold())
	if spirits.is_empty():
		_add_line(spirit_box, "No spirit gems installed.", 13, RVUIStyle.color_muted())
	else:
		for spirit_value: Variant in spirits:
			if typeof(spirit_value) != TYPE_DICTIONARY:
				continue
			var spirit: Dictionary = Dictionary(spirit_value)
			var status: String = "ON" if bool(spirit.get("enabled", false)) else "off"
			var id: String = str(spirit.get("gem_id", spirit.get("spirit_id", "spirit")))
			_add_line(spirit_box, status + " · " + RVUIStyle.title_case(id) + " · Lv " + str(_to_int(spirit.get("level", 1))), 13, RVUIStyle.color_text())
	_add_line(spirit_box, "", 4)
	if not selected.is_empty():
		var sid: String = str(selected.get("gem_id", selected.get("active_id", "skill")))
		_add_line(spirit_box, "Selected: " + RVUIStyle.title_case(sid), 16, RVUIStyle.color_gold())
		_add_line(spirit_box, "Level " + str(selected.get("level", 1)) + " · XP " + str(selected.get("xp", 0)), 13, RVUIStyle.color_text())
		var tags: Array = _as_array(selected.get("tags", []))
		if not tags.is_empty():
			var tag_text: PackedStringArray = PackedStringArray()
			for tag: Variant in tags:
				tag_text.append(str(tag))
			_add_line(spirit_box, "Tags: " + ", ".join(tag_text), 12, RVUIStyle.color_muted())
