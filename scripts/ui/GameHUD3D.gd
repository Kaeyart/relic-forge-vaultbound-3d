extends CanvasLayer

const RVUIStyle := preload("res://scripts/ui/RVUIStyle3D.gd")

var state_ref: Object = null
var _root: Control = null
var _life_bar: ProgressBar = null
var _mana_bar: ProgressBar = null
var _xp_bar: ProgressBar = null
var _life_label: Label = null
var _mana_label: Label = null
var _spirit_label: Label = null
var _xp_label: Label = null
var _objective_label: Label = null
var _notice_label: Label = null
var _prompt_label: Label = null
var _right_info: RichTextLabel = null
var _skill_buttons: Array[Button] = []
var _built: bool = false

func _ready() -> void:
	_build_ui()

func bind_state(state: Object) -> void:
	state_ref = state
	update_from_state(state)

func update_from_state(state: Object) -> void:
	state_ref = state
	_build_ui()
	_update_resources()
	_update_objective()
	_update_skills()
	_update_prompt()
	_update_right_info()

func _build_ui() -> void:
	if _built:
		return
	_built = true
	RVUIStyle.clear_children(self)
	_root = Control.new()
	_root.name = "Root"
	_root.anchor_right = 1.0
	_root.anchor_bottom = 1.0
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var bottom_left: PanelContainer = _anchored_panel("BottomLeft", 0.015, 0.755, 0.245, 0.975)
	var resources: VBoxContainer = RVUIStyle.make_vbox("Resources", 6)
	bottom_left.add_child(RVUIStyle.make_margin(resources, 10))
	_life_label = RVUIStyle.label("Life", 13, RVUIStyle.color_text())
	_life_bar = ProgressBar.new()
	_life_bar.custom_minimum_size = Vector2(220, 18)
	_mana_label = RVUIStyle.label("Mana", 13, RVUIStyle.color_text())
	_mana_bar = ProgressBar.new()
	_mana_bar.custom_minimum_size = Vector2(220, 18)
	_spirit_label = RVUIStyle.label("Spirit", 12, RVUIStyle.color_muted())
	resources.add_child(_life_label)
	resources.add_child(_life_bar)
	resources.add_child(_mana_label)
	resources.add_child(_mana_bar)
	resources.add_child(_spirit_label)

	var top_left: PanelContainer = _anchored_panel("TopLeft", 0.015, 0.025, 0.255, 0.145)
	var run_box: VBoxContainer = RVUIStyle.make_vbox("RunBox", 5)
	top_left.add_child(RVUIStyle.make_margin(run_box, 10))
	_xp_label = RVUIStyle.label("Lv 1", 13, RVUIStyle.color_gold())
	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(230, 16)
	run_box.add_child(_xp_label)
	run_box.add_child(_xp_bar)

	var top_center: PanelContainer = _anchored_panel("TopCenter", 0.315, 0.025, 0.685, 0.145)
	var objective_box: VBoxContainer = RVUIStyle.make_vbox("ObjectiveBox", 5)
	top_center.add_child(RVUIStyle.make_margin(objective_box, 10))
	_objective_label = RVUIStyle.label("VAULT HUB", 15, RVUIStyle.color_gold(), true)
	_notice_label = RVUIStyle.label("", 12, RVUIStyle.color_muted())
	objective_box.add_child(_objective_label)
	objective_box.add_child(_notice_label)

	var right_panel: PanelContainer = _anchored_panel("RightInfo", 0.765, 0.18, 0.985, 0.58)
	_right_info = RVUIStyle.rich("", 12)
	_right_info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_child(RVUIStyle.make_margin(_right_info, 10))

	var bottom_center: PanelContainer = _anchored_panel("BottomCenter", 0.285, 0.79, 0.715, 0.975)
	var skill_row: HBoxContainer = RVUIStyle.make_hbox("SkillRow", 8)
	bottom_center.add_child(RVUIStyle.make_margin(skill_row, 10))	
	_skill_buttons.clear()
	for i: int in range(4):
		var button: Button = Button.new()
		button.text = str(i + 1) + "\nSkill"
		button.focus_mode = Control.FOCUS_NONE
		button.disabled = true
		button.custom_minimum_size = Vector2(96, 72)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		RVUIStyle.apply_button(button, false)
		skill_row.add_child(button)
		_skill_buttons.append(button)

	var prompt_panel: PanelContainer = _anchored_panel("Prompt", 0.26, 0.68, 0.74, 0.745)
	_prompt_label = RVUIStyle.label("", 13, RVUIStyle.color_text())
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_panel.add_child(RVUIStyle.make_margin(_prompt_label, 8))

func _anchored_panel(name: String, left: float, top: float, right: float, bottom: float) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = name
	panel.anchor_left = left
	panel.anchor_top = top
	panel.anchor_right = right
	panel.anchor_bottom = bottom
	panel.offset_left = 0
	panel.offset_top = 0
	panel.offset_right = 0
	panel.offset_bottom = 0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	RVUIStyle.apply_panel(panel)
	_root.add_child(panel)
	return panel

