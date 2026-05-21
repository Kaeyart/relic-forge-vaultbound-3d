extends CanvasLayer

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
	_root.name = "MouseFirstPanelShell"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	var backdrop: ColorRect = ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color(0.02, 0.015, 0.01, 0.78)
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
	var title: RichTextLabel = RichTextLabel.new()
	title.bbcode_enabled = true
	title.fit_content = true
	title.scroll_active = false
	title.text = "[font_size=18][color=#c59b4a][b]RELIC FORGE[/b][/color][/font_size]\n[color=#8f8777]Click a screen. Esc closes.[/color]"
	_sidebar.add_child(title)
	var modes: Array[String] = ["inventory", "skills", "maps", "crafting", "character", "stash"]
	for mode: String in modes:
		var b: Button = Button.new()
		b.text = ("▶ " if mode == active else "") + _mode_title(mode)
		b.custom_minimum_size = Vector2(170, 42)
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(Callable(self, "_set_mode").bind(mode))
		if mode == active:
			b.modulate = Color(1.0, 0.82, 0.34, 1.0)
		_sidebar.add_child(b)
	var close_button: Button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(170, 42)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(Callable(self, "_close"))
	_sidebar.add_child(close_button)

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
	for child: Node in _content.get_children():
		child.queue_free()

func _set_mode(mode: String) -> void:
	if state_ref != null:
		UIAccessSystemScript.request_panel(state_ref, mode)
	_refresh()

func _close() -> void:
	if state_ref != null:
		state_ref.set("panel_mode", "")
	_refresh()

func _panel_mode() -> String:
	if state_ref == null:
		return ""
	var value: Variant = state_ref.get("panel_mode")
	if value == null:
		return ""
	return str(value)

func _mode_title(mode: String) -> String:
	match mode:
		"inventory": return "Inventory"
		"skills": return "Skill Gems"
		"maps": return "Map Device"
		"crafting": return "Forge"
		"character": return "Character"
		"stash": return "Stash"
		_: return mode.capitalize()
