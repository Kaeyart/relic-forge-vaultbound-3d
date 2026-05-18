class_name RVGameState3D
extends RefCounted

const SAVE_VERSION: int = 4
const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")

var mode: String = "hub" # hub / combat
var notice_text: String = ""
var notice_time: float = 0.0
var prompt_text: String = ""
var panel_mode: String = ""

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var character_class_id: String = "sorceress"
var character_name: String = "Vaultbound"
var level: int = 1
var xp: float = 0.0
var passive_points: int = 0
var gold: int = 0
var kills: int = 0
var deaths: int = 0

var player_pos: Vector3 = Vector3.ZERO
var player_radius: float = 0.42
var player_speed: float = 6.4
var player_hp: float = 120.0
var max_hp: float = 120.0
var player_mana: float = 100.0
var max_mana: float = 100.0
var armor: float = 0.0
var fire_resist: float = 0.0
var lightning_resist: float = 0.0
var void_resist: float = 0.0
var build_stats: Dictionary = {}
var invuln: float = 0.0

var health_flask_charges: int = 3
var health_flask_max_charges: int = 3
var mana_flask_charges: int = 3
var mana_flask_max_charges: int = 3
var flask_kill_counter: int = 0

var active_skills: Array[String] = ["fireball", "storm_lance", "arc_slash"]
var selected_skill_index: int = 0
var skill_cooldowns: Dictionary = {}
var skill_mods: Dictionary = {
	"fireball": [],
	"storm_lance": [],
	"arc_slash": []
}

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
var backpack: Array[Dictionary] = []
var materials: Dictionary = {
	"embers": 0,
	"shards": 0,
	"runes": 0
}
var map_stash: Array[Dictionary] = []
var current_map: Dictionary = {}
var active_map_snapshot: Dictionary = {}
var map_entries_remaining: int = 0
var map_entries_max: int = 6
var map_completed: bool = false

var last_loot_text: String = ""
var inventory_cursor: int = 0

func init_new() -> void:
	rng.randomize()
	ensure_defaults()
	full_restore()

func ensure_defaults() -> void:
	if active_skills.is_empty():
		active_skills = ["fireball"]
	selected_skill_index = clampi(selected_skill_index, 0, max(0, active_skills.size() - 1))
	for skill_id: String in active_skills:
		if not skill_cooldowns.has(skill_id):
			skill_cooldowns[skill_id] = 0.0
		if not skill_mods.has(skill_id):
			skill_mods[skill_id] = []
	if map_stash.is_empty():
		map_stash.append({"id": "ash_vault_t1", "name": "Ash Vault", "tier": 1, "level": 1, "rarity": "normal", "mods": []})
	health_flask_max_charges = max(1, health_flask_max_charges)
	mana_flask_max_charges = max(1, mana_flask_max_charges)
	health_flask_charges = clampi(health_flask_charges, 0, health_flask_max_charges)
	mana_flask_charges = clampi(mana_flask_charges, 0, mana_flask_max_charges)
	map_entries_max = max(1, map_entries_max)
	map_entries_remaining = clampi(map_entries_remaining, 0, map_entries_max)
	if map_entries_remaining <= 0:
		current_map.clear()
		active_map_snapshot.clear()
	_normalize_inventory()
	recompute_stats()

func _normalize_inventory() -> void:
	for slot_name: String in equipped.keys():
		if typeof(equipped[slot_name]) == TYPE_DICTIONARY and not Dictionary(equipped[slot_name]).is_empty():
			equipped[slot_name] = ItemDBScript.normalize_item(Dictionary(equipped[slot_name]))
	for i: int in range(backpack.size()):
		backpack[i] = ItemDBScript.normalize_item(Dictionary(backpack[i]))
	inventory_cursor = clampi(inventory_cursor, 0, max(0, backpack.size() - 1))

