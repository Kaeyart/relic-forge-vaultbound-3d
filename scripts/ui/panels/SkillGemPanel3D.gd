extends Control

const SlotButtonScript := preload("res://scripts/ui/widgets/UISlotButton3D.gd")
const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")
const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

var active_slot_grid: GridContainer = null
var support_socket_grid: GridContainer = null
var active_grid: GridContainer = null
var support_grid: GridContainer = null
var spirit_grid: GridContainer = null
var detail_label: RichTextLabel = null
var spirit_label: Label = null

var state_ref: Object = null

func _ready() -> void:
	_bind_nodes()

func _bind_nodes() -> void:
	active_slot_grid = get_node_or_null("VBox/ActiveBox/ActiveVBox/ActiveSlotGrid") as GridContainer
	support_socket_grid = get_node_or_null("VBox/Body/SocketBox/SocketVBox/SupportSocketGrid") as GridContainer
	active_grid = get_node_or_null("VBox/Body/LibraryBox/LibraryVBox/ActiveGemGrid") as GridContainer
	support_grid = get_node_or_null("VBox/Body/LibraryBox/LibraryVBox/SupportScroll/SupportGemGrid") as GridContainer
	spirit_grid = get_node_or_null("VBox/Body/SocketBox/SocketVBox/SpiritGemGrid") as GridContainer
	detail_label = get_node_or_null("VBox/Body/DetailBox/DetailLabel") as RichTextLabel
	spirit_label = get_node_or_null("VBox/Body/SocketBox/SocketVBox/SpiritLabel") as Label

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func update_from_state(state: Object) -> void:
	state_ref = state
	if active_slot_grid == null:
		_bind_nodes()
	if state_ref != null:
		SkillGemSystemScript.ensure_defaults(state_ref)
	_rebuild()

func _clear(root: Node) -> void:
	if root == null:
		return
	for child: Node in root.get_children():
		child.queue_free()

func _slots() -> Array:
	return Array(_state_get("active_skill_slots", []))

func _selected() -> int:
	var slots: Array = _slots()
	return clampi(_safe_int(_state_get("selected_skill_slot", 0)), 0, max(0, slots.size() - 1))

func _selected_slot() -> Dictionary:
	var slots: Array = _slots()
	if slots.is_empty():
		return {}
	return Dictionary(slots[_selected()])

func _rebuild() -> void:
	_clear(active_slot_grid)
	_clear(support_socket_grid)
	_clear(active_grid)
	_clear(support_grid)
	_clear(spirit_grid)
	if active_slot_grid == null:
		return
	_rebuild_active_slots()
	_rebuild_support_sockets()
	_rebuild_library()
	_rebuild_spirits()
	_refresh_detail()

func _rebuild_active_slots() -> void:
	var slots: Array = _slots()
	var selected: int = _selected()
	for i: int in range(slots.size()):
		var slot: Dictionary = Dictionary(slots[i])
		var id: String = str(slot.get("active", slot.get("active_id", "fireball")))
		var active_data: Dictionary = GemDBScript.active(id)
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(150, 70)
		b.setup("slot_%d" % i, "Slot %d\n%s" % [i + 1, str(active_data.get("name", id))], {"kind":"active_slot", "slot_index":i}, ["active_gem"], i == selected, _gem_tip(active_data))
		b.slot_clicked.connect(_select_slot)
		b.slot_dropped.connect(_drop_active)
		active_slot_grid.add_child(b)

func _rebuild_support_sockets() -> void:
	var slot: Dictionary = _selected_slot()
	var supports: Array = Array(slot.get("supports", []))
	for i: int in range(3):
		var label: String = "Support %d\nEmpty" % [i + 1]
		var payload: Dictionary = {"kind":"support_socket", "socket_index":i}
		var tip: String = "Drop a compatible support gem here."
		if i < supports.size():
			var sid: String = str(supports[i])
			var data: Dictionary = GemDBScript.support(sid)
			label = "Support %d\n%s" % [i + 1, str(data.get("name", sid))]
			payload["support_id"] = sid
			tip = _gem_tip(data) + "\nClick/right click to remove."
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(160, 62)
		b.setup("support_%d" % i, label, payload, ["support_gem"], false, tip)
		b.slot_clicked.connect(_remove_support)
		b.slot_right_clicked.connect(_remove_support)
		b.slot_dropped.connect(_drop_support)
		support_socket_grid.add_child(b)

func _rebuild_library() -> void:
	var owned_active: Dictionary = Dictionary(_state_get("active_gems_owned", {}))
	for key: Variant in owned_active.keys():
		if not bool(owned_active[key]):
			continue
		var id: String = str(key)
		var data: Dictionary = GemDBScript.active(id)
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(135, 54)
		b.setup("active_" + id, str(data.get("name", id)), {"kind":"active_gem", "gem_id":id}, [], false, _gem_tip(data))
		b.slot_clicked.connect(_click_active)
		b.slot_double_clicked.connect(_click_active)
		active_grid.add_child(b)

	var active_id: String = str(_selected_slot().get("active", _selected_slot().get("active_id", "fireball")))
	var owned_support: Dictionary = Dictionary(_state_get("support_gems_owned", {}))
	for key: Variant in owned_support.keys():
		if _safe_int(owned_support[key]) <= 0:
			continue
		var sid: String = str(key)
		var valid: bool = GemDBScript.support_compatible(active_id, sid)
		var data: Dictionary = GemDBScript.support(sid)
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(145, 54)
		b.setup("support_" + sid, ("✓ " if valid else "× ") + str(data.get("name", sid)), {"kind":"support_gem", "gem_id":sid}, [], false, _gem_tip(data))
		if not valid:
			b.set_disabled_reason("Not compatible with selected active skill.")
		b.slot_clicked.connect(_click_support)
		b.slot_double_clicked.connect(_click_support)
		support_grid.add_child(b)