func _update_resources() -> void:
	var hp: float = _to_float(_state_get("player_hp", _state_get("hp", 100.0)))
	var max_hp: float = maxf(1.0, _to_float(_state_get("max_hp", _state_get("max_health", 100.0))))
	var mana: float = _to_float(_state_get("player_mana", _state_get("mana", 50.0)))
	var max_mana: float = maxf(1.0, _to_float(_state_get("max_mana", 50.0)))
	if _life_bar != null:
		_life_bar.max_value = max_hp
		_life_bar.value = clampf(hp, 0.0, max_hp)
	if _mana_bar != null:
		_mana_bar.max_value = max_mana
		_mana_bar.value = clampf(mana, 0.0, max_mana)
	if _life_label != null:
		_life_label.text = "Life  " + str(int(round(hp))) + " / " + str(int(round(max_hp)))
	if _mana_label != null:
		_mana_label.text = "Mana  " + str(int(round(mana))) + " / " + str(int(round(max_mana)))
	if _spirit_label != null:
		_spirit_label.text = "Spirit  " + str(_state_get("spirit_reserved", 0)) + " / " + str(_state_get("spirit_max", 100))
	var xp: float = _to_float(_state_get("xp", 0.0))
	var next_xp: float = maxf(1.0, _to_float(_state_get("xp_to_next", 100.0)))
	if state_ref != null and state_ref.has_method("xp_to_next"):
		next_xp = maxf(1.0, _to_float(state_ref.call("xp_to_next")))
	if _xp_bar != null:
		_xp_bar.max_value = next_xp
		_xp_bar.value = clampf(xp, 0.0, next_xp)
	if _xp_label != null:
		_xp_label.text = "Lv " + str(_state_get("level", 1)) + " · XP " + str(int(round(xp))) + "/" + str(int(round(next_xp))) + " · Gold " + str(_state_get("gold", 0))

func _update_objective() -> void:
	var mode: String = str(_state_get("mode", "hub"))
	if _objective_label != null:
		if mode == "combat":
			_objective_label.text = "MAP ACTIVE · clear packs · secure exit"
		else:
			_objective_label.text = "VAULT HUB · tune build · choose map"
	if _notice_label != null:
		var notice_time: float = _to_float(_state_get("notice_time", 0.0))
		_notice_label.text = str(_state_get("notice_text", "")) if notice_time > 0.0 else ""

func _update_skills() -> void:
	var slots: Array = _as_array(_state_get("active_skill_slots", []))
	var selected: int = clampi(_to_int(_state_get("selected_skill_slot", 0)), 0, max(0, slots.size() - 1))
	for i: int in range(_skill_buttons.size()):
		var button: Button = _skill_buttons[i]
		var text: String = str(i + 1) + "\n—"
		if i < slots.size() and typeof(slots[i]) == TYPE_DICTIONARY:
			var slot: Dictionary = Dictionary(slots[i])
			var id: String = str(slot.get("gem_id", slot.get("active", slot.get("active_id", "skill"))))
			var supports: Array = _as_array(slot.get("supports", []))
			text = str(i + 1) + "\n" + RVUIStyle.title_case(id).substr(0, 12) + "\n+" + str(supports.size())
		button.text = text
		RVUIStyle.apply_button(button, i == selected)

func _update_prompt() -> void:
	if _prompt_label == null:
		return
	var mode: String = str(_state_get("mode", "hub"))
	if mode == "combat":
		_prompt_label.text = "[Click/Space] Cast · [1-4] Skill · [E] Loot/Exit · [I/K/F/M/C] Panels"
		return
	var station: String = str(_state_get("near_station_name", ""))
	if station != "":
		_prompt_label.text = "[E] Open " + station + " · [I] Inventory · [K] Gems · [M] Map Device"
	else:
		_prompt_label.text = "Hub: [M] Map Device · [I] Inventory · [K] Gems · [F] Forge · [C] Character"

func _update_right_info() -> void:
	if _right_info == null:
		return
	var mode: String = str(_state_get("mode", "hub"))
	var lines: PackedStringArray = PackedStringArray()
	if mode == "combat":
		var activity: Dictionary = _as_dict(_state_get("current_map_activity", _state_get("current_activity", {})))
		lines.append("[b]MAP[/b]")
		lines.append(str(activity.get("display_name", activity.get("name", "Unknown Map"))))
		lines.append("")
		var mods: Array = _as_array(activity.get("mods", []))
		if mods.is_empty():
			lines.append("No explicit modifiers")
		else:
			for mod_value: Variant in mods:
				if typeof(mod_value) == TYPE_DICTIONARY:
					var mod: Dictionary = Dictionary(mod_value)
					lines.append("• " + str(mod.get("display_name", mod.get("id", "mod"))))
				else:
					lines.append("• " + str(mod_value))
	else:
		lines.append("[b]HUB STATIONS[/b]")
		lines.append("Map Device · launch runs")
		lines.append("Forge · modify gear")
		lines.append("Stash · store loot")
		lines.append("Gem Bench · tune skills")
		lines.append("Character · inspect power")
		lines.append("")
		lines.append("Current panel: " + str(_state_get("panel_mode", "none")))
	_right_info.text = "\n".join(lines)

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	if value == null:
		return fallback
	return value

func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []

func _as_dict(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return Dictionary(value)
	return {}

func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return float(value)
		TYPE_FLOAT:
			return float(value)
		TYPE_STRING:
			var s: String = str(value)
			return s.to_float() if s.is_valid_float() else fallback
		_:
			return fallback

func _to_int(value: Variant, fallback: int = 0) -> int:
	return int(round(_to_float(value, float(fallback))))
