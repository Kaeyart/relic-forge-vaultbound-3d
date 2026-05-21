extends HBoxContainer

const UIFoundationSystemScript := preload("res://scripts/systems/UIFoundationSystem3D.gd")

signal action_requested(action_id: String)

var mode: String = ""

func _ready() -> void:
	add_theme_constant_override("separation", 8)

func set_mode(new_mode: String) -> void:
	mode = new_mode
	_rebuild()

func _rebuild() -> void:
	for child: Node in get_children():
		child.queue_free()

	var actions: Array[Dictionary] = UIFoundationSystemScript.panel_actions(mode)
	for action: Dictionary in actions:
		var button := Button.new()
		button.text = str(action.get("label", "Action"))
		button.custom_minimum_size = Vector2(112, 34)
		var action_id: String = str(action.get("id", ""))
		button.pressed.connect(func() -> void:
			action_requested.emit(action_id)
		)
		add_child(button)
