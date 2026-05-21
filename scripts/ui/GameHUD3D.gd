extends CanvasLayer

# patch_07_hud_rebuild
# Canonical gameplay HUD for Relic Forge: Vaultbound.
# This script intentionally owns only presentation. It reads state and never mutates
# gameplay except for selecting skill slots from HUD buttons.

const SkillGemSystemScript: GDScript = preload("res://scripts/systems/SkillGemSystem3D.gd")

var state_ref: Object = null

var root: Control = null
var life_panel: PanelContainer = null
var mana_panel: PanelContainer = null
var skill_panel: PanelContainer = null
var prompt_panel: PanelContainer = null
var map_panel: PanelContainer = null
var boss_panel: PanelContainer = null
var notice_panel: PanelContainer = null
var buff_panel: PanelContainer = null

var life_bar: ProgressBar = null
var mana_bar: ProgressBar = null
var boss_bar: ProgressBar = null

var life_label: Label = null
var defense_label: Label = null
var mana_label: Label = null
var spirit_label: Label = null
var prompt_label: Label = null
var map_title_label: Label = null
var map_body_label: RichTextLabel = null
var boss_name_label: Label = null
var boss_subtitle_label: Label = null
var boss_mods_label: Label = null
var notice_label: RichTextLabel = null
var buff_label: RichTextLabel = null

var skill_buttons: Array[Button] = []
var _built: bool = false

func _ready() -> void:
	_build_hud()
	_update_from_bound_state()

func bind_state(state: Object) -> void:
	state_ref = state
	_update_from_bound_state()

func update_from_state(state: Object) -> void:
	state_ref = state
	_update_from_bound_state()

func mark_dirty() -> void:
	_update_from_bound_state()

func _build_hud() -> void:
	if _built:
		return
	_built = true
	layer = 50

	root = Control.new()
	root.name = "Root"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	_build_top_left_buffs()
	_build_top_center_boss()
	_build_top_right_map_info()
	_build_center_prompt()
	_build_bottom_left_life()
	_build_bottom_center_skills()
	_build_bottom_right_mana()
	_build_notice_feed()

func _build_top_left_buffs() -> void:
	buff_panel = _make_panel("BuffStatusPanel")
	_anchor(buff_panel, 0.0, 0.0, 0.0, 0.0, 18.0, 18.0, 250.0, 160.0)
	root.add_child(buff_panel)

	var margin: MarginContainer = _margin(8)
	buff_panel.add_child(margin)
	buff_label = RichTextLabel.new()
	buff_label.name = "BuffStatusText"
	buff_label.bbcode_enabled = true
	buff_label.fit_content = true
	buff_label.scroll_active = false
	buff_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(buff_label)

