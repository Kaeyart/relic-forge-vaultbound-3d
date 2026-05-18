class_name RVGameState3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const GemDBScript := preload("res://scripts/data/GemDB3D.gd")
const SkillGemSystemScript := preload("res://scripts/systems/SkillGemSystem3D.gd")

const SAVE_VERSION: int = 7

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var mode: String = "hub"
var panel_mode: String = ""
var notice_text: String = ""
var notice_time: float = 0.0
var prompt_text: String = ""

var player_pos: Vector3 = Vector3.ZERO
var player_speed: float = 7.0
var player_radius: float = 0.55
var level: int = 1
var xp: float = 0.0
var gold: int = 0
var deaths: int = 0
var kills: int = 0

var max_hp: float = 120.0
var player_hp: float = 120.0
var max_mana: float = 100.0
var player_mana: float = 100.0
var mana_regen: float = 10.0
var armor: float = 0.0
var fire_resist: float = 0.0
var lightning_resist: float = 0.0
var void_resist: float = 0.0
var movement_speed_mult: float = 1.0
var build_stats: Dictionary = {}
var build_rules: Array[String] = []

var health_flask_charges: int = 3
var health_flask_max_charges: int = 3
var health_flask_heal_ratio: float = 0.45
var mana_flask_charges: int = 3
var mana_flask_max_charges: int = 3
var mana_flask_restore_ratio: float = 0.55
var flask_kill_counter: int = 0

var inventory: Array[Dictionary] = []
var inventory_cursor: int = 0
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
var map_stash: Array[Dictionary] = []
var current_map: Dictionary = {}
var completed_maps: Dictionary = {}

# 087G: clean skill gem model.
var selected_skill_slot: int = 0
var gem_uid_counter: int = 1
var spirit_max: int = 30
var spirit_reserved: int = 0
var active_gem_inventory: Array[Dictionary] = []
var support_gem_inventory: Array[Dictionary] = []
var spirit_gem_inventory: Array[Dictionary] = []
var skill_loadout: Array[Dictionary] = []
var skill_panel_selected_slot: int = 0

var class_id: String = "sorceress"
var class_display_name: String = "Sorceress"

func init_new() -> void:
	rng.randomize()
	ensure_defaults()
	full_restore()

func ensure_defaults() -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
	if active_gem_inventory.is_empty():
		active_gem_inventory = [
			GemDBScript.make_active_gem(_next_gem_uid("active"), "fireball", 1),
			GemDBScript.make_active_gem(_next_gem_uid("active"), "storm_lance", 1),
			GemDBScript.make_active_gem(_next_gem_uid("active"), "arc_slash", 1),
			GemDBScript.make_active_gem(_next_gem_uid("active"), "void_rift", 1),
			GemDBScript.make_active_gem(_next_gem_uid("active"), "ember_mine", 1),
		]
	if support_gem_inventory.is_empty():
		support_gem_inventory = [
			GemDBScript.make_support_gem(_next_gem_uid("support"), "controlled_power", 1),
			GemDBScript.make_support_gem(_next_gem_uid("support"), "efficient_casting", 1),
			GemDBScript.make_support_gem(_next_gem_uid("support"), "greater_area", 1),
			GemDBScript.make_support_gem(_next_gem_uid("support"), "split_projectile", 1),
			GemDBScript.make_support_gem(_next_gem_uid("support"), "chain_current", 1),
			GemDBScript.make_support_gem(_next_gem_uid("support"), "ignition", 1),
			GemDBScript.make_support_gem(_next_gem_uid("support"), "bleed_edge", 1),
			GemDBScript.make_support_gem(_next_gem_uid("support"), "echoing_void", 1),
		]
	if spirit_gem_inventory.is_empty():
		spirit_gem_inventory = [
			GemDBScript.make_spirit_gem(_next_gem_uid("spirit"), "clarity", 1),
			GemDBScript.make_spirit_gem(_next_gem_uid("spirit"), "vitality", 1),
			GemDBScript.make_spirit_gem(_next_gem_uid("spirit"), "ember_pact", 1),
			GemDBScript.make_spirit_gem(_next_gem_uid("spirit"), "storm_rhythm", 1),
			GemDBScript.make_spirit_gem(_next_gem_uid("spirit"), "void_tithe", 1),
			GemDBScript.make_spirit_gem(_next_gem_uid("spirit"), "iron_skin", 1),
		]
	SkillGemSystemScript.ensure_loadout_defaults(self)
	if inventory.is_empty():
		inventory.append(ItemDBScript.make_item("apprentice_wand", 1, "magic", rng))
		inventory.append(ItemDBScript.make_item("cloth_robe", 1, "magic", rng))
	if map_stash.is_empty():
		map_stash.append(ItemDBScript.make_map_item("ash_vault", 1, rng))
	selected_skill_slot = clampi(selected_skill_slot, 0, max(0, skill_loadout.size() - 1))
	skill_panel_selected_slot = clampi(skill_panel_selected_slot, 0, max(0, skill_loadout.size() - 1))
	inventory_cursor = clampi(inventory_cursor, 0, max(0, inventory.size() - 1))
	recompute_stats()

