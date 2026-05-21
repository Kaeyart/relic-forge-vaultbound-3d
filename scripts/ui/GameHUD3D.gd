extends CanvasLayer

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")
const UIAccessSystemScript := preload("res://scripts/systems/UIAccessSystem3D.gd")

var state_ref: Object = null
var hp_bar: ProgressBar = null
var mana_bar: ProgressBar = null
var xp_bar: ProgressBar = null
var hp_label: Label = null
var mana_label: Label = null
var spirit_label: Label = null
var xp_label: Label = null
var gold_label: Label = null
var objective_label: Label = null
var notice_label: Label = null
var station_prompt: Label = null
var map_mods_label: RichTextLabel = null
var skill_buttons: Array[Button] = []
var menu_buttons: Dictionary = {}

func _ready() -> void:
	_bind_nodes()
	_connect_buttons()

func bind_state(state: Object) -> void:
	state_ref = state
	update_from_state(state)

func update_from_state(state: Object) -> void:
	state_ref = state
	if state_ref == null:
		return
	if hp_bar == null:
		_bind_nodes()
	_update_resources()
	_update_objective()
	_update_skills()
	_update_station_prompt()
	_update_map_mods()

func _bind_nodes() -> void:
	hp_bar = get_node_or_null("Root/BottomLeft/ResourceBox/VBox/HPBar") as ProgressBar
	mana_bar = get_node_or_null("Root/BottomLeft/ResourceBox/VBox/ManaBar") as ProgressBar
	xp_bar = get_node_or_null("Root/TopLeft/RunBox/VBox/XPBar") as ProgressBar
	hp_label = get_node_or_null("Root/BottomLeft/ResourceBox/VBox/HPLabel") as Label
	mana_label = get_node_or_null("Root/BottomLeft/ResourceBox/VBox/ManaLabel") as Label
	spirit_label = get_node_or_null("Root/BottomLeft/ResourceBox/VBox/SpiritLabel") as Label
	xp_label = get_node_or_null("Root/TopLeft/RunBox/VBox/XPLabel") as Label
	gold_label = get_node_or_null("Root/TopLeft/RunBox/VBox/GoldLabel") as Label
	objective_label = get_node_or_null("Root/TopCenter/ObjectiveBox/VBox/ObjectiveLabel") as Label
	notice_label = get_node_or_null("Root/TopCenter/ObjectiveBox/VBox/NoticeLabel") as Label
	station_prompt = get_node_or_null("Root/PromptBox/PromptLabel") as Label
	map_mods_label = get_node_or_null("Root/RightInfo/MapModsBox/VBox/MapModsLabel") as RichTextLabel

	skill_buttons = [
		get_node_or_null("Root/BottomCenter/SkillBar/HBox/Skill1") as Button,
		get_node_or_null("Root/BottomCenter/SkillBar/HBox/Skill2") as Button,
		get_node_or_null("Root/BottomCenter/SkillBar/HBox/Skill3") as Button,
		get_node_or_null("Root/BottomCenter/SkillBar/HBox/Skill4") as Button,
	]

	menu_buttons = {
		"inventory": get_node_or_null("Root/TopRight/MenuBox/Grid/InventoryButton"),
		"skills": get_node_or_null("Root/TopRight/MenuBox/Grid/SkillsButton"),
		"crafting": get_node_or_null("Root/TopRight/MenuBox/Grid/ForgeButton"),
		"maps": get_node_or_null("Root/TopRight/MenuBox/Grid/MapsButton"),
		"character": get_node_or_null("Root/TopRight/MenuBox/Grid/CharacterButton"),
		"stash": get_node_or_null("Root/TopRight/MenuBox/Grid/StashButton"),
	}

func _connect_buttons() -> void:
	for i: int in range(skill_buttons.size()):
		var b: Button = skill_buttons[i]
		if b != null:
			var callable := _select_skill.bind(i)
			if not b.pressed.is_connected(callable):
				b.pressed.connect(callable)

	for mode: Variant in menu_buttons.keys():
		var button := menu_buttons[mode] as Button
		if button != null:
			var callable := _open_panel.bind(str(mode))
			if not button.pressed.is_connected(callable):
				button.pressed.connect(callable)

func _update_resources() -> void:
	var hp: float = _f(_get_value("player_hp", 0.0))
	var max_hp: float = max(1.0, _f(_get_value("max_hp", 1.0)))
	var mana: float = _f(_get_value("player_mana", 0.0))
	var max_mana: float = max(1.0, _f(_get_value("max_mana", 1.0)))

	if hp_bar != null:
		hp_bar.max_value = max_hp
		hp_bar.value = clampf(hp, 0.0, max_hp)

	if mana_bar != null:
		mana_bar.max_value = max_mana
		mana_bar.value = clampf(mana, 0.0, max_mana)

	if hp_label != null:
		hp_label.text = "Life  %d / %d" % [_i(hp), _i(max_hp)]

	if mana_label != null:
		mana_label.text = "Mana  %d / %d" % [_i(mana), _i(max_mana)]

	if spirit_label != null:
		spirit_label.text = "Spirit  %s / %s" % [
			str(_get_value("spirit_reserved", 0)),
			str(_get_value("spirit_max", 0))
		]

	var xp: float = _f(_get_value("xp", 0))
	var next_xp: float = 100.0

	if state_ref != null and state_ref.has_method("xp_to_next"):
		next_xp = max(1.0, _f(state_ref.call("xp_to_next")))
	else:
		next_xp = max(1.0, _f(_get_value("xp_to_next", 100)))

	if xp_bar != null:
		xp_bar.max_value = next_xp
		xp_bar.value = clampf(xp, 0.0, next_xp)

	if xp_label != null:
		xp_label.text = "Lv %s  XP %d/%d" % [
			str(_get_value("level", 1)),
			_i(xp),
			_i(next_xp)
		]

	if gold_label != null:
		gold_label.text = "Gold %s   Materials %s" % [
			str(_get_value("gold", 0)),
			_compact_materials(Dictionary(_get_value("materials", {})))
		]

