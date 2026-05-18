class_name RVGameState3D
extends RefCounted

var mode: String = "hub"
var player_pos: Vector3 = Vector3.ZERO
var player_radius: float = 0.45
var player_speed: float = 6.25
var player_hp: float = 120.0
var max_hp: float = 120.0
var player_mana: float = 100.0
var max_mana: float = 100.0
var level: int = 1
var xp: float = 0.0
var gold: int = 0
var kills: int = 0
var deaths: int = 0
var selected_skill_index: int = 0
var active_skills: Array[String] = ["Fireball", "Cleave", "Storm Lance", "Void Rift", "Blade Trap", "Frost Nova"]
var notice_text: String = ""
var notice_time: float = 0.0
var prompt_text: String = ""
var current_activity: Dictionary = {}
var active_map_entries: int = 0
var active_map_max_entries: int = 6
var health_flask_charges: int = 3
var health_flask_max_charges: int = 3
var mana_flask_charges: int = 3
var mana_flask_max_charges: int = 3
var skill_cooldowns: Dictionary = {}
var build_stats: Dictionary = {}
var build_flags: Array[String] = []
var backpack: Array[Dictionary] = []
var materials: Dictionary = {"embers": 10, "shards": 5, "runes": 0}

func reset_new() -> void:
	mode = "hub"
	player_pos = Vector3.ZERO
	full_restore()
	add_notice("3D clean runtime ready")

func full_restore() -> void:
	player_hp = max_hp
	player_mana = max_mana
	health_flask_charges = health_flask_max_charges
	mana_flask_charges = mana_flask_max_charges

func add_notice(text: String) -> void:
	notice_text = text
	notice_time = 2.0

func get_selected_skill() -> String:
	if active_skills.is_empty():
		return ""
	selected_skill_index = clampi(selected_skill_index, 0, active_skills.size() - 1)
	return active_skills[selected_skill_index]

func xp_to_next() -> float:
	return 120.0 + pow(float(level), 1.35) * 80.0

func add_xp(amount: float) -> void:
	xp += max(0.0, amount)
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		max_hp += 5.0
		max_mana += 3.0
		add_notice("Level Up - Level " + str(level))

func use_life_flask() -> bool:
	if health_flask_charges <= 0:
		add_notice("Health flask empty")
		return false
	if player_hp >= max_hp:
		add_notice("Life already full")
		return false
	health_flask_charges -= 1
	player_hp = min(max_hp, player_hp + max_hp * 0.45)
	return true

func use_mana_flask() -> bool:
	if mana_flask_charges <= 0:
		add_notice("Mana flask empty")
		return false
	if player_mana >= max_mana:
		add_notice("Mana already full")
		return false
	mana_flask_charges -= 1
	player_mana = min(max_mana, player_mana + max_mana * 0.55)
	return true

func on_enemy_killed(elite: bool = false, boss: bool = false) -> void:
	kills += 1
	var xp_gain: float = 18.0
	if elite:
		xp_gain = 55.0
	if boss:
		xp_gain = 180.0
	add_xp(xp_gain)
	gold += 2 + (6 if elite else 0) + (20 if boss else 0)
	if kills % 5 == 0:
		health_flask_charges = min(health_flask_max_charges, health_flask_charges + 1)
		mana_flask_charges = min(mana_flask_max_charges, mana_flask_charges + 1)
