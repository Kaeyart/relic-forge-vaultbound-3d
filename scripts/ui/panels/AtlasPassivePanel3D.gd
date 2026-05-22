extends Control

const AtlasPassiveSystemScript := preload("res://scripts/systems/AtlasPassiveSystem3D.gd")
const AtlasPassiveDBScript := preload("res://scripts/data/AtlasPassiveDB3D.gd")

var state_ref: Object = null
var _root: VBoxContainer = null
var _region_buttons: HBoxContainer = null
var _node_list: VBoxContainer = null
var _detail: RichTextLabel = null
var _selected_region: String = "center"
var _selected_node_id: String = "atlas_start"
var _last_signature: String = ""

func _ready() -> void:
	_build()

func bind_state(state: Object) -> void:
	state_ref = state
	_refresh(true)

func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh(false)

func _build() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	_root = VBoxContainer.new()
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.offset_left = 10
	_root.offset_top = 10
	_root.offset_right = -10
	_root.offset_bottom = -10
	_root.add_theme_constant_override("separation", 8)
	add_child(_root)
	var title: RichTextLabel = RichTextLabel.new()
	title.bbcode_enabled = true
	title.fit_content = true
	title.text = "[font_size=20][color=#c59b4a]Atlas Passive Tree[/color][/font_size]\n[color=#8f8777]Specialize map sustain, tablets, bosses, gems, and forge rewards.[/color]"
	_root.add_child(title)
	_region_buttons = HBoxContainer.new()
	_region_buttons.add_theme_constant_override("separation", 6)
	_root.add_child(_region_buttons)
	var body: HBoxContainer = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	_root.add_child(body)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(430, 0)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	_node_list = VBoxContainer.new()
	_node_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_node_list)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail.custom_minimum_size = Vector2(420, 0)
	body.add_child(_detail)

func _refresh(force: bool = false) -> void:
	if state_ref == null or _root == null:
		return
	AtlasPassiveSystemScript.ensure_defaults(state_ref)
	var sig: String = str(_state_get("atlas_passive_points", 0)) + ":" + str(_state_get("allocated_atlas_passive_nodes", {})) + ":" + _selected_region + ":" + _selected_node_id
	if not force and sig == _last_signature:
		return
	_last_signature = sig
	_render_regions()
	_render_nodes()
	_render_detail()

func _render_regions() -> void:
	_clear(_region_buttons)
	for region: String in AtlasPassiveDBScript.REGIONS:
		var b: Button = Button.new()
		b.text = region.capitalize()
		b.toggle_mode = true
		b.button_pressed = region == _selected_region
		b.pressed.connect(func() -> void:
			_selected_region = region
			var nodes: Array[Dictionary] = AtlasPassiveDBScript.nodes_for_region(region)
			if not nodes.is_empty():
				_selected_node_id = str(nodes[0].get("id", _selected_node_id))
			_refresh(true)
		)
		_region_buttons.add_child(b)

func _render_nodes() -> void:
	_clear(_node_list)
	var header: Label = Label.new()
	header.text = "Points: " + str(_state_get("atlas_passive_points", 0))
	_node_list.add_child(header)
	for node: Dictionary in AtlasPassiveDBScript.nodes_for_region(_selected_region):
		var id: String = str(node.get("id", ""))
		var b: Button = Button.new()
		b.text = _node_label(id, node)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(func() -> void:
			_selected_node_id = id
			_refresh(true)
		)
		_node_list.add_child(b)

func _render_detail() -> void:
	var node: Dictionary = AtlasPassiveDBScript.node(_selected_node_id)
	if node.is_empty():
		_detail.text = "Select an Atlas node."
		return
	var allocated: Dictionary = AtlasPassiveSystemScript.allocated(state_ref)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[font_size=18][color=#c59b4a]" + str(node.get("name", _selected_node_id)) + "[/color][/font_size]")
	lines.append("Type: " + str(node.get("type", "node")) + " · Region: " + str(node.get("region", "")))
	lines.append(str(node.get("description", "")))
	lines.append("")
	lines.append("Allocated: " + ("yes" if allocated.has(_selected_node_id) else "no"))
	lines.append("Requires: " + ", ".join(_strings(Array(node.get("requires", [])))))
	lines.append("")
	lines.append("[color=#8f8777]Stats[/color]")
	var stats: Dictionary = Dictionary(node.get("stats", {}))
	if stats.is_empty():
		lines.append("—")
	else:
		for key: Variant in stats.keys():
			lines.append("• " + str(key) + ": " + str(stats[key]))
	lines.append("[color=#8f8777]Rules[/color]")
	var rules: Array = Array(node.get("rules", []))
	if rules.is_empty():
		lines.append("—")
	else:
		for rule: Variant in rules:
			lines.append("• " + str(rule))
	lines.append("")
	lines.append(AtlasPassiveSystemScript.validation_report(state_ref))
	_detail.text = "\n".join(lines)
	_add_action_buttons()

func _add_action_buttons() -> void:
	var alloc_btn: Button = Button.new()
	alloc_btn.text = "Allocate Selected"
	alloc_btn.pressed.connect(func() -> void:
		var msg: String = AtlasPassiveSystemScript.allocate(state_ref, _selected_node_id)
		if state_ref.has_method("add_notice"):
			state_ref.call("add_notice", msg)
		_refresh(true)
	)
	_node_list.add_child(alloc_btn)
	var refund_btn: Button = Button.new()
	refund_btn.text = "Refund Selected"
	refund_btn.pressed.connect(func() -> void:
		var msg: String = AtlasPassiveSystemScript.refund(state_ref, _selected_node_id)
		if state_ref.has_method("add_notice"):
			state_ref.call("add_notice", msg)
		_refresh(true)
	)
	_node_list.add_child(refund_btn)

func _node_label(id: String, node: Dictionary) -> String:
	var allocated: Dictionary = AtlasPassiveSystemScript.allocated(state_ref)
	var prefix: String = "[ ] "
	if allocated.has(id):
		prefix = "[x] "
	elif AtlasPassiveSystemScript.can_allocate(state_ref, id):
		prefix = "[+] "
	else:
		prefix = "[-] "
	return prefix + str(node.get("name", id))

func _clear(node: Node) -> void:
	if node == null:
		return
	for child: Node in node.get_children():
		child.queue_free()

func _strings(values: Array) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for value: Variant in values:
		out.append(str(value))
	if out.is_empty():
		out.append("none")
	return out


func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value
