class_name RVGameHUD3D
extends CanvasLayer

@onready var status_label: Label = %StatusLabel
@onready var skill_label: Label = %SkillLabel
@onready var prompt_label: Label = %PromptLabel
@onready var notice_label: Label = %NoticeLabel
@onready var panel_label: RichTextLabel = %PanelLabel

func update_from_state(state: Object) -> void:
	if state == null:
		return
	var hp: float = float(state.get("player_hp"))
	var max_hp: float = float(state.get("max_hp"))
	var mana: float = float(state.get("player_mana"))
	var max_mana: float = float(state.get("max_mana"))
	status_label.text = "Lv %d  XP %.0f/%.0f  HP %.0f/%.0f  Mana %.0f/%.0f  Gold %d  Flask Z %d/%d X %d/%d" % [
		int(state.get("level")),
		float(state.get("xp")),
		float(state.call("xp_to_next")),
		hp,
		max_hp,
		mana,
		max_mana,
		int(state.get("gold")),
		int(state.get("health_flask_charges")),
		int(state.get("health_flask_max_charges")),
		int(state.get("mana_flask_charges")),
		int(state.get("mana_flask_max_charges"))
	]
	var skills: Array = Array(state.get("active_skills"))
	var selected: int = int(state.get("selected_skill_index"))
	var skill_text: String = ""
	for i: int in range(skills.size()):
		var marker: String = "▶" if i == selected else " "
		skill_text += marker + str(i + 1) + ": " + _skill_name(str(skills[i])) + "  "
	skill_label.text = skill_text
	prompt_label.text = str(state.get("prompt_text")) + "   Last: " + str(state.get("last_loot_text"))
	notice_label.visible = float(state.get("notice_time")) > 0.0
	notice_label.text = str(state.get("notice_text"))
	_update_panel(state)

func _update_panel(state: Object) -> void:
	var mode: String = str(state.get("panel_mode"))
	panel_label.visible = mode != ""
	if mode == "":
		return
	match mode:
		"inventory":
			panel_label.text = _inventory_text(state)
		"character":
			panel_label.text = _character_text(state)
		"maps":
			panel_label.text = _maps_text(state)
		"help":
			panel_label.text = _help_text()
		_:
			panel_label.text = "[b]" + mode.capitalize() + "[/b]"

func _inventory_text(state: Object) -> String:
	var text: String = "[b]Inventory[/b]\n"
	text += "Use [ and ] to select. U equips selected item.\n\n"
	var backpack: Array = Array(state.get("backpack"))
	var cursor: int = int(state.get("inventory_cursor"))
	if backpack.is_empty():
		text += "Backpack empty.\n"
	else:
		for i: int in range(backpack.size()):
			var item: Dictionary = Dictionary(backpack[i])
			var marker: String = "> " if i == cursor else "  "
			text += marker + str(i) + ": " + str(item.get("name", "Item")) + " [" + str(item.get("rarity", "normal")) + "] " + str(item.get("slot", "")) + "\n"
	text += "\n[b]Equipped[/b]\n"
	var equipped: Dictionary = Dictionary(state.get("equipped"))
	for slot_value: Variant in equipped.keys():
		var slot: String = str(slot_value)
		var item_value: Variant = equipped[slot]
		var item_name: String = "Empty"
		if typeof(item_value) == TYPE_DICTIONARY and not Dictionary(item_value).is_empty():
			item_name = str(Dictionary(item_value).get("name", "Item"))
		text += slot + ": " + item_name + "\n"
	return text

func _character_text(state: Object) -> String:
	return "[b]Character[/b]\n" + \
		"Class: " + str(state.get("character_class_id")) + "\n" + \
		"Level: " + str(int(state.get("level"))) + "\n" + \
		"Kills: " + str(int(state.get("kills"))) + "  Deaths: " + str(int(state.get("deaths"))) + "\n" + \
		"Passive Points placeholder: " + str(int(state.get("passive_points"))) + "\n"

func _maps_text(state: Object) -> String:
	var text: String = "[b]Maps[/b]\n"
	text += "T or E at device starts the first map. Entries: " + str(int(state.get("map_entries_remaining"))) + "\n\n"
	var maps: Array = Array(state.get("map_stash"))
	for i: int in range(maps.size()):
		var map_item: Dictionary = Dictionary(maps[i])
		text += str(i) + ": " + str(map_item.get("name", "Map")) + " T" + str(int(map_item.get("tier", 1))) + "\n"
	return text

func _help_text() -> String:
	return "[b]Controls[/b]\nWASD move\nLeft Click / Space cast\n1-6 select skill\nQ/R cycle skill\nZ/X flasks\nE interact / leave cleared map\nT start map / town portal\nI inventory\nC character\nM maps\nF5 save\n"

func _skill_name(skill_id: String) -> String:
	match skill_id:
		"fireball": return "Fireball"
		"storm_lance": return "Storm Lance"
		"arc_slash": return "Arc Slash"
		"void_rift": return "Void Rift"
		_: return skill_id.capitalize()