func recompute_stats() -> void:
	var old_hp_ratio: float = 1.0 if max_hp <= 0.0 else player_hp / max_hp
	var old_mana_ratio: float = 1.0 if max_mana <= 0.0 else player_mana / max_mana
	max_hp = 120.0 + float(level - 1) * 6.0
	max_mana = 100.0 + float(level - 1) * 4.0
	player_speed = 6.4
	armor = 0.0
	fire_resist = 0.0
	lightning_resist = 0.0
	void_resist = 0.0
	build_stats = {}
	for slot_name: String in equipped.keys():
		var item_value: Variant = equipped[slot_name]
		if typeof(item_value) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = ItemDBScript.normalize_item(Dictionary(item_value))
		if item.is_empty():
			continue
		equipped[slot_name] = item
		_merge_build_stats(Dictionary(item.get("total_stats", item.get("stats", {}))))
	max_hp += float(build_stats.get("max_life", 0.0))
	max_mana += float(build_stats.get("max_mana", 0.0))
	player_speed += float(build_stats.get("move_speed_flat", 0.0))
	armor = float(build_stats.get("armor", 0.0))
	fire_resist = float(build_stats.get("fire_resist", 0.0))
	lightning_resist = float(build_stats.get("lightning_resist", 0.0))
	void_resist = float(build_stats.get("void_resist", 0.0))
	player_speed = clampf(player_speed, 3.5, 10.5)
	player_hp = clampf(max_hp * old_hp_ratio, 1.0, max_hp)
	player_mana = clampf(max_mana * old_mana_ratio, 0.0, max_mana)

func _merge_build_stats(stats: Dictionary) -> void:
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		build_stats[key] = float(build_stats.get(key, 0.0)) + float(stats[key_value])

func full_restore() -> void:
	recompute_stats()
	player_hp = max_hp
	player_mana = max_mana
	health_flask_charges = health_flask_max_charges
	mana_flask_charges = mana_flask_max_charges
	invuln = 0.0

func add_notice(text: String) -> void:
	notice_text = text
	notice_time = 2.2

func xp_to_next() -> float:
	return 120.0 + pow(float(level), 1.35) * 75.0

func add_xp(amount: float) -> void:
	xp += max(0.0, amount)
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		passive_points += 1
		add_notice("Level Up - passive point gained")
	recompute_stats()

func get_selected_skill() -> String:
	if active_skills.is_empty():
		return ""
	selected_skill_index = clampi(selected_skill_index, 0, active_skills.size() - 1)
	return str(active_skills[selected_skill_index])

func cycle_skill(delta: int) -> void:
	if active_skills.is_empty():
		return
	selected_skill_index = wrapi(selected_skill_index + delta, 0, active_skills.size())

func use_health_flask() -> bool:
	if health_flask_charges <= 0 or player_hp >= max_hp:
		return false
	health_flask_charges -= 1
	var recovery_more: float = 1.0 + float(build_stats.get("flask_recovery", 0.0))
	player_hp = min(max_hp, player_hp + max_hp * 0.45 * recovery_more)
	add_notice("Health flask")
	return true

func use_mana_flask() -> bool:
	if mana_flask_charges <= 0 or player_mana >= max_mana:
		return false
	mana_flask_charges -= 1
	var recovery_more: float = 1.0 + float(build_stats.get("flask_recovery", 0.0))
	player_mana = min(max_mana, player_mana + max_mana * 0.55 * recovery_more)
	add_notice("Mana flask")
	return true

func refill_flasks_from_kill(is_elite: bool, is_boss: bool) -> void:
	flask_kill_counter += 4 if is_boss else (2 if is_elite else 1)
	while flask_kill_counter >= 5:
		flask_kill_counter -= 5
		if health_flask_charges < health_flask_max_charges:
			health_flask_charges += 1
		elif mana_flask_charges < mana_flask_max_charges:
			mana_flask_charges += 1

