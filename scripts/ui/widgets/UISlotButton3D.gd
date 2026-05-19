extends Button

signal slot_clicked(slot_id: String, payload: Dictionary)
signal slot_double_clicked(slot_id: String, payload: Dictionary)
signal slot_right_clicked(slot_id: String, payload: Dictionary)
signal slot_dropped(slot_id: String, payload: Dictionary)
signal slot_hovered(slot_id: String, payload: Dictionary)

var slot_id: String = ""
var payload: Dictionary = {}
var accepts: Array = []
var selected: bool = false
var disabled_reason: String = ""
var base_color: Color = Color(1, 1, 1, 1)
var allow_drag: bool = true

var _last_click_ms: int = 0

func setup(new_slot_id: String, label: String, new_payload: Dictionary = {}, accept_kinds: Array = [], is_selected: bool = false, tip: String = "", color: Color = Color(1, 1, 1, 1), can_drag: bool = true) -> void:
	slot_id = new_slot_id
	text = label
	payload = new_payload.duplicate(true)
	accepts = accept_kinds.duplicate(true)
	selected = is_selected
	tooltip_text = tip
	base_color = color
	allow_drag = can_drag
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_text = true
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_refresh()

func set_selected(value: bool) -> void:
	selected = value
	_refresh()

func set_disabled_reason(reason: String) -> void:
	disabled_reason = reason
	disabled = reason != ""
	if disabled:
		tooltip_text = reason
	_refresh()

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_text = true
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	_refresh()

func _refresh() -> void:
	if disabled:
		modulate = Color(0.42, 0.42, 0.42, 0.85)
	elif selected:
		modulate = base_color.lerp(Color(1.0, 0.78, 0.18, 1.0), 0.55)
	else:
		modulate = base_color

func _on_mouse_entered() -> void:
	slot_hovered.emit(slot_id, payload)
	if not selected and not disabled:
		modulate = base_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.35)

func _on_mouse_exited() -> void:
	_refresh()

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
	if disabled or not allow_drag or payload.is_empty():
		return null
	var label: Label = Label.new()
	label.text = text
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.modulate = base_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.25)
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
