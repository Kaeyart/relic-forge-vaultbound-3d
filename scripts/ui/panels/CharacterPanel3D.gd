extends Control
class_name RVCharacterPanel3D

var state_ref: Object = null
var _built: bool = false

var _offense_text: RichTextLabel = null
var _skills_text: RichTextLabel = null
var _paper_doll_text: RichTextLabel = null
var _equipment_grid: GridContainer = null
var _defense_text: RichTextLabel = null
var _survival_text: RichTextLabel = null
var _resource_cards: GridContainer = null
var _build_rules_text: RichTextLabel = null
var _footer_text: Label = null

const EQUIPMENT_SLOTS: Array[String] = [
	"weapon", "offhand", "helmet", "chest", "gloves", "boots", "amulet", "ring_1", "ring_2", "belt", "relic"
]


func _ready() -> void:
	_build_ui()
	_refresh()


func bind_state(state: Object) -> void:
	state_ref = state
	_refresh()


func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh()


func mark_dirty() -> void:
	_refresh()


func _build_ui() -> void:
	if _built:
		return
	_built = true
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_STOP

	for child: Node in get_children():
		child.queue_free()

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "CharacterRoot"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 18)
	root_margin.add_theme_constant_override("margin_right", 18)
	root_margin.add_theme_constant_override("margin_top", 16)
	root_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(root_margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.name = "RootVBox"
	root.add_theme_constant_override("separation", 10)
	root_margin.add_child(root)

	var header: HBoxContainer = HBoxContainer.new()
	header.name = "Header"
	header.add_theme_constant_override("separation", 10)
	root.add_child(header)

	var title: Label = _make_label("CHARACTER", 24, _gold())
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var hint: Label = _make_label("Build overview · offense left · equipment center · defense right · rules below", 13, _muted())
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	root.add_child(body)

	_build_left_column(body)
	_build_center_column(body)
	_build_right_column(body)

	_build_bottom_section(root)

	_footer_text = _make_label("Character screen target: readable power summary first, spreadsheet details later.", 12, _muted())
	_footer_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_footer_text)


