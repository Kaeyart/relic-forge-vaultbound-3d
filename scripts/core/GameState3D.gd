class_name RVGameState3D
extends RefCounted

const SAVE_VERSION: int = 1

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var mode: String = "hub"
var panel_mode: String = ""
var current_map_run: Dictionary = {}
var active_map_portal: Dictionary = {}

var character_name: String = "Vaultbound"
var class_id: String = "sorceress"
var level: int = 1
var xp: int = 0
var xp_to_next: int = 120
var passive_points: int = 0
var gold: int = 0

var player_pos: Vector3 = Vector3.ZERO
var player_hp: float = 120.0
var player_mana: float = 100.0
var max_hp: float = 120.0
var max_mana: float = 100.0
var move_speed: float = 7.0

var health_flask_charges: int = 3
var health_flask_max_charges: int = 3
var mana_flask_charges: int = 3
var mana_flask_max_charges: int = 3

var equipped: Dictionary = {
	"weapon": {},
	"offhand": {},
	"head": {},
	"chest": {},
	"gloves": {},
	"boots": {},
	"amulet": {},
	"ring1": {},
	"ring2": {},
	"relic": {}
}
var inventory: Array[Dictionary] = []
var map_inventory: Array[Dictionary] = []
var materials: Dictionary = {
	"embers": 0,
	"shards": 0,
	"runes": 0,
	"forge_seals": 0
}

var active_skill_slots: Array[String] = ["fireball", "storm_lance", "rift_pulse", "arc_slash"]
var selected_skill_index: int = 0
var skill_mods: Dictionary = {}
var skill_cooldowns: Dictionary = {}

var kills: int = 0
var deaths: int = 0
var maps_completed: int = 0
var completed_map_ids: Dictionary = {}

var notice_text: String = ""
var notice_time: float = 0.0

func init_new() -> void:
	rng.randomize()
	ensure_defaults()
	full_restore()

func ensure_defaults() -> void:
	level = max(1, int(level))
	xp = max(0, int(xp))
	xp_to_next = max(1, int(xp_to_next))
	max_hp = max(1.0, float(max_hp))
	max_mana = max(1.0, float(max_mana))
	move_speed = max(1.0, float(move_speed))
	health_flask_max_charges = max(1, int(health_flask_max_charges))
	mana_flask_max_charges = max(1, int(mana_flask_max_charges))
	health_flask_charges = clampi(int(health_flask_charges), 0, health_flask_max_charges)
	mana_flask_charges = clampi(int(mana_flask_charges), 0, mana_flask_max_charges)
	selected_skill_index = clampi(int(selected_skill_index), 0, max(0, active_skill_slots.size() - 1))
	for skill_id: String in active_skill_slots:
		if not skill_cooldowns.has(skill_id):
			skill_cooldowns[skill_id] = 0.0
	if inventory.is_empty():
		inventory.append(RVItemDB3D.make_starter_weapon(class_id))
	if map_inventory.is_empty():
		map_inventory.append(RVMapDB3D.make_map_item("ash_vault_01", 1, "Normal"))
	recompute_stats()

func recompute_stats() -> void:
	var class_data: Dictionary = RVCharacterClassSystem3D.class_data(class_id)
	max_hp = 120.0 + float(level - 1) * 6.0 + float(class_data.get("max_hp", 0.0))
	max_mana = 100.0 + float(level - 1) * 4.0 + float(class_data.get("max_mana", 0.0))
	move_speed = 7.0 + float(class_data.get("move_speed", 0.0))
	for slot_name: String in equipped.keys():
		var item_value: Variant = equipped.get(slot_name, {})
		if typeof(item_value) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = Dictionary(item_value)
		var stats: Dictionary = Dictionary(item.get("stats", {}))
		max_hp += float(stats.get("max_hp", 0.0))
		max_mana += float(stats.get("max_mana", 0.0))
		move_speed += float(stats.get("move_speed", 0.0))
	player_hp = min(player_hp, max_hp)
	player_mana = min(player_mana, max_mana)