func add_item(item: Dictionary) -> void:
	var normalized: Dictionary = ItemDBScript.normalize_item(item)
	backpack.append(normalized)
	inventory_cursor = clampi(inventory_cursor, 0, max(0, backpack.size() - 1))
	last_loot_text = "+ " + str(normalized.get("name", "Item"))

func add_material(id: String, amount: int) -> void:
	materials[id] = int(materials.get(id, 0)) + amount
	last_loot_text = "+ " + str(amount) + " " + id

func add_gold(amount: int) -> void:
	gold += max(0, amount)
	last_loot_text = "+ " + str(amount) + " gold"

func enter_hub() -> void:
	mode = "hub"
	player_pos = Vector3.ZERO
	prompt_text = "Approach the map device and press E, or press T to run a test map."
	full_restore()

func enter_combat(map_item: Dictionary) -> void:
	mode = "combat"
	current_map = map_item.duplicate(true)
	map_completed = false
	if map_entries_remaining <= 0:
		map_entries_remaining = map_entries_max
	player_pos = Vector3(0.0, 0.0, -13.0)
	prompt_text = "Clear the map. T returns to hub."
	full_restore()

func to_save_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"character_class_id": character_class_id,
		"character_name": character_name,
		"level": level,
		"xp": xp,
		"passive_points": passive_points,
		"gold": gold,
		"kills": kills,
		"deaths": deaths,
		"equipped": equipped,
		"backpack": backpack,
		"materials": materials,
		"map_stash": map_stash,
		"active_skills": active_skills,
		"skill_mods": skill_mods,
		"health_flask_charges": health_flask_charges,
		"mana_flask_charges": mana_flask_charges,
		"map_entries_remaining": map_entries_remaining,
		"current_map": current_map
	}

func apply_save_dict(data: Dictionary) -> void:
	character_class_id = str(data.get("character_class_id", character_class_id))
	character_name = str(data.get("character_name", character_name))
	level = int(data.get("level", level))
	xp = float(data.get("xp", xp))
	passive_points = int(data.get("passive_points", passive_points))
	gold = int(data.get("gold", gold))
	kills = int(data.get("kills", kills))
	deaths = int(data.get("deaths", deaths))
	if typeof(data.get("equipped", {})) == TYPE_DICTIONARY:
		equipped.merge(Dictionary(data.get("equipped", {})), true)
	if typeof(data.get("backpack", [])) == TYPE_ARRAY:
		backpack.clear()
		for item_value: Variant in Array(data.get("backpack", [])):
			if typeof(item_value) == TYPE_DICTIONARY:
				backpack.append(ItemDBScript.normalize_item(Dictionary(item_value)))
	if typeof(data.get("materials", {})) == TYPE_DICTIONARY:
		materials.merge(Dictionary(data.get("materials", {})), true)
	if typeof(data.get("map_stash", [])) == TYPE_ARRAY:
		map_stash.clear()
		for map_value: Variant in Array(data.get("map_stash", [])):
			if typeof(map_value) == TYPE_DICTIONARY:
				map_stash.append(Dictionary(map_value))
	if typeof(data.get("active_skills", [])) == TYPE_ARRAY:
		active_skills.clear()
		for skill_value: Variant in Array(data.get("active_skills", [])):
			active_skills.append(str(skill_value))
	if typeof(data.get("skill_mods", {})) == TYPE_DICTIONARY:
		skill_mods = Dictionary(data.get("skill_mods", {})).duplicate(true)
	health_flask_charges = int(data.get("health_flask_charges", health_flask_charges))
	mana_flask_charges = int(data.get("mana_flask_charges", mana_flask_charges))
	map_entries_remaining = int(data.get("map_entries_remaining", map_entries_remaining))
	if typeof(data.get("current_map", {})) == TYPE_DICTIONARY:
		current_map = Dictionary(data.get("current_map", {})).duplicate(true)
	ensure_defaults()
