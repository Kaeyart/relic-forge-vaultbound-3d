class_name RVLootPickupSystem3D
extends RefCounted

const LootSystemScript := preload("res://scripts/systems/LootSystem3D.gd")

static func pet_can_pick(drop: Dictionary) -> bool:
	var kind: String = str(drop.get("kind", ""))
	return kind == "gold" or kind == "material"

static func player_can_auto_pick(drop: Dictionary) -> bool:
	return bool(drop.get("auto_pickup", false))

static func apply_pickup(state: Object, loot_actor: Node) -> void:
	if state == null or loot_actor == null: return
	var drop: Dictionary = Dictionary(loot_actor.get("drop_data"))
	LootSystemScript.apply_drop_to_state(state, drop)
	loot_actor.call("collect")
