class_name RVUIMockState3D
extends Node

var mode: String = "hub"
var panel_mode: String = "inventory"
var player_hp: float = 154.0
var max_hp: float = 210.0
var player_mana: float = 62.0
var max_mana: float = 118.0
var spirit_reserved: int = 55
var spirit_max: int = 100
var level: int = 12
var xp: int = 420
var xp_next_value: int = 850
var gold: int = 1845
var materials: Dictionary = {"ember_shard": 14, "iron_sigil": 5, "void_dust": 2}
var notice_text: String = "UI Lab: mock data active"
var notice_time: float = 2.0
var near_station_name: String = "Map Device"
var selected_skill_slot: int = 0
var inventory_cursor: int = 0
var map_cursor: int = 0
var completed_maps: Dictionary = {"ash_gate": 3, "chain_yard": 1}
var build_rules: Array = []
var build_stats: Dictionary = {
	"spell_damage": 34,
	"attack_damage": 18,
	"fire_damage": 42,
	"lightning_damage": 21,
	"void_damage": 10,
	"armor": 88,
	"movement_speed": 8,
	"block_chance": 12
}
var equipped: Dictionary = {}
var backpack: Array = []
var stash: Array = []
var map_stash: Array = []
var active_skill_slots: Array = []
var spirit_gem_slots: Array = []
var current_map_activity: Dictionary = {}

func _ready() -> void:
	_seed()

func add_notice(text: String) -> void:
	notice_text = text
	notice_time = 2.0

func xp_to_next() -> int:
	return xp_next_value

func _seed() -> void:
	equipped = {
		"weapon": _item("Cinder Wand", "magic", "weapon", 41, {"Spell Damage": 18, "Fire Damage": 22, "Mana": 15}),
		"offhand": _item("Ledger Focus", "rare", "offhand", 37, {"Cast Speed": 8, "Mana Regen": 3}),
		"chest": _item("Ironbound Coat", "rare", "chest", 43, {"Armor": 58, "Maximum Life": 35}),
		"boots": _item("Ashwalker Boots", "magic", "boots", 29, {"Movement Speed": 10, "Armor": 14}),
		"ring_1": _item("Ring of Sparks", "magic", "ring", 25, {"Lightning Damage": 15}),
		"relic": _item("Cracked Furnace Relic", "unique", "relic", 52, {"Fire Damage": 30, "Ignite Chance": 15})
	}
	backpack = [
		_item("Meteor Glass Wand", "rare", "weapon", 55, {"Spell Damage": 27, "Fire Damage": 31, "Mana Cost": 6}),
		_item("Knight-Bone Cleaver", "rare", "weapon", 49, {"Attack Damage": 34, "Bleed Chance": 18}),
		_item("Silent Brass Ring", "magic", "ring", 34, {"Critical Chance": 7, "Mana": 12}),
		_item("Vaultbound Greaves", "unique", "boots", 61, {"Movement Speed": 18, "Dash Cooldown": -12}),
		_item("Support Gem: Split Projectile", "magic", "support_gem", 1, {"Projectiles": 2}),
		_item("Active Gem: Void Rift", "magic", "active_gem", 1, {"Void Damage": 44})
	]
	stash = [
		_item("Old Rust Axe", "normal", "weapon", 12, {"Attack Damage": 9}),
		_item("Apprentice Focus", "magic", "offhand", 18, {"Mana": 20}),
		_item("Spare Relic Frame", "rare", "relic", 38, {"Cooldown Recovery": 6})
	]
	map_stash = [
		_map("Ash Intake Yard", 1, [{"display_name": "+18% Monster Pack Size"}, {"display_name": "+12% Item Quantity"}]),
		_map("Chained Reservoir", 2, [{"display_name": "Monsters fire extra projectiles"}, {"display_name": "+20% Elite Chance"}]),
		_map("Furnace Audit Hall", 3, [{"display_name": "Boss has extra phase"}, {"display_name": "+28% Item Rarity"}])
	]
	current_map_activity = map_stash[0]
	active_skill_slots = [
		{"gem_id": "fireball", "level": 6, "xp": 120, "unlocked_support_sockets": 3, "supports": [{"gem_id": "split_projectile", "level": 4}, {"gem_id": "ignition", "level": 5}]},
		{"gem_id": "storm_lance", "level": 4, "xp": 80, "unlocked_support_sockets": 2, "supports": [{"gem_id": "chain_current", "level": 3}]},
		{"gem_id": "arc_slash", "level": 5, "xp": 300, "unlocked_support_sockets": 3, "supports": [{"gem_id": "bleed_edge", "level": 4}, {"gem_id": "rapid_strikes", "level": 2}]},
		{"gem_id": "void_rift", "level": 3, "xp": 60, "unlocked_support_sockets": 2, "supports": [{"gem_id": "greater_area", "level": 2}]}
	]
	spirit_gem_slots = [
		{"gem_id": "clarity", "enabled": true, "level": 3},
		{"gem_id": "ember_pact", "enabled": true, "level": 4},
		{"gem_id": "iron_skin", "enabled": false, "level": 2}
	]

func _item(name: String, rarity: String, slot: String, power: int, stats: Dictionary) -> Dictionary:
	return {
		"display_name": name,
		"name": name,
		"rarity": rarity,
		"slot": slot,
		"item_power": power,
		"quality": 8,
		"stats": stats,
		"forge_potential": 4,
		"detail_text": "Mock item for UI layout review. Replace with real generated item data in-game."
	}

func _map(name: String, tier: int, mods: Array) -> Dictionary:
	return {"display_name": name, "name": name, "tier": tier, "area_level": 65 + tier, "mods": mods}