func _next_gem_uid(prefix: String) -> String:
	var uid: String = prefix + "_" + str(gem_uid_counter)
	gem_uid_counter += 1
	return uid

func recompute_stats() -> void:
	build_stats.clear()
	build_rules.clear()
	var base_hp: float = 120.0 + float(level - 1) * 6.0
	var base_mana: float = 100.0 + float(level - 1) * 4.0
	var base_spirit: int = 30 + int(level / 5) * 5
	armor = 0.0
	fire_resist = 0.0
	lightning_resist = 0.0
	void_resist = 0.0
	movement_speed_mult = 1.0
	mana_regen = 10.0
	for slot_name: String in equipped.keys():
		var item: Variant = equipped.get(slot_name, {})
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var stats: Dictionary = Dictionary(item.get("total_stats", {}))
		_merge_stats(build_stats, stats)
	SkillGemSystemScript.apply_spirit_effects_to_state(self)
	max_hp = base_hp + float(build_stats.get("maximum_life", 0.0))
	max_mana = base_mana + float(build_stats.get("maximum_mana", 0.0))
	spirit_max = base_spirit + int(round(float(build_stats.get("maximum_spirit", 0.0))))
	armor = float(build_stats.get("armor", 0.0))
	fire_resist = clampf(float(build_stats.get("fire_resistance", 0.0)), -0.75, 0.75)
	lightning_resist = clampf(float(build_stats.get("lightning_resistance", 0.0)), -0.75, 0.75)
	void_resist = clampf(float(build_stats.get("void_resistance", 0.0)), -0.75, 0.75)
	movement_speed_mult = max(0.35, 1.0 + float(build_stats.get("movement_speed", 0.0)))
	mana_regen = 10.0 * (1.0 + float(build_stats.get("mana_regeneration", 0.0)))
	player_hp = clampf(player_hp, 0.0, max_hp)
	player_mana = clampf(player_mana, 0.0, max_mana)

func _merge_stats(target: Dictionary, stats: Dictionary) -> void:
	for key_value: Variant in stats.keys():
		var key: String = str(key_value)
		target[key] = float(target.get(key, 0.0)) + float(stats[key_value])

func full_restore() -> void:
	recompute_stats()
	player_hp = max_hp
	player_mana = max_mana
	health_flask_charges = health_flask_max_charges
	mana_flask_charges = mana_flask_max_charges

func update_resources(delta: float) -> void:
	player_mana = min(max_mana, player_mana + mana_regen * delta)
	if notice_time > 0.0:
		notice_time = max(0.0, notice_time - delta)

func add_notice(text: String) -> void:
	notice_text = text
	notice_time = 2.2

func xp_to_next() -> float:
	return 120.0 + pow(float(level), 1.35) * 85.0

func add_xp(amount: float) -> void:
	xp += max(0.0, amount)
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		add_notice("Level Up")
	recompute_stats()

func selected_loadout_entry() -> Dictionary:
	ensure_defaults()
	if skill_loadout.is_empty():
		return {}
	selected_skill_slot = clampi(selected_skill_slot, 0, skill_loadout.size() - 1)
	return Dictionary(skill_loadout[selected_skill_slot])

func use_health_flask() -> bool:
	if health_flask_charges <= 0 or player_hp >= max_hp:
		add_notice("Health flask unavailable")
		return false
	health_flask_charges -= 1
	player_hp = min(max_hp, player_hp + max_hp * health_flask_heal_ratio)
	add_notice("Health flask")
	return true

