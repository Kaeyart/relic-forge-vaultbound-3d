class_name RVGameHUD3D
extends CanvasLayer

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")

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
	status_label.text = "Lv %d  XP %.0f/%.0f  HP %.0f/%.0f  Mana %.0f/%.0f  Armor %.0f  Gold %d  Flask Z %d/%d X %d/%d" % [
		int(state.get("level")),
		float(state.get("xp")),
		float(state.call("xp_to_next")),
		hp,
		max_hp,
		mana,
		max_mana,
		float(state.get("armor")),
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
	var text: String = "[b]Inventory / Equipment[/b]\n"
	text += "[ and ] select item. U equips selected item. Gear now uses strict slot/tag affix rules.\n\n"
	var backpack: Array = Array(state.get("backpack"))
	var cursor: int = clampi(int(state.get("inventory_cursor")), 0, max(0, backpack.size() - 1))
	if backpack.is_empty():
		text += "Backpack empty. Kill elites/bosses for gear.\n"
	else:
		for i: int in range(backpack.size()):
			var item: Dictionary = ItemDBScript.normalize_item(Dictionary(backpack[i]))
			var marker: String = "> " if i == cursor else "  "
			text += marker + str(i) + ": " + ItemDBScript.compact_item_line(item) + "\n"
		var selected_item: Dictionary = ItemDBScript.normalize_item(Dictionary(backpack[cursor]))
		text += "\n[b]Selected[/b]\n" + ItemDBScript.item_text(selected_item)
		var old_item: Dictionary = ItemDBScript.best_equipped_for_compare(state, selected_item)
		text += "\n[b]Compare[/b]\n" + ItemDBScript.compare_text(selected_item, old_item)
	text += "\n[b]Equipped[/b]\n"
	var equipped: Dictionary = Dictionary(state.get("equipped"))
	var order: Array[String] = ["weapon", "offhand", "head", "chest", "gloves", "boots", "amulet", "ring1", "ring2", "relic"]
	for slot: String in order:
		var item_value: Variant = equipped.get(slot, {})
		var item_name: String = "Empty"
		if typeof(item_value) == TYPE_DICTIONARY and not Dictionary(item_value).is_empty():
			item_name = str(ItemDBScript.normalize_item(Dictionary(item_value)).get("name", "Item"))
		text += slot + ": " + item_name + "\n"
	return text

func _character_text(state: Object) -> String:
	var build_stats: Dictionary = Dictionary(state.get("build_stats"))
	var text: String = "[b]Character[/b]\n"
	text += "Class: " + str(state.get("character_class_id")) + "\n"
	text += "Level: " + str(int(state.get("level"))) + "\n"
	text += "Kills: " + str(int(state.get("kills"))) + "  Deaths: " + str(int(state.get("deaths"))) + "\n"
	text += "Passive Points placeholder: " + str(int(state.get("passive_points"))) + "\n\n"
	text += "HP " + str(snappedf(float(state.get("max_hp")), 0.1)) + "  Mana " + str(snappedf(float(state.get("max_mana")), 0.1)) + "  Speed " + str(snappedf(float(state.get("player_speed")), 0.01)) + "\n"
	text += "Armor " + str(snappedf(float(state.get("armor")), 0.1)) + "  Fire Res " + str(snappedf(float(state.get("fire_resist")), 0.1)) + "%  Lightning Res " + str(snappedf(float(state.get("lightning_resist")), 0.1)) + "%  Void Res " + str(snappedf(float(state.get("void_resist")), 0.1)) + "%\n\n"
	text += "[b]Build Stats[/b]\n"
	if build_stats.is_empty():
		text += "No equipment bonuses yet.\n"
	else:
		for key_value: Variant in build_stats.keys():
			text += str(key_value).replace("_", " ").capitalize() + ": +" + str(snappedf(float(build_stats[key_value]), 0.01)) + "\n"
	return text

func _maps_text(state: Object) -> String:
	var text: String = "[b]Maps[/b]\n"
	text += "T or E at device starts the first map. Entries: " + str(int(state.get("map_entries_remaining"))) + "\n\n"
	var maps: Array = Array(state.get("map_stash"))
	for i: int in range(maps.size()):
		var map_item: Dictionary = Dictionary(maps[i])
		text += str(i) + ": " + str(map_item.get("name", "Map")) + " T" + str(int(map_item.get("tier", 1))) + "\n"
	return text

func _help_text() -> String:
	return "[b]Controls[/b]\nWASD move\nLeft Click / Space cast\n1-6 select skill\nQ/R cycle skill\nZ/X flasks\nE interact / leave cleared map\nT start map / town portal\nI inventory\nC character\nM maps\n[ / ] inventory select\nU equip selected\nF5 save\n"

func _skill_name(skill_id: String) -> String:
	match skill_id:
		"fireball": return "Fireball"
		"storm_lance": return "Storm Lance"
		"arc_slash": return "Arc Slash"
		"void_rift": return "Void Rift"
		_: return skill_id.capitalize()
