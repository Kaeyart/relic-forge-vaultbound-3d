class_name RVLootSystem3D
extends RefCounted

static func enemy_drop_bundle(state: RVGameState3D, enemy_level: int, enemy_rank: String = "normal") -> Array[Dictionary]:
	var drops: Array[Dictionary] = []
	if state == null:
		return drops
	var rng: RandomNumberGenerator = state.rng
	var gold_amount: int = rng.randi_range(3, 8) + enemy_level
	if enemy_rank == "elite":
		gold_amount *= 3
	elif enemy_rank == "boss":
		gold_amount *= 8
	drops.append({"drop_type":"gold", "amount":gold_amount})

	var gear_chance: float = 0.12
	if enemy_rank == "elite":
		gear_chance = 0.45
	elif enemy_rank == "boss":
		gear_chance = 1.0
	if rng.randf() <= gear_chance:
		drops.append({"drop_type":"item", "item":roll_equipment_drop(state, enemy_level, enemy_rank)})

	var map_chance: float = 0.035
	if enemy_rank == "elite":
		map_chance = 0.10
	elif enemy_rank == "boss":
		map_chance = 0.45
	if rng.randf() <= map_chance:
		drops.append({"drop_type":"map", "item":RVMapDB3D.make_map_item("ash_vault_01", max(1, int(enemy_level / 3)), "Normal")})

	var material_chance: float = 0.10 if enemy_rank != "boss" else 1.0
	if rng.randf() <= material_chance:
		drops.append({"drop_type":"material", "id":"embers", "amount":rng.randi_range(1, 2 if enemy_rank == "normal" else 5)})
	return drops

static func roll_equipment_drop(state: RVGameState3D, item_level: int, enemy_rank: String = "normal") -> Dictionary:
	var bases: Array[String] = ["apprentice_focus", "iron_sword", "patched_helm", "vault_chestguard", "work_gloves", "ashwalkers", "copper_ring", "ember_amulet"]
	if state != null and state.class_id == "machinist":
		bases.append("coil_launcher")
	elif state != null and state.class_id == "voidbinder":
		bases.append("hollow_focus")
	var rng: RandomNumberGenerator = state.rng if state != null else RandomNumberGenerator.new()
	var base_id: String = bases[rng.randi_range(0, bases.size() - 1)]
	var rarity_roll: float = rng.randf()
	var rarity: String = "Normal"
	if enemy_rank == "boss":
		rarity = "Rare" if rarity_roll < 0.45 else "Magic"
	elif enemy_rank == "elite":
		rarity = "Rare" if rarity_roll < 0.16 else "Magic" if rarity_roll < 0.70 else "Normal"
	else:
		rarity = "Magic" if rarity_roll < 0.22 else "Normal"
	return RVItemDB3D.make_item(base_id, max(1, item_level), rarity, rng)

static func apply_drop_to_state(state: RVGameState3D, drop: Dictionary) -> void:
	if state == null or drop.is_empty():
		return
	match str(drop.get("drop_type", "")):
		"gold":
			state.gold += int(drop.get("amount", 0))
		"material":
			var id: String = str(drop.get("id", ""))
			if id != "":
				state.materials[id] = int(state.materials.get(id, 0)) + int(drop.get("amount", 1))
		"item":
			var item: Dictionary = Dictionary(drop.get("item", {}))
			if not item.is_empty():
				state.inventory.append(item)
		"map":
			var map_item: Dictionary = Dictionary(drop.get("item", {}))
			if not map_item.is_empty():
				state.map_inventory.append(map_item)
