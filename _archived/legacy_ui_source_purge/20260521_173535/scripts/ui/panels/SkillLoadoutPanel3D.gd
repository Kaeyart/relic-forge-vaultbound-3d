extends PanelContainer
class_name RVSkillLoadoutPanel3D

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

@onready var slot_list: ItemList = %SlotList
@onready var details_label: RichTextLabel = %DetailsLabel
@onready var prev_active_button: Button = %PrevActiveButton
@onready var next_active_button: Button = %NextActiveButton
@onready var add_support_button: Button = %AddSupportButton
@onready var remove_support_button: Button = %RemoveSupportButton
@onready var toggle_spirit_button: Button = %ToggleSpiritButton

var state_ref: Object = null

func _ready() -> void:
	slot_list.item_selected.connect(_on_slot_selected)
	prev_active_button.pressed.connect(_cycle_active.bind(-1))
	next_active_button.pressed.connect(_cycle_active.bind(1))
	add_support_button.pressed.connect(_add_support)
	remove_support_button.pressed.connect(_remove_support)
	toggle_spirit_button.pressed.connect(_toggle_spirit)

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func update_from_state(state: Object) -> void:
	state_ref = state
	if state_ref != null:
		SkillGemSystemScript.ensure_defaults(state_ref)
	_refresh_from_state()

func _refresh_from_state() -> void:
	if state_ref == null:
		return
	slot_list.clear()
	var slots: Array = Array(_state_get("active_skill_slots", []))
	var selected: int = clampi(int(_state_get("selected_skill_slot", 0)), 0, max(0, slots.size() - 1))
	for i: int in range(slots.size()):
		var slot: Dictionary = Dictionary(slots[i])
		var active_name: String = str(slot.get("active", slot.get("active_id", "fireball")))
		var supports: Array = Array(slot.get("supports", []))
		slot_list.add_item("Slot %d - %s [%s]" % [i + 1, active_name, ", ".join(supports)])
	if slots.size() > 0:
		slot_list.select(selected)
	details_label.text = SkillGemSystemScript.panel_text(state_ref)

func _on_slot_selected(index: int) -> void:
	if state_ref != null:
		state_ref.set("selected_skill_slot", index)
	_refresh_from_state()

func _cycle_active(dir: int) -> void:
	if state_ref != null:
		SkillGemSystemScript.cycle_active_slot_gem(state_ref, dir)
	_refresh_from_state()

func _add_support() -> void:
	if state_ref != null:
		SkillGemSystemScript.add_next_valid_support(state_ref)
	_refresh_from_state()

func _remove_support() -> void:
	if state_ref != null:
		SkillGemSystemScript.remove_last_support(state_ref)
	_refresh_from_state()

func _toggle_spirit() -> void:
	if state_ref != null:
		SkillGemSystemScript.toggle_next_spirit(state_ref)
	_refresh_from_state()