func _build_top_center_boss() -> void:
	boss_panel = _make_panel("BossEncounterPanel")
	_anchor(boss_panel, 0.5, 0.0, 0.5, 0.0, -380.0, 16.0, 380.0, 105.0)
	root.add_child(boss_panel)

	var margin: MarginContainer = _margin(8)
	boss_panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	margin.add_child(box)

	boss_name_label = _label("BossName", 20, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(boss_name_label)
	boss_subtitle_label = _label("BossSubtitle", 12, HORIZONTAL_ALIGNMENT_CENTER)
	boss_subtitle_label.modulate = Color(0.86, 0.64, 0.30, 1.0)
	box.add_child(boss_subtitle_label)
	boss_bar = ProgressBar.new()
	boss_bar.name = "BossHPBar"
	boss_bar.custom_minimum_size = Vector2(0, 18)
	boss_bar.min_value = 0.0
	boss_bar.max_value = 1.0
	boss_bar.value = 1.0
	box.add_child(boss_bar)
	boss_mods_label = _label("BossMods", 11, HORIZONTAL_ALIGNMENT_CENTER)
	boss_mods_label.modulate = Color(0.65, 0.74, 1.0, 1.0)
	box.add_child(boss_mods_label)

func _build_top_right_map_info() -> void:
	map_panel = _make_panel("MapObjectivePanel")
	_anchor(map_panel, 1.0, 0.0, 1.0, 0.0, -370.0, 18.0, -18.0, 330.0)
	root.add_child(map_panel)

	var margin: MarginContainer = _margin(10)
	map_panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	map_title_label = _label("MapTitle", 18, HORIZONTAL_ALIGNMENT_LEFT)
	map_title_label.modulate = Color(0.86, 0.67, 0.32, 1.0)
	box.add_child(map_title_label)

	map_body_label = RichTextLabel.new()
	map_body_label.name = "MapBody"
	map_body_label.bbcode_enabled = true
	map_body_label.scroll_active = false
	map_body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_body_label.custom_minimum_size = Vector2(0, 245)
	box.add_child(map_body_label)

func _build_center_prompt() -> void:
	prompt_panel = _make_panel("InteractionPromptPanel")
	_anchor(prompt_panel, 0.5, 1.0, 0.5, 1.0, -420.0, -238.0, 420.0, -194.0)
	root.add_child(prompt_panel)

	var margin: MarginContainer = _margin(8)
	prompt_panel.add_child(margin)
	prompt_label = _label("PromptLabel", 16, HORIZONTAL_ALIGNMENT_CENTER)
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	margin.add_child(prompt_label)

func _build_bottom_left_life() -> void:
	life_panel = _make_panel("LifeDefenseCluster")
	_anchor(life_panel, 0.0, 1.0, 0.0, 1.0, 18.0, -178.0, 335.0, -18.0)
	root.add_child(life_panel)

	var margin: MarginContainer = _margin(10)
	life_panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	var title: Label = _label("LifeTitle", 15, HORIZONTAL_ALIGNMENT_LEFT)
	title.text = "LIFE / DEFENSE"
	title.modulate = Color(0.96, 0.55, 0.36, 1.0)
	box.add_child(title)

	life_bar = ProgressBar.new()
	life_bar.name = "LifeBar"
	life_bar.custom_minimum_size = Vector2(0, 26)
	life_bar.min_value = 0.0
	life_bar.max_value = 1.0
	life_bar.value = 1.0
	box.add_child(life_bar)

	life_label = _label("LifeLabel", 18, HORIZONTAL_ALIGNMENT_LEFT)
	box.add_child(life_label)
	defense_label = _label("DefenseLabel", 13, HORIZONTAL_ALIGNMENT_LEFT)
	defense_label.modulate = Color(0.78, 0.72, 0.62, 1.0)
	box.add_child(defense_label)

	var flask_row: HBoxContainer = HBoxContainer.new()
	flask_row.add_theme_constant_override("separation", 8)
	box.add_child(flask_row)
	flask_row.add_child(_small_token("Z", "Life Flask", Color(0.55, 0.12, 0.10, 1.0)))
	flask_row.add_child(_small_token("X", "Mana Flask", Color(0.12, 0.24, 0.55, 1.0)))

func _build_bottom_center_skills() -> void:
	skill_panel = _make_panel("SkillActionCluster")
	_anchor(skill_panel, 0.5, 1.0, 0.5, 1.0, -360.0, -174.0, 360.0, -18.0)
	root.add_child(skill_panel)

	var margin: MarginContainer = _margin(10)
	skill_panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	margin.add_child(box)

	var title: Label = _label("SkillBarTitle", 14, HORIZONTAL_ALIGNMENT_CENTER)
	title.text = "ACTIVE SKILLS"
	title.modulate = Color(0.86, 0.67, 0.32, 1.0)
	box.add_child(title)

	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 9)
	box.add_child(row)

	skill_buttons.clear()
	for i: int in range(4):
		var button: Button = Button.new()
		button.name = "Skill%d" % [i + 1]
		button.custom_minimum_size = Vector2(126, 86)
		button.text = str(i + 1) + "\n—"
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		var callable: Callable = _select_skill_slot.bind(i)
		button.pressed.connect(callable)
		row.add_child(button)
		skill_buttons.append(button)

	var hint: Label = _label("SkillHint", 11, HORIZONTAL_ALIGNMENT_CENTER)
	hint.text = "Left Click / Space cast · Q/R cycle · 1-4 select"
	hint.modulate = Color(0.72, 0.67, 0.58, 1.0)
	box.add_child(hint)

