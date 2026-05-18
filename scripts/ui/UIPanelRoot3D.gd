extends CanvasLayer

var blocker: ColorRect = null
var shell: PanelContainer = null
var title_label: Label = null
var inventory_panel: Control = null
var forge_panel: Control = null
var skills_panel: Control = null
var maps_panel: Control = null
var character_panel: Control = null

var state_ref: Object = null

func _ready() -> void:
	_bind_nodes()
	_connect_buttons()
	_refresh()

func _bind_nodes() -> void:
	blocker = get_node_or_null("Blocker") as ColorRect
	shell = get_node_or_null("Shell") as PanelContainer
	title_label = get_node_or_null("Shell/VBox/Header/TitleLabel") as Label
	inventory_panel = get_node_or_null("Shell/VBox/Content/InventoryPanel") as Control
	forge_panel = get_node_or_null("Shell/VBox/Content/ForgePanel") as Control
	skills_panel = get_node_or_null("Shell/VBox/Content/SkillsPanel") as Control
	maps_panel = get_node_or_null("Shell/VBox/Content/MapsPanel") as Control
	character_panel = get_node_or_null("Shell/VBox/Content/CharacterPanel") as Control

func _connect_buttons() -> void:
	var tab_inventory: Button = get_node_or_null("Shell/VBox/Tabs/TabInventory") as Button
	var tab_forge: Button = get_node_or_null("Shell/VBox/Tabs/TabForge") as Button
	var tab_skills: Button = get_node_or_null("Shell/VBox/Tabs/TabSkills") as Button
	var tab_maps: Button = get_node_or_null("Shell/VBox/Tabs/TabMaps") as Button
	var tab_character: Button = get_node_or_null("Shell/VBox/Tabs/TabCharacter") as Button
	var close_button: Button = get_node_or_null("Shell/VBox/Header/CloseButton") as Button
	if tab_inventory != null:
		tab_inventory.pressed.connect(_set_mode.bind("inventory"))
	if tab_forge != null:
		tab_forge.pressed.connect(_set_mode.bind("crafting"))
	if tab_skills != null:
		tab_skills.pressed.connect(_set_mode.bind("skills"))
	if tab_maps != null:
		tab_maps.pressed.connect(_set_mode.bind("maps"))
	if tab_character != null:
		tab_character.pressed.connect(_set_mode.bind("character"))
	if close_button != null:
		close_button.pressed.connect(_close)

func bind_state(state: Object) -> void:
	state_ref = state
	update_from_state(state)

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func update_from_state(state: Object) -> void:
	state_ref = state
	if shell == null:
		_bind_nodes()
	_refresh()
	var panel: Node = _active_panel()
	if panel != null and panel.has_method("update_from_state"):
		panel.call("update_from_state", state_ref)

func _set_mode(mode: String) -> void:
	if state_ref != null:
		state_ref.set("panel_mode", mode)
		update_from_state(state_ref)

func _close() -> void:
	if state_ref != null:
		state_ref.set("panel_mode", "")
		update_from_state(state_ref)

func _refresh() -> void:
	var mode: String = str(_state_get("panel_mode", ""))
	var open: bool = mode != ""
	if blocker != null:
		blocker.visible = open
	if shell != null:
		shell.visible = open
	if inventory_panel != null:
		inventory_panel.visible = mode == "inventory"
	if forge_panel != null:
		forge_panel.visible = mode == "crafting"
	if skills_panel != null:
		skills_panel.visible = mode == "skills"
	if maps_panel != null:
		maps_panel.visible = mode == "maps"
	if character_panel != null:
		character_panel.visible = mode == "character"
	if title_label != null:
		title_label.text = _title(mode)

func _active_panel() -> Node:
	match str(_state_get("panel_mode", "")):
		"inventory": return inventory_panel
		"crafting": return forge_panel
		"skills": return skills_panel
		"maps": return maps_panel
		"character": return character_panel
		_: return null

func _title(mode: String) -> String:
	match mode:
		"inventory": return "Inventory & Equipment"
		"crafting": return "Forge"
		"skills": return "Skill Gems"
		"maps": return "Map Device"
		"character": return "Character"
		_: return ""
