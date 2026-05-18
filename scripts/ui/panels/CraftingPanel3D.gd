extends PanelContainer
class_name RVCraftingPanel3D

@onready var item_list: ItemList = %ItemList
@onready var details_label: RichTextLabel = %DetailsLabel
@onready var materials_label: RichTextLabel = %MaterialsLabel
@onready var seal_button: Button = %SealButton
@onready var reforge_button: Button = %ReforgeButton
@onready var polish_button: Button = %PolishButton

var state_ref: Object = null

func _ready() -> void:
	item_list.item_selected.connect(_on_item_selected)
	seal_button.pressed.connect(_apply_action.bind("seal"))
	reforge_button.pressed.connect(_apply_action.bind("reforge"))
	polish_button.pressed.connect(_apply_action.bind("polish"))

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
	item_list.clear()
	var backpack: Array = Array(_state_get("backpack", []))
	var selected_uid: String = str(_state_get("crafting_selected_item_uid", ""))
	var selected_index: int = -1
	for i: int in range(backpack.size()):
		var item: Dictionary = Dictionary(backpack[i])
		item_list.add_item(str(item.get("display_name", item.get("name", "Unknown Item"))))
		if str(item.get("uid", "")) == selected_uid:
			selected_index = i
	if selected_index >= 0:
		item_list.select(selected_index)
	_refresh_details()
	_refresh_materials()

func _on_item_selected(index: int) -> void:
	if state_ref == null:
		return
	var backpack: Array = Array(_state_get("backpack", []))
	if index < 0 or index >= backpack.size():
		return
	state_ref.set("crafting_selected_item_uid", str(Dictionary(backpack[index]).get("uid", "")))
	_refresh_details()

func _refresh_details() -> void:
	if state_ref == null:
		details_label.text = "Select an item to craft."
		return
	var selected_uid: String = str(_state_get("crafting_selected_item_uid", ""))
	if selected_uid == "":
		details_label.text = "Select an item to craft."
		return
	var backpack: Array = Array(_state_get("backpack", []))
	for item_value: Variant in backpack:
		var item: Dictionary = Dictionary(item_value)
		if str(item.get("uid", "")) == selected_uid:
			var lines: PackedStringArray = []
			lines.append("[b]" + str(item.get("display_name", "Item")) + "[/b]")
			lines.append("Rarity: " + str(item.get("rarity", "normal")))
			lines.append("Forge Potential: " + str(item.get("forge_potential", 0)))
			lines.append("\nActions: Seal / Reforge / Polish")
			details_label.text = "\n".join(lines)
			return
	details_label.text = "Selected item not found."

func _refresh_materials() -> void:
	if state_ref == null:
		materials_label.text = ""
		return
	var currency: Dictionary = Dictionary(_state_get("currency", {}))
	var lines: PackedStringArray = ["[b]Materials[/b]"]
	for k: Variant in currency.keys():
		lines.append("- %s: %s" % [str(k), str(currency[k])])
	materials_label.text = "\n".join(lines)

func _apply_action(action_id: String) -> void:
	if state_ref != null and state_ref.has_method("crafting_apply_action"):
		state_ref.call("crafting_apply_action", action_id)
	_refresh_from_state()
