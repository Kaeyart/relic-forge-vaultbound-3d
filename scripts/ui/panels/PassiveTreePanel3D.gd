extends Control

const ClassSystemScript: GDScript = preload("res://scripts/systems/CharacterClassSystem3D.gd")
const ClassProgressionScript: GDScript = preload("res://scripts/systems/ClassProgressionSystem3D.gd")
const PassiveTreeSystemScript: GDScript = preload("res://scripts/systems/PassiveTreeSystem3D.gd")

var state_ref: Object = null
var _root: VBoxContainer = null
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
	_root = VBoxContainer.new()
	_root.name = "PassiveTreeRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_theme_constant_override("separation", 8)
	add_child(_root)

func _signature() -> String:
	if state_ref == null:
		return ""
	var allocated_size: int = 0
	var allocated_value: Variant = state_ref.get("allocated_passive_nodes")
	if typeof(allocated_value) == TYPE_DICTIONARY:
		allocated_size = Dictionary(allocated_value).size()
	return str(state_ref.get("class_id")) + "|" + str(state_ref.get("passive_points")) + "|" + str(allocated_size)

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

	var title: RichTextLabel = _label("[font_size=20][color=#c59b4a][b]PASSIVE TREE SKELETON[/b][/color][/font_size]\n" + ClassSystemScript.class_summary_text(state_ref), 14)
	_root.add_child(title)

	var class_row: HBoxContainer = HBoxContainer.new()
	class_row.add_theme_constant_override("separation", 8)
	_root.add_child(class_row)
	for class_id: String in ClassSystemScript.class_ids():
		var btn: Button = Button.new()
		btn.text = "Switch: " + str(Dictionary(ClassSystemScript.classes()[class_id]).get("display_name", class_id.capitalize()))
		btn.focus_mode = Control.FOCUS_NONE
		btn.disabled = str(state_ref.get("class_id")) == class_id
		btn.pressed.connect(Callable(self, "_switch_class").bind(class_id))
		class_row.add_child(btn)

	var summary: RichTextLabel = _label("[color=#8f8777]" + PassiveTreeSystemScript.summary_text(state_ref) + "[/color]", 13)
	_root.add_child(summary)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root.add_child(scroll)

	var list: VBoxContainer = VBoxContainer.new()
	list.add_theme_constant_override("separation", 5)
	scroll.add_child(list)

	var current_region: String = ""
	for node: Dictionary in PassiveTreeSystemScript.sorted_nodes_for_ui(state_ref):
		var region: String = str(node.get("region", ""))
		if region != current_region:
			current_region = region
			list.add_child(_label("\n[color=#c59b4a][b]" + current_region.replace("_", " ").to_upper() + "[/b][/color]", 13))
		list.add_child(_node_row(node))

func _node_row(node: Dictionary) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var allocated: bool = bool(node.get("allocated", false))
	var can_allocate: bool = bool(node.get("can_allocate", false))
	var type_text: String = str(node.get("type", "small"))
	var prefix: String = "✓ " if allocated else ("+ " if can_allocate else "· ")
	var text: String = prefix + str(node.get("name", "Node")) + " [" + type_text + "]"
	var stats: Dictionary = Dictionary(node.get("stats", {}))
	if not stats.is_empty():
		text += " — " + _stats_text(stats)
	var rules: Array = Array(node.get("rules", []))
	if not rules.is_empty():
		text += " — Rules: " + ", ".join(rules)
	var label: RichTextLabel = _label(text, 12)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	if allocated:
		var refund: Button = Button.new()
		refund.text = "Refund"
		refund.focus_mode = Control.FOCUS_NONE
		refund.pressed.connect(Callable(self, "_refund").bind(str(node.get("id", ""))))
		row.add_child(refund)
	else:
		var alloc: Button = Button.new()
		alloc.text = "Allocate"
		alloc.disabled = not can_allocate
		alloc.focus_mode = Control.FOCUS_NONE
		alloc.pressed.connect(Callable(self, "_allocate").bind(str(node.get("id", ""))))
		row.add_child(alloc)
	return row

func _switch_class(class_id: String) -> void:
	if state_ref == null:
		return
	var msg: String = ClassProgressionScript.set_class_for_testing(state_ref, class_id)
	if state_ref.has_method("add_notice"):
		state_ref.call("add_notice", msg)
	_last_signature = ""
	_render(true)

func _allocate(node_id: String) -> void:
	var msg: String = PassiveTreeSystemScript.allocate(state_ref, node_id)
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", msg)
	_last_signature = ""
	_render(true)

func _refund(node_id: String) -> void:
	var msg: String = PassiveTreeSystemScript.refund(state_ref, node_id)
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", msg)
	_last_signature = ""
	_render(true)

func _stats_text(stats: Dictionary) -> String:
	var parts: Array[String] = []
	for key: Variant in stats.keys():
		parts.append(str(key) + " " + str(stats[key]))
	return ", ".join(parts)

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
