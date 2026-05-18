extends Control

const SlotButtonScript := preload("res://scripts/ui/widgets/UISlotButton3D.gd")

var item_grid: GridContainer = null
var forge_slot: VBoxContainer = null
var preview_label: RichTextLabel = null
var materials_label: RichTextLabel = null
var seal_button: Button = null
var reforge_button: Button = null
var polish_button: Button = null
var apply_button: Button = null

var state_ref: Object = null
var selected_action: String = "seal"

func _ready() -> void:
	_bind_nodes()
	if seal_button != null:
		seal_button.pressed.connect(_select_action.bind("seal"))
	if reforge_button != null:
		reforge_button.pressed.connect(_select_action.bind("reforge"))
	if polish_button != null:
		polish_button.pressed.connect(_select_action.bind("polish"))
	if apply_button != null:
		apply_button.pressed.connect(_apply_action)

func _bind_nodes() -> void:
	item_grid = get_node_or_null("HBox/ItemsBox/ItemsVBox/ItemsScroll/CraftableGrid") as GridContainer
	forge_slot = get_node_or_null("HBox/ForgeBox/ForgeVBox/ForgeSlot") as VBoxContainer
	preview_label = get_node_or_null("HBox/InfoBox/InfoVBox/PreviewLabel") as RichTextLabel
	materials_label = get_node_or_null("HBox/InfoBox/InfoVBox/MaterialsLabel") as RichTextLabel
	seal_button = get_node_or_null("HBox/ForgeBox/ForgeVBox/SealButton") as Button
	reforge_button = get_node_or_null("HBox/ForgeBox/ForgeVBox/ReforgeButton") as Button
	polish_button = get_node_or_null("HBox/ForgeBox/ForgeVBox/PolishButton") as Button
	apply_button = get_node_or_null("HBox/ForgeBox/ForgeVBox/ApplyButton") as Button

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func update_from_state(state: Object) -> void:
	state_ref = state
	if item_grid == null:
		_bind_nodes()
	_rebuild()

func _clear(root: Node) -> void:
	if root == null:
		return
	for child: Node in root.get_children():
		child.queue_free()

func _rebuild() -> void:
	_clear(item_grid)
	_clear(forge_slot)
	if item_grid == null or forge_slot == null:
		return

	var backpack: Array = Array(_state_get("backpack", []))
	var selected_uid: String = str(_state_get("crafting_selected_item_uid", ""))
	for i: int in range(backpack.size()):
		var item: Dictionary = Dictionary(backpack[i])
		var uid: String = str(item.get("uid", ""))
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(126, 64)
		b.setup("craft_%d" % i, str(item.get("display_name", "Item")).substr(0, 18), {"kind":"inventory_item", "index":i, "uid":uid}, [], uid == selected_uid)
		b.slot_clicked.connect(_select_payload)
		b.slot_double_clicked.connect(_select_payload)
		item_grid.add_child(b)

	var slot_button: Button = SlotButtonScript.new()
	var label: String = "DROP ITEM HERE"
	var item: Dictionary = _selected_item()
	if not item.is_empty():
		label = "FORGE ITEM\n" + str(item.get("display_name", "Item"))
	slot_button.custom_minimum_size = Vector2(230, 110)
	slot_button.setup("forge_slot", label, {}, ["inventory_item"], not item.is_empty())
	slot_button.slot_dropped.connect(_select_payload)
	forge_slot.add_child(slot_button)

	_refresh_text()

func _select_payload(_id: String, payload: Dictionary) -> void:
	if state_ref == null:
		return
	var backpack: Array = Array(_state_get("backpack", []))
	var index: int = int(payload.get("index", -1))
	if index >= 0 and index < backpack.size():
		state_ref.set("crafting_selected_item_uid", str(Dictionary(backpack[index]).get("uid", "")))
	_rebuild()

func _selected_item() -> Dictionary:
	var uid: String = str(_state_get("crafting_selected_item_uid", ""))
	if uid == "":
		return {}
	for item_value: Variant in Array(_state_get("backpack", [])):
		var item: Dictionary = Dictionary(item_value)
		if str(item.get("uid", "")) == uid:
			return item
	return {}

func _select_action(action: String) -> void:
	selected_action = action
	_refresh_text()

func _apply_action() -> void:
	if state_ref != null and state_ref.has_method("crafting_apply_action"):
		state_ref.call("crafting_apply_action", selected_action)
	_rebuild()

func _refresh_text() -> void:
	var item: Dictionary = _selected_item()
	if preview_label != null:
		preview_label.text = "Select or drag an item into the forge." if item.is_empty() else "[b]" + str(item.get("display_name", "Item")) + "[/b]\nAction: " + selected_action.capitalize() + "\nForge Potential: " + str(item.get("forge_potential", 0))
	if materials_label != null:
		var currency: Dictionary = Dictionary(_state_get("currency", {}))
		var lines: PackedStringArray = ["[b]Materials[/b]"]
		for k: Variant in currency.keys():
			lines.append("- %s: %s" % [str(k), str(currency[k])])
		materials_label.text = "\n".join(lines)
