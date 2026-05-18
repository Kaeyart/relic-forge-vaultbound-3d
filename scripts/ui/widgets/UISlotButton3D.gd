extends Button

signal slot_clicked(slot_id: String, payload: Dictionary)
signal slot_double_clicked(slot_id: String, payload: Dictionary)
signal slot_right_clicked(slot_id: String, payload: Dictionary)
signal slot_dropped(slot_id: String, payload: Dictionary)

var slot_id: String = ""
var payload: Dictionary = {}
var accepts: Array = []
var selected: bool = false
var _last_click_ms: int = 0

func setup(new_slot_id: String, label: String, new_payload: Dictionary = {}, accept_kinds: Array = [], is_selected: bool = false) -> void:
	slot_id = new_slot_id
	text = label
	payload = new_payload.duplicate(true)
	accepts = accept_kinds.duplicate(true)
	selected = is_selected
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_refresh()

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_refresh()

func _refresh() -> void:
	modulate = Color(1.0, 0.86, 0.46, 1.0) if selected else Color(1, 1, 1, 1)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			slot_right_clicked.emit(slot_id, payload)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			var now: int = Time.get_ticks_msec()
			if now - _last_click_ms < 280:
				slot_double_clicked.emit(slot_id, payload)
			else:
				slot_clicked.emit(slot_id, payload)
			_last_click_ms = now

func _get_drag_data(_at_position: Vector2) -> Variant:
	if payload.is_empty():
		return null
	var label: Label = Label.new()
	label.text = text
	set_drag_preview(label)
	return payload.duplicate(true)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if accepts.is_empty():
		return false
	return accepts.has(str(Dictionary(data).get("kind", "")))

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if typeof(data) == TYPE_DICTIONARY:
		slot_dropped.emit(slot_id, Dictionary(data).duplicate(true))
