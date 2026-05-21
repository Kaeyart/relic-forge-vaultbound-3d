extends PanelContainer
class_name RVMapPanel3D

@onready var map_list: ItemList = %MapList
@onready var details_label: RichTextLabel = %DetailsLabel
@onready var activate_button: Button = %ActivateButton

var state_ref: Object = null

func _ready() -> void:
	map_list.item_selected.connect(_on_map_selected)
	map_list.item_activated.connect(_on_map_activated)
	activate_button.pressed.connect(_activate_selected)

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func update_from_state(state: Object) -> void:
	state_ref = state
	_refresh_from_state()

func _refresh_from_state() -> void:
	if state_ref == null:
		return
	map_list.clear()
	var maps: Array = Array(_state_get("map_stash", []))
	var selected_index: int = clampi(int(_state_get("selected_map_index", 0)), 0, max(0, maps.size() - 1))
	for map_value: Variant in maps:
		var map_item: Dictionary = Dictionary(map_value)
		map_list.add_item(str(map_item.get("display_name", map_item.get("name", "Map"))))
	if maps.size() > 0:
		map_list.select(selected_index)
	_refresh_details()

func _on_map_selected(index: int) -> void:
	if state_ref != null:
		state_ref.set("selected_map_index", index)
	_refresh_details()

func _on_map_activated(index: int) -> void:
	if state_ref != null:
		state_ref.set("selected_map_index", index)
	_activate_selected()

func _refresh_details() -> void:
	if state_ref == null:
		details_label.text = ""
		return
	var maps: Array = Array(_state_get("map_stash", []))
	if maps.is_empty():
		details_label.text = "No maps available."
		return
	var index: int = clampi(int(_state_get("selected_map_index", 0)), 0, maps.size() - 1)
	var map_item: Dictionary = Dictionary(maps[index])
	var lines: PackedStringArray = []
	lines.append("[b]" + str(map_item.get("display_name", "Map")) + "[/b]")
	lines.append("Tier: " + str(map_item.get("tier", 1)))
	lines.append("Completed: " + str(map_item.get("completed", false)))
	lines.append("")
	lines.append("Modifiers:")
	lines.append(str(map_item.get("mods_text", "None")))
	details_label.text = "\n".join(lines)

func _activate_selected() -> void:
	if state_ref != null and state_ref.has_method("maps_activate_selected"):
		state_ref.call("maps_activate_selected")