func _update_objective() -> void:
	var mode: String = str(_get_value("mode", "hub"))

	if objective_label != null:
		if mode == "combat":
			objective_label.text = "MAP ACTIVE · kill packs · loot · extract with E when clear"
		else:
			objective_label.text = "VAULT HUB · choose station · tune build · launch map"

	if notice_label != null:
		var notice_time := _f(_get_value("notice_time", 0.0))
		if notice_time > 0.0:
			notice_label.text = str(_get_value("notice_text", ""))
		else:
			notice_label.text = ""

func _update_skills() -> void:
	if state_ref == null:
		return

	SkillGemSystemScript.ensure_defaults(state_ref)

	var slots: Array = Array(_get_value("active_skill_slots", []))
	var selected: int = _i(_get_value("selected_skill_slot", 0))

	for i: int in range(skill_buttons.size()):
		var button: Button = skill_buttons[i]
		if button == null:
			continue

		if i < slots.size():
			var slot: Dictionary = Dictionary(slots[i])
			var gem_id: String = str(slot.get("active", slot.get("active_id", "fireball")))
			var supports: Array = Array(slot.get("supports", []))
			button.text = "%d\n%s\n+%d" % [i + 1, _short_skill(gem_id), supports.size()]
		else:
			button.text = "%d\n—" % [i + 1]

		if i == selected:
			button.modulate = Color(1.0, 0.78, 0.30, 1.0)
		else:
			button.modulate = Color(1.0, 1.0, 1.0, 0.92)

func _update_station_prompt() -> void:
	if station_prompt == null:
		return

	var mode: String = str(_get_value("mode", "hub"))

	if mode == "combat":
		station_prompt.text = "[Left Click / Space] cast    [E] pick up / extract when clear    [Z/X] flasks"
		return

	var station_name: String = str(_get_value("near_station_name", ""))

	if station_name != "":
		station_prompt.text = "[E] Open " + station_name
	else:
		station_prompt.text = "Hub controls: [M] Map Device  [I] Inventory  [K] Gems  [F] Forge  [C] Character"

func _update_map_mods() -> void:
	if map_mods_label == null:
		return

	var mode: String = str(_get_value("mode", "hub"))

	if mode != "combat":
		map_mods_label.text = "[b]Hub Stations[/b]\nMap Device · Stash · Forge\nGem Bench · Character Shrine\nTraining Dummy"
		return

	var activity: Dictionary = Dictionary(_get_value("current_map_activity", _get_value("current_activity", {})))
	var lines: Array[String] = []

	lines.append("[b]Map Threat[/b]")
	lines.append(str(activity.get("display_name", "Unknown Map")))

	var mods: Array = Array(activity.get("mods", []))

	if mods.is_empty():
		lines.append("No explicit modifiers")
	else:
		for mod: Variant in mods:
			if mod is Dictionary:
				var mod_dict := Dictionary(mod)
				lines.append("• " + str(mod_dict.get("display_name", mod_dict.get("id", "mod"))))
			else:
				lines.append("• " + str(mod))

	map_mods_label.text = "\n".join(lines)

func _select_skill(index: int) -> void:
	if state_ref != null:
		state_ref.set("selected_skill_slot", index)

func _open_panel(mode: String) -> void:
	if state_ref != null:
		UIAccessSystemScript.toggle_panel(state_ref, mode)

func _get_value(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback

	var value: Variant = state_ref.get(key)

	if value == null:
		return fallback

	return value

func _short_skill(id: String) -> String:
	match id:
		"fireball":
			return "Fireball"
		"ember_mine":
			return "Mine"
		"storm_lance":
			return "Storm"
		"chain_spark":
			return "Spark"
		"arc_slash":
			return "Slash"
		"void_rift":
			return "Void"
		"blood_cleave":
			return "Cleave"
		"bone_spear":
			return "Spear"
		"ash_nova":
			return "Nova"
		"shield_burst":
			return "Shield"
		"infernal_step":
			return "Step"
		"furnace_totem":
			return "Totem"
		_:
			return id.replace("_", " ").capitalize().substr(0, 10)

func _compact_materials(materials: Dictionary) -> String:
	if materials.is_empty():
		return "0"

	var parts: Array[String] = []

	for key: Variant in materials.keys():
		parts.append(str(key) + ":" + str(materials[key]))

		if parts.size() >= 3:
			break

	return ", ".join(parts)

func _f(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback

	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(value)
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s: String = str(value)
			if s.is_valid_float():
				return s.to_float()
			if s.is_valid_int():
				return float(s.to_int())
			return fallback
		_:
			return fallback

func _i(value: Variant, fallback: int = 0) -> int:
	return int(round(_f(value, float(fallback))))