func full_restore() -> void:
	recompute_stats()
	player_hp = max_hp
	player_mana = max_mana
	health_flask_charges = health_flask_max_charges
	mana_flask_charges = mana_flask_max_charges

func selected_skill_id() -> String:
	if active_skill_slots.is_empty():
		return ""
	selected_skill_index = clampi(selected_skill_index, 0, active_skill_slots.size() - 1)
	return str(active_skill_slots[selected_skill_index])

func add_xp(amount: int) -> int:
	var gained_levels: int = 0
	xp += max(0, amount)
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		gained_levels += 1
		passive_points += 1
		xp_to_next = RVProgressionSystem3D.xp_to_next(level)
	if gained_levels > 0:
		recompute_stats()
		add_notice("Level Up! Level " + str(level))
	return gained_levels

func add_notice(text: String) -> void:
	notice_text = text
	notice_time = 2.25

func enter_hub() -> void:
	mode = "hub"
	panel_mode = ""
	current_map_run.clear()
	player_pos = Vector3.ZERO
	full_restore()

func enter_map_run(map_item: Dictionary) -> void:
	mode = "map"
	panel_mode = ""
	current_map_run = RVMapLoopSystem3D.start_run(map_item)
	active_map_portal = current_map_run.duplicate(true)
	player_pos = Vector3.ZERO
	full_restore()

func to_save_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"character_name": character_name,
		"class_id": class_id,
		"level": level,
		"xp": xp,
		"xp_to_next": xp_to_next,
		"passive_points": passive_points,
		"gold": gold,
		"equipped": equipped,
		"inventory": inventory,
		"map_inventory": map_inventory,
		"materials": materials,
		"active_skill_slots": active_skill_slots,
		"selected_skill_index": selected_skill_index,
		"skill_mods": skill_mods,
		"kills": kills,
		"deaths": deaths,
		"maps_completed": maps_completed,
		"completed_map_ids": completed_map_ids
	}

func apply_save_dict(data: Dictionary) -> void:
	character_name = str(data.get("character_name", character_name))
	class_id = str(data.get("class_id", class_id))
	level = int(data.get("level", level))
	xp = int(data.get("xp", xp))
	xp_to_next = int(data.get("xp_to_next", xp_to_next))
	passive_points = int(data.get("passive_points", passive_points))
	gold = int(data.get("gold", gold))
	if typeof(data.get("equipped", {})) == TYPE_DICTIONARY:
		equipped.merge(Dictionary(data.get("equipped", {})), true)
	if typeof(data.get("inventory", [])) == TYPE_ARRAY:
		inventory = []
		for value: Variant in Array(data.get("inventory", [])):
			if typeof(value) == TYPE_DICTIONARY:
				inventory.append(Dictionary(value))
	if typeof(data.get("map_inventory", [])) == TYPE_ARRAY:
		map_inventory = []
		for map_value: Variant in Array(data.get("map_inventory", [])):
			if typeof(map_value) == TYPE_DICTIONARY:
				map_inventory.append(Dictionary(map_value))
	if typeof(data.get("materials", {})) == TYPE_DICTIONARY:
		materials.merge(Dictionary(data.get("materials", {})), true)
	if typeof(data.get("active_skill_slots", [])) == TYPE_ARRAY:
		active_skill_slots = []
		for skill_value: Variant in Array(data.get("active_skill_slots", [])):
			active_skill_slots.append(str(skill_value))
	selected_skill_index = int(data.get("selected_skill_index", selected_skill_index))
	if typeof(data.get("skill_mods", {})) == TYPE_DICTIONARY:
		skill_mods = Dictionary(data.get("skill_mods", {})).duplicate(true)
	kills = int(data.get("kills", kills))
	deaths = int(data.get("deaths", deaths))
	maps_completed = int(data.get("maps_completed", maps_completed))
	if typeof(data.get("completed_map_ids", {})) == TYPE_DICTIONARY:
		completed_map_ids = Dictionary(data.get("completed_map_ids", {})).duplicate(true)
	ensure_defaults()
