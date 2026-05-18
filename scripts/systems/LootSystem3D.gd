class_name RVLootSystem3D
extends RefCounted

const ItemDBScript := preload("res://scripts/data/ItemDB3D.gd")
const GemDBScript := preload("res://scripts/data/GemDB3D.gd")

static func enemy_drop_bundle(state: Object, enemy_level: int, is_elite: bool, is_boss: bool) -> Array[Dictionary]:
	var rng: RandomNumberGenerator = state.get("rng")
	var drops: Array[Dictionary] = []
	var gold_amount: int = rng.randi_range(4, 10) + enemy_level * 2
	if is_elite:
		gold_amount *= 2
	if is_boss:
		gold_amount *= 4
	drops.append({"kind":"gold", "amount":gold_amount, "label":"Gold " + str(gold_amount)})
	var gear_chance: float = 0.12 + (0.22 if is_elite else 0.0) + (1.0 if is_boss else 0.0)
	if rng.randf() < gear_chance:
		drops.append({"kind":"item", "item":ItemDBScript.make_random_equipment(enemy_level, _rarity_for_drop(rng, is_elite, is_boss), rng), "label":"Equipment"})
	var gem_chance: float = 0.04 + (0.08 if is_elite else 0.0) + (0.35 if is_boss else 0.0)
	if rng.randf() < gem_chance:
		drops.append(_make_gem_drop(state, rng, is_boss))
	var map_chance: float = 0.025 + (0.08 if is_boss else 0.0)
	if rng.randf() < map_chance:
		drops.append({"kind":"map", "item":ItemDBScript.make_map_item("ash_vault", max(1, enemy_level), rng), "label":"Map"})
	return drops

static func apply_drop_to_state(state: Object, drop: Dictionary) -> void:
	match str(drop.get("kind", "")):
		"gold":
			state.set("gold", int(state.get("gold")) + int(drop.get("amount", 0)))
		"item":
			var inv: Array = Array(state.get("inventory"))
			inv.append(Dictionary(drop.get("item", {})).duplicate(true))
			state.set("inventory", inv)
		"map":
			var maps: Array = Array(state.get("map_stash"))
			maps.append(Dictionary(drop.get("item", {})).duplicate(true))
			state.set("map_stash", maps)
		"active_gem":
			var active: Array = Array(state.get("active_gem_inventory"))
			active.append(Dictionary(drop.get("gem", {})).duplicate(true))
			state.set("active_gem_inventory", active)
		"support_gem":
			var supports: Array = Array(state.get("support_gem_inventory"))
			supports.append(Dictionary(drop.get("gem", {})).duplicate(true))
			state.set("support_gem_inventory", supports)
		"spirit_gem":
			var spirits: Array = Array(state.get("spirit_gem_inventory"))
			spirits.append(Dictionary(drop.get("gem", {})).duplicate(true))
			state.set("spirit_gem_inventory", spirits)

static func _rarity_for_drop(rng: RandomNumberGenerator, is_elite: bool, is_boss: bool) -> String:
	var roll: float = rng.randf()
	if is_boss:
		return "rare" if roll < 0.72 else "magic"
	if is_elite:
		return "rare" if roll < 0.22 else "magic"
	return "magic" if roll < 0.38 else "normal"

static func _make_gem_drop(state: Object, rng: RandomNumberGenerator, boss: bool) -> Dictionary:
	var kind_roll: float = rng.randf()
	var uid_prefix: String = "gemdrop_" + str(Time.get_ticks_usec()) + "_"
	if boss and kind_roll < 0.25:
		var spirit_ids: Array = GemDBScript.spirit_gems().keys()
		var sid: String = str(spirit_ids[rng.randi_range(0, spirit_ids.size() - 1)])
		var sg: Dictionary = GemDBScript.make_spirit_gem(uid_prefix + "spirit", sid, 1)
		return {"kind":"spirit_gem", "gem":sg, "label":str(sg.get("name", "Spirit Gem"))}
	if kind_roll < 0.22:
		var active_ids: Array = GemDBScript.active_gems().keys()
		var aid: String = str(active_ids[rng.randi_range(0, active_ids.size() - 1)])
		var ag: Dictionary = GemDBScript.make_active_gem(uid_prefix + "active", aid, 1)
		return {"kind":"active_gem", "gem":ag, "label":str(ag.get("name", "Active Gem"))}
	var support_ids: Array = GemDBScript.support_gems().keys()
	var suid: String = str(support_ids[rng.randi_range(0, support_ids.size() - 1)])
	var sup: Dictionary = GemDBScript.make_support_gem(uid_prefix + "support", suid, 1)
	return {"kind":"support_gem", "gem":sup, "label":str(sup.get("name", "Support Gem"))}
