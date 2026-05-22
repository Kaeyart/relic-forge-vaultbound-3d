extends Control
class_name RVAscendancyPanel3D

const AscendancyDBScript := preload("res://scripts/data/AscendancyDB3D.gd")
const AscendancySystemScript := preload("res://scripts/systems/AscendancySystem3D.gd")

var state_ref: Object = null
var _root: HBoxContainer = null
var _asc_box: VBoxContainer = null
var _node_box: VBoxContainer = null
var _detail: RichTextLabel = null
var _last_signature: String = ""

func _ready() -> void:
	_build_shell()

func bind_state(state: Object) -> void:
	state_ref = state
	if state_ref != null:
		AscendancySystemScript.ensure_defaults(state_ref)
	_render(true)

func update_from_state(state: Object) -> void:
	state_ref = state
	if state_ref != null:
		AscendancySystemScript.ensure_defaults(state_ref)
	_render(false)

func _build_shell() -> void:
	if _root != null:
		return
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	_root = HBoxContainer.new()
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_root)
	_asc_box = VBoxContainer.new()
	_asc_box.custom_minimum_size = Vector2(240, 0)
	_root.add_child(_asc_box)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root.add_child(scroll)
	_node_box = VBoxContainer.new()
	_node_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_node_box)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.custom_minimum_size = Vector2(320, 0)
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root.add_child(_detail)

func _render(force: bool = false) -> void:
	if state_ref == null:
		return
	_build_shell()
	var sig: String = str(state_ref.get("class_id")) + "|" + str(state_ref.get("selected_ascendancy_id")) + "|" + str(state_ref.get("ascendancy_points")) + "|" + str(state_ref.get("allocated_ascendancy_nodes")) + "|" + str(state_ref.get("selected_ascendancy_node_id"))
	if not force and sig == _last_signature:
		return
	_last_signature = sig
	_clear(_asc_box)
	_clear(_node_box)
	_render_ascendancies()
	_render_nodes()
	_render_detail()

func _render_ascendancies() -> void:
	var title: Label = Label.new()
	title.text = "ASCENDANCY"
	_asc_box.add_child(title)
	var points: Label = Label.new()
	points.text = "Points: " + str(int(state_ref.get("ascendancy_points")))
	_asc_box.add_child(points)
	for asc_value: Variant in AscendancySystemScript.visible_ascendancies(state_ref):
		var asc: Dictionary = Dictionary(asc_value)
		var asc_id: String = str(asc.get("id", ""))
		var b: Button = Button.new()
		b.text = str(asc.get("display_name", asc_id))
		b.toggle_mode = true
		b.button_pressed = asc_id == str(state_ref.get("selected_ascendancy_id"))
		b.tooltip_text = str(asc.get("fantasy", ""))
		b.pressed.connect(func() -> void:
			var result: Dictionary = AscendancySystemScript.choose_ascendancy(state_ref, asc_id)
			_notice(result)
			_render(true)
		)
		_asc_box.add_child(b)

func _render_nodes() -> void:
	for node_value: Variant in AscendancySystemScript.visible_nodes(state_ref):
		var node: Dictionary = Dictionary(node_value)
		var id: String = str(node.get("id", ""))
		var state: String = AscendancySystemScript.node_state(state_ref, id)
		var b: Button = Button.new()
		b.text = "[" + state.to_upper() + "] " + str(node.get("display_name", id)) + "  (cost " + str(node.get("cost", 1)) + ")"
		b.tooltip_text = str(node.get("description", ""))
		b.pressed.connect(func() -> void:
			AscendancySystemScript.set_selected_node(state_ref, id)
			_render(true)
		)
		_node_box.add_child(b)

func _render_detail() -> void:
	var id: String = str(state_ref.get("selected_ascendancy_node_id"))
	if id == "":
		_detail.text = "[b]Choose an ascendancy node.[/b]"
		return
	var node: Dictionary = AscendancyDBScript.node(id)
	if node.is_empty():
		_detail.text = "[b]No ascendancy node selected.[/b]"
		return
	var text: String = "[b]" + str(node.get("display_name", id)) + "[/b]\n"
	text += "Type: " + str(node.get("type", "")) + "\n"
	text += "Cost: " + str(node.get("cost", 1)) + "\n\n"
	text += "[b]Stats[/b]\n"
	for key: Variant in Dictionary(node.get("stats", {})).keys():
		text += "• " + str(key) + ": " + str(Dictionary(node.get("stats", {}))[key]) + "\n"
	text += "\n[b]Rules[/b]\n"
	for rule: Variant in Array(node.get("rules", [])):
		text += "• " + str(rule) + "\n"
	_detail.text = text
	var allocate: Button = Button.new()
	allocate.text = "Allocate Selected"
	allocate.pressed.connect(func() -> void:
		var result: Dictionary = AscendancySystemScript.allocate_node(state_ref, id)
		_notice(result)
		_render(true)
	)
	_node_box.add_child(allocate)
	var refund: Button = Button.new()
	refund.text = "Refund Selected"
	refund.pressed.connect(func() -> void:
		var result: Dictionary = AscendancySystemScript.refund_node(state_ref, id)
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