func _build_bottom_right_mana() -> void:
	mana_panel = _make_panel("ManaSpiritCluster")
	_anchor(mana_panel, 1.0, 1.0, 1.0, 1.0, -335.0, -178.0, -18.0, -18.0)
	root.add_child(mana_panel)

	var margin: MarginContainer = _margin(10)
	mana_panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	var title: Label = _label("ManaTitle", 15, HORIZONTAL_ALIGNMENT_LEFT)
	title.text = "MANA / SPIRIT"
	title.modulate = Color(0.45, 0.68, 1.0, 1.0)
	box.add_child(title)

	mana_bar = ProgressBar.new()
	mana_bar.name = "ManaBar"
	mana_bar.custom_minimum_size = Vector2(0, 26)
	mana_bar.min_value = 0.0
	mana_bar.max_value = 1.0
	mana_bar.value = 1.0
	box.add_child(mana_bar)

	mana_label = _label("ManaLabel", 18, HORIZONTAL_ALIGNMENT_LEFT)
	box.add_child(mana_label)
	spirit_label = _label("SpiritLabel", 13, HORIZONTAL_ALIGNMENT_LEFT)
	spirit_label.modulate = Color(0.78, 0.72, 1.0, 1.0)
	box.add_child(spirit_label)

func _build_notice_feed() -> void:
	notice_panel = _make_panel("NoticeFeedPanel")
	_anchor(notice_panel, 1.0, 1.0, 1.0, 1.0, -390.0, -380.0, -18.0, -248.0)
	root.add_child(notice_panel)

	var margin: MarginContainer = _margin(8)
	notice_panel.add_child(margin)
	notice_label = RichTextLabel.new()
	notice_label.name = "NoticeText"
	notice_label.bbcode_enabled = true
	notice_label.fit_content = true
	notice_label.scroll_active = false
	notice_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(notice_label)

func _update_from_bound_state() -> void:
	if not _built:
		_build_hud()
	if state_ref == null:
		return
	_update_resources()
	_update_skills()
	_update_map_objectives()
	_update_prompt()
	_update_notice()
	_update_buffs()
	_update_boss_bar()

func _update_resources() -> void:
	var hp: float = _to_float(_get_value("player_hp", _get_value("hp", 0.0)))
	var max_hp: float = maxf(1.0, _to_float(_get_value("max_hp", _get_value("max_health", 1.0))))
	var mana: float = _to_float(_get_value("player_mana", _get_value("mana", 0.0)))
	var max_mana: float = maxf(1.0, _to_float(_get_value("max_mana", 1.0)))
	var armor: int = _to_int(_get_value("armor", 0))
	var shield: int = _to_int(_get_value("shield", 0))
	var ward: int = _to_int(_get_value("ward", 0))
	var spirit_max: int = _to_int(_get_value("spirit_max", 0))
	var spirit_reserved: int = _to_int(_get_value("spirit_reserved", 0))
	var spirit_available: int = maxi(0, spirit_max - spirit_reserved)

	if life_bar != null:
		life_bar.max_value = max_hp
		life_bar.value = clampf(hp, 0.0, max_hp)
	if mana_bar != null:
		mana_bar.max_value = max_mana
		mana_bar.value = clampf(mana, 0.0, max_mana)
	if life_label != null:
		life_label.text = "Life  %d / %d" % [_to_int(hp), _to_int(max_hp)]
	if defense_label != null:
		defense_label.text = "Armor %d   Shield %d   Ward %d" % [armor, shield, ward]
	if mana_label != null:
		mana_label.text = "Mana  %d / %d" % [_to_int(mana), _to_int(max_mana)]
	if spirit_label != null:
		spirit_label.text = "Spirit %d / %d   Reserved %d" % [spirit_available, spirit_max, spirit_reserved]

func _update_skills() -> void:
	if state_ref == null:
		return
	SkillGemSystemScript.ensure_defaults(state_ref)
	var slots: Array = _as_array(_get_value("active_skill_slots", []))
	var selected: int = clampi(_to_int(_get_value("selected_skill_slot", 0)), 0, maxi(0, slots.size() - 1))

	for i: int in range(skill_buttons.size()):
		var button: Button = skill_buttons[i]
		if button == null:
			continue

		var text: String = str(i + 1) + "\n—"
		if i < slots.size() and typeof(slots[i]) == TYPE_DICTIONARY:
			var slot: Dictionary = Dictionary(slots[i])
			var gem_id: String = str(slot.get("gem_id", slot.get("active", slot.get("active_id", "skill"))))
			var supports: Array = _as_array(slot.get("supports", []))
			var level: int = _to_int(slot.get("level", slot.get("gem_level", 1)))
			text = "%d\n%s\nLv %d · +%d" % [i + 1, _skill_short_name(gem_id), level, supports.size()]
		button.text = text

		if i == selected:
			button.modulate = Color(1.0, 0.78, 0.32, 1.0)
		else:
			button.modulate = Color(0.88, 0.86, 0.80, 0.92)

