extends Control

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

var state_ref: Object = null
var left_label: RichTextLabel = null
var center_label: RichTextLabel = null
var right_label: RichTextLabel = null
var bottom_label: RichTextLabel = null

func _ready() -> void:
	_bind_nodes()

func bind_state(state: Object) -> void:
	state_ref = state
	update_from_state(state)

func update_from_state(state: Object) -> void:
	state_ref = state
	if state_ref == null:
		return
	if left_label == null:
		_bind_nodes()
	SkillGemSystemScript.ensure_defaults(state_ref)
	_render()

func _bind_nodes() -> void:
	left_label = get_node_or_null("Root/Columns/Left/LeftText") as RichTextLabel
	center_label = get_node_or_null("Root/Columns/Center/CenterText") as RichTextLabel
	right_label = get_node_or_null("Root/Columns/Right/RightText") as RichTextLabel
	bottom_label = get_node_or_null("Root/Bottom/BottomText") as RichTextLabel

func _render() -> void:
	if state_ref == null:
		return
	if left_label != null:
		left_label.text = _left_text()
	if center_label != null:
		center_label.text = _center_text()
	if right_label != null:
		right_label.text = _right_text()
	if bottom_label != null:
		bottom_label.text = _bottom_text()

func _left_text() -> String:
	var lines: PackedStringArray = PackedStringArray()
	var equipped: Array = _arr(_get_value("equipped_skill_gems", []))
	var hotbar: Array = _arr(_get_value("hotbar_slots", []))
	var selected_hotbar: int = clampi(_int(_get_value("selected_hotbar_slot", _get_value("selected_skill_slot", 0))), 0, max(0, hotbar.size() - 1))
	lines.append("[b][color=#caa24a]HOTBAR BINDINGS[/color][/b]")
	for i: int in range(5):
		var uid_value: String = ""
		if i < hotbar.size():
			uid_value = str(hotbar[i])
		var row_index: int = _find_row_by_uid(equipped, uid_value)
		var label: String = "Empty"
		if row_index >= 0:
			label = _active_name(Dictionary(equipped[row_index])) + "  [row " + str(row_index + 1) + "]"
		var marker: String = "[color=#ffd36a]▶[/color] " if i == selected_hotbar else "   "
		lines.append(marker + "[" + str(i + 1) + "] " + label)
	lines.append("")
	lines.append("[b][color=#caa24a]EQUIPPED GEM PAGE[/color][/b]")
	lines.append("Nine skill rows. These are not the same thing as hotbar buttons.")
	for row: int in range(equipped.size()):
		if typeof(equipped[row]) != TYPE_DICTIONARY or Dictionary(equipped[row]).is_empty():
			lines.append("  " + str(row + 1) + ". Empty")
			continue
		var active: Dictionary = Dictionary(equipped[row])
		var supports: Array = _arr(active.get("support_sockets", []))
		lines.append("  " + str(row + 1) + ". " + _active_name(active) + " Lv" + str(_int(active.get("level", 1))) + " · " + str(_filled(supports)) + "/" + str(supports.size()) + " supports")
	return "\n".join(lines)

