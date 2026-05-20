extends CanvasLayer
class_name RVVerticalSliceDebugOverlay3D

const RuntimeDetectionSystemScript := preload("res://scripts/systems/RuntimeDetectionSystem3D.gd")
const SmokeTestSystemScript := preload("res://scripts/systems/VerticalSliceSmokeTestSystem3D.gd")

var game_root: Node = null
var _panel: PanelContainer = null
var _label: RichTextLabel = null
var _update_timer: float = 0.0


func _ready() -> void:
	name = "VerticalSliceDebugOverlay098A"
	layer = 90
	visible = false
	RuntimeDetectionSystemScript.mark_generated_visual(self, "vertical_slice_debug")
	_ensure_ui()
	set_process(true)


func bind_game(root: Node) -> void:
	game_root = root


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			visible = not visible
			if visible:
				_update_now()
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not visible:
		return
	_update_timer -= delta
	if _update_timer <= 0.0:
		_update_timer = 0.25
		_update_now()


func _ensure_ui() -> void:
	if _panel != null and is_instance_valid(_panel):
		return

	_panel = PanelContainer.new()
	_panel.name = "VerticalSliceDebugPanel"
	_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_panel.offset_left = 12.0
	_panel.offset_top = 12.0
	_panel.offset_right = 520.0
	_panel.offset_bottom = 250.0

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.035, 0.045, 0.86)
	style.border_color = Color(0.75, 0.58, 0.28, 0.92)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	_label = RichTextLabel.new()
	_label.name = "VerticalSliceDebugText"
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.scroll_active = false
	_label.custom_minimum_size = Vector2(480.0, 210.0)
	_panel.add_child(_label)

	RuntimeDetectionSystemScript.mark_generated_visual(_panel, "vertical_slice_debug")


func _update_now() -> void:
	_ensure_ui()
	if _label == null:
		return

	var root: Node = get_tree().current_scene
	if root == null and game_root != null:
		root = game_root

	var state: Object = _state()
	var report: Dictionary = SmokeTestSystemScript.report(root, state)
	var warnings: Array = Array(report.get("warnings", []))

	var text: String = ""
	text += "[b]098A Vertical Slice Debug[/b]  [i]F3 toggle[/i]\n"
	text += "Mode: " + str(report.get("mode", "")) + " · Panel: " + str(report.get("panel_mode", "")) + "\n"
	text += "Map: " + str(report.get("active_map", "")) + "\n"
	text += "Skill: " + str(report.get("selected_skill", "")) + "\n"
	text += "Enemies: " + str(report.get("enemy_count", 0)) + " · Loot: " + str(report.get("loot_count", 0)) + " · Generated Visuals: " + str(report.get("generated_visual_count", 0)) + "\n"

	if warnings.is_empty():
		text += "\n[color=green]No runtime boundary warnings.[/color]"
	else:
		text += "\n[color=yellow]Warnings[/color]\n"
		for value: Variant in warnings:
			text += " • " + str(value) + "\n"

	_label.text = text


func _state() -> Object:
	if game_root == null:
		return null
	var value: Variant = game_root.get("state")
	if value != null and value is Object:
		return value as Object
	return null
