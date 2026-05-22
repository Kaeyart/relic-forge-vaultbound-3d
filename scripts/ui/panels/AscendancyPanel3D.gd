extends Control

const AscDBScript: GDScript = preload("res://scripts/data/AscendancyDB3D.gd")
const ClassSystemScript: GDScript = preload("res://scripts/systems/CharacterClassSystem3D.gd")
const AscSystemScript: GDScript = preload("res://scripts/systems/AscendancySystem3D.gd")
const ClassProgressionScript: GDScript = preload("res://scripts/systems/ClassProgressionSystem3D.gd")

var state_ref: Object = null
var _root: HBoxContainer = null
var _selected_node_id: String = ""
var _last_signature: String = ""

func _ready() -> void:
	_build()

func bind_state(state: Object) -> void:
	state_ref = state
	_render(true)

func update_from_state(state: Object) -> void:
	state_ref = state
	_render(false)

func _build() -> void:
	if _root != null and is_instance_valid(_root):
		return
	_root = HBoxContainer.new()
	_root.name = "AscendancyRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_theme_constant_override("separation", 10)
	add_child(_root)

func _signature() -> String:
	if state_ref == null:
		return ""
	var allocated_size: int = 0
	var allocated_value: Variant = state_ref.get("allocated_ascendancy_nodes")
	if typeof(allocated_value) == TYPE_DICTIONARY:
		allocated_size = Dictionary(allocated_value).size()
	return str(state_ref.get("class_id")) + "|" + str(state_ref.get("selected_ascendancy_id")) + "|" + str(state_ref.get("ascendancy_points")) + "|" + str(allocated_size) + "|" + _selected_node_id

func _render(force: bool = false) -> void:
	_build()
	if state_ref == null:
		return
	ClassProgressionScript.ensure_progression_defaults(state_ref)
	var sig: String = _signature()
	if not force and sig == _last_signature:
		return
	_last_signature = sig
	for child: Node in _root.get_children():
		child.queue_free()
	_root.add_child(_left_panel())
	_root.add_child(_center_panel())
	_root.add_child(_right_panel())

func _left_panel() -> Control:
	var panel: VBoxContainer = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(260, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_constant_override("separation", 8)
	panel.add_child(_label("[font_size=19][color=#c59b4a][b]ASCENDANCY[/b][/color][/font_size]\n[color=#8f8777]Subclass identity layer[/color]", 13))
	panel.add_child(_label(ClassSystemScript.class_summary_text(state_ref), 12))
	panel.add_child(_label("[color=#c59b4a][b]Choose one[/b][/color]", 12))
	var selected: String = str(state_ref.get("selected_ascendancy_id"))
	for asc_id: String in AscSystemScript.available_ascendancies(state_ref):
		var data: Dictionary = AscDBScript.ascendancy_data(asc_id)
		var btn: Button = _button(("✓ " if selected == asc_id else "Choose ") + str(data.get("name", asc_id.capitalize())), Callable(self, "_choose").bind(asc_id))
		btn.tooltip_text = str(data.get("description", ""))
		btn.disabled = selected != "" and selected != asc_id
		panel.add_child(btn)
	panel.add_child(_label("[color=#8f8777]" + AscSystemScript.summary_text(state_ref) + "[/color]", 12))
	return panel

func _center_panel() -> Control:
	var panel: VBoxContainer = VBoxContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_constant_override("separation", 6)
	var selected: String = str(state_ref.get("selected_ascendancy_id"))
	if selected == "":
		panel.add_child(_label("[color=#8f8777]Pick an ascendancy on the left. This is locked for the current demo character so the subclass choice has weight.[/color]", 13))
		return panel
	var data: Dictionary = AscDBScript.ascendancy_data(selected)
	panel.add_child(_label("[font_size=17][color=#c59b4a][b]" + str(data.get("name", selected.capitalize())) + " TREE[/b][/color][/font_size]\n" + str(data.get("description", "")), 13))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)
	var list: VBoxContainer = VBoxContainer.new()
	list.add_theme_constant_override("separation", 5)
	scroll.add_child(list)
	for node: Dictionary in AscSystemScript.nodes_for_selected(state_ref):
		list.add_child(_node_row(node))
	return panel