func _update_map_objectives() -> void:
	var mode: String = str(_get_value("mode", "hub"))
	var activity: Dictionary = _current_activity()
	var lines: PackedStringArray = PackedStringArray()

	if mode == "combat":
		var map_name: String = str(activity.get("display_name", activity.get("name", "Active Map")))
		var tier_text: String = _map_tier_text(activity)
		if map_title_label != null:
			map_title_label.text = map_name
		if tier_text != "":
			lines.append("[color=#c59b4a]" + tier_text + "[/color]")
		lines.append("[b]OBJECTIVE[/b]")
		if bool(_get_value("room_clear", false)):
			lines.append("• Room clear · press E to extract")
		else:
			lines.append("• Clear enemies")
		lines.append("")
		lines.append("[b]MAP MODIFIERS[/b]")
		var mods: Array = _as_array(activity.get("mods", []))
		if mods.is_empty():
			lines.append("No explicit modifiers")
		else:
			var shown: int = 0
			for mod_value: Variant in mods:
				if shown >= 6:
					break
				lines.append("• " + _mod_display_name(mod_value))
				shown += 1
	else:
		if map_title_label != null:
			map_title_label.text = "VAULT HUB"
		lines.append("[b]STATIONS[/b]")
		lines.append("• Map Device · launch maps")
		lines.append("• Forge · improve items")
		lines.append("• Stash · store loot")
		lines.append("• Gem Bench · tune skills")
		lines.append("")
		lines.append("[b]SHORTCUTS[/b]")
		lines.append("I Inventory · K Gems · M Maps")
		lines.append("F Forge · C Character")

	if map_body_label != null:
		map_body_label.text = "\n".join(lines)

func _update_prompt() -> void:
	var mode: String = str(_get_value("mode", "hub"))
	var station_name: String = str(_get_value("near_station_name", ""))
	var text: String = ""
	if mode == "combat":
		if bool(_get_value("room_clear", false)):
			text = "[E] Extract to Hub     [I] Inventory     [K] Skill Gems"
		else:
			text = "[Left Click / Space] Cast     [E] Pick Up     [Z/X] Flasks"
	else:
		if station_name != "":
			text = "[E] Open " + station_name
		else:
			text = "[M] Map Device     [I] Inventory     [K] Gems     [F] Forge     [C] Character"
	if prompt_label != null:
		prompt_label.text = text

func _update_notice() -> void:
	var notice_text: String = str(_get_value("notice_text", ""))
	var notice_time: float = _to_float(_get_value("notice_time", 0.0))
	var show_notice: bool = notice_text != "" and notice_time > 0.0
	if notice_panel != null:
		notice_panel.visible = show_notice
	if notice_label != null:
		notice_label.text = "[color=#c59b4a]NOTICE[/color]\n" + notice_text if show_notice else ""

func _update_buffs() -> void:
	var spirits: Array = _as_array(_get_value("spirit_gem_slots", []))
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a]STATUS[/color]")
	var count: int = 0
	for value: Variant in spirits:
		if count >= 4:
			break
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit: Dictionary = Dictionary(value)
		if not bool(spirit.get("enabled", false)):
			continue
		lines.append("• " + str(spirit.get("gem_id", "Spirit")).replace("_", " ").capitalize())
		count += 1
	if count == 0:
		lines.append("No active buffs")
	if buff_label != null:
		buff_label.text = "\n".join(lines)