func _rebuild_spirits() -> void:
	if spirit_label != null:
		spirit_label.text = "Spirit %s / %s" % [str(_state_get("spirit_reserved", 0)), str(_state_get("spirit_max", 0))]
	var spirits: Dictionary = Dictionary(_state_get("spirit_gems_owned", {}))
	for key: Variant in spirits.keys():
		var id: String = str(key)
		var enabled: bool = bool(spirits[key])
		var data: Dictionary = GemDBScript.spirit(id)
		var b: Button = SlotButtonScript.new()
		b.custom_minimum_size = Vector2(148, 54)
		b.setup("spirit_" + id, ("ON " if enabled else "off ") + str(data.get("name", id)), {"kind":"spirit_gem", "gem_id":id}, [], enabled, _gem_tip(data))
		b.slot_clicked.connect(_toggle_spirit)
		spirit_grid.add_child(b)

func _gem_tip(data: Dictionary) -> String:
	var lines: PackedStringArray = [str(data.get("name", "Gem"))]
	if data.has("tags"):
		lines.append("Tags: " + ", ".join(PackedStringArray(_to_strings(Array(data.get("tags", []))))))
	if data.has("description"):
		lines.append(str(data.get("description", "")))
	return "\n".join(lines)

func _select_slot(_id: String, payload: Dictionary) -> void:
	if state_ref != null:
		state_ref.set("selected_skill_slot", _safe_int(payload.get("slot_index", 0)))
	_rebuild()

func _drop_active(_id: String, payload: Dictionary) -> void:
	_assign_active(str(payload.get("gem_id", "")))

func _click_active(_id: String, payload: Dictionary) -> void:
	_assign_active(str(payload.get("gem_id", "")))

func _assign_active(gem_id: String) -> void:
	if gem_id == "":
		return
	var slots: Array = _slots()
	if slots.is_empty():
		return
	var idx: int = _selected()
	var slot: Dictionary = Dictionary(slots[idx])
	slot["active"] = gem_id
	slot["active_id"] = gem_id
	slot["supports"] = []
	slots[idx] = slot
	state_ref.set("active_skill_slots", slots)
	_rebuild()

func _drop_support(_id: String, payload: Dictionary) -> void:
	_add_support(str(payload.get("gem_id", "")))

func _click_support(_id: String, payload: Dictionary) -> void:
	_add_support(str(payload.get("gem_id", "")))

func _add_support(sid: String) -> void:
	var slots: Array = _slots()
	if slots.is_empty() or sid == "":
		return
	var idx: int = _selected()
	var slot: Dictionary = Dictionary(slots[idx])
	var active_id: String = str(slot.get("active", slot.get("active_id", "fireball")))
	if not GemDBScript.support_compatible(active_id, sid):
		if state_ref != null and state_ref.has_method("add_notice"):
			state_ref.call("add_notice", "Invalid support")
		return
	var supports: Array = Array(slot.get("supports", []))
	if supports.has(sid):
		return
	if supports.size() >= 3:
		if state_ref != null and state_ref.has_method("add_notice"):
			state_ref.call("add_notice", "Support sockets full")
		return
	supports.append(sid)
	slot["supports"] = supports
	slots[idx] = slot
	state_ref.set("active_skill_slots", slots)
	_rebuild()

func _remove_support(_id: String, payload: Dictionary) -> void:
	var sid: String = str(payload.get("support_id", ""))
	if sid == "":
		return
	var slots: Array = _slots()
	if slots.is_empty():
		return
	var idx: int = _selected()
	var slot: Dictionary = Dictionary(slots[idx])
	var supports: Array = Array(slot.get("supports", []))
	supports.erase(sid)
	slot["supports"] = supports
	slots[idx] = slot
	state_ref.set("active_skill_slots", slots)
	_rebuild()

func _toggle_spirit(_id: String, payload: Dictionary) -> void:
	var sid: String = str(payload.get("gem_id", ""))
	var spirits: Dictionary = Dictionary(_state_get("spirit_gems_owned", {}))
	spirits[sid] = not bool(spirits.get(sid, false))
	state_ref.set("spirit_gems_owned", spirits)
	if state_ref.has_method("recompute_stats"):
		state_ref.call("recompute_stats")
	_rebuild()

func _refresh_detail() -> void:
	if state_ref == null or detail_label == null:
		return
	var cast: Dictionary = SkillGemSystemScript.selected_cast_data(state_ref)
	detail_label.text = "[b]%s[/b]\nDamage: %s\nMana: %s\nTags: %s\n\n[i]Click active slot, then click/drag gems. Click support sockets to remove. Click spirit gems to toggle.[/i]" % [
		str(cast.get("name", "")),
		str(_safe_int(round(_safe_float(cast.get("damage", 0.0))))),
		str(_safe_int(round(_safe_float(cast.get("mana_cost", 0.0))))),
		", ".join(PackedStringArray(_to_strings(Array(cast.get("tags", [])))))
	]

func _to_strings(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value: Variant in values:
		out.append(str(value))
	return out

func _safe_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT: return value
		TYPE_INT: return float(value)
		TYPE_STRING:
			var s: String = str(value)
			return s.to_float() if s.is_valid_float() else fallback
		_: return fallback

func _safe_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT: return value
		TYPE_FLOAT: return int(round(value))
		TYPE_STRING:
			var s: String = str(value)
			return s.to_int() if s.is_valid_int() else fallback
		_: return fallback