func _right_panel() -> Control:
	var panel: VBoxContainer = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(330, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_constant_override("separation", 8)
	panel.add_child(_label("[font_size=17][color=#c59b4a][b]DETAIL[/b][/color][/font_size]", 13))
	var node: Dictionary = AscDBScript.node(_selected_node_id)
	if node.is_empty():
		panel.add_child(_label("[color=#8f8777]Select an ascendancy node. Minor nodes are glue; major nodes should be gameplay hooks.[/color]", 12))
	else:
		panel.add_child(_detail_text(node))
		var allocated: Dictionary = Dictionary(state_ref.get("allocated_ascendancy_nodes"))
		if allocated.has(_selected_node_id):
			var refund: Button = _button("Refund selected", Callable(self, "_refund").bind(_selected_node_id))
			refund.disabled = not AscSystemScript.can_refund(state_ref, _selected_node_id)
			panel.add_child(refund)
		else:
			var alloc: Button = _button("Allocate selected", Callable(self, "_allocate").bind(_selected_node_id))
			alloc.disabled = not AscSystemScript.can_allocate(state_ref, _selected_node_id)
			panel.add_child(alloc)
	panel.add_child(_label("[color=#c59b4a][b]Validation[/b][/color]\n" + AscSystemScript.validation_report(state_ref), 11))
	return panel

func _node_row(node: Dictionary) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var id: String = str(node.get("id", ""))
	var allocated: bool = bool(node.get("allocated", false))
	var can_allocate: bool = bool(node.get("can_allocate", false))
	var status: String = "✓" if allocated else ("+" if can_allocate else "·")
	var label: String = status + " " + str(node.get("name", "Node")) + " [" + str(node.get("type", "")) + "]"
	var select: Button = _button(label, Callable(self, "_select_node").bind(id))
	select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select.alignment = HORIZONTAL_ALIGNMENT_LEFT
	select.tooltip_text = str(node.get("description", ""))
	row.add_child(select)
	if allocated:
		var refund: Button = _button("Refund", Callable(self, "_refund").bind(id))
		refund.disabled = not bool(node.get("can_refund", false))
		row.add_child(refund)
	else:
		var alloc: Button = _button("Allocate", Callable(self, "_allocate").bind(id))
		alloc.disabled = not can_allocate
		row.add_child(alloc)
	return row

func _detail_text(node: Dictionary) -> RichTextLabel:
	var text: String = "[font_size=16][color=#d8d0be][b]" + str(node.get("name", "Node")) + "[/b][/color][/font_size]\n"
	text += "[color=#8f8777]" + str(node.get("type", "")) + " · cost " + str(int(node.get("cost", 1))) + "[/color]\n"
	text += "Requires: " + _requires_text(node) + "\n\n"
	text += "[color=#c59b4a]Stats[/color]\n" + _stats_lines(Dictionary(node.get("stats", {}))) + "\n"
	var rules: Array = Array(node.get("rules", []))
	text += "[color=#c59b4a]Rules[/color]\n" + (("- " + "\n- ".join(rules)) if not rules.is_empty() else "none") + "\n"
	var desc: String = str(node.get("description", ""))
	if desc != "":
		text += "\n[color=#8f8777]" + desc + "[/color]"
	var err: String = AscSystemScript.allocation_error(state_ref, str(node.get("id", "")))
	if err != "" and not Dictionary(state_ref.get("allocated_ascendancy_nodes")).has(str(node.get("id", ""))):
		text += "\n\n[color=#d65a32]" + err + "[/color]"
	return _label(text, 12)

func _choose(asc_id: String) -> void:
	var msg: String = AscSystemScript.choose_ascendancy(state_ref, asc_id)
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", msg)
	_selected_node_id = ""
	_last_signature = ""
	_render(true)

func _select_node(node_id: String) -> void:
	_selected_node_id = node_id
	_last_signature = ""
	_render(true)

func _allocate(node_id: String) -> void:
	var msg: String = AscSystemScript.allocate(state_ref, node_id)
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", msg)
	_selected_node_id = node_id
	_last_signature = ""
	_render(true)

func _refund(node_id: String) -> void:
	var msg: String = AscSystemScript.refund(state_ref, node_id)
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", msg)
	_selected_node_id = node_id
	_last_signature = ""
	_render(true)

func _requires_text(node: Dictionary) -> String:
	var reqs: Array = Array(node.get("requires", []))
	if reqs.is_empty():
		return "none"
	var names: Array[String] = []
	for req: Variant in reqs:
		var rn: Dictionary = AscDBScript.node(str(req))
		names.append(str(rn.get("name", str(req))))
	return ", ".join(names)

func _stats_lines(stats: Dictionary) -> String:
	if stats.is_empty():
		return "none"
	var parts: Array[String] = []
	for key: Variant in stats.keys():
		parts.append("- " + str(key) + ": " + str(stats[key]))
	return "\n".join(parts)

func _button(text: String, cb: Callable) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(cb)
	return btn

func _label(text: String, font_size: int) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = text
	label.add_theme_font_size_override("normal_font_size", font_size)
	return label
