class_name RVGameState3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const GemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")
const ClassSystemScript := preload("res://scripts/systems/CharacterClassSystem3D.gd")
const MapDBScript := preload("res://scripts/data/MapDB3D.gd")

const SAVE_VERSION: int = 87

# RF-090F stash persistence state
# RF-091A station/gem refinement state
# RF-093A gem contract state
var spirit_gem_slots: Array = []
var near_station_mode: String = ""
var near_station_name: String = ""
var gem_progression_seeded: bool = false
var stash_categories: Array = []
var stash_tabs: Array = []
var selected_stash_category_id: String = "cat_general"
var selected_stash_tab_id: String = "tab_general_1"
var stash_selected_item_index: int = -1
var stash_search_query: String = ""
var stash_search_all: bool = false
var map_completion: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var mode: String = "hub"
var panel_mode: String = ""
var notice_text: String = ""
var notice_time: float = 0.0
var prompt_text: String = ""

var class_id: String = "sorceress"
var class_display_name: String = "Sorceress"
var class_tags: Array[String] = []
var class_rules: Array[String] = []

var level: int = 1
var xp: float = 0.0
var passive_points: int = 0
var gold: int = 0
var materials: Dictionary = {
	"embers": 25,
	"shards": 12,
	"runes": 2,
	"echo_glass": 0,
	"socket_prisms": 1
}

var player_hp: float = 120.0
var player_mana: float = 100.0
var max_hp: float = 120.0
var max_mana: float = 100.0
var armor: float = 0.0
var move_speed: float = 6.2
var spirit_max: int = 30
var spirit_reserved: int = 0
var player_pos: Vector3 = Vector3.ZERO

var health_flask_charges: int = 3
var health_flask_max_charges: int = 3
var health_flask_heal_ratio: float = 0.45
var mana_flask_charges: int = 3
var mana_flask_max_charges: int = 3
var mana_flask_restore_ratio: float = 0.55

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
var inventory_cursor: int = 0
var stash: Array[Dictionary] = []
var map_stash: Array[Dictionary] = []
var map_cursor: int = 0
var completed_maps: Dictionary = {}
var current_map_activity: Dictionary = {}
var active_map_entries: int = 0
var active_map_max_entries: int = 6

var active_skill_slots: Array[Dictionary] = []
var active_gems_owned: Dictionary = {}
var support_gems_owned: Dictionary = {}
var spirit_gems_owned: Dictionary = {}
var selected_skill_slot: int = 0
var selected_support_cursor: int = 0
var selected_spirit_cursor: int = 0

var build_stats: Dictionary = {}
var build_rules: Array[String] = []

var kills: int = 0
var deaths: int = 0
var maps_completed: int = 0

func init_new() -> void:
	rng.randomize()
	ensure_defaults()
	full_restore()

func ensure_defaults() -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
	rng.randomize()
	ClassSystemScript.ensure_defaults(self)
	GemSystemScript.ensure_defaults(self)
	if Dictionary(equipped.get("weapon", {})).is_empty():
		equipped["weapon"] = ItemDBScript.make_starter_weapon(rng)
	if map_stash.is_empty():
		map_stash.append(MapDBScript.make_map_item("ash_vault", 1, rng))
	inventory_cursor = clampi(inventory_cursor, 0, max(0, backpack.size() - 1))
	map_cursor = clampi(map_cursor, 0, max(0, map_stash.size() - 1))
	selected_skill_slot = clampi(selected_skill_slot, 0, max(0, active_skill_slots.size() - 1))
	recompute_stats()

