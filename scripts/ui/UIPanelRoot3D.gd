extends CanvasLayer

const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")
const UIItemFormatSystemScript := preload("res://scripts/systems/UIItemFormatSystem3D.gd")
const UIAccessSystemScript := preload("res://scripts/systems/UIAccessSystem3D.gd") 
const UIUXSystemScript := preload("res://scripts/systems/UIUXSystem3D.gd")

var _rf_094a_contract_label: RichTextLabel = null 
var _rf_097g_action_bar: RichTextLabel = null
var _rf_092b_hint_bar: RichTextLabel = null
var blocker: ColorRect = null
var shell: PanelContainer = null
var title_label: Label = null

var inventory_panel: Control = null
var forge_panel: Control = null
var skills_panel: Control = null
var maps_panel: Control = null
var character_panel: Control = null
var stash_panel: Control = null

var tab_inventory: Button = null
var tab_forge: Button = null
var tab_skills: Button = null
var tab_maps: Button = null
var tab_character: Button = null
var tab_stash: Button = null
var close_button: Button = null

var state_ref: Object = null
var _last_mode: String = "__none__"
var _last_signature: String = ""
var _force_refresh: bool = true

func _ready() -> void:
	_bind_nodes()
	_rf_092b_ensure_hint_bar()
	_connect_buttons()
	_refresh_shell()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if str(_state_get("panel_mode", "")) != "":
			_close()
			get_viewport().set_input_as_handled()

func bind_state(state: Object) -> void:
	state_ref = state
	_force_refresh = true
	update_from_state(state)

func update_from_state(state: Object) -> void:
	_rf_094a_update_contract_label()
	state_ref = state
	if shell == null:
		_bind_nodes()
	var mode: String = str(_state_get("panel_mode", ""))
	_refresh_shell()
	if mode == "":
		_last_mode = mode
		_last_signature = ""
		return
	var panel: Node = _active_panel()
	if panel == null:
		return
	var sig: String = _signature_for_mode(mode)
	if _force_refresh or mode != _last_mode or sig != _last_signature:
		_force_refresh = false
		_last_mode = mode
		_last_signature = sig
		if panel.has_method("update_from_state"):
			panel.call("update_from_state", state_ref)
		elif panel.has_method("bind_state"):
			panel.call("bind_state", state_ref)

func mark_dirty() -> void:
	_force_refresh = true
	update_from_state(state_ref)

func _bind_nodes() -> void:
	blocker = get_node_or_null("Blocker") as ColorRect
	shell = get_node_or_null("Shell") as PanelContainer
	title_label = get_node_or_null("Shell/VBox/Header/TitleLabel") as Label
	inventory_panel = get_node_or_null("Shell/VBox/Content/InventoryPanel") as Control
	stash_panel = get_node_or_null("Shell/VBox/Content/StashPanel") as Control
	forge_panel = get_node_or_null("Shell/VBox/Content/ForgePanel") as Control
	skills_panel = get_node_or_null("Shell/VBox/Content/SkillsPanel") as Control
	maps_panel = get_node_or_null("Shell/VBox/Content/MapsPanel") as Control
	character_panel = get_node_or_null("Shell/VBox/Content/CharacterPanel") as Control
	tab_inventory = get_node_or_null("Shell/VBox/Tabs/TabInventory") as Button
	tab_stash = get_node_or_null("Shell/VBox/Tabs/TabStash") as Button
	tab_forge = get_node_or_null("Shell/VBox/Tabs/TabForge") as Button
	tab_skills = get_node_or_null("Shell/VBox/Tabs/TabSkills") as Button
	tab_maps = get_node_or_null("Shell/VBox/Tabs/TabMaps") as Button
	tab_character = get_node_or_null("Shell/VBox/Tabs/TabCharacter") as Button
	close_button = get_node_or_null("Shell/VBox/Header/CloseButton") as Button

func _connect_buttons() -> void:
	_connect_button(tab_inventory, "inventory")
	_connect_button(tab_stash, "stash")
	_connect_button(tab_forge, "crafting")
	_connect_button(tab_skills, "skills")
	_connect_button(tab_maps, "maps")
	_connect_button(tab_character, "character")
	if close_button != null and not close_button.pressed.is_connected(_close):
		close_button.pressed.connect(_close)

