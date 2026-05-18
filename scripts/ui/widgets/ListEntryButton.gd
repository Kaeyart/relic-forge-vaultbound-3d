extends Button
class_name RVListEntryButton

@export var entry_index: int = -1
signal entry_pressed(index: int)
signal entry_right_pressed(index: int)
signal entry_double_clicked(index: int)

var _last_click_ms: int = 0

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	pressed.connect(_emit_pressed)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			entry_right_pressed.emit(entry_index)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			var now: int = Time.get_ticks_msec()
			if now - _last_click_ms < 300:
				entry_double_clicked.emit(entry_index)
			_last_click_ms = now

func _emit_pressed() -> void:
	entry_pressed.emit(entry_index)
