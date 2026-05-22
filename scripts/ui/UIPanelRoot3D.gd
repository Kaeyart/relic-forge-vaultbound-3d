extends CanvasLayer

const UIAccessSystemScript: GDScript = preload("res://scripts/systems/UIAccessSystem3D.gd")

const PANEL_SCENES: Dictionary = {
	"inventory": "res://scenes/ui/panels/InventoryPanel3D.tscn",
	"stash": "res://scenes/ui/panels/StashPanel3D.tscn",
	"crafting": "res://scenes/ui/panels/ForgePanel3D.tscn",
	"skills": "res://scenes/ui/panels/SkillGemPanel3D.tscn",
	"passives": "res://scenes/ui/panels/PassiveTreePanel3D.tscn",
	"ascendancy": "res://scenes/ui/panels/AscendancyPanel3D.tscn",
	"maps": "res://scenes/ui/panels/MapDevicePanel3D.tscn",
	"character": "res://scenes/ui/panels/CharacterPanel3D.tscn"
}

var state_ref: Object = null
var _root: Control = null
var _sidebar: VBoxContainer = null
var _content: Control = null
var _active_panel: Node = null
var _active_mode: String = ""
var _last_sidebar_mode: String = ""
var _last_content_signature: String = ""

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
	shell.offset_left = 8
	shell.offset_top = 8
	shell.offset_right = -8
	shell.offset_bottom = -8
	shell.add_theme_constant_override("separation", 8)
	_root.add_child(shell)

	_sidebar = VBoxContainer.new()
	_sidebar.name = "Sidebar"
	_sidebar.custom_minimum_size = Vector2(172, 0)
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

	if _root != null:
		_root.visible = mode != ""

	if mode == "":
		_active_mode = ""
		_last_sidebar_mode = ""
		_last_content_signature = ""
		_clear_active_panel()
		return

	if mode != _active_mode:
		_build_sidebar(mode)
		_load_panel(mode)
		_last_sidebar_mode = mode
		_last_content_signature = _panel_signature(mode)
		return

	if mode != _last_sidebar_mode:
		_build_sidebar(mode)
		_last_sidebar_mode = mode

	var signature: String = _panel_signature(mode)
	if signature == _last_content_signature:
		return

	_last_content_signature = signature
	if _active_panel != null:
		if _active_panel.has_method("update_from_state"):
			_active_panel.call("update_from_state", state_ref)
		elif _active_panel.has_method("bind_state"):
			_active_panel.call("bind_state", state_ref)

func _build_sidebar(active: String) -> void:
	for child: Node in _sidebar.get_children():
		child.queue_free()

	var title: RichTextLabel = _rich_label("[font_size=15][color=#c59b4a][b]" + UIAccessSystemScript.panel_title(active).to_upper() + "[/b][/color][/font_size]\n[color=#8f8777]" + UIAccessSystemScript.panel_hint(active) + "[/color]", 12)
	_sidebar.add_child(title)

	var active_label: RichTextLabel = _rich_label("[color=#c59b4a]Current[/color]\n" + UIAccessSystemScript.panel_title(active), 14)
	_sidebar.add_child(active_label)

	var global_label: RichTextLabel = _rich_label("\n[color=#8f8777]Global screens[/color]", 12)
	_sidebar.add_child(global_label)

	_add_sidebar_button("inventory", active)
	_add_sidebar_button("skills", active)
	_add_sidebar_button("passives", active)
	_add_sidebar_button("ascendancy", active)

	var close_button: Button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(152, 36)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(Callable(self, "_close"))
	_sidebar.add_child(close_button)

func _add_sidebar_button(mode: String, active: String) -> void:
	var button: Button = Button.new()
	button.text = ("▶ " if mode == active else "") + UIAccessSystemScript.panel_title(mode)
	button.custom_minimum_size = Vector2(152, 36)
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


func _panel_signature(mode: String) -> String:
	if state_ref == null:
		return mode + ":no_state"

	match mode:
		"skills":
			return JSON.stringify([
				mode,
				state_ref.get("gem_inventory"),
				state_ref.get("equipped_gem_page"),
				state_ref.get("hotbar_slots"),
				state_ref.get("spirit_gem_slots"),
				state_ref.get("selected_gem_uid"),
				state_ref.get("selected_uncut_uid"),
				state_ref.get("selected_support_uid"),
				state_ref.get("selected_spirit_uid"),
				state_ref.get("selected_hotbar_slot"),
				state_ref.get("gem_last_message"),
			])

		"inventory":
			return JSON.stringify([
				mode,
				state_ref.get("backpack"),
				state_ref.get("equipped"),
				state_ref.get("inventory_cursor"),
			])

		"maps":
			return JSON.stringify([
				mode,
				state_ref.get("map_stash"),
				state_ref.get("map_cursor"),
				state_ref.get("current_map_activity"),
			])

		"crafting":
			return JSON.stringify([
				mode,
				state_ref.get("backpack"),
				state_ref.get("equipped"),
				state_ref.get("materials"),
				state_ref.get("inventory_cursor"),
			])

		"stash":
			return JSON.stringify([
				mode,
				state_ref.get("stash"),
				state_ref.get("backpack"),
				state_ref.get("stash_selected_item_index"),
				state_ref.get("selected_stash_category_id"),
				state_ref.get("selected_stash_tab_id"),
			])

		"character":
			return JSON.stringify([
				mode,
				state_ref.get("level"),
				state_ref.get("xp"),
				state_ref.get("equipped"),
				state_ref.get("build_stats"),
				state_ref.get("build_rules"),
			])

		_:
			return JSON.stringify([mode, state_ref.get("panel_mode")])


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