func _connect_button(button: Button, mode: String) -> void:
	if button != null and not button.pressed.is_connected(_set_mode.bind(mode)):
		button.pressed.connect(_set_mode.bind(mode))

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func _set_mode(mode: String) -> void:
	if state_ref == null:
		return
	if UIAccessSystemScript.toggle_panel(state_ref, mode):
		_force_refresh = true
		update_from_state(state_ref)

func _close() -> void:
	UIAccessSystemScript.close_panel(state_ref)
	_force_refresh = true
	update_from_state(state_ref)

func _refresh_shell() -> void:
	var mode: String = str(_state_get("panel_mode", ""))
	var open: bool = mode != ""
	_apply_shell_layout(mode)
	if blocker != null:
		blocker.visible = open
		blocker.mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	if shell != null:
		shell.visible = open
		shell.mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	_set_panel(inventory_panel, mode == "inventory")
	_set_panel(stash_panel, mode == "stash")
	_set_panel(forge_panel, mode == "crafting")
	_set_panel(skills_panel, mode == "skills")
	_set_panel(maps_panel, mode == "maps")
	_set_panel(character_panel, mode == "character")
	if title_label != null:
		title_label.text = UIAccessSystemScript.panel_title(mode)
	_set_tab(tab_inventory, mode == "inventory")
	_set_tab(tab_stash, mode == "stash")
	_set_tab(tab_forge, mode == "crafting")
	_set_tab(tab_skills, mode == "skills")
	_set_tab(tab_maps, mode == "maps")
	_set_tab(tab_character, mode == "character")
	_rf_092b_update_hint_bar(mode) 
	_rf_097g_update_action_bar(mode)

func _set_panel(panel: Control, visible_state: bool) -> void:
	if panel != null:
		panel.visible = visible_state
		panel.mouse_filter = Control.MOUSE_FILTER_STOP if visible_state else Control.MOUSE_FILTER_IGNORE

func _set_tab(button: Button, active: bool) -> void:
	if button != null:
		button.modulate = Color(1.0, 0.82, 0.32, 1.0) if active else Color(1, 1, 1, 1)

func _active_panel() -> Node:
	match str(_state_get("panel_mode", "")):
		"inventory": return inventory_panel
		"stash": return stash_panel
		"crafting": return forge_panel
		"skills": return skills_panel
		"maps": return maps_panel
		"character": return character_panel
		_: return null

func _signature_for_mode(mode: String) -> String:
	if state_ref == null:
		return ""
	match mode:
		"inventory": return JSON.stringify([_state_get("backpack", []), _state_get("equipped", {}), _state_get("inventory_cursor", 0), _state_get("gold", 0), _state_get("materials", {})])
		"stash": return JSON.stringify([_state_get("stash_categories", []), _state_get("stash_tabs", []), _state_get("selected_stash_category_id", ""), _state_get("selected_stash_tab_id", ""), _state_get("stash_selected_item_index", -1), _state_get("stash_search_query", ""), _state_get("stash_search_all", false), Array(_state_get("backpack", [])).size(), _state_get("gold", 0)])
		"crafting": return JSON.stringify([_state_get("backpack", []), _state_get("equipped", {}), _state_get("inventory_cursor", 0), _state_get("materials", {}), _state_get("gold", 0)])
		"skills": return JSON.stringify([_state_get("active_skill_slots", []), _state_get("selected_skill_slot", 0), _state_get("active_gems_owned", {}), _state_get("support_gems_owned", {}), _state_get("spirit_gems_owned", {}), _state_get("spirit_gem_slots", []), _state_get("gem_stash", {}), _state_get("spirit_reserved", 0), _state_get("spirit_max", 0)])
		"maps": return JSON.stringify([_state_get("map_stash", []), _state_get("map_cursor", 0), _state_get("completed_maps", {}), _state_get("map_completion", {}), _state_get("stash_tabs", [])])
		"character": return JSON.stringify([_state_get("class_display_name", ""), _state_get("level", 1), _state_get("xp", 0), _state_get("passive_points", 0), _state_get("build_stats", {}), _state_get("build_rules", []), _state_get("equipped", {})])
		_: return mode

func _apply_shell_layout(mode: String) -> void:
	if shell == null:
		return
	if mode == "skills":
		shell.anchor_left = 0.0
		shell.anchor_top = 0.0
		shell.anchor_right = 0.54
		shell.anchor_bottom = 1.0
		shell.offset_left = 24.0
		shell.offset_top = 72.0
		shell.offset_right = -12.0
		shell.offset_bottom = -64.0
	else:
		shell.anchor_left = 0.0
		shell.anchor_top = 0.0
		shell.anchor_right = 1.0
		shell.anchor_bottom = 1.0
		shell.offset_left = 64.0
		shell.offset_top = 72.0
		shell.offset_right = -64.0
		shell.offset_bottom = -64.0


