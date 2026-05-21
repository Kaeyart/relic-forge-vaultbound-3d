extends Control

const SkillGemSystemScript: GDScript = preload("res://scripts/systems/SkillGemSystem3D.gd")

const PANEL_BG: Color = Color(0.045, 0.037, 0.030, 0.96)
const PANEL_BG_2: Color = Color(0.075, 0.060, 0.045, 0.96)
const PANEL_BG_SELECTED: Color = Color(0.150, 0.095, 0.035, 0.98)
const BORDER_DARK: Color = Color(0.260, 0.205, 0.115, 1.0)
const BORDER_GOLD: Color = Color(0.750, 0.545, 0.225, 1.0)
const TEXT_MAIN: Color = Color(0.870, 0.825, 0.720, 1.0)
const TEXT_MUTED: Color = Color(0.570, 0.520, 0.430, 1.0)
const TEXT_BLUE: Color = Color(0.420, 0.620, 1.000, 1.0)
const TEXT_RED: Color = Color(0.950, 0.390, 0.230, 1.0)
const TEXT_GREEN: Color = Color(0.470, 0.850, 0.440, 1.0)

const SUPPORT_ORDER_FALLBACK: Array[String] = [
	"controlled_power",
	"efficient_casting",
	"swift_casting",
	"rapid_strikes",
	"greater_area",
	"focused_area",
	"split_projectile",
	"volley_matrix",
	"piercing_force",
	"chain_current",
	"returning_orbit",
	"ignition",
	"searing_burst",
	"shock_charge",
	"bleed_edge",
	"executioner",
	"echoing_ritual",
	"blood_price",
	"minefield",
	"remote_detonator",
	"totem_fortify",
	"cooldown_focus",
	"mana_leech",
	"life_leech"
]

var state_ref: Object = null
var left_slots: VBoxContainer = null
var center_content: VBoxContainer = null
var right_supports: VBoxContainer = null
var right_spirits: VBoxContainer = null
var footer_label: RichTextLabel = null
var header_label: Label = null


func _ready() -> void:
	_build_layout()
	_render()


func bind_state(state: Object) -> void:
	state_ref = state
	_render()


func update_from_state(state: Object) -> void:
	state_ref = state
	_render()


func mark_dirty() -> void:
	_render()