func _build_left_column(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("OffenseColumn")
	panel.custom_minimum_size = Vector2(345, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	box.add_child(_make_label("OFFENSE", 17, _gold()))
	_offense_text = _make_rich_label(false)
	_offense_text.custom_minimum_size = Vector2(0, 310)
	_offense_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_offense_text)

	box.add_child(_make_label("ACTIVE SKILLS", 17, _gold()))
	_skills_text = _make_rich_label(false)
	_skills_text.custom_minimum_size = Vector2(0, 220)
	box.add_child(_skills_text)


func _build_center_column(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("CharacterCenterColumn")
	panel.custom_minimum_size = Vector2(460, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	_paper_doll_text = _make_rich_label(false)
	_paper_doll_text.custom_minimum_size = Vector2(0, 165)
	box.add_child(_paper_doll_text)

	box.add_child(_make_label("EQUIPMENT", 17, _gold()))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	_equipment_grid = GridContainer.new()
	_equipment_grid.columns = 2
	_equipment_grid.add_theme_constant_override("h_separation", 8)
	_equipment_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_equipment_grid)


func _build_right_column(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("DefenseColumn")
	panel.custom_minimum_size = Vector2(365, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	box.add_child(_make_label("DEFENSE", 17, _gold()))
	_defense_text = _make_rich_label(false)
	_defense_text.custom_minimum_size = Vector2(0, 300)
	_defense_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_defense_text)

	box.add_child(_make_label("SURVIVABILITY", 17, _gold()))
	_survival_text = _make_rich_label(false)
	_survival_text.custom_minimum_size = Vector2(0, 235)
	box.add_child(_survival_text)


func _build_bottom_section(parent: VBoxContainer) -> void:
	var bottom: HBoxContainer = HBoxContainer.new()
	bottom.name = "BottomSummary"
	bottom.custom_minimum_size = Vector2(0, 170)
	bottom.add_theme_constant_override("separation", 12)
	parent.add_child(bottom)

	var resource_panel: PanelContainer = _make_panel("ResourceCardsPanel")
	resource_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(resource_panel)
	var resource_margin: MarginContainer = _panel_margin()
	resource_panel.add_child(resource_margin)
	var resource_box: VBoxContainer = VBoxContainer.new()
	resource_box.add_theme_constant_override("separation", 7)
	resource_margin.add_child(resource_box)
	resource_box.add_child(_make_label("RESOURCE SUMMARY", 16, _gold()))
	_resource_cards = GridContainer.new()
	_resource_cards.columns = 4
	_resource_cards.add_theme_constant_override("h_separation", 8)
	_resource_cards.add_theme_constant_override("v_separation", 8)
	resource_box.add_child(_resource_cards)

	var rules_panel: PanelContainer = _make_panel("BuildRulesPanel")
	rules_panel.custom_minimum_size = Vector2(490, 0)
	bottom.add_child(rules_panel)
	var rules_margin: MarginContainer = _panel_margin()
	rules_panel.add_child(rules_margin)
	var rules_box: VBoxContainer = VBoxContainer.new()
	rules_box.add_theme_constant_override("separation", 7)
	rules_margin.add_child(rules_box)
	rules_box.add_child(_make_label("BUILD BONUSES & RULES", 16, _gold()))
	_build_rules_text = _make_rich_label(false)
	_build_rules_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rules_box.add_child(_build_rules_text)


func _refresh() -> void:
	if not _built:
		_build_ui()
	_refresh_header_center()
	_refresh_offense()
	_refresh_skills()
	_refresh_equipment()
	_refresh_defense()
	_refresh_survival()
	_refresh_resource_cards()
	_refresh_rules()


func _refresh_header_center() -> void:
	if _paper_doll_text == null:
		return
	var class_name: String = str(_state_get("class_display_name", _state_get("class_name", "Vaultbound")))
	var level: int = _to_int(_state_get("level", 1))
	var xp: int = _to_int(_state_get("xp", 0))
	var next_xp: int = 100
	if state_ref != null and state_ref.has_method("xp_to_next"):
		next_xp = maxi(1, _to_int(state_ref.call("xp_to_next")))
	else:
		next_xp = maxi(1, _to_int(_state_get("xp_to_next", 100)))
	var xp_ratio: float = clampf(float(xp) / float(next_xp), 0.0, 1.0)
	var xp_bar: String = _bar(xp_ratio, 18)
	_paper_doll_text.text = "[center][font_size=20][color=#c59b4a]" + class_name + "[/color][/font_size]\n" + "Level " + str(level) + " · XP " + str(xp) + "/" + str(next_xp) + "\n" + xp_bar + "\n\n[color=#8f8777]Final art target: central character paper-doll with equipment orbiting the silhouette.[/color][/center]"


func _refresh_offense() -> void:
	if _offense_text == null:
		return
	var stats: Dictionary = _build_stats()
	var lines: PackedStringArray = PackedStringArray()
	lines.append(_stat_line("Attack Power", _stat_total(stats, "attack_damage", "Attack Damage"), "%"))
	lines.append(_stat_line("Spell Power", _stat_total(stats, "spell_damage", "Spell Damage"), "%"))
	lines.append(_stat_line("Projectile Damage", _stat_total(stats, "projectile_damage", "Projectile Damage"), "%"))
	lines.append(_stat_line("Physical Damage", _stat_total(stats, "physical_damage", "Physical Damage"), "%"))
	lines.append(_stat_line("Fire Damage", _stat_total(stats, "fire_damage", "Fire Damage"), "%"))
	lines.append(_stat_line("Lightning Damage", _stat_total(stats, "lightning_damage", "Lightning Damage"), "%"))
	lines.append(_stat_line("Void Damage", _stat_total(stats, "void_damage", "Void Damage"), "%"))
	lines.append(_stat_line("Crit Chance", _stat_total(stats, "crit_chance", "Crit Chance"), "%"))
	lines.append(_stat_line("Crit Damage", _stat_total(stats, "crit_damage", "Crit Damage"), "%"))
	lines.append(_stat_line("Cooldown Recovery", _stat_total(stats, "cooldown_recovery", "Cooldown Recovery"), "%"))
	_offense_text.text = "\n".join(lines)


func _refresh_skills() -> void:
	if _skills_text == null:
		return
	var slots: Array = _as_array(_state_get("active_skill_slots", []))
	var selected: int = _to_int(_state_get("selected_skill_slot", 0))
	var lines: PackedStringArray = PackedStringArray()
	if slots.is_empty():
		lines.append("[color=#8f8777]No active skills found.[/color]")
	else:
		for i: int in range(slots.size()):
			if typeof(slots[i]) != TYPE_DICTIONARY:
				continue
			var slot: Dictionary = Dictionary(slots[i])
			var active_id: String = str(slot.get("gem_id", slot.get("active", slot.get("active_id", "skill"))))
			var level: int = _to_int(slot.get("level", slot.get("gem_level", 1)))
			var supports: int = _as_array(slot.get("supports", [])).size()
			var marker: String = "[color=#c59b4a]◆[/color] " if i == selected else "◇ "
			lines.append(marker + str(i + 1) + " · " + active_id.replace("_", " ").capitalize() + " · Lv " + str(level) + " · +" + str(supports))
	_skills_text.text = "\n".join(lines)


func _refresh_equipment() -> void:
	if _equipment_grid == null:
		return
	for child: Node in _equipment_grid.get_children():
		child.queue_free()
	var equipped: Dictionary = _equipped()
	for slot: String in EQUIPMENT_SLOTS:
		var card: PanelContainer = _make_panel("Slot_" + slot)
		card.custom_minimum_size = Vector2(198, 72)
		_equipment_grid.add_child(card)
		var margin: MarginContainer = _panel_margin()
		card.add_child(margin)
		var text: RichTextLabel = _make_rich_label(false)
		text.fit_content = true
		margin.add_child(text)
		var item_name: String = "— empty —"
		var rarity: String = ""
		if equipped.has(slot) and typeof(equipped[slot]) == TYPE_DICTIONARY:
			var item: Dictionary = Dictionary(equipped[slot])
			item_name = str(item.get("display_name", item.get("name", "Item")))
			rarity = str(item.get("rarity", "normal")).capitalize()
		text.text = "[color=#c59b4a]" + _pretty_slot(slot) + "[/color]\n" + item_name + ("\n[color=#8f8777]" + rarity + "[/color]" if rarity != "" else "")


func _refresh_defense() -> void:
	if _defense_text == null:
		return
	var stats: Dictionary = _build_stats()
	var lines: PackedStringArray = PackedStringArray()
	lines.append(_stat_line("Armor", _state_float("armor", _stat_total(stats, "armor", "Armor")), ""))
	lines.append(_stat_line("Block Chance", _stat_total(stats, "block_chance", "Block Chance"), "%"))
	lines.append(_stat_line("Movement Speed", _state_float("move_speed", 1.0) * 100.0, "%"))
	lines.append(_stat_line("Fire Resistance", _stat_total(stats, "fire_resistance", "Fire Resistance"), "%"))
	lines.append(_stat_line("Cold Resistance", _stat_total(stats, "cold_resistance", "Cold Resistance"), "%"))
	lines.append(_stat_line("Lightning Resistance", _stat_total(stats, "lightning_resistance", "Lightning Resistance"), "%"))
	lines.append(_stat_line("Void Resistance", _stat_total(stats, "void_resistance", "Void Resistance"), "%"))
	lines.append(_stat_line("Damage Reduction", _stat_total(stats, "damage_reduction", "Damage Reduction"), "%"))
	_defense_text.text = "\n".join(lines)


func _refresh_survival() -> void:
	if _survival_text == null:
		return
	var stats: Dictionary = _build_stats()
	var lines: PackedStringArray = PackedStringArray()
	lines.append(_stat_line("Maximum Life", _state_float("max_hp", _state_float("max_health", 100.0)), ""))
	lines.append(_stat_line("Current Life", _state_float("player_hp", 0.0), ""))
	lines.append(_stat_line("Maximum Mana", _state_float("max_mana", 100.0), ""))
	lines.append(_stat_line("Current Mana", _state_float("player_mana", 0.0), ""))
	lines.append(_stat_line("Maximum Spirit", _state_float("spirit_max", 100.0), ""))
	lines.append(_stat_line("Reserved Spirit", _state_float("spirit_reserved", 0.0), ""))
	lines.append(_stat_line("Life Regen", _stat_total(stats, "health_regen", "Life Regeneration"), ""))
	lines.append(_stat_line("Mana Regen", _stat_total(stats, "mana_regen", "Mana Regeneration"), ""))
	_survival_text.text = "\n".join(lines)


func _refresh_resource_cards() -> void:
	if _resource_cards == null:
		return
	for child: Node in _resource_cards.get_children():
		child.queue_free()
	_add_summary_card("LIFE", str(_to_int(_state_get("player_hp", 0))) + " / " + str(_to_int(_state_get("max_hp", _state_get("max_health", 100)))))
	_add_summary_card("MANA", str(_to_int(_state_get("player_mana", 0))) + " / " + str(_to_int(_state_get("max_mana", 100))))
	var spirit_available: int = maxi(0, _to_int(_state_get("spirit_max", 100)) - _to_int(_state_get("spirit_reserved", 0)))
	_add_summary_card("SPIRIT", str(spirit_available) + " / " + str(_to_int(_state_get("spirit_max", 100))))
	_add_summary_card("ARMOR", str(_to_int(_state_get("armor", 0))))
	_add_summary_card("GOLD", str(_to_int(_state_get("gold", 0))))
	_add_summary_card("MAPS", str(_as_array(_state_get("map_stash", [])).size()))
	_add_summary_card("GEAR", str(_equipped_count()) + "/" + str(EQUIPMENT_SLOTS.size()))
	_add_summary_card("BUILD", str(_build_stats().size()) + " stats")


func _add_summary_card(title: String, value: String) -> void:
	var card: PanelContainer = _make_panel("Summary_" + title)
	card.custom_minimum_size = Vector2(125, 54)
	_resource_cards.add_child(card)
	var margin: MarginContainer = _panel_margin()
	card.add_child(margin)
	var label: RichTextLabel = _make_rich_label(false)
	label.fit_content = true
	label.text = "[color=#c59b4a]" + title + "[/color]\n" + value
	margin.add_child(label)


func _refresh_rules() -> void:
	if _build_rules_text == null:
		return
	var rules: Array = _as_array(_state_get("build_rules", []))
	var lines: PackedStringArray = PackedStringArray()
	if rules.is_empty():
		lines.append("[color=#8f8777]No explicit build rules exposed yet.[/color]")
		lines.append("Future target: class identity, relic bonuses, forge rules, unique item effects.")
	else:
		for rule: Variant in rules:
			lines.append("◆ " + str(rule))
	_build_rules_text.text = "\n".join(lines)


func _equipped() -> Dictionary:
	var value: Variant = _state_get("equipped", {})
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


func _build_stats() -> Dictionary:
	var value: Variant = _state_get("build_stats", {})
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


func _equipped_count() -> int:
	var equipped: Dictionary = _equipped()
	var count: int = 0
	for slot: String in EQUIPMENT_SLOTS:
		if equipped.has(slot) and typeof(equipped[slot]) == TYPE_DICTIONARY:
			count += 1
	return count


func _stat_total(stats: Dictionary, snake_key: String, title_key: String) -> float:
	return _to_float(stats.get(snake_key, stats.get(title_key, 0.0)))


func _state_float(key: String, fallback: float = 0.0) -> float:
	return _to_float(_state_get(key, fallback), fallback)


func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback
	return value


func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []


func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback


func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return float(value)
		TYPE_INT:
			return float(value)
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		_:
			return fallback


func _stat_line(label: String, value: float, suffix: String) -> String:
	return "[color=#8f8777]" + label + "[/color]  [color=#d8d0be]" + str(snappedf(value, 0.01)) + suffix + "[/color]"


func _bar(ratio: float, segments: int) -> String:
	var filled: int = clampi(int(round(ratio * float(segments))), 0, segments)
	var out: String = ""
	for i: int in range(segments):
		out += "█" if i < filled else "░"
	return out


func _pretty_slot(slot: String) -> String:
	return slot.replace("_", " ").capitalize()


func _make_rich_label(scroll: bool) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = false
	label.scroll_active = scroll
	label.add_theme_font_size_override("normal_font_size", 13)
	label.add_theme_color_override("default_color", _text())
	return label


func _make_label(text_value: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_panel(panel_name: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = panel_name
	panel.add_theme_stylebox_override("panel", _panel_style(false))
	return panel


func _panel_margin() -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	return margin


func _panel_style(selected: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.047, 0.038, 0.94)
	style.border_color = Color(0.55, 0.40, 0.18, 1.0) if selected else Color(0.22, 0.17, 0.10, 1.0)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _gold() -> Color:
	return Color(0.84, 0.64, 0.30, 1.0)


func _text() -> Color:
	return Color(0.82, 0.78, 0.68, 1.0)


func _muted() -> Color:
	return Color(0.56, 0.52, 0.44, 1.0)
