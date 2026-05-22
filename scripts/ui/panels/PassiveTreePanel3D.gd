extends Control
class_name RVPassiveTreePanel3D

const ClassDBScript := preload("res://scripts/data/ClassDB3D.gd")
const PassiveTreeDBScript := preload("res://scripts/data/PassiveTreeDB3D.gd")
const PassiveTreeSystemScript := preload("res://scripts/systems/PassiveTreeSystem3D.gd")
const ClassProgressionSystemScript := preload("res://scripts/systems/ClassProgressionSystem3D.gd")
const ValidationSystemScript := preload("res://scripts/systems/ProgressionValidationSystem3D.gd")

var state_ref: Object = null
var _root: HBoxContainer = null
var _class_box: VBoxContainer = null
var _node_box: VBoxContainer = null
var _detail: RichTextLabel = null
var _last_signature: String = ""

func _ready() -> void:
	_build_shell()

func bind_state(state: Object) -> void:
	state_ref = state
	if state_ref != null:
		PassiveTreeSystemScript.ensure_defaults(state_ref)
	_render(true)

func update_from_state(state: Object) -> void:
	state_ref = state
	if state_ref != null:
		PassiveTreeSystemScript.ensure_defaults(state_ref)
	_render(false)

func _build_shell() -> void:
	if _root != null:
		return
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	_root = HBoxContainer.new()
	_root.name = "PassiveTreeLayout"
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_root)
	_class_box = VBoxContainer.new()
	_class_box.custom_minimum_size = Vector2(220, 0)
	_root.add_child(_class_box)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root.add_child(scroll)
	_node_box = VBoxContainer.new()
	_node_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_node_box)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.fit_content = false
	_detail.custom_minimum_size = Vector2(300, 0)
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root.add_child(_detail)

func _render(force: bool = false) -> void:
	if state_ref == null:
		return
	_build_shell()
	var sig: String = str(state_ref.get("class_id")) + "|" + str(state_ref.get("passive_points")) + "|" + str(state_ref.get("allocated_passive_nodes")) + "|" + str(state_ref.get("selected_passive_node_id")) + "|" + str(state_ref.get("passive_tree_filter"))
	if not force and sig == _last_signature:
		return
	_last_signature = sig
	_clear(_class_box)
	_clear(_node_box)
	_render_classes()
	_render_nodes()
	_render_detail()

func _render_classes() -> void:
	var title: Label = Label.new()
	title.text = "CLASS / TREE"
	_class_box.add_child(title)
	var points: Label = Label.new()
	points.text = "Passive Points: " + str(int(state_ref.get("passive_points")))
	_class_box.add_child(points)
	for class_id_value: Variant in ClassDBScript.class_ids():
		var class_id: String = str(class_id_value)
		var b: Button = Button.new()
		b.text = ClassDBScript.display_name(class_id)
		b.toggle_mode = true
		b.button_pressed = class_id == str(state_ref.get("class_id"))
		b.pressed.connect(func() -> void:
			var result: Dictionary = ClassProgressionSystemScript.switch_class_for_testing(state_ref, class_id)
			_notice(result)
			_render(true)
		)
		_class_box.add_child(b)
	_class_box.add_child(HSeparator.new())
	for filter_id: String in ["current_class", "available", "allocated", "notable", "keystone", "center"]:
		var fb: Button = Button.new()
		fb.text = filter_id.replace("_", " ").capitalize()
		fb.pressed.connect(func() -> void:
			PassiveTreeSystemScript.set_filter(state_ref, filter_id)
			_render(true)
		)
		_class_box.add_child(fb)
	_class_box.add_child(HSeparator.new())
	var validation: Button = Button.new()
	validation.text = "Validation Report"
	validation.pressed.connect(func() -> void:
		if state_ref != null and state_ref.has_method("add_notice"):
			state_ref.call("add_notice", ValidationSystemScript.report_text(state_ref))
		_render(true)
	)
	_class_box.add_child(validation)

func _render_nodes() -> void:
	var nodes: Array = PassiveTreeSystemScript.visible_nodes(state_ref)
	var current_lane: String = ""
	for node_value: Variant in nodes:
		var node: Dictionary = Dictionary(node_value)
		var lane: String = str(node.get("lane", ""))
		if lane != current_lane:
			current_lane = lane
			var lane_label: Label = Label.new()
			lane_label.text = "--- " + lane + " ---"
			_node_box.add_child(lane_label)
		var id: String = str(node.get("id", ""))
		var state: String = PassiveTreeSystemScript.node_state(state_ref, id)
		var b: Button = Button.new()
		b.text = "[" + state.to_upper() + "] " + str(node.get("display_name", id)) + "  (" + str(node.get("type", "small")) + ")"
		b.tooltip_text = str(node.get("description", ""))
		b.pressed.connect(func() -> void:
			PassiveTreeSystemScript.set_selected_node(state_ref, id)
			_render(true)
		)
		_node_box.add_child(b)

func _render_detail() -> void:
	var id: String = str(state_ref.get("selected_passive_node_id"))
	var node: Dictionary = PassiveTreeDBScript.node(id)
	if node.is_empty():
		_detail.text = "[b]No passive selected.[/b]"
		return
	var state: String = PassiveTreeSystemScript.node_state(state_ref, id)
	var text: String = "[b]" + str(node.get("display_name", id)) + "[/b]\n"
	text += "State: " + state + "\n"
	text += "Region: " + str(node.get("region", "")) + "\n"
	text += "Type: " + str(node.get("type", "")) + "\n\n"
	text += "[b]Stats[/b]\n"
	for key: Variant in Dictionary(node.get("stats", {})).keys():
		text += "• " + str(key) + ": " + str(Dictionary(node.get("stats", {}))[key]) + "\n"
	text += "\n[b]Rules[/b]\n"
	for rule: Variant in Array(node.get("rules", [])):
		text += "• " + str(rule) + "\n"
	text += "\n[b]Requires[/b]\n"
	for req: Variant in Array(node.get("requires", [])):
		text += "• " + str(req) + "\n"
	_detail.text = text
	var allocate: Button = Button.new()
	allocate.text = "Allocate Selected"
	allocate.pressed.connect(func() -> void:
		var result: Dictionary = PassiveTreeSystemScript.allocate_node(state_ref, id)
		_notice(result)
		_render(true)
	)
	_node_box.add_child(allocate)
	var refund: Button = Button.new()
	refund.text = "Refund Selected"
	refund.pressed.connect(func() -> void:
		var result: Dictionary = PassiveTreeSystemScript.refund_node(state_ref, id)
		_notice(result)
		_render(true)
	)
	_node_box.add_child(refund)

func _notice(result: Dictionary) -> void:
	if state_ref != null and state_ref.has_method("add_notice"):
		state_ref.call("add_notice", str(result.get("message", "")))

func _clear(node: Node) -> void:
	for child: Node in node.get_children():
		child.queue_free()
