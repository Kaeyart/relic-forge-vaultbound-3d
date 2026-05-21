extends Control
class_name RVForgePanel3D

const CraftingSystemScript: GDScript = preload("res://scripts/systems/CraftingSystem3D.gd")

var state_ref: Object = null
var _built: bool = false

var _item_title: Label = null
var _item_meta: Label = null
var _item_text: RichTextLabel = null
var _potential_text: Label = null
var _preview_text: RichTextLabel = null
var _materials_text: RichTextLabel = null
var _action_list: VBoxContainer = null
var _footer_text: Label = null
var _confirm_button: Button = null
var _selected_action: String = "seal"

var _actions: Array[Dictionary] = [
	{
		"id": "seal",
		"title": "ADD CRAFTED AFFIX",
		"key": "1",
		"cost_id": "shards",
		"cost": 2,
		"risk": "Controlled",
		"description": "Adds one crafted modifier. Limited by crafted mod count and forge potential."
	},
	{
		"id": "reforge",
		"title": "REFORGE AS RARE",
		"key": "2",
		"cost_id": "embers",
		"cost": 7,
		"risk": "Moderate",
		"description": "Rerolls the selected non-unique item as a rare item. High change, high uncertainty."
	},
	{
		"id": "polish",
		"title": "UPGRADE QUALITY",
		"key": "3",
		"cost_id": "runes",
		"cost": 1,
		"risk": "Safe",
		"description": "Improves item quality up to the current cap. Best for items worth keeping."
	},
	{
		"id": "socket_future",
		"title": "ADD SOCKET",
		"key": "4",
		"cost_id": "ore",
		"cost": 5,
		"risk": "Locked",
		"description": "Future action: add or improve sockets once socket crafting is promoted to runtime."
	},
	{
		"id": "lock_future",
		"title": "LOCK AFFIX",
		"key": "5",
		"cost_id": "seals",
		"cost": 1,
		"risk": "Locked",
		"description": "Future action: protect one affix before a dangerous forge operation."
	},
	{
		"id": "risky_future",
		"title": "RISKY FORGE",
		"key": "6",
		"cost_id": "embers",
		"cost": 20,
		"risk": "High Risk",
		"description": "Future action: restore, brick, empower, or destroy valuable items."
	}
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
	root_margin.name = "ForgeRoot"
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

	var title: Label = _make_label("FORGE", 24, _gold())
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var hint: Label = _make_label("1 Seal · 2 Reforge · 3 Polish · [ / ] select inventory item · Esc close", 13, _muted())
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(hint)

	var body: HBoxContainer = HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	root.add_child(body)

	_build_left_item_panel(body)
	_build_center_forge_panel(body)
	_build_right_action_panel(body)

	_footer_text = _make_label("Select an item in the inventory, then choose a forge action. Forge potential is the item's crafting lifespan.", 12, _muted())
	_footer_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_footer_text)


func _build_left_item_panel(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("SelectedItemPanel")
	panel.custom_minimum_size = Vector2(365, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.name = "SelectedItemVBox"
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	box.add_child(_make_label("SELECTED ITEM", 16, _gold()))
	_item_title = _make_label("No item selected", 20, Color(0.88, 0.68, 0.32, 1.0))
	_item_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_item_title)

	_item_meta = _make_label("", 12, _muted())
	_item_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_item_meta)

	var gauge_panel: PanelContainer = _make_panel("PotentialGauge")
	gauge_panel.custom_minimum_size = Vector2(0, 72)
	box.add_child(gauge_panel)

	var gauge_margin: MarginContainer = _panel_margin()
	gauge_panel.add_child(gauge_margin)
	_potential_text = _make_label("FORGE POTENTIAL —", 14, _text())
	_potential_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gauge_margin.add_child(_potential_text)

	_item_text = RichTextLabel.new()
	_item_text.name = "ItemText"
	_item_text.bbcode_enabled = true
	_item_text.fit_content = false
	_item_text.scroll_active = true
	_item_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_item_text.add_theme_font_size_override("normal_font_size", 13)
	_item_text.add_theme_color_override("default_color", _text())
	box.add_child(_item_text)