func _build_layout() -> void:
	_clear_children(self)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "SkillGemRoot"
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 18)
	root_margin.add_theme_constant_override("margin_right", 18)
	root_margin.add_theme_constant_override("margin_top", 14)
	root_margin.add_theme_constant_override("margin_bottom", 14)
	add_child(root_margin)

	var main: VBoxContainer = VBoxContainer.new()
	main.name = "Main"
	main.add_theme_constant_override("separation", 10)
	root_margin.add_child(main)

	var header_panel: PanelContainer = _make_panel(PANEL_BG, BORDER_GOLD, 2)
	header_panel.name = "Header"
	header_panel.custom_minimum_size = Vector2(0, 64)
	main.add_child(header_panel)

	var header_margin: MarginContainer = _margin(14, 8, 14, 8)
	header_panel.add_child(header_margin)

	var header_row: HBoxContainer = HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 12)
	header_margin.add_child(header_row)

	header_label = Label.new()
	header_label.text = "SKILL GEMS"
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	header_label.add_theme_font_size_override("font_size", 24)
	header_label.add_theme_color_override("font_color", BORDER_GOLD)
	header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header_label)

	var hint: RichTextLabel = _rich("[color=#c59b4a]1-4[/color] select  ·  [color=#c59b4a]A/D[/color] change active  ·  [color=#c59b4a]S[/color] add support  ·  [color=#c59b4a]W[/color] remove  ·  [color=#c59b4a]G[/color] spirit", 13)
	hint.custom_minimum_size = Vector2(680, 42)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	main.add_child(body)

	var left_panel: PanelContainer = _make_panel(PANEL_BG, BORDER_DARK, 1)
	left_panel.name = "ActiveSkillsPanel"
	left_panel.custom_minimum_size = Vector2(270, 0)
	body.add_child(left_panel)
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var left_margin: MarginContainer = _margin(12, 12, 12, 12)
	left_panel.add_child(left_margin)

	var left_main: VBoxContainer = VBoxContainer.new()
	left_main.add_theme_constant_override("separation", 8)
	left_margin.add_child(left_main)

	left_main.add_child(_section_header("ACTIVE SKILLS"))
	left_slots = VBoxContainer.new()
	left_slots.name = "ActiveSlotList"
	left_slots.add_theme_constant_override("separation", 8)
	left_slots.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_main.add_child(left_slots)

	var center_panel: PanelContainer = _make_panel(PANEL_BG, BORDER_DARK, 1)
	center_panel.name = "SelectedSkillPanel"
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_panel.custom_minimum_size = Vector2(560, 0)
	body.add_child(center_panel)

	var center_scroll: ScrollContainer = ScrollContainer.new()
	center_scroll.name = "SelectedSkillScroll"
	center_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	center_panel.add_child(center_scroll)

	var center_margin: MarginContainer = _margin(14, 14, 14, 14)
	center_scroll.add_child(center_margin)

	center_content = VBoxContainer.new()
	center_content.name = "SelectedSkillContent"
	center_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_content.add_theme_constant_override("separation", 12)
	center_margin.add_child(center_content)

	var right_panel: PanelContainer = _make_panel(PANEL_BG, BORDER_DARK, 1)
	right_panel.name = "SupportSpiritPanel"
	right_panel.custom_minimum_size = Vector2(360, 0)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(right_panel)

	var right_scroll: ScrollContainer = ScrollContainer.new()
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_panel.add_child(right_scroll)

	var right_margin: MarginContainer = _margin(12, 12, 12, 12)
	right_scroll.add_child(right_margin)

	var right_main: VBoxContainer = VBoxContainer.new()
	right_main.add_theme_constant_override("separation", 12)
	right_main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_margin.add_child(right_main)

	right_main.add_child(_section_header("COMPATIBLE SUPPORTS"))
	right_supports = VBoxContainer.new()
	right_supports.name = "CompatibleSupports"
	right_supports.add_theme_constant_override("separation", 7)
	right_main.add_child(right_supports)

	right_main.add_child(_section_header("SPIRIT RESERVATION"))
	right_spirits = VBoxContainer.new()
	right_spirits.name = "SpiritGems"
	right_spirits.add_theme_constant_override("separation", 7)
	right_main.add_child(right_spirits)

	var footer_panel: PanelContainer = _make_panel(PANEL_BG_2, BORDER_DARK, 1)
	footer_panel.name = "Footer"
	footer_panel.custom_minimum_size = Vector2(0, 44)
	main.add_child(footer_panel)

	var footer_margin: MarginContainer = _margin(12, 6, 12, 6)
	footer_panel.add_child(footer_margin)
	footer_label = _rich("", 13)
	footer_margin.add_child(footer_label)


func _render() -> void:
	if left_slots == null or center_content == null or right_supports == null or right_spirits == null:
		return
	if state_ref != null:
		SkillGemSystemScript.ensure_defaults(state_ref)
	_render_active_slots()
	_render_selected_skill()
	_render_support_column()
	_render_spirit_column()
	_render_footer()


