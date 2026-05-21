class_name RVHUD3D
extends CanvasLayer

@onready var status_label: Label = %StatusLabel
@onready var prompt_label: Label = %PromptLabel
@onready var notice_label: Label = %NoticeLabel
@onready var hp_bar: ProgressBar = %HPBar
@onready var mana_bar: ProgressBar = %ManaBar

func update_from_state(state: RVGameState3D) -> void:
	if state == null:
		return
	status_label.text = "Lv " + str(state.level) + "  XP " + str(int(state.xp)) + "/" + str(int(state.xp_to_next())) + "  Gold " + str(state.gold) + "  Skill: " + state.get_selected_skill()
	prompt_label.text = state.prompt_text
	notice_label.text = state.notice_text if state.notice_time > 0.0 else ""
	hp_bar.max_value = state.max_hp
	hp_bar.value = state.player_hp
	mana_bar.max_value = state.max_mana
	mana_bar.value = state.player_mana