func use_mana_flask() -> bool:
	if mana_flask_charges <= 0 or player_mana >= max_mana:
		add_notice("Mana flask unavailable")
		return false
	mana_flask_charges -= 1
	player_mana = min(max_mana, player_mana + max_mana * mana_flask_restore_ratio)
	add_notice("Mana flask")
	return true

func on_enemy_killed(enemy_level: int, is_elite: bool, is_boss: bool) -> void:
	kills += 1
	var xp_gain: float = 18.0 + float(enemy_level) * 8.0
	if is_elite:
		xp_gain *= 2.0
	if is_boss:
		xp_gain *= 5.0
	add_xp(xp_gain)
	flask_kill_counter += 3 if is_boss else (2 if is_elite else 1)
	while flask_kill_counter >= 5:
		flask_kill_counter -= 5
		if health_flask_charges < health_flask_max_charges:
			health_flask_charges += 1
		elif mana_flask_charges < mana_flask_max_charges:
			mana_flask_charges += 1
	SkillGemSystemScript.award_equipped_gem_xp(self, xp_gain * 0.65)

func equip_inventory_item(index: int) -> bool:
	if index < 0 or index >= inventory.size():
		return false
	var item: Dictionary = inventory[index]
	if str(item.get("item_type", "")) == "map":
		add_notice("Map items go to map stash")
		return false
	var slot: String = str(item.get("slot", ""))
	if slot == "":
		add_notice("Item cannot be equipped")
		return false
	var old_item: Variant = equipped.get(slot, {})
	equipped[slot] = item
	inventory.remove_at(index)
	if typeof(old_item) == TYPE_DICTIONARY and not Dictionary(old_item).is_empty():
		inventory.append(old_item)
	inventory_cursor = clampi(index, 0, max(0, inventory.size() - 1))
	recompute_stats()
	add_notice("Equipped " + str(item.get("display_name", "Item")))
	return true

func to_save_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"mode": "hub",
		"level": level,
		"xp": xp,
		"gold": gold,
		"deaths": deaths,
		"kills": kills,
		"inventory": inventory,
		"inventory_cursor": inventory_cursor,
		"equipped": equipped,
		"map_stash": map_stash,
		"completed_maps": completed_maps,
		"selected_skill_slot": selected_skill_slot,
		"gem_uid_counter": gem_uid_counter,
		"active_gem_inventory": active_gem_inventory,
		"support_gem_inventory": support_gem_inventory,
		"spirit_gem_inventory": spirit_gem_inventory,
		"skill_loadout": skill_loadout,
		"health_flask_charges": health_flask_charges,
		"mana_flask_charges": mana_flask_charges,
	}

func apply_save_dict(data: Dictionary) -> void:
	level = int(data.get("level", level))
	xp = float(data.get("xp", xp))
	gold = int(data.get("gold", gold))
	deaths = int(data.get("deaths", deaths))
	kills = int(data.get("kills", kills))
	inventory = _dict_array(data.get("inventory", inventory))
	inventory_cursor = int(data.get("inventory_cursor", inventory_cursor))
	equipped = Dictionary(data.get("equipped", equipped)).duplicate(true)
	map_stash = _dict_array(data.get("map_stash", map_stash))
	completed_maps = Dictionary(data.get("completed_maps", completed_maps)).duplicate(true)
	selected_skill_slot = int(data.get("selected_skill_slot", selected_skill_slot))
	gem_uid_counter = int(data.get("gem_uid_counter", gem_uid_counter))
	active_gem_inventory = _dict_array(data.get("active_gem_inventory", active_gem_inventory))
	support_gem_inventory = _dict_array(data.get("support_gem_inventory", support_gem_inventory))
	spirit_gem_inventory = _dict_array(data.get("spirit_gem_inventory", spirit_gem_inventory))
	skill_loadout = _dict_array(data.get("skill_loadout", skill_loadout))
	health_flask_charges = int(data.get("health_flask_charges", health_flask_charges))
	mana_flask_charges = int(data.get("mana_flask_charges", mana_flask_charges))
	mode = "hub"
	panel_mode = ""
	ensure_defaults()
	full_restore()

func _dict_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item: Variant in Array(value):
		if typeof(item) == TYPE_DICTIONARY:
			result.append(Dictionary(item).duplicate(true))
	return result