func _render_active_slots() -> void:
	_clear_children(left_slots)
	var slots: Array = _slots()
	var selected: int = _selected_index()

	if slots.is_empty():
		left_slots.add_child(_muted_rich("No active skill slots found."))
		return

	for i: int in range(slots.size()):
		var active: Dictionary = _active_at(i)
		var supports: Array = _as_array(active.get("supports", []))
		var level: int = _to_int(active.get("level", 1), 1)
		var support_limit: int = SkillGemSystemScript.unlocked_support_sockets(level)
		var cast_data: Dictionary = _cast_for(active, i)
		var is_selected: bool = i == selected

		var button: Button = Button.new()
		button.name = "SkillSlot" + str(i + 1)
		button.text = str(i + 1) + "  " + _active_name(active) + "\nLv " + str(level) + "  ·  " + str(supports.size()) + "/" + str(support_limit) + " supports\n" + _tag_line(cast_data)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 82)
		button.add_theme_font_size_override("font_size", 13)
		button.add_theme_color_override("font_color", TEXT_MAIN if is_selected else TEXT_MUTED)
		button.add_theme_stylebox_override("normal", _style(PANEL_BG_SELECTED if is_selected else PANEL_BG_2, BORDER_GOLD if is_selected else BORDER_DARK, 2 if is_selected else 1))
		button.add_theme_stylebox_override("hover", _style(Color(0.18, 0.12, 0.05, 1.0), BORDER_GOLD, 2))
		button.pressed.connect(_select_slot.bind(i))
		left_slots.add_child(button)

	var controls: HBoxContainer = HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	left_slots.add_child(controls)
	controls.add_child(_small_button("A  Previous", _cycle_active.bind(-1)))
	controls.add_child(_small_button("D  Next", _cycle_active.bind(1)))


func _render_selected_skill() -> void:
	_clear_children(center_content)
	var active: Dictionary = _selected_active()
	if active.is_empty():
		center_content.add_child(_muted_rich("No selected active skill."))
		return

	var cast_data: Dictionary = _selected_cast()
	var active_id: String = str(active.get("gem_id", active.get("active_id", "fireball")))
	var active_data: Dictionary = Dictionary(SkillGemSystemScript.active_data(active_id))
	var level: int = _to_int(active.get("level", 1), 1)
	var xp: int = _to_int(active.get("xp", 0), 0)
	var quality: int = _to_int(active.get("quality", 0), 0)

	var hero: PanelContainer = _make_panel(PANEL_BG_2, BORDER_GOLD, 2)
	hero.custom_minimum_size = Vector2(0, 170)
	center_content.add_child(hero)
	var hero_margin: MarginContainer = _margin(14, 12, 14, 12)
	hero.add_child(hero_margin)
	var hero_v: VBoxContainer = VBoxContainer.new()
	hero_v.add_theme_constant_override("separation", 8)
	hero_margin.add_child(hero_v)

	var title: RichTextLabel = _rich("[color=#c59b4a][font_size=24]" + _active_name(active) + "[/font_size][/color]  [color=#8f8777]Level " + str(level) + " · Quality +" + str(quality) + "%[/color]", 16)
	title.custom_minimum_size = Vector2(0, 34)
	hero_v.add_child(title)

	var xp_next: int = SkillGemSystemScript.xp_to_next(level)
	var xp_bar: ProgressBar = ProgressBar.new()
	xp_bar.min_value = 0.0
	xp_bar.max_value = float(maxi(1, xp_next))
	xp_bar.value = clampf(float(xp), 0.0, float(maxi(1, xp_next)))
	xp_bar.custom_minimum_size = Vector2(0, 12)
	hero_v.add_child(xp_bar)

	var desc: String = str(active_data.get("description", "No description."))
	hero_v.add_child(_rich("[color=#8f8777]" + desc + "[/color]", 13))
	hero_v.add_child(_rich("[color=#c59b4a]Tags:[/color] " + ", ".join(_as_string_array(cast_data.get("tags", []))), 13))

	var metrics: GridContainer = GridContainer.new()
	metrics.name = "SkillMetrics"
	metrics.columns = 4
	metrics.add_theme_constant_override("h_separation", 8)
	metrics.add_theme_constant_override("v_separation", 8)
	center_content.add_child(metrics)
	metrics.add_child(_metric_card("DAMAGE", str(int(round(_f(cast_data.get("damage", 0.0)))))))
	metrics.add_child(_metric_card("MANA", str(int(round(_f(cast_data.get("mana_cost", 0.0)))))))
	metrics.add_child(_metric_card("LIFE COST", str(int(round(_f(cast_data.get("life_cost", 0.0)))))))
	metrics.add_child(_metric_card("COOLDOWN", str(snappedf(_f(cast_data.get("cooldown", 0.0)), 0.01)) + "s"))
	metrics.add_child(_metric_card("PROJECTILES", str(_to_int(cast_data.get("projectile_count", 1), 1))))
	metrics.add_child(_metric_card("CHAIN", str(_to_int(cast_data.get("chain", 0), 0))))
	metrics.add_child(_metric_card("PIERCE", str(_to_int(cast_data.get("pierce", 0), 0))))
	metrics.add_child(_metric_card("AREA", "x" + str(snappedf(_f(cast_data.get("area_mult", 1.0)), 0.01))))

	center_content.add_child(_section_header("SUPPORT SOCKETS"))
	_render_socket_row(center_content, active)

	center_content.add_child(_section_header("BEHAVIOR PREVIEW"))
	_render_behavior_preview(center_content, active, cast_data)


