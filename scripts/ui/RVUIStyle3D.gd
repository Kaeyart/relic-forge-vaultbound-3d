class_name RVUIStyle3D
extends RefCounted

# Patch 05 UI foundation: code-side visual grammar for prototype UI.
# No external art required. The goal is hierarchy, spacing, and readable state.

static func color_bg() -> Color:
	return Color(0.035, 0.032, 0.029, 0.96)

static func color_panel() -> Color:
	return Color(0.075, 0.065, 0.055, 0.96)

static func color_panel_alt() -> Color:
	return Color(0.105, 0.088, 0.070, 0.96)

static func color_border() -> Color:
	return Color(0.42, 0.31, 0.16, 0.72)

static func color_gold() -> Color:
	return Color(1.0, 0.73, 0.26, 1.0)

static func color_text() -> Color:
	return Color(0.92, 0.88, 0.78, 1.0)

static func color_muted() -> Color:
	return Color(0.63, 0.58, 0.50, 1.0)

static func color_bad() -> Color:
	return Color(1.0, 0.28, 0.18, 1.0)

static func color_good() -> Color:
	return Color(0.48, 0.90, 0.48, 1.0)

static func color_magic() -> Color:
	return Color(0.42, 0.62, 1.0, 1.0)

static func color_rare() -> Color:
	return Color(1.0, 0.82, 0.28, 1.0)

static func color_unique() -> Color:
	return Color(1.0, 0.48, 0.15, 1.0)

static func rarity_color(rarity: String) -> Color:
	match rarity.to_lower():
		"normal":
			return color_text()
		"magic":
			return color_magic()
		"rare":
			return color_rare()
		"unique":
			return color_unique()
		_:
			return color_text()

static func make_style(bg: Color, border: Color, radius: int = 10, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style

static func apply_panel(panel: Control, variant: String = "normal") -> void:
	if panel == null:
		return
	var bg: Color = color_panel()
	var border: Color = color_border()
	if variant == "alt":
		bg = color_panel_alt()
	elif variant == "danger":
		border = color_bad()
	elif variant == "selected":
		border = color_gold()
	panel.add_theme_stylebox_override("panel", make_style(bg, border, 12, 1))

static func apply_button(button: Button, selected: bool = false) -> void:
	if button == null:
		return
	var normal_bg: Color = Color(0.11, 0.095, 0.075, 0.96)
	var hover_bg: Color = Color(0.16, 0.125, 0.08, 0.98)
	var border: Color = color_gold() if selected else color_border()
	button.add_theme_stylebox_override("normal", make_style(normal_bg, border, 8, 1))
	button.add_theme_stylebox_override("hover", make_style(hover_bg, color_gold(), 8, 1))
	button.add_theme_stylebox_override("pressed", make_style(Color(0.22, 0.16, 0.08, 1.0), color_gold(), 8, 1))
	button.add_theme_color_override("font_color", color_gold() if selected else color_text())
	button.add_theme_color_override("font_hover_color", color_gold())
	button.add_theme_font_size_override("font_size", 13)

static func label(text: String, size: int = 14, color: Color = Color(0.92, 0.88, 0.78, 1.0), upper: bool = false) -> Label:
	var out: Label = Label.new()
	out.text = text.to_upper() if upper else text
	out.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	out.add_theme_font_size_override("font_size", size)
	out.add_theme_color_override("font_color", color)
	return out

static func rich(text: String, size: int = 14) -> RichTextLabel:
	var out: RichTextLabel = RichTextLabel.new()
	out.bbcode_enabled = true
	out.fit_content = true
	out.scroll_active = false
	out.text = text
	out.add_theme_font_size_override("normal_font_size", size)
	out.add_theme_color_override("default_color", color_text())
	return out

static func small_caps(text: String) -> Label:
	return label(text, 12, color_gold(), true)

static func section_title(text: String) -> Label:
	return label(text, 16, color_gold(), true)

static func make_vbox(name: String = "VBox", separation: int = 8) -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.name = name
	box.add_theme_constant_override("separation", separation)
	return box

static func make_hbox(name: String = "HBox", separation: int = 8) -> HBoxContainer:
	var box: HBoxContainer = HBoxContainer.new()
	box.name = name
	box.add_theme_constant_override("separation", separation)
	return box

static func make_margin(child: Control, margin: int = 12) -> MarginContainer:
	var out: MarginContainer = MarginContainer.new()
	out.add_theme_constant_override("margin_left", margin)
	out.add_theme_constant_override("margin_top", margin)
	out.add_theme_constant_override("margin_right", margin)
	out.add_theme_constant_override("margin_bottom", margin)
	out.add_child(child)
	return out

static func clear_children(node: Node) -> void:
	if node == null:
		return
	for child: Node in node.get_children():
		child.queue_free()

static func compact_number(value: Variant) -> String:
	var number: float = 0.0
	match typeof(value):
		TYPE_INT:
			number = float(value)
		TYPE_FLOAT:
			number = float(value)
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				number = s.to_float()
			else:
				return s
		_:
			return str(value)
	if absf(number) >= 1000000.0:
		return str(snappedf(number / 1000000.0, 0.1)) + "m"
	if absf(number) >= 1000.0:
		return str(snappedf(number / 1000.0, 0.1)) + "k"
	return str(int(round(number)))

static func title_case(raw: String) -> String:
	var parts: PackedStringArray = raw.replace("-", "_").split("_")
	var out: PackedStringArray = PackedStringArray()
	for part: String in parts:
		if part == "":
			continue
		out.append(part.substr(0, 1).to_upper() + part.substr(1).to_lower())
	return " ".join(out)
