class_name RVItemCraftingSystem3D
extends RefCounted

const ItemizationScript: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")

static func craft_selected(state: Object, action: String) -> bool:
	return apply_to_selected(state, action)

static func apply_to_selected(state: Object, action: String) -> bool:
	if state == null:
		return false
	var backpack: Array = Array(state.get("backpack"))
	var index: int = clampi(int(state.get("inventory_cursor")), 0, max(0, backpack.size() - 1))
	if backpack.is_empty() or index < 0 or index >= backpack.size() or typeof(backpack[index]) != TYPE_DICTIONARY:
		return _fail(state, "No selected item.")
	var item: Dictionary = ItemizationScript.normalize_item(Dictionary(backpack[index]), _rng(state))
	if not ItemizationScript.is_equipment(item):
		return _fail(state, "Selected item is not craftable gear.")
	if bool(item.get("locked", false)) and not action in ["favorite", "lock"]:
		return _fail(state, "Item is locked.")
	if action in ["sell", "disenchant", "salvage"]:
		return _sink(state, action, backpack, index, item)
	if action == "appraise":
		item = ItemizationScript.appraise_item(item)
		backpack[index] = item
		state.set("backpack", backpack)
		_notice(state, "Appraised " + str(item.get("display_name", "Item")) + ".")
		return true
	if not bool(item.get("identified", true)):
		return _fail(state, "Appraise the item before crafting.")
	var cost_id: String = _cost_id(action, item)
	if cost_id != "" and not _pay(state, cost_id, 1):
		return _fail(state, "Missing " + ItemizationScript.material_label(cost_id) + ".")
	var potential_cost: int = _potential_cost(action, item)
	if potential_cost > 0 and int(item.get("forge_potential", 0)) < potential_cost:
		return _fail(state, "Not enough Forge Potential.")
	var rng: RandomNumberGenerator = _rng(state)
	var rarity: String = str(item.get("rarity", "normal"))
	match action:
		"transmute":
			if rarity != "normal": return _fail(state, "Transmute requires a Normal item.")
			item["rarity"] = "magic"
			item = ItemizationScript.add_random_affix(item, rng)
		"augment":
			if rarity != "magic": return _fail(state, "Augment requires a Magic item.")
			if Array(item.get("explicit_mods", [])).size() >= 2: return _fail(state, "Magic item already has two modifiers.")
			item = ItemizationScript.add_random_affix(item, rng)
		"regal":
			if rarity != "magic": return _fail(state, "Regal requires a Magic item.")
			item["rarity"] = "rare"
			item = ItemizationScript.add_random_affix(item, rng)
		"exalt":
			if rarity != "rare": return _fail(state, "Exalt requires a Rare item.")
			if Array(item.get("explicit_mods", [])).size() >= 6: return _fail(state, "Rare item has no open affix slot.")
			item = ItemizationScript.add_random_affix(item, rng)
		"chaos":
			if rarity != "rare": return _fail(state, "Chaos requires a Rare item.")
			item = ItemizationScript.remove_random_affix(item, rng)
			item = ItemizationScript.add_random_affix(item, rng)
		"annul":
			item = ItemizationScript.remove_random_affix(item, rng)
		"alchemy":
			if rarity != "normal": return _fail(state, "Alchemy requires a Normal item.")
			item["rarity"] = "rare"
			for i: int in range(4):
				item = ItemizationScript.add_random_affix(item, rng)
		"quality", "quality_weapon":
			if str(item.get("category", "")) != "weapon": return _fail(state, "Whetstone requires a weapon.")
			item["quality"] = clampi(int(item.get("quality", 0)) + 4, 0, 20)
		"quality_armor":
			item["quality"] = clampi(int(item.get("quality", 0)) + 4, 0, 20)
		"socket":
			item = ItemizationScript.add_socket(item)
		"rune_ash":
			item = ItemizationScript.socket_rune(item, "ash_rune")
		"rune_storm":
			item = ItemizationScript.socket_rune(item, "storm_rune")
		"rune_blood":
			item = ItemizationScript.socket_rune(item, "blood_rune")
		"rune_iron":
			item = ItemizationScript.socket_rune(item, "iron_rune")
		"rune_vault":
			item = ItemizationScript.socket_rune(item, "vault_rune")
		"rune_seeker":
			item = ItemizationScript.socket_rune(item, "seeker_rune")
		"essence_ember":
			item = _essence(item, rng, "fire")
		"essence_storm":
			item = _essence(item, rng, "lightning")
		"essence_blood":
			item = _essence(item, rng, "life")
		"essence_iron":
			item = _essence(item, rng, "defence")
		"essence_fleet":
			item = _essence(item, rng, "movement")
		"essence_arcanist":
			item = _essence(item, rng, "caster")
		"risky_forge":
			item = _risky_forge(state, item, rng)
		"restore_potential":
			item = _restore_potential(state, item, rng)
		_:
			return _fail(state, "Unknown craft: " + action)
	if potential_cost > 0:
		item["forge_potential"] = maxi(0, int(item.get("forge_potential", 0)) - potential_cost)
	item = ItemizationScript.rebuild_totals(item)
	backpack[index] = item
	state.set("backpack", backpack)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	_notice(state, "Applied " + action.replace("_", " ").capitalize() + ".")
	return true

static func preview_action(state: Object, action: String) -> String:
	if state == null:
		return "No state."
	var backpack: Array = Array(state.get("backpack"))
	if backpack.is_empty():
		return "No selected item."
	var index: int = clampi(int(state.get("inventory_cursor")), 0, backpack.size() - 1)
	if typeof(backpack[index]) != TYPE_DICTIONARY:
		return "No selected item."
	var item: Dictionary = ItemizationScript.normalize_item(Dictionary(backpack[index]))
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a][b]Preview: " + action.replace("_", " ").capitalize() + "[/b][/color]")
	lines.append(_action_explain(action, item))
	var cost_id: String = _cost_id(action, item)
	var potential_cost: int = _potential_cost(action, item)
	if cost_id != "":
		lines.append("Cost: 1 " + ItemizationScript.material_label(cost_id))
	if potential_cost > 0:
		lines.append("Forge Potential: -" + str(potential_cost) + "  (current " + str(int(item.get("forge_potential", 0))) + ")")
	if not bool(item.get("identified", true)) and action != "appraise":
		lines.append("[color=#d65a32]Requires appraisal first.[/color]")
	return "\n".join(lines)

static func _action_explain(action: String, item: Dictionary) -> String:
	match action:
		"appraise": return "Reveal hidden affixes so the item can be evaluated and crafted."
		"transmute": return "Normal → Magic. Adds one random modifier."
		"augment": return "Adds one random modifier to a Magic item with an open slot."
		"regal": return "Magic → Rare. Adds one random modifier."
		"exalt": return "Adds one random modifier to a Rare item."
		"chaos": return "Rare only. Removes one random modifier and adds one new random modifier."
		"annul": return "Removes one random explicit modifier. High risk."
		"alchemy": return "Normal → Rare with several random modifiers."
		"quality", "quality_weapon": return "Increase weapon quality, improving base weapon stats."
		"quality_armor": return "Increase armour/offhand quality, improving base defence."
		"socket": return "Adds an empty rune socket if the base can accept one."
		"rune_ash": return "Socket Ash Rune into the first empty socket: Fire Damage."
		"rune_storm": return "Socket Storm Rune into the first empty socket: Lightning Damage."
		"rune_blood": return "Socket Blood Rune into the first empty socket: Maximum Life."
		"rune_iron": return "Socket Iron Rune into the first empty socket: Armor."
		"rune_vault": return "Socket Vault Rune into the first empty socket: Maximum Spirit."
		"rune_seeker": return "Socket Seeker Rune into the first empty socket: Item Rarity."
		"essence_ember": return "Deterministic Fire craft. Magic → Rare, or replaces a Rare modifier."
		"essence_storm": return "Deterministic Lightning craft. Magic → Rare, or replaces a Rare modifier."
		"essence_blood": return "Deterministic Life craft. Magic → Rare, or replaces a Rare modifier."
		"essence_iron": return "Deterministic defence craft. Magic → Rare, or replaces a Rare modifier."
		"essence_fleet": return "Deterministic speed/movement craft. Magic → Rare, or replaces a Rare modifier."
		"essence_arcanist": return "Deterministic caster craft. Magic → Rare, or replaces a Rare modifier."
		"risky_forge": return "Adds a high-tier modifier, but can strain or fracture the item."
		"restore_potential": return "Restores Forge Potential with a small chance to strain the item."
		"sell": return "Destroy item for gold."
		"disenchant": return "Destroy magic/rare/unique item for essence dust and crafting shards."
		"salvage": return "Destroy socketed/quality item for socket and quality materials."
		_: return "No preview available."

static func _essence(item: Dictionary, rng: RandomNumberGenerator, tag: String) -> Dictionary:
	var rarity: String = str(item.get("rarity", "normal"))
	if rarity == "magic" or rarity == "normal":
		item["rarity"] = "rare"
	elif rarity == "rare":
		item = ItemizationScript.remove_random_affix(item, rng)
	elif rarity == "unique":
		return item
	return ItemizationScript.add_random_affix(item, rng, tag, true)

static func _risky_forge(state: Object, item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if not _pay(state, "echo_glass", 1):
		_fail(state, "Missing Echo Glass.")
		return item
	var roll: float = rng.randf()
	if roll < 0.62:
		item = ItemizationScript.add_random_affix(item, rng, "", true)
		item["craft_state"] = "strained" if roll > 0.45 else str(item.get("craft_state", "stable"))
	elif roll < 0.87:
		item["craft_state"] = "strained"
		item["forge_potential"] = maxi(0, int(item.get("forge_potential", 0)) - 2)
	else:
		item["craft_state"] = "fractured"
		item["forge_potential"] = 0
	return item

static func _restore_potential(state: Object, item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if not _pay(state, "relic_core", 1):
		_fail(state, "Missing Relic Core.")
		return item
	var max_potential: int = int(item.get("forge_potential_max", 6))
	var gain: int = rng.randi_range(2, 4)
	item["forge_potential"] = clampi(int(item.get("forge_potential", 0)) + gain, 0, max_potential)
	if rng.randf() < 0.18:
		item["craft_state"] = "strained"
	return item

static func _sink(state: Object, action: String, backpack: Array, index: int, item: Dictionary) -> bool:
	if bool(item.get("locked", false)) or bool(item.get("favorite", false)):
		return _fail(state, "Unlock/unfavorite before destroying item.")
	var materials: Dictionary = Dictionary(state.get("materials"))
	if action == "sell":
		state.set("gold", int(state.get("gold")) + 8 + int(item.get("item_power", 0)))
	elif action == "disenchant":
		var rarity: String = str(item.get("rarity", "normal"))
		materials["essence_dust"] = int(materials.get("essence_dust", 0)) + (8 if rarity == "unique" else (4 if rarity == "rare" else 1))
		materials["shards"] = int(materials.get("shards", 0)) + (4 if rarity == "rare" or rarity == "unique" else 1)
		if rarity == "unique":
			materials["relic_core"] = int(materials.get("relic_core", 0)) + 1
		state.set("materials", materials)
	elif action == "salvage":
		materials["shards"] = int(materials.get("shards", 0)) + 2 + int(item.get("quality", 0)) / 5
		materials["artificer_shard"] = int(materials.get("artificer_shard", 0)) + Array(item.get("sockets", [])).size()
		if int(item.get("quality", 0)) > 0:
			materials["whetstone"] = int(materials.get("whetstone", 0)) + 1
		state.set("materials", materials)
	backpack.remove_at(index)
	state.set("backpack", backpack)
	_notice(state, action.capitalize() + " complete.")
	return true

static func _cost_id(action: String, item: Dictionary) -> String:
	match action:
		"transmute": return "transmutation_orb"
		"augment": return "augmentation_orb"
		"regal": return "regal_orb"
		"exalt": return "exalted_orb"
		"chaos": return "chaos_orb"
		"annul": return "annulment_orb"
		"alchemy": return "alchemy_orb"
		"quality", "quality_weapon": return "whetstone"
		"quality_armor": return "armour_scrap"
		"socket": return "artificer_orb"
		"rune_ash": return "ash_rune"
		"rune_storm": return "storm_rune"
		"rune_blood": return "blood_rune"
		"rune_iron": return "iron_rune"
		"rune_vault": return "vault_rune"
		"rune_seeker": return "seeker_rune"
		"essence_ember": return "ember_seal_lesser"
		"essence_storm": return "storm_seal_lesser"
		"essence_blood": return "blood_seal_lesser"
		"essence_iron": return "iron_seal_lesser"
		"essence_fleet": return "fleet_seal_lesser"
		"essence_arcanist": return "arcanist_seal_lesser"
		_: return ""

static func _potential_cost(action: String, item: Dictionary) -> int:
	match action:
		"transmute", "augment", "regal", "quality", "quality_weapon", "quality_armor", "appraise": return 0
		"socket": return 1
		"rune_ash", "rune_storm", "rune_blood", "rune_iron", "rune_vault", "rune_seeker": return 0
		"exalt", "chaos", "annul", "essence_ember", "essence_storm", "essence_blood", "essence_iron", "essence_fleet", "essence_arcanist": return 1
		"alchemy": return 2
		"risky_forge": return 3
		_: return 0

static func _pay(state: Object, id: String, amount: int) -> bool:
	var materials: Dictionary = Dictionary(state.get("materials"))
	if int(materials.get(id, 0)) < amount:
		return false
	materials[id] = int(materials.get(id, 0)) - amount
	state.set("materials", materials)
	return true

static func _rng(state: Object) -> RandomNumberGenerator:
	var value: Variant = state.get("rng")
	if value is RandomNumberGenerator:
		return value as RandomNumberGenerator
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng

static func _fail(state: Object, text: String) -> bool:
	_notice(state, text)
	return false

static func _notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)