func recompute_stats() -> void:
	build_stats = {}
	build_rules = []
	max_hp = 110.0 + float(level - 1) * 7.0
	max_mana = 95.0 + float(level - 1) * 4.0
	spirit_max = 30 + int(level / 5) * 5
	armor = 0.0
	move_speed = 6.2
	var class_bundle: Dictionary = ClassSystemScript.class_bundle(self)
	_merge_stats(Dictionary(class_bundle.get("stats", {})))
	_merge_rules(Array(class_bundle.get("rules", [])))
	for slot_key: Variant in equipped.keys():
		var item_value: Variant = equipped[slot_key]
		if typeof(item_value) == TYPE_DICTIONARY:
			_merge_stats(Dictionary(item_value).get("total_stats", {}))
	var spirit_bundle: Dictionary = GemSystemScript.collect_spirit_bundle(self)
	_merge_stats(Dictionary(spirit_bundle.get("stats", {})))
	_merge_rules(Array(spirit_bundle.get("rules", [])))
	max_hp += float(build_stats.get("Maximum Life", 0.0))
	max_mana += float(build_stats.get("Maximum Mana", 0.0))
	spirit_max += int(round(float(build_stats.get("Maximum Spirit", 0.0))))
	armor += float(build_stats.get("Armor", 0.0))
	move_speed *= 1.0 + float(build_stats.get("Movement Speed", 0.0))
	move_speed = clampf(move_speed, 4.0, 10.5)
	spirit_reserved = int(spirit_bundle.get("reserved", 0))
	player_hp = clampf(player_hp, 0.0, max_hp)
	player_mana = clampf(player_mana, 0.0, max_mana)

func _merge_stats(stats: Dictionary) -> void:
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		build_stats[key] = float(build_stats.get(key, 0.0)) + float(stats[key_value])

func _merge_rules(rules: Array) -> void:
	for value: Variant in rules:
		var rule: String = str(value)
		if rule != "" and not build_rules.has(rule):
			build_rules.append(rule)

func full_restore() -> void:
	recompute_stats()
	player_hp = max_hp
	player_mana = max_mana
	health_flask_charges = health_flask_max_charges
	mana_flask_charges = mana_flask_max_charges

func xp_to_next() -> float:
	return 120.0 + pow(float(level), 1.32) * 75.0

func add_xp(amount: float) -> void:
	xp += max(0.0, amount)
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		passive_points += 1
		add_notice("Level Up: " + str(level))
	recompute_stats()

func on_enemy_killed(enemy_level: int, elite: bool, boss: bool) -> void:
	kills += 1
	var xp_gain: float = 18.0 + float(enemy_level) * 6.0
	if elite:
		xp_gain *= 2.2
	if boss:
		xp_gain *= 6.0
	add_xp(xp_gain)
	if rng.randf() < 0.22 or boss:
		health_flask_charges = mini(health_flask_max_charges, health_flask_charges + 1)
	if rng.randf() < 0.18 or boss:
		mana_flask_charges = mini(mana_flask_max_charges, mana_flask_charges + 1)

func use_health_flask() -> bool:
	if health_flask_charges <= 0 or player_hp >= max_hp:
		return false
	health_flask_charges -= 1
	player_hp = min(max_hp, player_hp + max_hp * health_flask_heal_ratio)
	return true

func use_mana_flask() -> bool:
	if mana_flask_charges <= 0 or player_mana >= max_mana:
		return false
	mana_flask_charges -= 1
	player_mana = min(max_mana, player_mana + max_mana * mana_flask_restore_ratio)
	return true

func spend_mana(amount: float) -> bool:
	if amount <= 0.0:
		return true
	if player_mana < amount:
		add_notice("Not enough mana")
		return false
	player_mana -= amount
	return true

func add_notice(text: String) -> void:
	notice_text = text
	notice_time = 2.5

func add_backpack_item(item: Dictionary) -> void:
	if item.is_empty():
		return
	backpack.append(item.duplicate(true))
	inventory_cursor = clampi(inventory_cursor, 0, max(0, backpack.size() - 1))

func add_material(id: String, amount: int) -> void:
	materials[id] = int(materials.get(id, 0)) + max(0, amount)