func _render_socket_row(parent: VBoxContainer, active: Dictionary) -> void:
	var support_row: GridContainer = GridContainer.new()
	support_row.columns = 5
	support_row.add_theme_constant_override("h_separation", 8)
	support_row.add_theme_constant_override("v_separation", 8)
	parent.add_child(support_row)

	var level: int = _to_int(active.get("level", 1), 1)
	var unlocked: int = SkillGemSystemScript.unlocked_support_sockets(level)
	var supports: Array = _as_array(active.get("supports", []))

	for i: int in range(5):
		var socket: PanelContainer = _make_panel(PANEL_BG_2, BORDER_GOLD if i < unlocked else BORDER_DARK, 1)
		socket.custom_minimum_size = Vector2(104, 72)
		var margin: MarginContainer = _margin(8, 8, 8, 8)
		socket.add_child(margin)
		var label: RichTextLabel = _rich("", 12)
		margin.add_child(label)
		if i < supports.size():
			var support: Dictionary = Dictionary(SkillGemSystemScript.normalize_support_value(supports[i]))
			label.text = "[color=#c59b4a]" + _support_name(support) + "[/color]\n[color=#8f8777]Lv " + str(_to_int(support.get("level", 1), 1)) + "[/color]"
		elif i < unlocked:
			label.text = "[color=#8f8777]Empty\nSocket " + str(i + 1) + "[/color]"
		else:
			label.text = "[color=#4c463b]Locked\nLv " + str(1 + i * 4) + "+[/color]"
		support_row.add_child(socket)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	parent.add_child(button_row)
	button_row.add_child(_small_button("S  Add Compatible Support", _add_support))
	button_row.add_child(_small_button("W  Remove Last Support", _remove_support))


func _render_behavior_preview(parent: VBoxContainer, active: Dictionary, after_cast: Dictionary) -> void:
	var base_active: Dictionary = active.duplicate(true)
	base_active["supports"] = []
	var base_cast: Dictionary = _cast_for(base_active, _selected_index())
	var preview: HBoxContainer = HBoxContainer.new()
	preview.add_theme_constant_override("separation", 8)
	parent.add_child(preview)

	preview.add_child(_preview_card("BASE SKILL", base_cast, after_cast, false))
	var arrow: Label = Label.new()
	arrow.text = "→"
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow.add_theme_font_size_override("font_size", 32)
	arrow.add_theme_color_override("font_color", BORDER_GOLD)
	arrow.custom_minimum_size = Vector2(42, 130)
	preview.add_child(arrow)
	preview.add_child(_preview_card("WITH SUPPORTS", after_cast, base_cast, true))


