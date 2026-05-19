class_name RVSkillLoadoutPanel3D
extends CanvasLayer

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")
const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

var root: Control = null
var summary_label: Label = null
var detail_text: RichTextLabel = null
var slot_box: VBoxContainer = null
var active_box: VBoxContainer = null
var support_box: VBoxContainer = null
var spirit_box: VBoxContainer = null
var close_button: Button = null
var state_ref: Object = null

func _ready() -> void:
	_bind_nodes()
	if root != null: root.visible = false
	if close_button != null: close_button.pressed.connect(_on_close_pressed)

func _bind_nodes() -> void:
	root = get_node_or_null("Root") as Control
	summary_label = get_node_or_null("Root/Panel/SummaryLabel") as Label
	detail_text = get_node_or_null("Root/Panel/DetailText") as RichTextLabel
	slot_box = get_node_or_null("Root/Panel/Columns/SlotsColumn/SlotButtons") as VBoxContainer
	active_box = get_node_or_null("Root/Panel/Columns/ActiveColumn/ActiveButtons") as VBoxContainer
	support_box = get_node_or_null("Root/Panel/Columns/SupportColumn/SupportButtons") as VBoxContainer
	spirit_box = get_node_or_null("Root/Panel/Columns/SpiritColumn/SpiritButtons") as VBoxContainer
	close_button = get_node_or_null("Root/Panel/CloseButton") as Button

func bind_state(state: Object) -> void:
	update_from_state(state)

func update_from_state(state: Object) -> void:
	state_ref = state
	if root == null: _bind_nodes()
	if state_ref == null:
		if root != null: root.visible = false
		return
	var show: bool = str(_state_get("panel_mode", "")) == "skills"
	if root != null: root.visible = show
	if not show: return
	SkillGemSystemScript.ensure_defaults(state_ref)
	_ensure_selected_slot()
	_rebuild_buttons()
	_refresh_text()

func _rebuild_buttons() -> void:
	_clear(slot_box); _clear(active_box); _clear(support_box); _clear(spirit_box)
	var slots: Array = Array(_state_get("active_skill_slots", []))
	var selected_slot: int = _selected_slot_index()
	for i: int in range(4):
		var slot: Dictionary = {}
		if i < slots.size() and typeof(slots[i]) == TYPE_DICTIONARY: slot = Dictionary(slots[i])
		var active_id: String = str(slot.get("active", slot.get("active_id", "fireball")))
		var active_data: Dictionary = GemDBScript.active(active_id)
		var btn: Button = Button.new()
		btn.text = ("> " if i == selected_slot else "") + "Slot " + str(i + 1) + ": " + str(active_data.get("name", active_id))
		btn.tooltip_text = _gem_detail("active", active_id)
		btn.pressed.connect(_select_slot.bind(i))
		if slot_box != null: slot_box.add_child(btn)
	var active_owned: Dictionary = Dictionary(_state_get("active_gems_owned", {}))
	for key_value: Variant in active_owned.keys():
		if not bool(active_owned[key_value]): continue
		var active_id_2: String = str(key_value)
		var active: Dictionary = GemDBScript.active(active_id_2)
		var abtn: Button = Button.new()
		abtn.text = str(active.get("name", active_id_2))
		abtn.tooltip_text = _gem_detail("active", active_id_2)
		abtn.pressed.connect(_assign_active.bind(active_id_2))
		if active_box != null: active_box.add_child(abtn)
	var selected_active_id: String = _active_id_for_slot(selected_slot)
	var support_owned: Dictionary = Dictionary(_state_get("support_gems_owned", {}))
	for support_key: Variant in support_owned.keys():
		if _safe_int(support_owned[support_key]) <= 0: continue
		var support_id: String = str(support_key)
		var valid: bool = selected_active_id != "" and GemDBScript.support_compatible(selected_active_id, support_id)
		var equipped: bool = _slot_has_support(selected_slot, support_id)
		var support: Dictionary = GemDBScript.support(support_id)
		var sbtn: Button = Button.new()
		sbtn.text = ("[x] " if equipped else "[ ] ") + str(support.get("name", support_id)) + ("" if valid else " (invalid)")
		sbtn.disabled = not valid
		sbtn.tooltip_text = _gem_detail("support", support_id)
		sbtn.pressed.connect(_toggle_support.bind(support_id))
		if support_box != null: support_box.add_child(sbtn)
	var spirits: Dictionary = Dictionary(_state_get("spirit_gems_owned", {}))
	for spirit_key: Variant in spirits.keys():
		var spirit_id: String = str(spirit_key)
		var spirit: Dictionary = GemDBScript.spirit(spirit_id)
		var enabled: bool = bool(spirits[spirit_key])
		var spbtn: Button = Button.new()
		spbtn.text = ("[on] " if enabled else "[off] ") + str(spirit.get("name", spirit_id)) + " (" + str(_safe_int(spirit.get("reservation", 0))) + ")"
		spbtn.tooltip_text = _gem_detail("spirit", spirit_id)
		spbtn.pressed.connect(_toggle_spirit.bind(spirit_id))
		if spirit_box != null: spirit_box.add_child(spbtn)

