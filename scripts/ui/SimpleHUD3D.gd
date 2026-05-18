class_name RVSimpleHUD3D
extends CanvasLayer

@onready var status_label: Label = $Root/StatusLabel
@onready var prompt_label: Label = $Root/PromptLabel
@onready var notice_label: Label = $Root/NoticeLabel
@onready var panel_text: RichTextLabel = $Root/PanelText

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

func update_from_state(state: Object) -> void:
	if state == null:
		return
	status_label.text = "Lv %s  HP %d/%d  Mana %d/%d  Spirit %d/%d  Gold %d  Skill %d" % [
		str(int(state.get("level"))),
		int(round(float(state.get("player_hp")))), int(round(float(state.get("max_hp")))),
		int(round(float(state.get("player_mana")))), int(round(float(state.get("max_mana")))),
		int(state.get("spirit_reserved")), int(state.get("spirit_max")),
		int(state.get("gold")), int(state.get("selected_skill_slot")) + 1
	]
	prompt_label.text = str(state.get("prompt_text"))
	notice_label.visible = float(state.get("notice_time")) > 0.0
	notice_label.text = str(state.get("notice_text"))
	panel_text.visible = str(state.get("panel_mode")) != "" and str(state.get("panel_mode")) != "skills"
	if not panel_text.visible:
		return
	match str(state.get("panel_mode")):
		"inventory": panel_text.text = _inventory_text(state)
		"character": panel_text.text = _character_text(state)
		"maps": panel_text.text = _maps_text(state)
		"help": panel_text.text = _help_text()
		_: panel_text.text = ""

func _inventory_text(state: Object) -> String:
	var inv: Array = Array(state.get("inventory"))
	var cursor: int = clampi(int(state.get("inventory_cursor")), 0, max(0, inv.size() - 1))
	var text: String = "[b]Inventory[/b]\n[ / ] move cursor, U equip selected\n\n"
	for i: int in range(inv.size()):
		var item: Dictionary = Dictionary(inv[i])
		var marker: String = "> " if i == cursor else "  "
		text += marker + str(item.get("display_name", "Item")) + "\n"
	text += "\n[b]Selected[/b]\n"
	if inv.size() > 0:
		text += ItemDBScript.item_detail_text(Dictionary(inv[cursor]))
	return text

func _character_text(state: Object) -> String:
	var text: String = "[b]Character[/b]\n"
	text += "Level: " + str(int(state.get("level"))) + "  XP: " + str(int(float(state.get("xp")))) + "\n"
	text += "HP: " + str(int(state.get("max_hp"))) + "  Mana: " + str(int(state.get("max_mana"))) + "\n"
	text += "Armor: " + str(int(state.get("armor"))) + "\n"
	text += "Fire Res: " + str(int(float(state.get("fire_resist"))*100.0)) + "%  Lightning Res: " + str(int(float(state.get("lightning_resist"))*100.0)) + "%  Void Res: " + str(int(float(state.get("void_resist"))*100.0)) + "%\n"
	text += "\n[b]Build Stats[/b]\n"
	for key: Variant in Dictionary(state.get("build_stats")).keys():
		text += str(key).replace("_", " ").capitalize() + ": " + str(Dictionary(state.get("build_stats"))[key]) + "\n"
	text += "\n" + SkillGemSystemScript.skill_summary_text(state)
	return text

func _maps_text(state: Object) -> String:
	var text: String = "[b]Maps[/b]\nT/E in hub starts a test map.\n\n"
	var maps: Array = Array(state.get("map_stash"))
	for map_item: Variant in maps:
		if typeof(map_item) == TYPE_DICTIONARY:
			text += str(Dictionary(map_item).get("display_name", "Map")) + "\n"
	return text

func _help_text() -> String:
	return "[b]Controls[/b]\nWASD: move\nLeft click / Space: cast selected skill\n1-4: select skill slot\nQ/R: cycle skill\nK: skill gems loadout\nI: inventory\nC: character\nM: maps\nZ/X: flasks\nE/T: map/portal\nF5: save\n"