func _render_support_column() -> void:
	_clear_children(right_supports)
	var active: Dictionary = _selected_active()
	if active.is_empty():
		right_supports.add_child(_muted_rich("Select an active skill to inspect compatible supports."))
		return

	var supports: Array = _as_array(active.get("supports", []))
	var shown: int = 0
	for support_id: String in SUPPORT_ORDER_FALLBACK:
		var support: Dictionary = Dictionary(SkillGemSystemScript.normalize_support({"gem_id": support_id}))
		var is_compatible: bool = bool(SkillGemSystemScript.is_support_compatible(active, support))
		var is_socketed: bool = _support_list_has(supports, support_id)
		if not is_compatible and shown >= 10:
			continue
		var support_data: Dictionary = Dictionary(SkillGemSystemScript.support_data(support_id))
		var title_color: String = "#c59b4a" if is_compatible else "#62594b"
		var state_text: String = "SOCKETED" if is_socketed else ("compatible" if is_compatible else "inactive")
		var text: String = "[color=" + title_color + "]" + str(support_data.get("name", support_id.capitalize())) + "[/color]  [color=#8f8777]" + state_text + "[/color]\n"
		text += "[color=#8f8777]Requires: " + ", ".join(_as_string_array(support_data.get("requires_any", []))) + "[/color]\n"
		text += "[color=#d8d0be]" + _clamp_text(str(support_data.get("description", "")), 78) + "[/color]"
		right_supports.add_child(_info_box(text, PANEL_BG_SELECTED if is_socketed else PANEL_BG_2, BORDER_GOLD if is_socketed else BORDER_DARK))
		shown += 1
		if shown >= 14:
			break


func _render_spirit_column() -> void:
	_clear_children(right_spirits)
	if state_ref == null:
		right_spirits.add_child(_muted_rich("No state bound."))
		return
	var reserved: int = _to_int(_get_value("spirit_reserved", 0), 0)
	var maximum: int = _to_int(_get_value("spirit_max", 100), 100)
	var available: int = maxi(0, maximum - reserved)
	right_spirits.add_child(_info_box("[color=#c59b4a]Spirit[/color]  " + str(available) + " / " + str(maximum) + "\n[color=#8f8777]Reserved: " + str(reserved) + "[/color]", PANEL_BG_2, BORDER_GOLD))

	var spirits: Array = _as_array(_get_value("spirit_gem_slots", []))
	if spirits.is_empty():
		right_spirits.add_child(_muted_rich("No spirit gems installed. Press G to seed or toggle starter spirit gems."))
	else:
		for spirit_value: Variant in spirits:
			if typeof(spirit_value) != TYPE_DICTIONARY:
				continue
			var spirit: Dictionary = Dictionary(SkillGemSystemScript.normalize_spirit(Dictionary(spirit_value)))
			var enabled: bool = bool(spirit.get("enabled", false))
			var spirit_data: Dictionary = Dictionary(SkillGemSystemScript.spirit_data(str(spirit.get("gem_id", "clarity"))))
			var status: String = "ON" if enabled else "off"
			var status_color: String = "#69d66b" if enabled else "#8f8777"
			var text: String = "[color=#c59b4a]" + str(spirit_data.get("name", "Spirit")) + "[/color]  [color=" + status_color + "]" + status + "[/color]\n"
			text += "[color=#8f8777]Reserves " + str(_to_int(spirit_data.get("reservation", 25), 25)) + " spirit · Lv " + str(_to_int(spirit.get("level", 1), 1)) + "[/color]\n"
			text += "[color=#d8d0be]" + _clamp_text(str(spirit_data.get("description", "")), 74) + "[/color]"
			right_spirits.add_child(_info_box(text, PANEL_BG_SELECTED if enabled else PANEL_BG_2, BORDER_GOLD if enabled else BORDER_DARK))

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	right_spirits.add_child(button_row)
	button_row.add_child(_small_button("G  Toggle Spirit", _toggle_spirit))


func _render_footer() -> void:
	if footer_label == null:
		return
	var cast_data: Dictionary = _selected_cast()
	var rules: Dictionary = Dictionary(cast_data.get("rules", {}))
	footer_label.text = "[color=#c59b4a]Selected:[/color] " + str(cast_data.get("name", "Skill"))
	footer_label.text += "   [color=#8f8777]Damage[/color] " + str(int(round(_f(cast_data.get("damage", 0.0)))))
	footer_label.text += "   [color=#8f8777]Mana[/color] " + str(int(round(_f(cast_data.get("mana_cost", 0.0)))))
	footer_label.text += "   [color=#8f8777]Ignite[/color] " + str(int(round(_f(rules.get("ignite_chance", 0.0)) * 100.0))) + "%"
	footer_label.text += "   [color=#8f8777]Shock[/color] " + str(int(round(_f(rules.get("shock_chance", 0.0)) * 100.0))) + "%"
	footer_label.text += "   [color=#8f8777]Bleed[/color] " + str(int(round(_f(rules.get("bleed_chance", 0.0)) * 100.0))) + "%"