func _rf_092b_ensure_hint_bar() -> void:
	if _rf_092b_hint_bar != null and is_instance_valid(_rf_092b_hint_bar):
		return
	var vbox := get_node_or_null("Shell/VBox") as VBoxContainer
	if vbox == null:
		return
	_rf_092b_hint_bar = RichTextLabel.new()
	_rf_092b_hint_bar.name = "UXHintBar092B"
	_rf_092b_hint_bar.custom_minimum_size = Vector2(0, 44)
	_rf_092b_hint_bar.fit_content = true
	_rf_092b_hint_bar.bbcode_enabled = true
	_rf_092b_hint_bar.scroll_active = false
	_rf_092b_hint_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_rf_092b_hint_bar)

func _rf_092b_update_hint_bar(mode: String) -> void:
	_rf_092b_ensure_hint_bar()
	if _rf_092b_hint_bar == null:
		return
	var text_value: String = UIItemFormatSystemScript.action_hint_for_panel(mode)
	_rf_092b_hint_bar.visible = text_value != ""
	_rf_092b_hint_bar.text = text_value


func _rf_094a_ensure_contract_label() -> void:
	if _rf_094a_contract_label != null and is_instance_valid(_rf_094a_contract_label):
		return
	var host: Control = _rf_094a_find_root_vbox(self)
	if host == null:
		return
	_rf_094a_contract_label = RichTextLabel.new()
	_rf_094a_contract_label.name = "UIContractHint094A"
	_rf_094a_contract_label.bbcode_enabled = true
	_rf_094a_contract_label.fit_content = true
	_rf_094a_contract_label.scroll_active = false
	_rf_094a_contract_label.custom_minimum_size = Vector2(0, 38)
	_rf_094a_contract_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(_rf_094a_contract_label)

func _rf_094a_update_contract_label() -> void:
	_rf_094a_ensure_contract_label()
	if _rf_094a_contract_label == null:
		return
	var s: Object = get("state_ref") as Object
	var mode: String = ""
	if s != null:
		mode = str(s.get("panel_mode"))
	_rf_094a_contract_label.visible = mode != ""
	_rf_094a_contract_label.text = "[b]" + UIFoundationSystemScript.panel_title(mode) + "[/b] · " + UIFoundationSystemScript.panel_hint(mode)

func _rf_094a_find_root_vbox(node: Node) -> Control:
	if node is VBoxContainer:
		return node as Control
	for child: Node in node.get_children():
		var found: Control = _rf_094a_find_root_vbox(child)
		if found != null:
			return found
	return null


func _rf_097g_ensure_action_bar() -> void:
	if _rf_097g_action_bar != null and is_instance_valid(_rf_097g_action_bar):
		return
	var vbox := get_node_or_null("Shell/VBox") as VBoxContainer
	if vbox == null:
		return
	_rf_097g_action_bar = RichTextLabel.new()
	_rf_097g_action_bar.name = "UXActionBar097G"
	_rf_097g_action_bar.bbcode_enabled = true
	_rf_097g_action_bar.fit_content = true
	_rf_097g_action_bar.scroll_active = false
	_rf_097g_action_bar.custom_minimum_size = Vector2(0, 54)
	_rf_097g_action_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_rf_097g_action_bar)


func _rf_097g_update_action_bar(mode: String) -> void:
	_rf_097g_ensure_action_bar()
	if _rf_097g_action_bar == null:
		return
	_rf_097g_action_bar.visible = mode != ""
	if mode == "":
		_rf_097g_action_bar.text = ""
		return
	_rf_097g_action_bar.text = UIUXSystemScript.action_bar_text(state_ref, mode) + "\n" + UIUXSystemScript.nav_strip_text(mode)


func _rf_097g_handle_key(event: InputEventKey) -> void:
	if state_ref == null:
		return

	if event.keycode == KEY_TAB:
		var current: String = str(_state_get("panel_mode", "inventory"))
		var target: String = UIUXSystemScript.next_mode(current, event.shift_pressed)
		_set_mode(target)
		get_viewport().set_input_as_handled()
		return

	var target_mode: String = UIUXSystemScript.mode_for_keycode(event.keycode)
	if target_mode != "":
		_set_mode(target_mode)
		get_viewport().set_input_as_handled()
		return
