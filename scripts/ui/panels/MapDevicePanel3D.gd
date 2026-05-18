extends Control

const SlotButtonScript := preload("res://scripts/ui/widgets/UISlotButton3D.gd")

var map_grid: GridContainer = null
var device_slot: VBoxContainer = null
var detail_label: RichTextLabel = null
var start_button: Button = null
var reenter_button: Button = null

var state_ref: Object = null

func _ready() -> void:
	_bind_nodes()
	if start_button != null:
		start_button.pressed.connect(_start)
	if reenter_button != null:
		reenter_button.pressed.connect(_reenter)

func _bind_nodes() -> void:
	map_grid = get_node_or_null("HBox/MapBox/MapVBox/MapScroll/MapGrid") as GridContainer
	device_slot = get_node_or_null("HBox/DeviceBox/DeviceVBox/DeviceSlot") as VBoxContainer
	detail_label = get_node_or_null("HBox/DetailBox/DetailLabel") as RichTextLabel
	start_button = get_node_or_null("HBox/DeviceBox/DeviceVBox/StartButton") as Button
	reenter_button = get_node_or_null("HBox/DeviceBox/DeviceVBox/ReenterButton") as Button

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func update_from_state(state: Object) -> void:
	state_ref = state
	if map_grid == null:
		_bind_nodes()
	_rebuild()

func _clear(root: Node) -> void:
	if root == null:
		return
	for child: Node in root.get_children():
		child.queue_free()

func _maps() -> Array:
	return Array(_state_get("map_stash", []))

func _selected_index() -> int:
	var maps: Array = _maps()
	return clampi(int(_state_get("selected_map_index", 0)), 0, max(0, maps.size() - 1))

func _selected_map() -> Dictionary:
	var maps: Array = _maps()
	if maps.is_empty():
		return {}
	return Dictionary(maps[_selected_index()])

func _rebuild() -> void:
	_clear(map_grid)
	_clear(device_slot)
	if map_grid == null or device_slot == null:
		return

	var maps: Array = _maps()
	var selected: int = _selected_index()
	for i: int in range(maps.size()):
		var map_item: Dictionary = Dictionary(maps[i])
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(145, 64)
		b.setup("map_%d" % i, "T%s\n%s" % [str(map_item.get("tier", 1)), str(map_item.get("display_name", map_item.get("name", "Map"))).substr(0, 18)], {"kind":"map_item", "index":i}, [], i == selected)
		b.slot_clicked.connect(_select_map)
		b.slot_double_clicked.connect(_activate_map)
		map_grid.add_child(b)

	var slot: Button = SlotButtonScript.new()
	var selected_map: Dictionary = _selected_map()
	var label: String = "DROP MAP HERE" if selected_map.is_empty() else "MAP DEVICE\n" + str(selected_map.get("display_name", "Map"))
	slot.custom_minimum_size = Vector2(240, 110)
	slot.setup("device", label, {}, ["map_item"], not selected_map.is_empty())
	slot.slot_dropped.connect(_select_map)
	device_slot.add_child(slot)

	_refresh_detail()

func _select_map(_id: String, payload: Dictionary) -> void:
	if state_ref != null:
		state_ref.set("selected_map_index", int(payload.get("index", 0)))
	_rebuild()

func _activate_map(_id: String, payload: Dictionary) -> void:
	_select_map(_id, payload)
	_start()

func _refresh_detail() -> void:
	if detail_label == null:
		return
	var map_item: Dictionary = _selected_map()
	if map_item.is_empty():
		detail_label.text = "No map selected."
		return
	detail_label.text = "[b]%s[/b]\nTier: %s\nLevel: %s\n\n[b]Modifiers[/b]\n%s" % [str(map_item.get("display_name", "Map")), str(map_item.get("tier", 1)), str(map_item.get("map_level", map_item.get("tier", 1))), str(map_item.get("mods_text", "None"))]

func _start() -> void:
	if state_ref != null and state_ref.has_method("maps_activate_selected"):
		state_ref.call("maps_activate_selected")

func _reenter() -> void:
	if state_ref != null:
		state_ref.set("panel_mode", "")
		if state_ref.has_method("add_notice"):
			state_ref.call("add_notice", "Use T or hub portal to re-enter")
