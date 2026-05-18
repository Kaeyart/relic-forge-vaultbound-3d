extends Control

const SlotButtonScript := preload("res://scripts/ui/widgets/UISlotButton3D.gd")

var equipment_grid: GridContainer = null
var backpack_grid: GridContainer = null
var details_label: RichTextLabel = null
var compare_label: RichTextLabel = null
var equip_button: Button = null

var state_ref: Object = null
var equipment_slots: Array = ["weapon", "offhand", "head", "chest", "gloves", "boots", "amulet", "ring1", "ring2", "relic"]

func _ready() -> void:
	_bind_nodes()
	if equip_button != null:
		equip_button.pressed.connect(_equip_selected)

func _bind_nodes() -> void:
	equipment_grid = get_node_or_null("HBox/EquipmentBox/EquipmentVBox/EquipmentGrid") as GridContainer
	backpack_grid = get_node_or_null("HBox/BackpackBox/BackpackVBox/BackpackScroll/BackpackGrid") as GridContainer
	details_label = get_node_or_null("HBox/DetailsBox/DetailsVBox/DetailsLabel") as RichTextLabel
	compare_label = get_node_or_null("HBox/DetailsBox/DetailsVBox/CompareLabel") as RichTextLabel
	equip_button = get_node_or_null("HBox/DetailsBox/DetailsVBox/EquipButton") as Button

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func update_from_state(state: Object) -> void:
	state_ref = state
	if equipment_grid == null:
		_bind_nodes()
	_rebuild()

func _clear(root: Node) -> void:
	if root == null:
		return
	for child: Node in root.get_children():
		child.queue_free()

func _rebuild() -> void:
	_clear(equipment_grid)
	_clear(backpack_grid)
	if equipment_grid == null or backpack_grid == null:
		return

	var equipped: Dictionary = Dictionary(_state_get("equipped", {}))
	for slot_name: String in equipment_slots:
		var item: Dictionary = Dictionary(equipped.get(slot_name, {}))
		var label: String = slot_name.to_upper()
		if not item.is_empty():
			label += "\n" + str(item.get("display_name", item.get("name", "Item"))).substr(0, 18)
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(128, 68)
		b.setup(slot_name, label, {"kind":"equipment_slot", "slot":slot_name}, ["inventory_item"], false)
		b.slot_dropped.connect(_on_equipment_drop)
		equipment_grid.add_child(b)

	var backpack: Array = Array(_state_get("backpack", []))
	var cursor: int = clampi(int(_state_get("inventory_cursor", 0)), 0, max(0, backpack.size() - 1))
	for i: int in range(backpack.size()):
		var item: Dictionary = Dictionary(backpack[i])
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(116, 64)
		b.setup("item_%d" % i, str(item.get("display_name", item.get("name", "Item"))).substr(0, 20), {"kind":"inventory_item", "index":i}, [], i == cursor)
		b.slot_clicked.connect(_on_item_click)
		b.slot_double_clicked.connect(_on_item_double)
		b.slot_right_clicked.connect(_on_item_double)
		backpack_grid.add_child(b)

	_refresh_details()

func _on_item_click(_id: String, payload: Dictionary) -> void:
	if state_ref != null:
		state_ref.set("inventory_cursor", int(payload.get("index", 0)))
	_rebuild()

func _on_item_double(_id: String, payload: Dictionary) -> void:
	if state_ref != null:
		state_ref.set("inventory_cursor", int(payload.get("index", 0)))
	_equip_selected()

func _on_equipment_drop(_slot_id: String, payload: Dictionary) -> void:
	if state_ref != null and str(payload.get("kind", "")) == "inventory_item":
		state_ref.set("inventory_cursor", int(payload.get("index", 0)))
	_equip_selected()

func _equip_selected() -> void:
	if state_ref != null and state_ref.has_method("inventory_equip_selected"):
		state_ref.call("inventory_equip_selected")
	_rebuild()

func _refresh_details() -> void:
	if details_label == null:
		return
	var backpack: Array = Array(_state_get("backpack", []))
	if backpack.is_empty():
		details_label.text = "Backpack is empty."
		if compare_label != null:
			compare_label.text = ""
		return

	var index: int = clampi(int(_state_get("inventory_cursor", 0)), 0, backpack.size() - 1)
	var item: Dictionary = Dictionary(backpack[index])
	var lines: PackedStringArray = []
	lines.append("[b]" + str(item.get("display_name", "Item")) + "[/b]")
	lines.append(str(item.get("rarity", "normal")).to_upper() + " · " + str(item.get("slot", "")))
	lines.append("Item Level " + str(item.get("item_level", 1)) + " · Forge " + str(item.get("forge_potential", 0)))

	var stats: Dictionary = Dictionary(item.get("total_stats", {}))
	if not stats.is_empty():
		lines.append("")
		lines.append("[b]Stats[/b]")
		for k: Variant in stats.keys():
			lines.append("+ %s %s" % [str(stats[k]), str(k)])

	details_label.text = "\n".join(lines)
	if compare_label != null:
		compare_label.text = "[b]Action[/b]\nDouble click / right click / drag to equipment slot / Equip button."
