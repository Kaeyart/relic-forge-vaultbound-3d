extends CanvasLayer

const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

var state_ref: Object = null

func bind_state(state: Object) -> void:
	state_ref = state
	update_from_state(state)

func update_from_state(state: Object) -> void:
	state_ref = state
	if state_ref == null:
		return
	_set_first_label_matching(["StatusLabel", "TopStatusLabel", "SummaryLabel"], _status_text())
	_set_first_label_matching(["HelpLabel", "PromptLabel"], _help_text())

func _status_text() -> String:
	if state_ref == null:
		return ""
	SkillGemSystemScript.ensure_defaults(state_ref)
	var cast: Dictionary = SkillGemSystemScript.selected_cast_data(state_ref)
	return "Lv %s · HP %s/%s · Mana %s/%s · Skill %s" % [
		str(_state_get("level", 1)),
		str(_safe_int(_state_get("player_hp", 0))),
		str(_safe_int(_state_get("max_hp", 0))),
		str(_safe_int(_state_get("player_mana", 0))),
		str(_safe_int(_state_get("max_mana", 0))),
		str(cast.get("name", "Skill"))
	]

func _help_text() -> String:
	return "I Inventory · K Skills · F Forge · M Maps · C Character · Esc Close"

func _set_first_label_matching(names: Array, value: String) -> void:
	for name_value: Variant in names:
		var n: Node = find_child(str(name_value), true, false)
		if n is Label:
			(n as Label).text = value
			return
		if n is RichTextLabel:
			(n as RichTextLabel).text = value
			return

func _state_get(key: String, fallback: Variant = null) -> Variant:
	if state_ref == null:
		return fallback
	var value: Variant = state_ref.get(key)
	return fallback if value == null else value

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

func item_summary(item: Dictionary) -> String:
	if item.is_empty(): return "No item selected."
	var lines: PackedStringArray = [str(item.get("display_name", item.get("name", "Item")))]
	lines.append(str(item.get("rarity", "normal")).to_upper() + " · " + str(item.get("slot", "")))
	var stats: Dictionary = Dictionary(item.get("total_stats", {}))
	for k: Variant in stats.keys(): lines.append("+ %s %s" % [str(stats[k]), str(k)])
	return "\n".join(lines)
