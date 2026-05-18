class_name RVSkillLoadoutPanel3D
extends CanvasLayer

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")
const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

@onready var root: Control = $Root
@onready var summary_label: Label = $Root/Panel/SummaryLabel
@onready var detail_text: RichTextLabel = $Root/Panel/DetailText
@onready var slot_box: VBoxContainer = $Root/Panel/Columns/SlotsColumn/SlotButtons
@onready var active_box: VBoxContainer = $Root/Panel/Columns/ActiveColumn/ActiveButtons
@onready var support_box: VBoxContainer = $Root/Panel/Columns/SupportColumn/SupportButtons
@onready var spirit_box: VBoxContainer = $Root/Panel/Columns/SpiritColumn/SpiritButtons
@onready var close_button: Button = $Root/Panel/CloseButton

var state_ref: Object = null
var _bound: bool = false

func _ready() -> void:
	root.visible = false
	close_button.pressed.connect(_on_close_pressed)

func update_from_state(state: Object) -> void:
	state_ref = state
	if state_ref == null:
		root.visible = false
		return
	var show: bool = str(state_ref.get("panel_mode")) == "skills"
	root.visible = show
	if not show:
		return
	SkillGemSystemScript.ensure_loadout_defaults(state_ref)
	_rebuild_buttons()
	_refresh_text()

func _rebuild_buttons() -> void:
	_clear(slot_box)
	_clear(active_box)
	_clear(support_box)
	_clear(spirit_box)
	for i: int in range(4):
		var active: Dictionary = SkillGemSystemScript.active_gem_for_slot(state_ref, i)
		var btn := Button.new()
		btn.text = ("> " if i == int(state_ref.get("skill_panel_selected_slot")) else "") + "Slot " + str(i + 1) + ": " + str(active.get("name", "Empty"))
		btn.pressed.connect(_select_slot.bind(i))
		slot_box.add_child(btn)
	for gem_value: Variant in Array(state_ref.get("active_gem_inventory")):
		var gem: Dictionary = Dictionary(gem_value)
		var abtn := Button.new()
		abtn.text = str(gem.get("name", "Active")) + " Lv" + str(int(gem.get("level", 1)))
		abtn.tooltip_text = GemDBScript.gem_detail("active", str(gem.get("gem_id", "")))
		abtn.pressed.connect(_assign_active.bind(str(gem.get("uid", ""))))
		active_box.add_child(abtn)
	var selected_slot: int = int(state_ref.get("skill_panel_selected_slot"))
	var active_gem: Dictionary = SkillGemSystemScript.active_gem_for_slot(state_ref, selected_slot)
	var active_id: String = str(active_gem.get("gem_id", ""))
	for support_value: Variant in Array(state_ref.get("support_gem_inventory")):
		var support: Dictionary = Dictionary(support_value)
		var sbtn := Button.new()
		var valid: bool = active_id != "" and GemDBScript.can_support(active_id, str(support.get("gem_id", "")))
		var equipped: bool = _slot_has_support(selected_slot, str(support.get("uid", "")))
		sbtn.text = ("[x] " if equipped else "[ ] ") + str(support.get("name", "Support")) + ("" if valid else " (invalid)")
		sbtn.disabled = not valid
		sbtn.tooltip_text = GemDBScript.gem_detail("support", str(support.get("gem_id", "")))
		sbtn.pressed.connect(_toggle_support.bind(str(support.get("uid", ""))))
		support_box.add_child(sbtn)
	for spirit_value: Variant in Array(state_ref.get("spirit_gem_inventory")):
		var spirit: Dictionary = Dictionary(spirit_value)
		var spbtn := Button.new()
		spbtn.text = ("[on] " if bool(spirit.get("enabled", false)) else "[off] ") + str(spirit.get("name", "Spirit")) + " (" + str(int(spirit.get("reservation", 0))) + ")"
		spbtn.tooltip_text = GemDBScript.gem_detail("spirit", str(spirit.get("gem_id", "")))
		spbtn.pressed.connect(_toggle_spirit.bind(str(spirit.get("uid", ""))))
		spirit_box.add_child(spbtn)

func _refresh_text() -> void:
	summary_label.text = "Spirit: " + str(int(state_ref.get("spirit_reserved"))) + " / " + str(int(state_ref.get("spirit_max"))) + " reserved   Selected Slot: " + str(int(state_ref.get("skill_panel_selected_slot")) + 1)
	var selected_slot: int = int(state_ref.get("skill_panel_selected_slot"))
	var cast_data: Dictionary = SkillGemSystemScript.build_cast_data(state_ref, selected_slot)
	if cast_data.is_empty():
		detail_text.text = "Select an active gem for this slot."
		return
	detail_text.text = "[b]" + str(cast_data.get("name", "Skill")) + "[/b]\n"
	detail_text.text += "Damage: " + str(int(round(float(cast_data.get("damage", 0.0))))) + "\n"
	detail_text.text += "Mana Cost: " + str(int(round(float(cast_data.get("mana_cost", 0.0))))) + "\n"
	detail_text.text += "Tags: " + ", ".join(PackedStringArray(_string_array(Array(cast_data.get("tags", []))))) + "\n"
	detail_text.text += "Extra Projectiles: " + str(int(cast_data.get("extra_projectiles", 0))) + "  Chain: " + str(int(cast_data.get("chain_count", 0))) + "  Echo: " + str(int(cast_data.get("echo_count", 0))) + "\n"
	detail_text.text += "Ignite: " + str(int(float(cast_data.get("ignite_chance", 0.0)) * 100.0)) + "%  Shock: " + str(int(float(cast_data.get("shock_chance", 0.0)) * 100.0)) + "%  Bleed: " + str(int(float(cast_data.get("bleed_chance", 0.0)) * 100.0)) + "%\n"

func _select_slot(index: int) -> void:
	state_ref.set("skill_panel_selected_slot", index)
	state_ref.set("selected_skill_slot", index)
	_rebuild_buttons()
	_refresh_text()

func _assign_active(uid: String) -> void:
	SkillGemSystemScript.set_active_for_slot(state_ref, int(state_ref.get("skill_panel_selected_slot")), uid)
	_rebuild_buttons()
	_refresh_text()

func _toggle_support(uid: String) -> void:
	SkillGemSystemScript.toggle_support_for_slot(state_ref, int(state_ref.get("skill_panel_selected_slot")), uid)
	_rebuild_buttons()
	_refresh_text()

func _toggle_spirit(uid: String) -> void:
	SkillGemSystemScript.toggle_spirit_gem(state_ref, uid)
	_rebuild_buttons()
	_refresh_text()

func _slot_has_support(slot_index: int, uid: String) -> bool:
	var loadout: Array = Array(state_ref.get("skill_loadout"))
	if slot_index < 0 or slot_index >= loadout.size():
		return false
	return Array(Dictionary(loadout[slot_index]).get("support_uids", [])).has(uid)

func _on_close_pressed() -> void:
	if state_ref != null:
		state_ref.set("panel_mode", "")

func _clear(container: Node) -> void:
	for child: Node in container.get_children():
		child.queue_free()

func _string_array(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value: Variant in values:
		out.append(str(value))
	return out
