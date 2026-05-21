extends Control

const RVUIStyle := preload("res://scripts/ui/RVUIStyle3D.gd")

var _root: MarginContainer = null
var _columns: HBoxContainer = null
var _built: bool = false

func _ready() -> void:
	_build_base()

func update_from_state(state: Object) -> void:
	_build_base()
	render(state)

func bind_state(state: Object) -> void:
	update_from_state(state)

func render(_state: Object) -> void:
	pass

func _build_base() -> void:
	if _built:
		return
	_built = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	anchor_right = 1.0
	anchor_bottom = 1.0
	_root = MarginContainer.new()
	_root.name = "PanelMargin"
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.add_theme_constant_override("margin_left", 16)
	_root.add_theme_constant_override("margin_top", 16)
	_root.add_theme_constant_override("margin_right", 16)
	_root.add_theme_constant_override("margin_bottom", 16)
	add_child(_root)
	_columns = RVUIStyle.make_hbox("Columns", 14)
	_root.add_child(_columns)

func _reset_columns() -> void:
	_build_base()
	RVUIStyle.clear_children(_columns)

func _section(title: String, weight: float = 1.0) -> VBoxContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = title.replace(" ", "") + "Section"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(220.0 * weight, 120.0)
	RVUIStyle.apply_panel(panel)
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var box: VBoxContainer = RVUIStyle.make_vbox(title.replace(" ", "") + "Box", 7)
	margin.add_child(box)
	box.add_child(RVUIStyle.section_title(title))
	_columns.add_child(panel)
	return box

func _add_line(parent: VBoxContainer, text: String, size: int = 13, color: Color = Color(0.92, 0.88, 0.78, 1.0)) -> Label:
	var label: Label = RVUIStyle.label(text, size, color)
	parent.add_child(label)
	return label

func _add_rich(parent: VBoxContainer, text: String, size: int = 13) -> RichTextLabel:
	var label: RichTextLabel = RVUIStyle.rich(text, size)
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _add_button_like(parent: VBoxContainer, text: String, selected: bool = false) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.disabled = true
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	RVUIStyle.apply_button(b, selected)
	parent.add_child(b)
	return b

func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	if value == null:
		return fallback
	return value

func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []

func _as_dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}

func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return float(value)
		TYPE_FLOAT:
			return float(value)
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			return s.to_float() if s.is_valid_float() else fallback
		_:
			return fallback

func _to_int(value: Variant, fallback: int = 0) -> int:
	return int(round(_to_float(value, float(fallback))))

func _item_name(item: Dictionary) -> String:
	return str(item.get("display_name", item.get("name", item.get("base_id", "Item"))))

func _item_rarity(item: Dictionary) -> String:
	return str(item.get("rarity", "normal")).to_lower()

func _item_slot(item: Dictionary) -> String:
	return str(item.get("slot", item.get("equip_slot", item.get("category", "misc"))))

func _item_power(item: Dictionary) -> int:
	if item.has("item_power"):
		return _to_int(item.get("item_power", 0))
	if item.has("power"):
		return _to_int(item.get("power", 0))
	if item.has("item_level"):
		return _to_int(item.get("item_level", 1))
	return _to_int(item.get("level", 1))

func _stat_map(item: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for dict_key: String in ["stats", "implicit_stats", "explicit_stats", "rolled_stats"]:
		if item.has(dict_key) and typeof(item[dict_key]) == TYPE_DICTIONARY:
			var source: Dictionary = Dictionary(item[dict_key])
			for key: Variant in source.keys():
				var name: String = RVUIStyle.title_case(str(key))
				out[name] = _to_float(out.get(name, 0.0)) + _to_float(source[key])
	if item.has("affixes") and typeof(item["affixes"]) == TYPE_ARRAY:
		for affix_value: Variant in Array(item["affixes"]):
			if typeof(affix_value) != TYPE_DICTIONARY:
				continue
			var affix: Dictionary = Dictionary(affix_value)
			var stat_name: String = RVUIStyle.title_case(str(affix.get("stat", affix.get("stat_key", affix.get("id", "Affix")))))
			out[stat_name] = _to_float(out.get(stat_name, 0.0)) + _to_float(affix.get("value", affix.get("amount", 0.0)))
	return out

func _describe_item(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."
	var lines: PackedStringArray = PackedStringArray()
	var rarity: String = _item_rarity(item)
	lines.append("[color=#" + RVUIStyle.rarity_color(rarity).to_html(false) + "][b]" + _item_name(item) + "[/b][/color]")
	lines.append(rarity.capitalize() + " · " + RVUIStyle.title_case(_item_slot(item)) + " · Power " + str(_item_power(item)))
	var quality: int = _to_int(item.get("quality", -1))
	if quality >= 0:
		lines.append("Quality +" + str(quality) + "%")
	var sockets: Array = _as_array(item.get("sockets", []))
	if not sockets.is_empty():
		lines.append("Sockets: " + str(sockets.size()))
	var stats: Dictionary = _stat_map(item)
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for key: Variant in stats.keys():
			var stat_value: float = _to_float(stats[key])
			var sign: String = "+" if stat_value > 0.0 else ""
			lines.append("• " + sign + str(snappedf(stat_value, 0.01)) + " " + str(key))
	var detail: String = str(item.get("detail_text", item.get("description", "")))
	if detail != "" and lines.size() < 18:
		lines.append("")
		lines.append(detail)
	return "\n".join(lines)

func _selected_backpack_item(state: Object) -> Dictionary:
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack.is_empty():
		return {}
	var cursor: int = clampi(_to_int(_state_get(state, "inventory_cursor", 0)), 0, backpack.size() - 1)
	if typeof(backpack[cursor]) == TYPE_DICTIONARY:
		return Dictionary(backpack[cursor])
	return {}

func _materials_text(state: Object) -> String:
	var mats: Dictionary = _as_dict(_state_get(state, "materials", {}))
	if mats.is_empty():
		return "No materials"
	var parts: PackedStringArray = PackedStringArray()
	for key: Variant in mats.keys():
		parts.append(RVUIStyle.title_case(str(key)) + ": " + str(mats[key]))
		if parts.size() >= 6:
			break
	return " · ".join(parts)
