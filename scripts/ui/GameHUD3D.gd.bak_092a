extends CanvasLayer

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

var hp_bar: ProgressBar = null
var mana_bar: ProgressBar = null
var xp_bar: ProgressBar = null
var hp_label: Label = null
var mana_label: Label = null
var xp_label: Label = null
var notice_label: Label = null
var objective_label: Label = null
var skill_buttons: Array = []
var health_flask_button: Button = null
var mana_flask_button: Button = null
var inventory_button: Button = null
var skills_button: Button = null
var forge_button: Button = null
var maps_button: Button = null
var character_button: Button = null

var state_ref: Object = null

func _ready() -> void:
	_bind_nodes()
	_connect_buttons()

func _bind_nodes() -> void:
	hp_label = get_node_or_null("TopLeft/VBox/HPLabel") as Label
	hp_bar = get_node_or_null("TopLeft/VBox/HPBar") as ProgressBar
	mana_label = get_node_or_null("TopLeft/VBox/ManaLabel") as Label
	mana_bar = get_node_or_null("TopLeft/VBox/ManaBar") as ProgressBar
	xp_label = get_node_or_null("TopLeft/VBox/XPLabel") as Label
	xp_bar = get_node_or_null("TopLeft/VBox/XPBar") as ProgressBar

	objective_label = get_node_or_null("ObjectivePanel/VBox/ObjectiveLabel") as Label
	notice_label = get_node_or_null("ObjectivePanel/VBox/NoticeLabel") as Label

	inventory_button = get_node_or_null("MenuPanel/HBox/InventoryButton") as Button
	skills_button = get_node_or_null("MenuPanel/HBox/SkillsButton") as Button
	forge_button = get_node_or_null("MenuPanel/HBox/ForgeButton") as Button
	maps_button = get_node_or_null("MenuPanel/HBox/MapsButton") as Button
	character_button = get_node_or_null("MenuPanel/HBox/CharacterButton") as Button

	health_flask_button = get_node_or_null("BottomPanel/HBox/HealthFlask") as Button
	mana_flask_button = get_node_or_null("BottomPanel/HBox/ManaFlask") as Button
	skill_buttons = [
		get_node_or_null("BottomPanel/HBox/Skill1") as Button,
		get_node_or_null("BottomPanel/HBox/Skill2") as Button,
		get_node_or_null("BottomPanel/HBox/Skill3") as Button,
		get_node_or_null("BottomPanel/HBox/Skill4") as Button,
	]

func _connect_buttons() -> void:
	for i: int in range(skill_buttons.size()):
		var b: Button = skill_buttons[i]
		if b != null:
			b.pressed.connect(_select_skill.bind(i))
	if health_flask_button != null:
		health_flask_button.pressed.connect(_use_health)
	if mana_flask_button != null:
		mana_flask_button.pressed.connect(_use_mana)
	if inventory_button != null:
		inventory_button.pressed.connect(_open.bind("inventory"))
	if skills_button != null:
		skills_button.pressed.connect(_open.bind("skills"))
	if forge_button != null:
		forge_button.pressed.connect(_open.bind("crafting"))
	if maps_button != null:
		maps_button.pressed.connect(_open.bind("maps"))
	if character_button != null:
		character_button.pressed.connect(_open.bind("character"))

func bind_state(state: Object) -> void:
	state_ref = state
	update_from_state(state)

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

func update_from_state(state: Object) -> void:
	state_ref = state
	if state_ref == null:
		return
	if hp_bar == null:
		_bind_nodes()

	var hp: float = _rf_087v_float(_state_get("player_hp", 0.0), 0.0)
	var max_hp: float = max(1.0, _rf_087v_float(_state_get("max_hp", 1.0), 1.0))
	var mana: float = _rf_087v_float(_state_get("player_mana", 0.0), 0.0)
	var max_mana: float = max(1.0, _rf_087v_float(_state_get("max_mana", 1.0), 1.0))
	var xp: float = _rf_087v_float(_state_get("xp", 0.0), 0.0)
	var next_xp: float = max(1.0, _rf_087v_float(_state_get("xp_to_next", 100.0), 100.0))

	if hp_bar != null:
		hp_bar.max_value = max_hp
		hp_bar.value = clampf(hp, 0.0, max_hp)
	if mana_bar != null:
		mana_bar.max_value = max_mana
		mana_bar.value = clampf(mana, 0.0, max_mana)
	if xp_bar != null:
		xp_bar.max_value = next_xp
		xp_bar.value = clampf(xp, 0.0, next_xp)

	if hp_label != null:
		hp_label.text = "HP %d / %d" % [_rf_087v_int(hp), _rf_087v_int(max_hp)]
	if mana_label != null:
		mana_label.text = "Mana %d / %d" % [_rf_087v_int(mana), _rf_087v_int(max_mana)]
	if xp_label != null:
		xp_label.text = "Lv %s   XP %d / %d" % [str(_state_get("level", 1)), _rf_087v_int(xp), _rf_087v_int(next_xp)]
	if notice_label != null:
		notice_label.text = str(_state_get("notice_text", "")) if _rf_087v_float(_state_get("notice_time", 0.0), 0.0) > 0.0 else ""
	if objective_label != null:
		objective_label.text = "Map active · kill, loot, extract" if str(_state_get("mode", "hub")) == "combat" else "Hub · prepare, craft, map"

	SkillGemSystemScript.ensure_defaults(state_ref)
	var slots: Array = Array(_state_get("active_skill_slots", []))
	var selected: int = _rf_087v_int(_state_get("selected_skill_slot", 0), 0)
	for i: int in range(skill_buttons.size()):
		var b: Button = skill_buttons[i]
		if b == null:
			continue
		if i < slots.size():
			var slot: Dictionary = Dictionary(slots[i])
			var id: String = str(slot.get("active", slot.get("active_id", "fireball")))
			b.text = "%d\n%s" % [i + 1, _short(id)]
			b.modulate = Color(1.0, 0.86, 0.46, 1.0) if i == selected else Color(1, 1, 1, 1)
		else:
			b.text = "%d\n-" % [i + 1]

func _short(id: String) -> String:
	match id:
		"fireball": return "Fire"
		"storm_lance": return "Storm"
		"arc_slash": return "Slash"
		"void_rift": return "Void"
		"ember_mine": return "Mine"
		_: return id.substr(0, min(6, id.length()))

func _select_skill(index: int) -> void:
	if state_ref != null:
		state_ref.set("selected_skill_slot", index)

func _open(mode: String) -> void:
	if state_ref != null:
		state_ref.set("panel_mode", mode)

func _use_health() -> void:
	if state_ref == null:
		return
	var max_hp: float = max(1.0, _rf_087v_float(_state_get("max_hp", 1.0), 1.0))
	var hp: float = _rf_087v_float(_state_get("player_hp", max_hp), max_hp)
	state_ref.set("player_hp", min(max_hp, hp + max_hp * 0.45))
	if state_ref.has_method("add_notice"):
		state_ref.call("add_notice", "Health flask")

func _use_mana() -> void:
	if state_ref == null:
		return
	var max_mana: float = max(1.0, _rf_087v_float(_state_get("max_mana", 1.0), 1.0))
	var mana: float = _rf_087v_float(_state_get("player_mana", max_mana), max_mana)
	state_ref.set("player_mana", min(max_mana, mana + max_mana * 0.55))
	if state_ref.has_method("add_notice"):
		state_ref.call("add_notice", "Mana flask")

func _rf_087v_float(value: Variant, fallback: float = 0.0) -> float:
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

func _rf_087v_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
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