func _build_center_forge_panel(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("ForgeWorkstationPanel")
	panel.custom_minimum_size = Vector2(430, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.name = "ForgeWorkstationVBox"
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var forge_title: Label = _make_label("RELIC FORGE WORKSTATION", 16, _gold())
	forge_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(forge_title)

	var altar: PanelContainer = _make_panel("ForgeAltarMock")
	altar.custom_minimum_size = Vector2(0, 225)
	altar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(altar)

	var altar_margin: MarginContainer = _panel_margin()
	altar.add_child(altar_margin)

	var altar_text: RichTextLabel = RichTextLabel.new()
	altar_text.bbcode_enabled = true
	altar_text.fit_content = false
	altar_text.scroll_active = false
	altar_text.add_theme_font_size_override("normal_font_size", 15)
	altar_text.add_theme_color_override("default_color", _text())
	altar_text.text = "[center][b]◆ THE ANVIL OF CONTROLLED RUIN ◆[/b]\n\nItem goes in. Potential burns down.\nPower is improved by deliberate actions, not random noise.\n\n[font_size=12][color=#8f8777]Final art target: molten altar, chains, ember beam, and material sockets.[/color][/font_size][/center]"
	altar_margin.add_child(altar_text)

	box.add_child(_make_label("PREVIEW CHANGES", 16, _gold()))

	_preview_text = RichTextLabel.new()
	_preview_text.name = "PreviewText"
	_preview_text.bbcode_enabled = true
	_preview_text.fit_content = false
	_preview_text.scroll_active = true
	_preview_text.custom_minimum_size = Vector2(0, 130)
	_preview_text.add_theme_font_size_override("normal_font_size", 13)
	_preview_text.add_theme_color_override("default_color", _text())
	box.add_child(_preview_text)

	box.add_child(_make_label("REQUIRED MATERIALS", 16, _gold()))
	_materials_text = RichTextLabel.new()
	_materials_text.name = "MaterialsText"
	_materials_text.bbcode_enabled = true
	_materials_text.fit_content = true
	_materials_text.scroll_active = false
	_materials_text.custom_minimum_size = Vector2(0, 72)
	_materials_text.add_theme_font_size_override("normal_font_size", 13)
	_materials_text.add_theme_color_override("default_color", _text())
	box.add_child(_materials_text)

	_confirm_button = _make_button("CONFIRM FORGE")
	_confirm_button.custom_minimum_size = Vector2(0, 44)
	_confirm_button.pressed.connect(_craft_selected_action)
	box.add_child(_confirm_button)
	_apply_button_style(_confirm_button, true)


func _build_right_action_panel(parent: HBoxContainer) -> void:
	var panel: PanelContainer = _make_panel("ForgeActionsPanel")
	panel.custom_minimum_size = Vector2(395, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin: MarginContainer = _panel_margin()
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.name = "ForgeActionsVBox"
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	box.add_child(_make_label("FORGING ACTIONS", 16, _gold()))
	box.add_child(_make_label("Choose one operation. Only the first three are live runtime actions.", 12, _muted()))

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "ActionScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	_action_list = VBoxContainer.new()
	_action_list.name = "ActionList"
	_action_list.add_theme_constant_override("separation", 7)
	scroll.add_child(_action_list)


func _refresh() -> void:
	if not _built:
		_build_ui()

	var item: Dictionary = _selected_item()
	_refresh_item(item)
	_refresh_actions(item)
	_refresh_preview(item)
	_refresh_materials()


func _refresh_item(item: Dictionary) -> void:
	if _item_title == null:
		return

	if item.is_empty():
		_item_title.text = "No item selected"
		_item_meta.text = "Open Inventory, select a gear item, then return to the Forge."
		_potential_text.text = "FORGE POTENTIAL —"
		_item_text.text = "[color=#d65a32]No forge target.[/color]\n\nThe forge modifies equipment, not maps, currency, or gems."
		return

	var item_name: String = str(item.get("display_name", item.get("name", "Item")))
	var rarity: String = str(item.get("rarity", "normal")).capitalize()
	var slot: String = str(item.get("slot", item.get("item_kind", item.get("kind", "item")))).replace("_", " ").capitalize()
	var power: int = _to_int(item.get("item_power", item.get("power", item.get("item_level", item.get("level", 1)))))
	var quality: int = _to_int(item.get("quality", 0))
	var potential: int = _to_int(item.get("forge_potential", item.get("potential", 0)))

	_item_title.text = item_name
	_item_meta.text = rarity + " · " + slot + " · Power " + str(power) + " · Quality +" + str(quality) + "%"
	_potential_text.text = "FORGE POTENTIAL  " + _potential_bar(potential) + "  " + str(potential)
	_item_text.text = _item_detail_text(item)


func _refresh_actions(item: Dictionary) -> void:
	if _action_list == null:
		return

	for child: Node in _action_list.get_children():
		child.queue_free()

	for action: Dictionary in _actions:
		var action_id: String = str(action.get("id", ""))
		var live: bool = action_id in ["seal", "reforge", "polish"]
		var selected: bool = action_id == _selected_action
		var can_use: bool = live and _can_craft_action(item, action_id)
		var card: Button = _make_action_card(action, selected, can_use, live)
		card.pressed.connect(_select_action.bind(action_id))
		_action_list.add_child(card)

	if _confirm_button != null:
		_confirm_button.disabled = not _can_craft_action(item, _selected_action)
		_confirm_button.text = "CONFIRM FORGE · " + _action_title(_selected_action)


func _refresh_preview(item: Dictionary) -> void:
	if _preview_text == null:
		return

	if item.is_empty():
		_preview_text.text = "[color=#8f8777]No preview. Select a gear item first.[/color]"
		return

	match _selected_action:
		"seal":
			_preview_text.text = "[b]Add Crafted Affix[/b]\n• Adds one crafted modifier if limit allows.\n• Costs 1 forge potential.\n• Best for filling a controlled power gap.\n\n[color=#69a84f]Success expected:[/color] new crafted stat line."
		"reforge":
			_preview_text.text = "[b]Reforge Item[/b]\n• Rerolls the selected non-unique as a rare item.\n• Costs 1 forge potential.\n• Current affix identity may be lost.\n\n[color=#d65a32]Risk:[/color] useful item can become worse."
		"polish":
			_preview_text.text = "[b]Polish Quality[/b]\n• Improves quality toward the cap.\n• Costs 1 forge potential.\n• Safest long-term item investment.\n\n[color=#69a84f]Success expected:[/color] +quality on selected item."
		_:
			_preview_text.text = "[b]Locked Forge Action[/b]\nThis operation is a planned system target. It is shown here so the final Forge layout already has the right shape."


func _refresh_materials() -> void:
	if _materials_text == null:
		return

	var materials: Dictionary = _materials()
	var parts: PackedStringArray = PackedStringArray()
	for action: Dictionary in _actions:
		var action_id: String = str(action.get("id", ""))
		if not (action_id in ["seal", "reforge", "polish"]):
			continue
		var cost_id: String = str(action.get("cost_id", ""))
		var cost: int = _to_int(action.get("cost", 0))
		var owned: int = _to_int(materials.get(cost_id, 0))
		var color_tag: String = "#69a84f" if owned >= cost else "#d65a32"
		parts.append("[color=" + color_tag + "]" + cost_id.capitalize() + " " + str(owned) + "/" + str(cost) + "[/color]")

	if parts.is_empty():
		_materials_text.text = "No material requirements."
	else:
		_materials_text.text = "   ".join(parts)


func _select_action(action_id: String) -> void:
	_selected_action = action_id
	_refresh()


func _craft_selected_action() -> void:
	if state_ref == null:
		return
	if not (_selected_action in ["seal", "reforge", "polish"]):
		_add_notice("That forge action is not implemented yet.")
		return
	CraftingSystemScript.craft_selected(state_ref, _selected_action)
	_refresh()


func _selected_item() -> Dictionary:
	if state_ref == null:
		return {}
	if state_ref.has_method("selected_backpack_item"):
		var selected: Variant = state_ref.call("selected_backpack_item")
		if typeof(selected) == TYPE_DICTIONARY:
			return Dictionary(selected)
	var backpack: Array = _as_array(_state_get("backpack", []))
	var cursor: int = clampi(_to_int(_state_get("inventory_cursor", 0)), 0, max(0, backpack.size() - 1))
	if backpack.is_empty() or cursor < 0 or cursor >= backpack.size():
		return {}
	if typeof(backpack[cursor]) != TYPE_DICTIONARY:
		return {}
	return Dictionary(backpack[cursor])


func _can_craft_action(item: Dictionary, action_id: String) -> bool:
	if item.is_empty():
		return false
	if not _is_equipment(item):
		return false
	if _to_int(item.get("forge_potential", item.get("potential", 0))) <= 0:
		return false

	var rarity: String = str(item.get("rarity", "normal")).to_lower()
	var materials: Dictionary = _materials()

	match action_id:
		"seal":
			if _crafted_count(item) >= 2:
				return false
			return _to_int(materials.get("shards", 0)) >= 2
		"reforge":
			if rarity == "unique":
				return false
			return _to_int(materials.get("embers", 0)) >= 7
		"polish":
			if _to_int(item.get("quality", 0)) >= 20:
				return false
			return _to_int(materials.get("runes", 0)) >= 1
		_:
			return false


func _make_action_card(action: Dictionary, selected: bool, can_use: bool, live: bool) -> Button:
	var action_id: String = str(action.get("id", ""))
	var title: String = str(action.get("title", action_id))
	var key: String = str(action.get("key", ""))
	var cost_id: String = str(action.get("cost_id", ""))
	var cost: int = _to_int(action.get("cost", 0))
	var risk: String = str(action.get("risk", ""))
	var description: String = str(action.get("description", ""))
	var prefix: String = "◆ " if selected else "  "
	var state_text: String = "READY" if can_use else ("LOCKED" if not live else "BLOCKED")

	var button: Button = Button.new()
	button.name = "ForgeAction_" + action_id
	button.text = prefix + key + " · " + title + "\n" + description + "\nCost: " + str(cost) + " " + cost_id + " · Risk: " + risk + " · " + state_text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 92)
	button.disabled = false
	_apply_button_style(button, selected)
	if not live:
		button.modulate = Color(0.65, 0.65, 0.65, 0.72)
	elif not can_use:
		button.modulate = Color(0.82, 0.72, 0.65, 0.85)
	return button


func _item_detail_text(item: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	var kind: String = str(item.get("item_kind", item.get("kind", "item"))).replace("_", " ").capitalize()
	var rarity: String = str(item.get("rarity", "normal")).capitalize()
	var level: int = _to_int(item.get("item_level", item.get("level", 1)))
	var sockets: int = _to_int(item.get("sockets", 0))
	var quality: int = _to_int(item.get("quality", 0))
	var potential: int = _to_int(item.get("forge_potential", item.get("potential", 0)))

	lines.append("[b]" + rarity + " " + kind + "[/b]")
	lines.append("Item Level " + str(level) + " · Quality +" + str(quality) + "% · Sockets " + str(sockets))
	lines.append("Forge Potential " + str(potential))
	lines.append("")

	var stats: Dictionary = _extract_stats(item)
	if not stats.is_empty():
		lines.append("[color=#c59b4a]Explicit Stats[/color]")
		for key: Variant in stats.keys():
			lines.append("• " + _pretty_stat(str(key)) + " " + _signed_float(_to_float(stats[key])))
	else:
		lines.append("[color=#8f8777]No explicit stat map found.[/color]")

	var crafted: Array = _as_array(item.get("crafted_mods", []))
	if not crafted.is_empty():
		lines.append("")
		lines.append("[color=#c59b4a]Crafted Modifiers[/color]")
		for crafted_value: Variant in crafted:
			if typeof(crafted_value) == TYPE_DICTIONARY:
				var crafted_mod: Dictionary = Dictionary(crafted_value)
				lines.append("• " + str(crafted_mod.get("display", crafted_mod.get("id", "crafted modifier"))))
			else:
				lines.append("• " + str(crafted_value))

	var rules: Array = _as_array(item.get("rules", []))
	if not rules.is_empty():
		lines.append("")
		lines.append("[color=#c59b4a]Rules[/color]")
		for rule: Variant in rules:
			lines.append("• " + str(rule))

	return "\n".join(lines)


func _extract_stats(item: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for field: String in ["stats", "implicit_stats", "explicit_stats"]:
		if item.has(field) and typeof(item[field]) == TYPE_DICTIONARY:
			var stats: Dictionary = Dictionary(item[field])
			for key: Variant in stats.keys():
				out[str(key)] = _to_float(out.get(str(key), 0.0)) + _to_float(stats[key])
	if item.has("affixes") and typeof(item["affixes"]) == TYPE_ARRAY:
		for affix_value: Variant in Array(item["affixes"]):
			if typeof(affix_value) != TYPE_DICTIONARY:
				continue
			var affix: Dictionary = Dictionary(affix_value)
			var stat_key: String = str(affix.get("stat", affix.get("stat_key", affix.get("id", ""))))
			if stat_key == "":
				continue
			out[stat_key] = _to_float(out.get(stat_key, 0.0)) + _to_float(affix.get("value", affix.get("amount", 0.0)))
	return out


func _is_equipment(item: Dictionary) -> bool:
	var kind: String = str(item.get("item_kind", item.get("kind", item.get("category", "")))).to_lower()
	if kind in ["map", "currency", "material", "active_gem", "support_gem", "spirit_gem", "active_gem_gem", "support_gem_gem", "spirit_gem_gem"]:
		return false
	if str(item.get("category", "")).to_lower() == "skill_gem":
		return false
	return true


func _crafted_count(item: Dictionary) -> int:
	return _as_array(item.get("crafted_mods", [])).size()


func _materials() -> Dictionary:
	if state_ref == null:
		return {}
	var value: Variant = state_ref.get("materials")
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}


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


func _potential_bar(value: int) -> String:
	var max_segments: int = 6
	var filled: int = clampi(value, 0, max_segments)
	var out: String = ""
	for i: int in range(max_segments):
		out += "◆" if i < filled else "◇"
	return out


func _action_title(action_id: String) -> String:
	for action: Dictionary in _actions:
		if str(action.get("id", "")) == action_id:
			return str(action.get("title", action_id))
	return action_id.capitalize()


func _pretty_stat(key: String) -> String:
	return key.replace("_", " ").replace("-", " ").capitalize()


func _signed_float(value: float) -> String:
	var rounded_value: float = snappedf(value, 0.01)
	if rounded_value > 0.0:
		return "+" + str(rounded_value)
	return str(rounded_value)


func _add_notice(text: String) -> void:
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", text)


func _make_label(text_value: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_button(text_value: String) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", _text())
	button.add_theme_color_override("font_hover_color", _gold())
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.45, 1.0))
	return button


func _make_panel(panel_name: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = panel_name
	panel.add_theme_stylebox_override("panel", _panel_style(false))
	return panel


func _panel_margin() -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	return margin


func _apply_button_style(button: Button, selected: bool = false) -> void:
	button.add_theme_stylebox_override("normal", _button_style(selected, false))
	button.add_theme_stylebox_override("hover", _button_style(true, false))
	button.add_theme_stylebox_override("pressed", _button_style(true, true))
	button.add_theme_stylebox_override("disabled", _button_style(false, false))


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


func _button_style(selected: bool, pressed: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if pressed:
		style.bg_color = Color(0.26, 0.16, 0.07, 0.96)
	elif selected:
		style.bg_color = Color(0.18, 0.12, 0.055, 0.96)
	else:
		style.bg_color = Color(0.075, 0.062, 0.048, 0.94)
	style.border_color = Color(0.78, 0.56, 0.24, 1.0) if selected else Color(0.24, 0.18, 0.11, 1.0)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(7)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _gold() -> Color:
	return Color(0.84, 0.64, 0.30, 1.0)


func _text() -> Color:
	return Color(0.82, 0.78, 0.68, 1.0)


func _muted() -> Color:
	return Color(0.56, 0.52, 0.44, 1.0)
