extends Control

const ClassSystemScript: GDScript = preload("res://scripts/systems/CharacterClassSystem3D.gd")
const ClassProgressionScript: GDScript = preload("res://scripts/systems/ClassProgressionSystem3D.gd")
const PassiveTreeSystemScript: GDScript = preload("res://scripts/systems/PassiveTreeSystem3D.gd")
const PassiveDBScript: GDScript = preload("res://scripts/data/PassiveTreeDB3D.gd")

var state_ref: Object = null
var _root: HBoxContainer = null
var _filter_mode: String = "class"
var _search_query: String = ""
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
	_root.name = "PassiveTreeRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_theme_constant_override("separation", 10)
	add_child(_root)

func _signature() -> String:
	if state_ref == null:
		return ""
	var allocated_size: int = 0
	var allocated_value: Variant = state_ref.get("allocated_passive_nodes")
	if typeof(allocated_value) == TYPE_DICTIONARY:
		allocated_size = Dictionary(allocated_value).size()
	return str(state_ref.get("class_id")) + "|" + str(state_ref.get("passive_points")) + "|" + str(allocated_size) + "|" + _filter_mode + "|" + _search_query + "|" + _selected_node_id

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
	_root.add_child(_build_left())
	_root.add_child(_build_center())
	_root.add_child(_build_right())

func _build_left() -> Control:
	var panel: VBoxContainer = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(230, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_constant_override("separation", 8)
	panel.add_child(_label("[font_size=19][color=#c59b4a][b]PASSIVE TREE[/b][/color][/font_size]\n[color=#8f8777]Identity expansion V1[/color]", 13))
	panel.add_child(_label(ClassSystemScript.class_summary_text(state_ref), 12))

	var class_title: RichTextLabel = _label("[color=#c59b4a][b]Class testing[/b][/color]", 12)
	panel.add_child(class_title)
	for class_id: String in ClassSystemScript.class_ids():
		var data: Dictionary = Dictionary(ClassSystemScript.classes()[class_id])
		var btn: Button = _button(str(data.get("display_name", class_id.capitalize())), Callable(self, "_switch_class").bind(class_id))
		btn.disabled = str(state_ref.get("class_id")) == class_id
		panel.add_child(btn)

	panel.add_child(_label("[color=#c59b4a][b]Filters[/b][/color]", 12))
	for pair: Dictionary in [
		{"id":"class", "label":"Current Class + Center"},
		{"id":"available", "label":"Available Now"},
		{"id":"allocated", "label":"Allocated"},
		{"id":"sorceress", "label":"Sorceress"},
		{"id":"warrior", "label":"Warrior"},
		{"id":"huntress", "label":"Huntress"},
		{"id":"center", "label":"Center / Forge"},
		{"id":"keystone", "label":"Keystones"},
		{"id":"all", "label":"All Nodes"},
	]:
		var f: Button = _button(("✓ " if _filter_mode == str(pair["id"]) else "") + str(pair["label"]), Callable(self, "_set_filter").bind(str(pair["id"])))
		panel.add_child(f)

	var search: LineEdit = LineEdit.new()
	search.placeholder_text = "Search tags/rules/stats"
	search.text = _search_query
	search.text_submitted.connect(Callable(self, "_set_search"))
	search.text_changed.connect(Callable(self, "_set_search_live"))
	panel.add_child(search)

	panel.add_child(_label("[color=#8f8777]" + PassiveTreeSystemScript.summary_text(state_ref) + "[/color]", 12))
	return panel

func _build_center() -> Control:
	var container: VBoxContainer = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 6)
	var shown: Array[Dictionary] = PassiveTreeSystemScript.nodes_for_ui_filtered(state_ref, _filter_mode, _search_query)
	container.add_child(_label("[color=#c59b4a][b]Nodes shown:[/b][/color] " + str(shown.size()) + " / " + str(PassiveDBScript.node_ids().size()), 12))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(scroll)
	var list: VBoxContainer = VBoxContainer.new()
	list.add_theme_constant_override("separation", 4)
	scroll.add_child(list)
	var current_lane: String = ""
	for node: Dictionary in shown:
		var lane: String = str(node.get("lane_label", node.get("lane", "")))
		if lane != current_lane:
			current_lane = lane
			list.add_child(_label("\n[color=#c59b4a][b]" + lane + "[/b][/color]", 12))
		list.add_child(_node_row(node))
	return container

