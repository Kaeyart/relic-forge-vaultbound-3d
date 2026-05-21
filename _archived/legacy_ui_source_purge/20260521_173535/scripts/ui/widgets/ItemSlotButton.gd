extends TextureButton
class_name RVItemSlotButton

@export var slot_id: String = ""
signal slot_clicked(slot_id: String)
signal slot_right_clicked(slot_id: String)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	pressed.connect(func() -> void: slot_clicked.emit(slot_id))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		slot_right_clicked.emit(slot_id)
