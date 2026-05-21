extends Control

const MockStateScript := preload("res://scripts/ui/lab/UIMockState3D.gd")
const HUDScript := preload("res://scripts/ui/GameHUD3D.gd")
const PanelRootScript := preload("res://scripts/ui/UIPanelRoot3D.gd")

var _state: Node = null
var _hud: CanvasLayer = null
var _panel_root: CanvasLayer = null
var _buttons: HBoxContainer = null

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	_build_lab()

func _build_lab() -> void:
	_state = MockStateScript.new()
	add_child(_state)

	_hud = CanvasLayer.new()
	_hud.set_script(HUDScript)
	add_child(_hud)
	if _hud.has_method("bind_state"):
		_hud.call("bind_state", _state)

	_panel_root = CanvasLayer.new()
	_panel_root.set_script(PanelRootScript)
	add_child(_panel_root)
	if _panel_root.has_method("bind_state"):
		_panel_root.call("bind_state", _state)

	_buttons = HBoxContainer.new()
	_buttons.name = "LabButtons"
	_buttons.anchor_left = 0.26
	_buttons.anchor_top = 0.01
	_buttons.anchor_right = 0.74
	_buttons.anchor_bottom = 0.06
	_buttons.add_theme_constant_override("separation", 6)
	add_child(_buttons)
	for mode: String in ["inventory", "skills", "maps", "crafting", "stash", "character"]:
		var b: Button = Button.new()
		b.text = mode.capitalize()
		var callable: Callable = _set_panel.bind(mode)
		b.pressed.connect(callable)
		_buttons.add_child(b)

func _set_panel(mode: String) -> void:
	if _state != null:
		_state.set("panel_mode", mode)
	if _hud != null and _hud.has_method("update_from_state"):
		_hud.call("update_from_state", _state)
	if _panel_root != null and _panel_root.has_method("update_from_state"):
		_panel_root.call("update_from_state", _state)