func _update_boss_bar() -> void:
	var mode: String = str(_get_value("mode", "hub"))
	var activity: Dictionary = _current_activity()
	var boss_name: String = str(_get_value("boss_name", activity.get("boss_name", "")))
	var boss_hp: float = _to_float(_get_value("boss_hp", -1.0))
	var boss_max_hp: float = maxf(1.0, _to_float(_get_value("boss_max_hp", 1.0)))
	var should_show: bool = mode == "combat" and boss_name != ""
	if boss_panel != null:
		boss_panel.visible = should_show
	if not should_show:
		return
	if boss_name_label != null:
		boss_name_label.text = boss_name.to_upper()
	if boss_subtitle_label != null:
		boss_subtitle_label.text = str(activity.get("boss_title", "Vaultbound Encounter"))
	if boss_bar != null:
		boss_bar.max_value = boss_max_hp
		boss_bar.value = boss_max_hp if boss_hp < 0.0 else clampf(boss_hp, 0.0, boss_max_hp)
	if boss_mods_label != null:
		boss_mods_label.text = _boss_modifier_summary(activity)

func _select_skill_slot(index: int) -> void:
	if state_ref == null:
		return
	state_ref.set("selected_skill_slot", index)
	_update_skills()

func _current_activity() -> Dictionary:
	var activity_value: Variant = _get_value("current_map_activity", _get_value("current_activity", {}))
	if typeof(activity_value) == TYPE_DICTIONARY:
		return Dictionary(activity_value)
	return {}

func _map_tier_text(activity: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	if activity.has("tier"):
		parts.append("Tier " + str(activity.get("tier", 1)))
	if activity.has("area_level"):
		parts.append("Area Level " + str(activity.get("area_level", 1)))
	return " · ".join(parts)

func _mod_display_name(mod_value: Variant) -> String:
	if typeof(mod_value) == TYPE_DICTIONARY:
		var mod: Dictionary = Dictionary(mod_value)
		return str(mod.get("display_name", mod.get("name", mod.get("id", "modifier"))))
	return str(mod_value)

func _boss_modifier_summary(activity: Dictionary) -> String:
	var mods: Array = _as_array(activity.get("mods", []))
	if mods.is_empty():
		return ""
	var labels: PackedStringArray = PackedStringArray()
	var count: int = 0
	for mod_value: Variant in mods:
		if count >= 4:
			break
		labels.append(_mod_display_name(mod_value))
		count += 1
	return " · ".join(labels)

func _skill_short_name(id: String) -> String:
	match id:
		"fireball": return "Fireball"
		"storm_lance": return "Storm"
		"chain_spark": return "Spark"
		"arc_slash": return "Slash"
		"blood_cleave": return "Cleave"
		"void_rift": return "Void Rift"
		"ember_mine": return "Mine"
		"bone_spear": return "Spear"
		"ash_nova": return "Nova"
		"shield_burst": return "Shield"
		"infernal_step": return "Step"
		"furnace_totem": return "Totem"
		_: return id.replace("_", " ").capitalize().substr(0, 12)

func _make_panel(node_name: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _panel_style())
	return panel

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.030, 0.025, 0.82)
	style.border_color = Color(0.48, 0.34, 0.15, 0.90)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = 6.0
	style.content_margin_top = 6.0
	style.content_margin_right = 6.0
	style.content_margin_bottom = 6.0
	return style

func _label(node_name: String, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.name = node_name
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate = Color(0.84, 0.80, 0.70, 1.0)
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _small_token(key: String, label_text: String, color: Color) -> Control:
	var panel: PanelContainer = _make_panel("Token" + key)
	panel.custom_minimum_size = Vector2(136, 34)
	var margin: MarginContainer = _margin(4)
	panel.add_child(margin)
	var label: Label = _label("Label", 12, HORIZONTAL_ALIGNMENT_CENTER)
	label.text = "[" + key + "] " + label_text
	label.modulate = color.lightened(0.45)
	margin.add_child(label)
	return panel

func _margin(size: int) -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", size)
	margin.add_theme_constant_override("margin_right", size)
	margin.add_theme_constant_override("margin_top", size)
	margin.add_theme_constant_override("margin_bottom", size)
	return margin

func _anchor(control: Control, left: float, top: float, right: float, bottom: float, offset_left: float, offset_top: float, offset_right: float, offset_bottom: float) -> void:
	control.anchor_left = left
	control.anchor_top = top
	control.anchor_right = right
	control.anchor_bottom = bottom
	control.offset_left = offset_left
	control.offset_top = offset_top
	control.offset_right = offset_right
	control.offset_bottom = offset_bottom

func _get_value(key: String, fallback: Variant = null) -> Variant:
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

func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return float(value)
		TYPE_INT:
			return float(int(value))
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			return fallback
		_:
			return fallback

func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback
