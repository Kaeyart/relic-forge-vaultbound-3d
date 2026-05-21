extends CanvasLayer

const RVUIStyle := preload("res://scripts/ui/RVUIStyle3D.gd")

var state_ref: Object = null
var _root: Control = null
var _blocker: ColorRect = null
var _shell: PanelContainer = null
var _title_label: Label = null
var _hint_label: Label = null
var _tabs_box: VBoxContainer = null
var _content: Control = null
var _tabs: Dictionary = {}
var _panels: Dictionary = {}
var _last_signature: String = ""
var _last_mode: String = "__none__"
var _built: bool = false

const PANEL_ORDER: Array[String] = ["inventory", "skills", "maps", "crafting", "stash", "character"]
const PANEL_SCRIPT_PATHS: Dictionary = {
	"inventory": "res://scripts/ui/panels/InventoryPanel3D.gd",
	"skills": "res://scripts/ui/panels/SkillGemPanel3D.gd",
	"maps": "res://scripts/ui/panels/MapDevicePanel3D.gd",
	"crafting": "res://scripts/ui/panels/ForgePanel3D.gd",
	"stash": "res://scripts/ui/panels/StashPanel3D.gd",
	"character": "res://scripts/ui/panels/CharacterPanel3D.gd"
}

func _ready() -> void:
	_build_ui()
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
	if event.is_action_pressed("ui_cancel") and str(_state_get("panel_mode", "")) != "":
		_close()
		get_viewport().set_input_as_handled()

func _build_ui() -> void:
	if _built:
		return
	_built = true
	RVUIStyle.clear_children(self)
	_root = Control.new()
	_root.name = "Root"
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	add_child(_root)

	_blocker = ColorRect.new()
	_blocker.name = "Blocker"
	_blocker.anchor_right = 1.0
	_blocker.anchor_bottom = 1.0
	_blocker.color = Color(0.0, 0.0, 0.0, 0.55)
	_root.add_child(_blocker)

	_shell = PanelContainer.new()
	_shell.name = "Shell"
	_shell.anchor_left = 0.07
	_shell.anchor_top = 0.08
	_shell.anchor_right = 0.93
	_shell.anchor_bottom = 0.92
	RVUIStyle.apply_panel(_shell, "alt")
	_root.add_child(_shell)

	var shell_margin: MarginContainer = MarginContainer.new()
	shell_margin.add_theme_constant_override("margin_left", 14)
	shell_margin.add_theme_constant_override("margin_top", 14)
	shell_margin.add_theme_constant_override("margin_right", 14)
	shell_margin.add_theme_constant_override("margin_bottom", 14)
	_shell.add_child(shell_margin)

	var main_row: HBoxContainer = RVUIStyle.make_hbox("MainRow", 14)
	shell_margin.add_child(main_row)
	_tabs_box = RVUIStyle.make_vbox("Tabs", 8)
	_tabs_box.custom_minimum_size = Vector2(160, 0)
	main_row.add_child(_tabs_box)
	var main: VBoxContainer = RVUIStyle.make_vbox("Main", 10)
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_child(main)

	var header: HBoxContainer = RVUIStyle.make_hbox("Header", 8)
	main.add_child(header)
	_title_label = RVUIStyle.label("Inventory", 22, RVUIStyle.color_gold(), true)
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)
	var close_button: Button = Button.new()
	close_button.text = "Close [Esc]"
	RVUIStyle.apply_button(close_button, false)
	if not close_button.pressed.is_connected(_close):
		close_button.pressed.connect(_close)
	header.add_child(close_button)
	_hint_label = RVUIStyle.label("", 12, RVUIStyle.color_muted())
	main.add_child(_hint_label)
	_content = Control.new()
	_content.name = "Content"
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(_content)
	_build_tabs_and_panels()

func _build_tabs_and_panels() -> void:
	for mode: String in PANEL_ORDER:
		var tab: Button = Button.new()
		tab.text = _panel_title(mode)
		tab.focus_mode = Control.FOCUS_NONE
		RVUIStyle.apply_button(tab, false)
		var callable: Callable = _set_mode.bind(mode)
		if not tab.pressed.is_connected(callable):
			tab.pressed.connect(callable)
		_tabs_box.add_child(tab)
		_tabs[mode] = tab

		var panel: Control = Control.new()
		panel.name = _panel_title(mode).replace(" ", "") + "Panel"
		panel.anchor_right = 1.0
		panel.anchor_bottom = 1.0
		panel.visible = false
		var script_path: String = str(PANEL_SCRIPT_PATHS.get(mode, ""))
		if script_path != "":
			var script_resource: Resource = load(script_path)
			if script_resource != null:
				panel.set_script(script_resource)
		_content.add_child(panel)
		_panels[mode] = panel