func _preview_card(title_text: String, cast_data: Dictionary, compare_cast: Dictionary, show_delta: bool) -> PanelContainer:
	var panel: PanelContainer = _make_panel(PANEL_BG_2, BORDER_DARK, 1)
	panel.custom_minimum_size = Vector2(240, 156)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin: MarginContainer = _margin(10, 10, 10, 10)
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)
	box.add_child(_small_title(title_text))
	box.add_child(_delta_line("Projectiles", _to_int(cast_data.get("projectile_count", 1), 1), _to_int(compare_cast.get("projectile_count", 1), 1), show_delta))
	box.add_child(_delta_line("Chain", _to_int(cast_data.get("chain", 0), 0), _to_int(compare_cast.get("chain", 0), 0), show_delta))
	box.add_child(_delta_line("Pierce", _to_int(cast_data.get("pierce", 0), 0), _to_int(compare_cast.get("pierce", 0), 0), show_delta))
	box.add_child(_delta_line("Mana", int(round(_f(cast_data.get("mana_cost", 0.0)))), int(round(_f(compare_cast.get("mana_cost", 0.0)))), show_delta, true))
	var rules: Dictionary = Dictionary(cast_data.get("rules", {}))
	var compare_rules: Dictionary = Dictionary(compare_cast.get("rules", {}))
	box.add_child(_delta_line("Ignite %", int(round(_f(rules.get("ignite_chance", 0.0)) * 100.0)), int(round(_f(compare_rules.get("ignite_chance", 0.0)) * 100.0)), show_delta))
	return panel


func _metric_card(title_text: String, value_text: String) -> PanelContainer:
	var panel: PanelContainer = _make_panel(PANEL_BG_2, BORDER_DARK, 1)
	panel.custom_minimum_size = Vector2(126, 58)
	var margin: MarginContainer = _margin(8, 7, 8, 7)
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	margin.add_child(box)
	box.add_child(_label(title_text, 11, TEXT_MUTED))
	box.add_child(_label(value_text, 17, TEXT_MAIN))
	return panel


func _delta_line(label_text: String, value: int, old_value: int, show_delta: bool, inverse_good: bool = false) -> Label:
	var label: Label = Label.new()
	var delta: int = value - old_value
	var delta_text: String = ""
	var color: Color = TEXT_MAIN
	if show_delta and delta != 0:
		delta_text = "  (" + _signed(delta) + ")"
		var positive_good: bool = delta > 0
		if inverse_good:
			positive_good = delta < 0
		color = TEXT_GREEN if positive_good else TEXT_RED
	label.text = label_text + ": " + str(value) + delta_text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", color)
	return label


func _select_slot(index: int) -> void:
	if state_ref == null:
		return
	state_ref.set("selected_skill_slot", index)
	_render()


func _cycle_active(dir: int) -> void:
	if state_ref == null:
		return
	SkillGemSystemScript.cycle_active_slot_gem(state_ref, dir)
	_render()


func _add_support() -> void:
	if state_ref == null:
		return
	SkillGemSystemScript.add_next_valid_support(state_ref)
	_render()


func _remove_support() -> void:
	if state_ref == null:
		return
	SkillGemSystemScript.remove_last_support(state_ref)
	_render()


func _toggle_spirit() -> void:
	if state_ref == null:
		return
	SkillGemSystemScript.toggle_next_spirit(state_ref)
	_render()


func _slots() -> Array:
	if state_ref == null:
		return []
	SkillGemSystemScript.ensure_defaults(state_ref)
	return _as_array(_get_value("active_skill_slots", []))


func _selected_index() -> int:
	var slots: Array = _slots()
	if slots.is_empty():
		return 0
	return clampi(_to_int(_get_value("selected_skill_slot", 0), 0), 0, slots.size() - 1)


