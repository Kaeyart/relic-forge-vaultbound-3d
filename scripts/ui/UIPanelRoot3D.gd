extends CanvasLayer

const UIAccessSystemScript: GDScript = preload("res://scripts/systems/UIAccessSystem3D.gd")

const PANEL_SCENES: Dictionary = {
	"inventory": "res://scenes/ui/panels/InventoryPanel3D.tscn",
	"stash": "res://scenes/ui/panels/StashPanel3D.tscn",
	"crafting": "res://scenes/ui/panels/ForgePanel3D.tscn",
	"skills": "res://scenes/ui/panels/SkillGemPanel3D.tscn",
	"maps": "res://scenes/ui/panels/MapDevicePanel3D.tscn",
	"character": "res://scenes/ui/panels/CharacterPanel3D.tscn"
}

var state_ref: Object = null
var _root: Control = null
var _sidebar: VBoxContainer = null
var _content: Control = null
var _active_panel: Node = null
var _active_mode: String = ""

func _ready() -> void:
	_build_shell()
	_refresh()

func bind_state(state: Object) -> void:
	state_ref = state
	_refresh()

func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh()

func mark_dirty() -> void:
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _panel_mode() != "":
		_close()
		get_viewport().set_input_as_handled()

func _build_shell() -> void:
	if _root != null and is_instance_valid(_root):
		return

	_root = Control.new()
	_root.name = "StationGatedPanelShell018"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var backdrop: ColorRect = ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color(0.02, 0.015, 0.01, 0.80)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(backdrop)

	var shell: HBoxContainer = HBoxContainer.new()
	shell.name = "Shell"
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.offset_left = 24
	shell.offset_top = 24
	shell.offset_right = -24
	shell.offset_bottom = -24
	shell.add_theme_constant_override("separation", 10)
	_root.add_child(shell)

	_sidebar = VBoxContainer.new()
	_sidebar.name = "Sidebar"
	_sidebar.custom_minimum_size = Vector2(190, 0)
	_sidebar.add_theme_constant_override("separation", 6)
	shell.add_child(_sidebar)

	_content = Control.new()
	_content.name = "Content"
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(_content)

func _refresh() -> void:
	_build_shell()
	var mode: String = _panel_mode()
	_root.visible = mode != ""

	if mode == "":
		_active_mode = ""
		_clear_active_panel()
		return

	_build_sidebar(mode)
	if mode != _active_mode:
		_load_panel(mode)

	if _active_panel != null:
		if _active_panel.has_method("update_from_state"):
			_active_panel.call("update_from_state", state_ref)
		elif _active_panel.has_method("bind_state"):
			_active_panel.call("bind_state", state_ref)

func _build_sidebar(active: String) -> void:
	for child: Node in _sidebar.get_children():
		child.queue_free()

	var title: RichTextLabel = _rich_label("[font_size=18][color=#c59b4a][b]" + UIAccessSystemScript.panel_title(active).to_upper() + "[/b][/color][/font_size]\n[color=#8f8777]" + UIAccessSystemScript.panel_hint(active) + "[/color]", 13)
	_sidebar.add_child(title)

	var active_label: RichTextLabel = _rich_label("[color=#c59b4a]Current[/color]\n" + UIAccessSystemScript.panel_title(active), 14)
	_sidebar.add_child(active_label)

	var global_label: RichTextLabel = _rich_label("\n[color=#8f8777]Global screens[/color]", 12)
	_sidebar.add_child(global_label)

	_add_sidebar_button("inventory", active)
	_add_sidebar_button("skills", active)

	var close_button: Button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(170, 42)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(Callable(self, "_close"))
	_sidebar.add_child(close_button)

func _add_sidebar_button(mode: String, active: String) -> void:
	var button: Button = Button.new()
	button.text = ("▶ " if mode == active else "") + UIAccessSystemScript.panel_title(mode)
	button.custom_minimum_size = Vector2(170, 42)
	button.focus_mode = Control.FOCUS_NONE
	button.disabled = not UIAccessSystemScript.can_open_panel(state_ref, mode, false)
	button.pressed.connect(Callable(self, "_set_mode").bind(mode))
	if mode == active:
		button.modulate = Color(1.0, 0.82, 0.34, 1.0)
	_sidebar.add_child(button)

func _load_panel(mode: String) -> void:
	_clear_active_panel()
	_active_mode = mode
	var path: String = str(PANEL_SCENES.get(mode, ""))
	if path == "":
		return
	var packed: Resource = load(path)
	if packed is PackedScene:
		_active_panel = (packed as PackedScene).instantiate()
		if _active_panel is Control:
			(_active_panel as Control).set_anchors_preset(Control.PRESET_FULL_RECT)
		_content.add_child(_active_panel)
		if _active_panel.has_method("bind_state"):
			_active_panel.call("bind_state", state_ref)

func _clear_active_panel() -> void:
	if _active_panel != null and is_instance_valid(_active_panel):
		_active_panel.queue_free()
	_active_panel = null
	if _content != null:
		for child: Node in _content.get_children():
			child.queue_free()

func _set_mode(mode: String) -> void:
	if state_ref != null:
		UIAccessSystemScript.request_panel(state_ref, mode, false)
	_refresh()

func _close() -> void:
	if state_ref != null:
		UIAccessSystemScript.close_panel(state_ref)
	_refresh()

func _panel_mode() -> String:
	if state_ref == null:
		return ""
	var value: Variant = state_ref.get("panel_mode")
	if value == null:
		return ""
	return str(value)

func _rich_label(text: String, size: int) -> RichTextLabel:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.add_theme_font_size_override("normal_font_size", size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