func _refresh_text() -> void:
	if state_ref == null: return
	var selected_slot: int = _selected_slot_index()
	if summary_label != null:
		summary_label.text = "Spirit: " + str(_safe_int(_state_get("spirit_reserved", 0))) + " / " + str(_safe_int(_state_get("spirit_max", 0))) + " reserved   Selected Slot: " + str(selected_slot + 1)
	var slots: Array = Array(_state_get("active_skill_slots", []))
	var slot: Dictionary = {}
	if selected_slot >= 0 and selected_slot < slots.size() and typeof(slots[selected_slot]) == TYPE_DICTIONARY: slot = Dictionary(slots[selected_slot])
	else: slot = SkillGemSystemScript.selected_slot(state_ref)
	var cast_data: Dictionary = SkillGemSystemScript.cast_data_for_slot(state_ref, slot)
	if detail_text == null: return
	if cast_data.is_empty():
		detail_text.text = "Select an active gem for this slot."
		return
	detail_text.text = "[b]" + str(cast_data.get("name", "Skill")) + "[/b]\n"
	detail_text.text += "Damage: " + str(_safe_int(round(_safe_float(cast_data.get("damage", 0.0))))) + "\n"
	detail_text.text += "Mana Cost: " + str(_safe_int(round(_safe_float(cast_data.get("mana_cost", 0.0))))) + "\n"
	detail_text.text += "Tags: " + ", ".join(PackedStringArray(_string_array(Array(cast_data.get("tags", []))))) + "\n"
	detail_text.text += "Extra Projectiles: " + str(_safe_int(cast_data.get("extra_projectiles", 0))) + "  Chain: " + str(_safe_int(cast_data.get("chain", cast_data.get("chain_count", 0)))) + "  Echo: " + str(_safe_int(cast_data.get("echo_count", 0))) + "\n"

func _select_slot(index: int) -> void:
	if state_ref == null: return
	state_ref.set("skill_panel_selected_slot", index); state_ref.set("selected_skill_slot", index); _rebuild_buttons(); _refresh_text()

func _assign_active(active_id: String) -> void:
	if state_ref == null or active_id == "": return
	var slots: Array = Array(_state_get("active_skill_slots", []))
	while slots.size() < 4: slots.append({"active":"fireball", "supports":[]})
	var index: int = _selected_slot_index()
	var slot: Dictionary = Dictionary(slots[index])
	slot["active"] = active_id; slot["active_id"] = active_id; slot["supports"] = []
	slots[index] = slot; state_ref.set("active_skill_slots", slots); _rebuild_buttons(); _refresh_text()

func _toggle_support(support_id: String) -> void:
	if state_ref == null or support_id == "": return
	var slots: Array = Array(_state_get("active_skill_slots", []))
	if slots.is_empty(): return
	var index: int = _selected_slot_index()
	var slot: Dictionary = Dictionary(slots[index])
	var active_id: String = str(slot.get("active", slot.get("active_id", "fireball")))
	if not GemDBScript.support_compatible(active_id, support_id): return
	var supports: Array = Array(slot.get("supports", []))
	if supports.has(support_id): supports.erase(support_id)
	elif supports.size() < 3: supports.append(support_id)
	slot["supports"] = supports; slots[index] = slot; state_ref.set("active_skill_slots", slots); _rebuild_buttons(); _refresh_text()

func _toggle_spirit(spirit_id: String) -> void:
	if state_ref == null or spirit_id == "": return
	var spirits: Dictionary = Dictionary(_state_get("spirit_gems_owned", {}))
	spirits[spirit_id] = not bool(spirits.get(spirit_id, false))
	state_ref.set("spirit_gems_owned", spirits)
	if state_ref.has_method("recompute_stats"): state_ref.call("recompute_stats")
	_rebuild_buttons(); _refresh_text()

func _slot_has_support(slot_index: int, support_id: String) -> bool:
	var slots: Array = Array(_state_get("active_skill_slots", []))
	if slot_index < 0 or slot_index >= slots.size() or typeof(slots[slot_index]) != TYPE_DICTIONARY: return false
	return Array(Dictionary(slots[slot_index]).get("supports", [])).has(support_id)

func _active_id_for_slot(slot_index: int) -> String:
	var slots: Array = Array(_state_get("active_skill_slots", []))
	if slot_index < 0 or slot_index >= slots.size() or typeof(slots[slot_index]) != TYPE_DICTIONARY: return "fireball"
	var slot: Dictionary = Dictionary(slots[slot_index])
	return str(slot.get("active", slot.get("active_id", "fireball")))

func _selected_slot_index() -> int:
	return clampi(_safe_int(_state_get("skill_panel_selected_slot", _state_get("selected_skill_slot", 0))), 0, 3)

func _ensure_selected_slot() -> void:
	var selected: int = _selected_slot_index(); state_ref.set("skill_panel_selected_slot", selected); state_ref.set("selected_skill_slot", selected)

func _gem_detail(kind: String, id: String) -> String:
	var data: Dictionary = {}
	match kind:
		"active": data = GemDBScript.active(id)
		"support": data = GemDBScript.support(id)
		"spirit": data = GemDBScript.spirit(id)
		_: data = {}
	if data.is_empty(): return id
	var lines: PackedStringArray = [str(data.get("name", id))]
	if data.has("tags"): lines.append("Tags: " + ", ".join(PackedStringArray(_string_array(Array(data.get("tags", []))))))
	if data.has("description"): lines.append(str(data.get("description", "")))
	return "\n".join(lines)

func _on_close_pressed() -> void:
	if state_ref != null: state_ref.set("panel_mode", "")
	if root != null: root.visible = false

func _clear(container: Node) -> void:
	if container == null: return
	for child: Node in container.get_children(): child.queue_free()

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null: return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func _safe_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null: return fallback
	match typeof(value):
		TYPE_FLOAT: return value
		TYPE_INT: return float(value)
		TYPE_STRING:
			var s: String = str(value); return s.to_float() if s.is_valid_float() else fallback
		_: return fallback

func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null: return fallback
	match typeof(value):
		TYPE_INT: return value
		TYPE_FLOAT: return int(round(value))
		TYPE_STRING:
			var s: String = str(value); return s.to_int() if s.is_valid_int() else fallback
		_: return fallback

func _string_array(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value: Variant in values: out.append(str(value))
	return out
