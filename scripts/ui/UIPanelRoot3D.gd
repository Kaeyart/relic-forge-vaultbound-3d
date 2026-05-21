extends CanvasLayer

const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")
const UIAccessSystemScript := preload("res://scripts/systems/UIAccessSystem3D.gd")

var state_ref: Object = null
var blocker: ColorRect = null
var shell: PanelContainer = null
var title_label: Label = null
var hint_label: RichTextLabel = null
var close_button: Button = null
var panels: Dictionary = {}
var tabs: Dictionary = {}
var _last_mode: String = "__none__"
var _last_signature: String = ""

func _ready() -> void:
	_bind_nodes()
	_connect_buttons()
	_refresh(true)

func bind_state(state: Object) -> void:
	state_ref = state
	_refresh(true)

func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh(false)

func mark_dirty() -> void:
	_refresh(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and str(_get_value("panel_mode", "")) != "":
		_close()
		get_viewport().set_input_as_handled()

func _bind_nodes() -> void:
	blocker = get_node_or_null("Blocker") as ColorRect
	shell = get_node_or_null("Shell") as PanelContainer
	title_label = get_node_or_null("Shell/Root/Main/Header/TitleLabel") as Label
	hint_label = get_node_or_null("Shell/Root/Main/HintLabel") as RichTextLabel
	close_button = get_node_or_null("Shell/Root/Main/Header/CloseButton") as Button

	panels = {
		"inventory": get_node_or_null("Shell/Root/Main/Content/InventoryPanel"),
		"stash": get_node_or_null("Shell/Root/Main/Content/StashPanel"),
		"crafting": get_node_or_null("Shell/Root/Main/Content/ForgePanel"),
		"skills": get_node_or_null("Shell/Root/Main/Content/SkillsPanel"),
		"maps": get_node_or_null("Shell/Root/Main/Content/MapsPanel"),
		"character": get_node_or_null("Shell/Root/Main/Content/CharacterPanel"),
	}

	tabs = {
		"inventory": get_node_or_null("Shell/Root/Sidebar/TabInventory"),
		"stash": get_node_or_null("Shell/Root/Sidebar/TabStash"),
		"crafting": get_node_or_null("Shell/Root/Sidebar/TabForge"),
		"skills": get_node_or_null("Shell/Root/Sidebar/TabSkills"),
		"maps": get_node_or_null("Shell/Root/Sidebar/TabMaps"),
		"character": get_node_or_null("Shell/Root/Sidebar/TabCharacter"),
	}

func _connect_buttons() -> void:
	for mode: Variant in tabs.keys():
		var button: Button = tabs[mode] as Button
		if button != null:
			var tab_callable: Callable = _set_mode.bind(str(mode))
			if not button.pressed.is_connected(tab_callable):
				button.pressed.connect(tab_callable)

	if close_button != null and not close_button.pressed.is_connected(_close):
		close_button.pressed.connect(_close)

func _refresh(force: bool) -> void:
	if shell == null:
		_bind_nodes()

	var mode: String = str(_get_value("panel_mode", ""))
	var is_open: bool = mode != ""

	if blocker != null:
		blocker.visible = is_open
		blocker.mouse_filter = Control.MOUSE_FILTER_STOP if is_open else Control.MOUSE_FILTER_IGNORE

	if shell != null:
		shell.visible = is_open
		shell.mouse_filter = Control.MOUSE_FILTER_STOP if is_open else Control.MOUSE_FILTER_IGNORE

	if not is_open:
		_last_mode = ""
		_last_signature = ""

		for p: Variant in panels.values():
			var closed_panel: Control = p as Control
			if closed_panel != null:
				closed_panel.visible = false

		return

	if title_label != null:
		title_label.text = UIFoundationSystemScript.panel_title(mode)

	if hint_label != null:
		hint_label.text = "[b]" + UIFoundationSystemScript.panel_title(mode) + "[/b] · " + UIFoundationSystemScript.panel_hint(mode)

	for key: Variant in panels.keys():
		var panel: Control = panels[key] as Control
		if panel != null:
			panel.visible = str(key) == mode
			panel.mouse_filter = Control.MOUSE_FILTER_STOP if panel.visible else Control.MOUSE_FILTER_IGNORE

	for key2: Variant in tabs.keys():
		var tab: Button = tabs[key2] as Button
		if tab != null:
			tab.modulate = Color(1.0, 0.75, 0.25, 1.0) if str(key2) == mode else Color(1.0, 1.0, 1.0, 0.82)

	var active: Node = panels.get(mode, null) as Node
	if active == null:
		return

	var sig: String = _signature_for_mode(mode)

	if force or sig != _last_signature or mode != _last_mode:
		_last_mode = mode
		_last_signature = sig

		if active.has_method("update_from_state"):
			active.call("update_from_state", state_ref)
		elif active.has_method("bind_state"):
			active.call("bind_state", state_ref)

func _set_mode(mode: String) -> void:
	if state_ref == null:
		return

	UIAccessSystemScript.request_panel(state_ref, mode)
	_refresh(true)

func _close() -> void:
	UIAccessSystemScript.close_panel(state_ref)
	_refresh(true)

func _get_value(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback

	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback

	return value

func _signature_for_mode(mode: String) -> String:
	if state_ref == null:
		return ""

	match mode:
		"inventory":
			return JSON.stringify([
				_get_value("backpack", []),
				_get_value("equipped", {}),
				_get_value("inventory_cursor", 0),
				_get_value("gold", 0),
				_get_value("materials", {})
			])

		"stash":
			return JSON.stringify([
				_get_value("stash", []),
				_get_value("stash_tabs", []),
				_get_value("backpack", []),
				_get_value("gold", 0)
			])

		"crafting":
			return JSON.stringify([
				_get_value("backpack", []),
				_get_value("inventory_cursor", 0),
				_get_value("materials", {}),
				_get_value("gold", 0)
			])

		"skills":
			return JSON.stringify([
				_get_value("active_skill_slots", []),
				_get_value("selected_skill_slot", 0),
				_get_value("spirit_gem_slots", []),
				_get_value("spirit_reserved", 0)
			])

		"maps":
			return JSON.stringify([
				_get_value("map_stash", []),
				_get_value("map_cursor", 0),
				_get_value("completed_maps", {}),
				_get_value("current_map_activity", {})
			])

		"character":
			return JSON.stringify([
				_get_value("level", 1),
				_get_value("xp", 0),
				_get_value("equipped", {}),
				_get_value("build_stats", {}),
				_get_value("build_rules", [])
			])

		_:
			return mode