func add_map_item(map_item: Dictionary) -> void:
	if map_item.is_empty():
		return
	map_stash.append(map_item.duplicate(true))
	map_cursor = clampi(map_cursor, 0, max(0, map_stash.size() - 1))

func equip_backpack_index(index: int) -> bool:
	if index < 0 or index >= backpack.size():
		return false
	var item: Dictionary = backpack[index]
	var slot: String = str(item.get("slot", ""))
	if slot == "":
		add_notice("Cannot equip this")
		return false
	var old_item: Dictionary = Dictionary(equipped.get(slot, {}))
	equipped[slot] = item
	backpack.remove_at(index)
	if not old_item.is_empty():
		backpack.append(old_item)
	inventory_cursor = clampi(index, 0, max(0, backpack.size() - 1))
	recompute_stats()
	add_notice("Equipped " + str(item.get("display_name", "Item")))
	return true

func selected_backpack_item() -> Dictionary:
	if backpack.is_empty() or inventory_cursor < 0 or inventory_cursor >= backpack.size():
		return {}
	return backpack[inventory_cursor]

func _rf_pre_090f_to_save_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"class_id": class_id,
		"level": level,
		"xp": xp,
		"passive_points": passive_points,
		"gold": gold,
		"materials": materials,
		"equipped": equipped,
		"backpack": backpack,
		"inventory_cursor": inventory_cursor,
		"stash": stash,
		"map_stash": map_stash,
		"map_cursor": map_cursor,
		"completed_maps": completed_maps,
		"active_gems_owned": active_gems_owned,
		"support_gems_owned": support_gems_owned,
		"spirit_gems_owned": spirit_gems_owned,
		"active_skill_slots": active_skill_slots,
		"selected_skill_slot": selected_skill_slot,
		"selected_support_cursor": selected_support_cursor,
		"selected_spirit_cursor": selected_spirit_cursor,
		"kills": kills,
		"deaths": deaths,
		"maps_completed": maps_completed
	}

func _rf_pre_090f_apply_save_dict(data: Dictionary) -> void:
	class_id = str(data.get("class_id", class_id))
	level = int(data.get("level", level))
	xp = float(data.get("xp", xp))
	passive_points = int(data.get("passive_points", passive_points))
	gold = int(data.get("gold", gold))
	if typeof(data.get("materials", {})) == TYPE_DICTIONARY:
		materials.merge(Dictionary(data.get("materials", {})), true)
	if typeof(data.get("equipped", {})) == TYPE_DICTIONARY:
		equipped.merge(Dictionary(data.get("equipped", {})), true)
	if typeof(data.get("backpack", [])) == TYPE_ARRAY:
		backpack.clear()
		for value: Variant in Array(data.get("backpack", [])):
			if typeof(value) == TYPE_DICTIONARY:
				backpack.append(Dictionary(value))
	inventory_cursor = int(data.get("inventory_cursor", inventory_cursor))
	if typeof(data.get("stash", [])) == TYPE_ARRAY:
		stash.clear()
		for value2: Variant in Array(data.get("stash", [])):
			if typeof(value2) == TYPE_DICTIONARY:
				stash.append(Dictionary(value2))
	if typeof(data.get("map_stash", [])) == TYPE_ARRAY:
		map_stash.clear()
		for value3: Variant in Array(data.get("map_stash", [])):
			if typeof(value3) == TYPE_DICTIONARY:
				map_stash.append(Dictionary(value3))
	map_cursor = int(data.get("map_cursor", map_cursor))
	if typeof(data.get("completed_maps", {})) == TYPE_DICTIONARY:
		completed_maps = Dictionary(data.get("completed_maps", {})).duplicate(true)
	if typeof(data.get("active_gems_owned", {})) == TYPE_DICTIONARY:
		active_gems_owned = Dictionary(data.get("active_gems_owned", {})).duplicate(true)
	if typeof(data.get("support_gems_owned", {})) == TYPE_DICTIONARY:
		support_gems_owned = Dictionary(data.get("support_gems_owned", {})).duplicate(true)
	if typeof(data.get("spirit_gems_owned", {})) == TYPE_DICTIONARY:
		spirit_gems_owned = Dictionary(data.get("spirit_gems_owned", {})).duplicate(true)
	if typeof(data.get("active_skill_slots", [])) == TYPE_ARRAY:
		active_skill_slots.clear()
		for slot_value: Variant in Array(data.get("active_skill_slots", [])):
			if typeof(slot_value) == TYPE_DICTIONARY:
				active_skill_slots.append(Dictionary(slot_value))
	selected_skill_slot = int(data.get("selected_skill_slot", selected_skill_slot))
	selected_support_cursor = int(data.get("selected_support_cursor", selected_support_cursor))
	selected_spirit_cursor = int(data.get("selected_spirit_cursor", selected_spirit_cursor))
	kills = int(data.get("kills", kills))
	deaths = int(data.get("deaths", deaths))
	maps_completed = int(data.get("maps_completed", maps_completed))
	ensure_defaults()