func _refresh(force: bool) -> void:
	_build_ui()
	var mode: String = str(_state_get("panel_mode", ""))
	var open: bool = mode != ""
	if _blocker != null:
		_blocker.visible = open
		_blocker.mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	if _shell != null:
		_shell.visible = open
		_shell.mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	if not open:
		_last_mode = ""
		_last_signature = ""
		for panel_value: Variant in _panels.values():
			var p: Control = panel_value as Control
			if p != null:
				p.visible = false
		return
	if not _panels.has(mode):
		mode = "inventory"
		_state_set("panel_mode", mode)
	if _title_label != null:
		_title_label.text = _panel_title(mode)
	if _hint_label != null:
		_hint_label.text = _panel_hint(mode)
	for key_value: Variant in _tabs.keys():
		var key: String = str(key_value)
		var tab: Button = _tabs[key] as Button
		if tab != null:
			RVUIStyle.apply_button(tab, key == mode)
	for panel_key_value: Variant in _panels.keys():
		var panel_key: String = str(panel_key_value)
		var panel: Control = _panels[panel_key] as Control
		if panel != null:
			panel.visible = panel_key == mode
	var signature: String = _signature_for_mode(mode)
	if force or signature != _last_signature or mode != _last_mode:
		_last_signature = signature
		_last_mode = mode
		var active: Node = _panels[mode] as Node
		if active != null:
			if active.has_method("update_from_state"):
				active.call("update_from_state", state_ref)
			elif active.has_method("bind_state"):
				active.call("bind_state", state_ref)

func _set_mode(mode: String) -> void:
	_state_set("panel_mode", mode)
	_refresh(true)

func _close() -> void:
	_state_set("panel_mode", "")
	_refresh(true)

func _panel_title(mode: String) -> String:
	match mode:
		"inventory":
			return "Inventory"
		"skills":
			return "Skill Gems"
		"maps":
			return "Map Device"
		"crafting":
			return "Forge"
		"stash":
			return "Stash"
		"character":
			return "Character"
		_:
			return RVUIStyle.title_case(mode)

func _panel_hint(mode: String) -> String:
	match mode:
		"inventory":
			return "Own, inspect, compare, and equip loot. Primary loop: pick up → judge → equip/forge/stash."
		"skills":
			return "Active gems define actions. Supports mutate behavior. Spirit reserves power for passive pressure."
		"maps":
			return "Choose a map by tier, threat, modifier load, and expected reward."
		"crafting":
			return "Modify selected items with visible cost and risk. Deterministic first, gambling later."
		"stash":
			return "Long-term loot storage. Later this gets tabs, filters, and affinities."
		"character":
			return "Readable power audit: offense, defense, resources, and build identity."
		_:
			return ""

func _signature_for_mode(mode: String) -> String:
	match mode:
		"inventory":
			return JSON.stringify([_state_get("backpack", []), _state_get("equipped", {}), _state_get("inventory_cursor", 0), _state_get("gold", 0), _state_get("materials", {})])
		"skills":
			return JSON.stringify([_state_get("active_skill_slots", []), _state_get("selected_skill_slot", 0), _state_get("spirit_gem_slots", []), _state_get("spirit_reserved", 0)])
		"maps":
			return JSON.stringify([_state_get("map_stash", []), _state_get("map_cursor", 0), _state_get("completed_maps", {}), _state_get("current_map_activity", {})])
		"crafting":
			return JSON.stringify([_state_get("backpack", []), _state_get("inventory_cursor", 0), _state_get("materials", {}), _state_get("gold", 0)])
		"stash":
			return JSON.stringify([_state_get("stash", []), _state_get("backpack", []), _state_get("stash_tabs", [])])
		"character":
			return JSON.stringify([_state_get("level", 1), _state_get("xp", 0), _state_get("equipped", {}), _state_get("build_stats", {}), _state_get("build_rules", [])])
		_:
			return mode

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback
	return value

func _state_set(key: String, value: Variant) -> void:
	if state_ref != null:
		state_ref.set(key, value)