func _build_right() -> Control:
	var panel: VBoxContainer = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(330, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_constant_override("separation", 8)
	panel.add_child(_label("[font_size=17][color=#c59b4a][b]NODE DETAIL[/b][/color][/font_size]", 13))
	var node: Dictionary = PassiveDBScript.node(_selected_node_id)
	if node.is_empty():
		panel.add_child(_label("[color=#8f8777]Select a node. The tree is grouped by build lanes: Fire, Storm, Mana, Slam, Guard, Rage, Bow, Mark, Trap, Center, and Keystones.[/color]", 12))
	else:
		panel.add_child(_detail_text(node))
		var allocated_nodes: Dictionary = PassiveTreeSystemScript.allocated(state_ref)
		if allocated_nodes.has(_selected_node_id):
			var refund: Button = _button("Refund selected", Callable(self, "_refund").bind(_selected_node_id))
			refund.disabled = not PassiveTreeSystemScript.can_refund(state_ref, _selected_node_id)
			panel.add_child(refund)
		else:
			var alloc: Button = _button("Allocate selected", Callable(self, "_allocate").bind(_selected_node_id))
			alloc.disabled = not PassiveTreeSystemScript.can_allocate(state_ref, _selected_node_id)
			panel.add_child(alloc)
	panel.add_child(_label("[color=#c59b4a][b]Validation[/b][/color]\n" + PassiveTreeSystemScript.validation_report(state_ref), 11))
	return panel

func _node_row(node: Dictionary) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	var id: String = str(node.get("id", ""))
	var allocated: bool = bool(node.get("allocated", false))
	var can_allocate: bool = bool(node.get("can_allocate", false))
	var type_text: String = str(node.get("type", "small"))
	var status: String = "✓" if allocated else ("+" if can_allocate else "·")
	var name_text: String = status + " " + str(node.get("name", "Node")) + " [" + type_text + "]"
	var select: Button = _button(name_text, Callable(self, "_select_node").bind(id))
	select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select.alignment = HORIZONTAL_ALIGNMENT_LEFT
	select.tooltip_text = _tooltip(node)
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
	text += "[color=#8f8777]" + str(node.get("lane_label", "")) + " · " + str(node.get("type", "")) + " · cost " + str(int(node.get("cost", 1))) + "[/color]\n"
	text += "Requires: " + _requires_text(node) + "\n\n"
	text += "[color=#c59b4a]Stats[/color]\n" + _stats_lines(Dictionary(node.get("stats", {}))) + "\n"
	var rules: Array = Array(node.get("rules", []))
	text += "[color=#c59b4a]Rules[/color]\n" + (("- " + "\n- ".join(rules)) if not rules.is_empty() else "none") + "\n"
	var desc: String = str(node.get("description", ""))
	if desc != "":
		text += "\n[color=#8f8777]" + desc + "[/color]\n"
	var err: String = PassiveTreeSystemScript.allocation_error(state_ref, str(node.get("id", "")))
	if err != "" and not PassiveTreeSystemScript.allocated(state_ref).has(str(node.get("id", ""))):
		text += "\n[color=#d65a32]" + err + "[/color]"
	return _label(text, 12)

func _switch_class(class_id: String) -> void:
	if state_ref == null:
		return
	var msg: String = ClassProgressionScript.set_class_for_testing(state_ref, class_id)
	if state_ref.has_method("add_notice"):
		state_ref.call("add_notice", msg)
	_selected_node_id = ""
	_last_signature = ""
	_render(true)

func _set_filter(filter_id: String) -> void:
	_filter_mode = filter_id
	_last_signature = ""
	_render(true)

func _set_search(value: String) -> void:
	_search_query = value.strip_edges()
	_last_signature = ""
	_render(true)

func _set_search_live(value: String) -> void:
	_search_query = value.strip_edges()
	_last_signature = ""
	_render(true)

func _select_node(node_id: String) -> void:
	_selected_node_id = node_id
	_last_signature = ""
	_render(true)

func _allocate(node_id: String) -> void:
	var msg: String = PassiveTreeSystemScript.allocate(state_ref, node_id)
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", msg)
	_selected_node_id = node_id
	_last_signature = ""
	_render(true)

func _refund(node_id: String) -> void:
	var msg: String = PassiveTreeSystemScript.refund(state_ref, node_id)
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
		var rn: Dictionary = PassiveDBScript.node(str(req))
		names.append(str(rn.get("name", str(req))))
	return ", ".join(names)

func _stats_lines(stats: Dictionary) -> String:
	if stats.is_empty():
		return "none"
	var parts: Array[String] = []
	for key: Variant in stats.keys():
		parts.append("- " + str(key) + ": " + str(stats[key]))
	return "\n".join(parts)

func _tooltip(node: Dictionary) -> String:
	var text: String = str(node.get("name", "")) + "\n" + str(node.get("lane_label", ""))
	var desc: String = str(node.get("description", ""))
	if desc != "":
		text += "\n" + desc
	return text

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