func to_save_dict() -> Dictionary:
	var data: Dictionary = _rf_pre_090f_to_save_dict()
	_rf_090f_ensure_stash_state_defaults()

	data["stash_categories"] = stash_categories
	data["stash_tabs"] = stash_tabs
	data["selected_stash_category_id"] = selected_stash_category_id
	data["selected_stash_tab_id"] = selected_stash_tab_id
	data["stash_selected_item_index"] = stash_selected_item_index
	data["stash_search_query"] = stash_search_query
	data["stash_search_all"] = stash_search_all
	data["map_completion"] = map_completion
	data["gem_progression_seeded"] = gem_progression_seeded
	data["spirit_gem_slots"] = spirit_gem_slots
	data["spirit_reserved"] = spirit_reserved
	data["spirit_max"] = spirit_max
	return data


func apply_save_dict(data: Dictionary) -> void:
	_rf_pre_090f_apply_save_dict(data)

	if data.has("stash_categories"):
		stash_categories = Array(data.get("stash_categories", []))
	if data.has("stash_tabs"):
		stash_tabs = Array(data.get("stash_tabs", []))

	selected_stash_category_id = str(data.get("selected_stash_category_id", selected_stash_category_id))
	selected_stash_tab_id = str(data.get("selected_stash_tab_id", selected_stash_tab_id))
	stash_selected_item_index = int(data.get("stash_selected_item_index", stash_selected_item_index))
	stash_search_query = str(data.get("stash_search_query", stash_search_query))
	stash_search_all = bool(data.get("stash_search_all", stash_search_all))

	if data.has("map_completion") and typeof(data.get("map_completion")) == TYPE_DICTIONARY:
		map_completion = Dictionary(data.get("map_completion", {}))

	gem_progression_seeded = bool(data.get("gem_progression_seeded", gem_progression_seeded))

	if data.has("spirit_gem_slots") and typeof(data.get("spirit_gem_slots")) == TYPE_ARRAY:
		spirit_gem_slots = Array(data.get("spirit_gem_slots", []))
	spirit_reserved = int(data.get("spirit_reserved", spirit_reserved))
	spirit_max = int(data.get("spirit_max", spirit_max))

	_rf_090f_ensure_stash_state_defaults()
	ensure_defaults()


func _rf_090f_ensure_stash_state_defaults() -> void:
	near_station_mode = ""
	near_station_name = ""
	if typeof(stash_categories) != TYPE_ARRAY:
		stash_categories = []
	if typeof(stash_tabs) != TYPE_ARRAY:
		stash_tabs = []
	if selected_stash_category_id == "":
		selected_stash_category_id = "cat_general"
	if selected_stash_tab_id == "":
		selected_stash_tab_id = "tab_general_1"
	if typeof(map_completion) != TYPE_DICTIONARY:
		map_completion = {}