func _selected_active() -> Dictionary:
	return _active_at(_selected_index())


func _active_at(index: int) -> Dictionary:
	var slots: Array = _slots()
	if index < 0 or index >= slots.size():
		return {}
	var raw: Variant = slots[index]
	if typeof(raw) != TYPE_DICTIONARY:
		return {}
	return Dictionary(SkillGemSystemScript.normalize_active(Dictionary(raw)))


func _selected_cast() -> Dictionary:
	if state_ref == null:
		return {}
	return Dictionary(SkillGemSystemScript.selected_cast_data(state_ref))


func _cast_for(active: Dictionary, index: int) -> Dictionary:
	if state_ref == null:
		return {}
	return Dictionary(SkillGemSystemScript.build_cast_data(state_ref, active, index))


func _active_name(active: Dictionary) -> String:
	if active.is_empty():
		return "Empty"
	return str(SkillGemSystemScript.active_display_name(active))


func _support_name(support: Dictionary) -> String:
	if support.is_empty():
		return "Empty"
	return str(SkillGemSystemScript.support_display_name(support))


func _support_list_has(supports: Array, id: String) -> bool:
	for support_value: Variant in supports:
		var support: Dictionary = Dictionary(SkillGemSystemScript.normalize_support_value(support_value))
		if str(support.get("gem_id", "")) == id:
			return true
	return false


func _tag_line(cast_data: Dictionary) -> String:
	var tags: PackedStringArray = _as_string_array(cast_data.get("tags", []))
	if tags.is_empty():
		return "untagged"
	var out: PackedStringArray = PackedStringArray()
	var count: int = mini(3, tags.size())
	for i: int in range(count):
		out.append(tags[i])
	return ", ".join(out)


func _make_panel(bg: Color, border: Color, border_width: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(bg, border, border_width))
	return panel


func _style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _margin(left: int, top: int, right: int, bottom: int) -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_bottom", bottom)
	return margin


func _section_header(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", BORDER_GOLD)
	label.custom_minimum_size = Vector2(0, 24)
	return label


func _small_title(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", BORDER_GOLD)
	return label


func _label(text: String, size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _rich(text: String, size: int) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("normal_font_size", size)
	label.add_theme_color_override("default_color", TEXT_MAIN)
	label.text = text
	return label


func _muted_rich(text: String) -> RichTextLabel:
	return _rich("[color=#8f8777]" + text + "[/color]", 13)


func _info_box(text: String, bg: Color, border: Color) -> PanelContainer:
	var panel: PanelContainer = _make_panel(bg, border, 1)
	panel.custom_minimum_size = Vector2(0, 82)
	var margin: MarginContainer = _margin(8, 7, 8, 7)
	panel.add_child(margin)
	margin.add_child(_rich(text, 12))
	return panel


func _small_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 34)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", TEXT_MAIN)
	button.add_theme_stylebox_override("normal", _style(PANEL_BG_2, BORDER_DARK, 1))
	button.add_theme_stylebox_override("hover", _style(Color(0.18, 0.12, 0.05, 1.0), BORDER_GOLD, 1))
	button.pressed.connect(callback)
	return button


func _clear_children(node: Node) -> void:
	var children: Array = node.get_children()
	for child_value: Variant in children:
		var child: Node = child_value as Node
		if child == null:
			continue
		node.remove_child(child)
		child.queue_free()


func _get_value(key: String, fallback: Variant = null) -> Variant:
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


func _as_string_array(value: Variant) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for item: Variant in _as_array(value):
		out.append(str(item))
	return out


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


func _f(value: Variant, fallback: float = 0.0) -> float:
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
			return s.to_float() if s.is_valid_float() else fallback
		_:
			return fallback


func _signed(value: int) -> String:
	if value > 0:
		return "+" + str(value)
	return str(value)


func _clamp_text(text: String, limit: int) -> String:
	if text.length() <= limit:
		return text
	return text.substr(0, maxi(0, limit - 1)) + "…"