func _center_text() -> String:
	var active: Dictionary = SkillGemSystemScript.selected_active_gem(state_ref)
	if active.is_empty():
		return "[b]SELECTED SKILL[/b]\nNo skill bound."
	var cast_data: Dictionary = SkillGemSystemScript.selected_cast_data(state_ref)
	var tags: Array = _arr(cast_data.get("tags", []))
	var supports: Array = _arr(active.get("support_sockets", []))
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[b][color=#e6c16a]" + str(cast_data.get("name", "Skill")) + "[/color][/b]")
	lines.append("Level " + str(cast_data.get("level", 1)) + " · Quality +" + str(cast_data.get("quality", 0)) + "% · Sockets " + str(_filled(supports)) + "/" + str(supports.size()))
	lines.append("Tags: " + ", ".join(_strings(tags)))
	lines.append("")
	lines.append("[b]Core Combat Data[/b]")
	lines.append("Damage: " + str(int(round(float(cast_data.get("damage", 0.0))))) + "    Mana: " + str(int(round(float(cast_data.get("mana_cost", 0.0))))) + "    Life: " + str(int(round(float(cast_data.get("life_cost", 0.0))))) )
	lines.append("Cooldown: " + str(snappedf(float(cast_data.get("cooldown", 0.0)), 0.01)) + "    Area x" + str(snappedf(float(cast_data.get("area_mult", 1.0)), 0.01)))
	lines.append("Projectiles: " + str(cast_data.get("projectile_count", 1)) + "    Chain: " + str(cast_data.get("chain", 0)) + "    Pierce: " + str(cast_data.get("pierce", 0)))
	var rules: Dictionary = Dictionary(cast_data.get("rules", {}))
	lines.append("Ignite " + str(int(round(float(rules.get("ignite_chance", 0.0)) * 100.0))) + "% · Shock " + str(int(round(float(rules.get("shock_chance", 0.0)) * 100.0))) + "% · Bleed " + str(int(round(float(rules.get("bleed_chance", 0.0)) * 100.0))) + "%")
	lines.append("")
	lines.append("[b]Support Sockets[/b]")
	for i: int in range(supports.size()):
		if typeof(supports[i]) == TYPE_DICTIONARY:
			var support: Dictionary = Dictionary(supports[i])
			lines.append("  " + str(i + 1) + ". " + _support_name(support) + " Lv" + str(_int(support.get("level", 1))) + " T" + str(_int(support.get("tier", 1))))
		else:
			lines.append("  " + str(i + 1) + ". [empty]")
	return "\n".join(lines)

func _right_text() -> String:
	var lines: PackedStringArray = PackedStringArray()
	var active: Dictionary = SkillGemSystemScript.selected_active_gem(state_ref)
	lines.append("[b][color=#caa24a]COMPATIBLE SUPPORTS[/color][/b]")
	if active.is_empty():
		lines.append("No active skill selected.")
	else:
		var shown: int = 0
		for support_id: String in SkillGemSystemScript.SUPPORT_ORDER:
			var support: Dictionary = SkillGemSystemScript.support_instance(support_id)
			if SkillGemSystemScript.is_support_compatible(active, support):
				var data: Dictionary = SkillGemSystemScript.support_data(support_id)
				lines.append("• " + str(data.get("name", support_id)) + "  [T" + str(data.get("tier", 1)) + "]")
				lines.append("  " + str(data.get("description", "")))
				shown += 1
				if shown >= 8:
					break
		if shown == 0:
			lines.append("No compatible support found.")
	lines.append("")
	lines.append("[b][color=#caa24a]SPIRIT GEMS[/color][/b]")
	lines.append("Reserved: " + str(_int(_get_value("spirit_reserved", 0))) + "/" + str(_int(_get_value("spirit_max", 100))))
	var spirits: Array = _arr(_get_value("spirit_gem_slots", []))
	if spirits.is_empty():
		lines.append("No spirit gems installed.")
	else:
		for value: Variant in spirits:
			if typeof(value) != TYPE_DICTIONARY:
				continue
			var spirit: Dictionary = Dictionary(value)
			lines.append(("ON  " if bool(spirit.get("enabled", false)) else "off ") + _spirit_name(spirit) + " Lv" + str(_int(spirit.get("level", 1))) + " · reserves " + str(spirit.get("reservation", 0)))
	return "\n".join(lines)

func _bottom_text() -> String:
	return "[b]Controls:[/b] 1-5 select hotbar · A/D change active skill · S socket next compatible support · W remove support · G toggle spirit · Y carve uncut skill · T carve uncut support · B carve uncut spirit\n[color=#9c8a72]Sockets are earned by gem level: 2 base, +1 every 5 levels, max 6. No socket RNG/orbs.[/color]"

func _get_value(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback
	return value

func _find_row_by_uid(equipped: Array, uid_value: String) -> int:
	for i: int in range(equipped.size()):
		if typeof(equipped[i]) == TYPE_DICTIONARY and str(Dictionary(equipped[i]).get("uid", "")) == uid_value:
			return i
	return -1

func _active_name(active: Dictionary) -> String:
	return SkillGemSystemScript.active_display_name(active)

func _support_name(support: Dictionary) -> String:
	return SkillGemSystemScript.support_display_name(support)

func _spirit_name(spirit: Dictionary) -> String:
	return SkillGemSystemScript.spirit_display_name(spirit)

func _filled(values: Array) -> int:
	var out: int = 0
	for value: Variant in values:
		if typeof(value) == TYPE_DICTIONARY:
			out += 1
	return out

func _arr(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []

func _strings(values: Array) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for value: Variant in values:
		out.append(str(value))
	return out

func _int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback
