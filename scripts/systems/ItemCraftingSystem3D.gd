class_name RVItemCraftingSystem3D
extends RefCounted

const ItemizationScript: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")

static func craft_selected(state: Object, action: String) -> bool:
	if action == "seal": action = "essence_ember"
	elif action == "reforge": action = "chaos"
	elif action == "polish": action = "quality"
	return apply_to_selected(state, action)

static func apply_to_selected(state: Object, action: String) -> bool:
	if state == null: return false
	var backpack: Array = Array(state.get("backpack"))
	var index: int = int(state.get("inventory_cursor"))
	if index < 0 or index >= backpack.size(): return _fail(state, "No item selected.")
	if typeof(backpack[index]) != TYPE_DICTIONARY: return _fail(state, "Invalid selected item.")
	var item: Dictionary = ItemizationScript.normalize_item(Dictionary(backpack[index]).duplicate(true), _rng(state))
	if not ItemizationScript.is_equipment(item): return _fail(state, "Select equipment.")
	if action in ["sell","disenchant","salvage"]:
		if bool(item.get("locked", false)) or bool(item.get("favorite", false)): return _fail(state, "Unlock/unfavorite first.")
		return _sink(state, action, backpack, index, item)
	var cost_id: String = _cost_id(action, item)
	if cost_id != "" and not _pay(state, cost_id, 1): return _fail(state, "Missing " + ItemizationScript.material_label(cost_id) + ".")
	var rng: RandomNumberGenerator = _rng(state)
	var rarity: String = str(item.get("rarity", "normal"))
	match action:
		"transmute":
			if rarity != "normal": return _fail(state, "Transmute requires Normal item.")
			item["rarity"] = "magic"; item = ItemizationScript.add_random_affix(item, rng)
		"augment":
			if rarity != "magic": return _fail(state, "Augment requires Magic item.")
			if Array(item.get("explicit_mods", [])).size() >= 2: return _fail(state, "Magic item already has two mods.")
			item = ItemizationScript.add_random_affix(item, rng)
		"regal":
			if rarity != "magic": return _fail(state, "Regal requires Magic item.")
			item["rarity"] = "rare"; item = ItemizationScript.add_random_affix(item, rng)
		"exalt":
			if rarity != "rare": return _fail(state, "Exalt requires Rare item.")
			item = ItemizationScript.add_random_affix(item, rng)
		"chaos":
			if rarity != "rare": return _fail(state, "Chaos requires Rare item.")
			item = ItemizationScript.remove_random_affix(item, rng); item = ItemizationScript.add_random_affix(item, rng)
		"annul":
			item = ItemizationScript.remove_random_affix(item, rng)
		"alchemy":
			if rarity != "normal": return _fail(state, "Alchemy requires Normal item.")
			item["rarity"] = "rare"
			for i: int in range(4): item = ItemizationScript.add_random_affix(item, rng)
		"quality", "quality_armor":
			item["quality"] = clampi(int(item.get("quality", 0)) + 4, 0, 20)
		"socket": item = ItemizationScript.add_socket(item)
		"rune_ash": item = ItemizationScript.socket_rune(item, "ash_rune")
		"rune_iron": item = ItemizationScript.socket_rune(item, "iron_rune")
		"rune_vault": item = ItemizationScript.socket_rune(item, "vault_rune")
		"essence_ember": item = _essence(item, rng, "fire")
		"essence_iron": item = _essence(item, rng, "defence")
		"essence_arcanist": item = _essence(item, rng, "caster")
		_: return _fail(state, "Unknown craft: " + action)
	if action not in ["quality", "quality_armor"]: item["forge_potential"] = maxi(0, int(item.get("forge_potential", 0)) - 1)
	item = ItemizationScript.rebuild_totals(item)
	backpack[index] = item; state.set("backpack", backpack)
	if state.has_method("recompute_stats"): state.call("recompute_stats")
	_notice(state, "Applied " + action.replace("_", " ").capitalize() + ".")
	return true

static func _essence(item: Dictionary, rng: RandomNumberGenerator, tag: String) -> Dictionary:
	if str(item.get("rarity", "normal")) == "magic": item["rarity"] = "rare"
	elif str(item.get("rarity", "normal")) == "rare": item = ItemizationScript.remove_random_affix(item, rng)
	return ItemizationScript.add_random_affix(item, rng, tag)

static func _sink(state: Object, action: String, backpack: Array, index: int, item: Dictionary) -> bool:
	var materials: Dictionary = Dictionary(state.get("materials"))
	if action == "sell": state.set("gold", int(state.get("gold")) + 8 + int(item.get("item_power", 0)))
	elif action == "disenchant": materials["essence_dust"] = int(materials.get("essence_dust", 0)) + (3 if str(item.get("rarity", "normal")) == "rare" else 1); state.set("materials", materials)
	elif action == "salvage": materials["shards"] = int(materials.get("shards", 0)) + 2; materials["artificer_shard"] = int(materials.get("artificer_shard", 0)) + Array(item.get("sockets", [])).size(); state.set("materials", materials)
	backpack.remove_at(index); state.set("backpack", backpack); _notice(state, action.capitalize() + " complete."); return true

static func _cost_id(action: String, item: Dictionary) -> String:
	match action:
		"transmute": return "transmutation_orb"
		"augment": return "augmentation_orb"
		"regal": return "regal_orb"
		"exalt": return "exalted_orb"
		"chaos": return "chaos_orb"
		"annul": return "annulment_orb"
		"alchemy": return "alchemy_orb"
		"quality": return "whetstone"
		"quality_armor": return "armour_scrap"
		"socket": return "artificer_orb"
		"rune_ash": return "ash_rune"
		"rune_iron": return "iron_rune"
		"rune_vault": return "vault_rune"
		"essence_ember": return "ember_seal_lesser"
		"essence_iron": return "iron_seal_lesser"
		"essence_arcanist": return "arcanist_seal_lesser"
		_: return ""

static func _pay(state: Object, id: String, amount: int) -> bool:
	var materials: Dictionary = Dictionary(state.get("materials"))
	if int(materials.get(id, 0)) < amount: return false
	materials[id] = int(materials.get(id, 0)) - amount; state.set("materials", materials); return true

static func _rng(state: Object) -> RandomNumberGenerator:
	var value: Variant = state.get("rng")
	if value is RandomNumberGenerator: return value as RandomNumberGenerator
	var rng: RandomNumberGenerator = RandomNumberGenerator.new(); rng.randomize(); return rng

static func _fail(state: Object, text: String) -> bool:
	_notice(state, text); return false

static func _notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"): state.call("add_notice", text)
