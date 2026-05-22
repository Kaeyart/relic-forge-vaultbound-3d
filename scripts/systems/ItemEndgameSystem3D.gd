class_name RVItemEndgameSystem3D
extends RefCounted

const ItemizationScript: GDScript = preload("res://scripts/systems/ItemizationSystem3D.gd")

const ENDGAME_STARTER_COUNTS: Dictionary = {
	"greater_transmutation_orb": 2,
	"perfect_transmutation_orb": 1,
	"greater_augmentation_orb": 2,
	"perfect_augmentation_orb": 1,
	"greater_regal_orb": 1,
	"perfect_regal_orb": 1,
	"greater_exalted_orb": 1,
	"perfect_exalted_orb": 1,
	"greater_chaos_orb": 1,
	"perfect_chaos_orb": 1,
	"oracle_lens": 2,
	"binding_omen": 1,
	"ash_omen": 1,
	"null_omen": 1,
	"perfecting_omen": 1,
	"vaultbinding_orb": 2,
	"relic_reforge_core": 1,
	"ancient_ash_rune": 1,
	"ancient_storm_rune": 1,
	"mythic_vault_rune": 1,
	"ward_rune": 1,
	"meta_forge_rune": 1,
	"boss_relic_fragment": 0,
	"vault_ward_shard": 0,
}

const ENDGAME_ACTIONS: Array[String] = [
	"greater_transmute", "perfect_transmute", "greater_augment", "perfect_augment",
	"greater_regal", "perfect_regal", "greater_exalt", "perfect_exalt",
	"greater_chaos", "perfect_chaos",
	"oracle_lens", "binding_omen", "ash_omen", "null_omen", "perfecting_omen",
	"vaultbind", "relic_reforge", "extract_unique_rune",
	"rune_ancient_ash", "rune_ancient_storm", "rune_mythic_vault", "rune_ward", "rune_meta_forge",
]

const EXTRA_MATERIAL_LABELS: Dictionary = {
	"greater_transmutation_orb": "Greater Orb of Transmutation",
	"perfect_transmutation_orb": "Perfect Orb of Transmutation",
	"greater_augmentation_orb": "Greater Orb of Augmentation",
	"perfect_augmentation_orb": "Perfect Orb of Augmentation",
	"greater_regal_orb": "Greater Regal Orb",
	"perfect_regal_orb": "Perfect Regal Orb",
	"greater_exalted_orb": "Greater Exalted Orb",
	"perfect_exalted_orb": "Perfect Exalted Orb",
	"greater_chaos_orb": "Greater Chaos Orb",
	"perfect_chaos_orb": "Perfect Chaos Orb",
	"oracle_lens": "Vault Oracle Lens",
	"binding_omen": "Binding Omen",
	"ash_omen": "Ash Omen",
	"null_omen": "Null Omen",
	"perfecting_omen": "Perfecting Omen",
	"vaultbinding_orb": "Vaultbinding Orb",
	"relic_reforge_core": "Relic Reforge Core",
	"ancient_ash_rune": "Ancient Ash Rune",
	"ancient_storm_rune": "Ancient Storm Rune",
	"mythic_vault_rune": "Mythic Vault Rune",
	"ward_rune": "Runic Ward Rune",
	"meta_forge_rune": "Meta Forge Rune",
	"boss_relic_fragment": "Boss Relic Fragment",
	"vault_ward_shard": "Vault Ward Shard",
}

const CUSTOM_RUNES: Dictionary = {
	"ancient_ash_rune": {
		"name": "Ancient Ash Rune",
		"stats": {"Fire Damage": 18.0, "Ignite Chance": 8.0},
		"rule": "Fire skills leave a small burning scar on elite enemies.",
		"text": "+18% Fire Damage, +8% Ignite Chance"
	},
	"ancient_storm_rune": {
		"name": "Ancient Storm Rune",
		"stats": {"Lightning Damage": 18.0, "Chain Bonus": 1.0},
		"rule": "Lightning skills gain a small chance to create a secondary chain.",
		"text": "+18% Lightning Damage, +1 Chain Bonus"
	},
	"mythic_vault_rune": {
		"name": "Mythic Vault Rune",
		"stats": {"Maximum Spirit": 6.0, "Item Rarity": 18.0},
		"rule": "Enabled Spirit gems grant additional item rarity.",
		"text": "+6 Spirit, +18% Item Rarity"
	},
	"ward_rune": {
		"name": "Runic Ward Rune",
		"stats": {"Runic Ward": 35.0, "Armor": 12.0},
		"rule": "Gain emergency ward when reduced near death. Prototype defensive layer.",
		"text": "+35 Runic Ward, +12 Armor"
	},
	"meta_forge_rune": {
		"name": "Meta Forge Rune",
		"stats": {"Forge Potential Bonus": 2.0},
		"rule": "First deterministic craft on this item has a chance to refund Forge Potential.",
		"text": "+2 Forge Potential Bonus"
	},
}

const ENDGAME_AFFIXES: Array[Dictionary] = [
	{"id":"fire_skill_level", "group":"fire_skill_level", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["fire","caster","skill"], "stat":"Fire Skill Level", "tiers":[[1,1],[1,1],[1,2],[2,2]], "min_levels":[1,16,32,50], "rule":"Fire skill gems scale harder."},
	{"id":"projectile_repetition", "group":"projectile_repetition", "side":"prefix", "domains":["weapon","offhand","jewelry"], "tags":["projectile","spell"], "stat":"Projectile Damage", "tiers":[[8,14],[15,24],[25,38],[39,55]], "min_levels":[1,14,30,48], "rule":"Projectile skills are favored by this item."},
	{"id":"chain_mastery", "group":"chain_mastery", "side":"prefix", "domains":["weapon","offhand","jewelry"], "tags":["lightning","chain"], "stat":"Chain Bonus", "tiers":[[1,1],[1,1],[1,2],[2,2]], "min_levels":[12,24,38,54], "rule":"Storm Lance and chain skills gain clearer upgrade direction."},
	{"id":"void_area", "group":"void_area", "side":"prefix", "domains":["weapon","offhand","relic"], "tags":["void","area"], "stat":"Area Damage", "tiers":[[8,14],[15,25],[26,40],[41,60]], "min_levels":[1,18,34,52], "rule":"Void Rift and area skills gain a stronger endgame base."},
	{"id":"spirit_reservation", "group":"spirit_reservation", "side":"suffix", "domains":["jewelry","relic","offhand"], "tags":["spirit"], "stat":"Spirit Reservation Efficiency", "tiers":[[3,5],[6,9],[10,14],[15,20]], "min_levels":[10,24,40,58], "rule":"Spirit builds reserve more efficiently."},
	{"id":"support_efficiency", "group":"support_efficiency", "side":"suffix", "domains":["relic","jewelry","weapon"], "tags":["support","mana"], "stat":"Supported Skill Mana Efficiency", "tiers":[[3,5],[6,9],[10,15],[16,22]], "min_levels":[8,22,38,56], "rule":"Skills with several supports become easier to sustain."},
	{"id":"forge_mastery", "group":"forge_mastery", "side":"suffix", "domains":["weapon","armor","jewelry","relic","offhand"], "tags":["forge"], "stat":"Forge Potential Bonus", "tiers":[[1,1],[1,2],[2,3],[3,5]], "min_levels":[1,20,36,55], "rule":"This item is a better long-term crafting project."},
	{"id":"boss_hunter", "group":"boss_hunter", "side":"suffix", "domains":["weapon","jewelry","relic"], "tags":["boss","loot"], "stat":"Boss Reward Chance", "tiers":[[4,8],[9,15],[16,25],[26,40]], "min_levels":[12,26,42,60], "rule":"Boss kills have improved item/currency outcomes."},
	{"id":"ward_emergency", "group":"ward_emergency", "side":"prefix", "domains":["armor","offhand","relic"], "tags":["ward","defence"], "stat":"Runic Ward", "tiers":[[15,25],[26,42],[43,70],[71,105]], "min_levels":[6,20,38,56], "rule":"Runic Ward protects you near death."},
]

static func ensure_endgame_defaults(state: Object) -> void:
	if state == null:
		return
	var materials: Dictionary = Dictionary(state.get("materials"))
	if bool(materials.get("_item_endgame_seeded_031", false)):
		return
	for key: Variant in ENDGAME_STARTER_COUNTS.keys():
		materials[str(key)] = int(materials.get(str(key), 0)) + int(ENDGAME_STARTER_COUNTS[key])
	materials["_item_endgame_seeded_031"] = true
	state.set("materials", materials)
	_seed_items(state)
	if state.has_method("add_notice"):
		state.call("add_notice", "Endgame item systems seeded.")

static func _seed_items(state: Object) -> void:
	var rng: RandomNumberGenerator = _rng(state)
	var backpack: Array = Array(state.get("backpack"))
	backpack.append(make_endgame_rare("ash_wand", 28, rng, "fire"))
	backpack.append(make_endgame_rare("storm_focus", 28, rng, "lightning"))
	backpack.append(make_endgame_rare("iron_plate", 30, rng, "ward"))
	backpack.append(make_boss_relic("ash_foundry_warden", 28, rng))
	state.set("backpack", backpack)

static func is_endgame_action(action: String) -> bool:
	return ENDGAME_ACTIONS.has(action)

static func material_label(id: String) -> String:
	return str(EXTRA_MATERIAL_LABELS.get(id, ItemizationScript.material_label(id)))

static func all_endgame_actions() -> Array[String]:
	return ENDGAME_ACTIONS.duplicate()

static func preview_action(state: Object, action: String) -> String:
	if state == null:
		return "No state."
	var item: Dictionary = _selected_item(state)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a][b]Endgame Preview: " + action.replace("_", " ").capitalize() + "[/b][/color]")
	lines.append(_explain(action))
	var cost: String = _cost_id(action)
	if cost != "":
		lines.append("Cost: 1 " + material_label(cost))
	if item.is_empty():
		lines.append("[color=#d65a32]No selected item.[/color]")
	else:
		lines.append("Target: " + str(item.get("display_name", "Item")))
		lines.append("State: " + str(item.get("craft_state", "stable")).capitalize() + " · FP " + str(int(item.get("forge_potential", 0))) + "/" + str(int(item.get("forge_potential_max", 0))))
		lines.append("Item Level Gate: " + item_level_report(item))
	return "\n".join(lines)

static func apply_to_selected(state: Object, action: String) -> bool:
	if state == null:
		return false
	var backpack: Array = Array(state.get("backpack"))
	if backpack.is_empty():
		return _fail(state, "No item selected.")
	var index: int = clampi(int(state.get("inventory_cursor")), 0, backpack.size() - 1)
	if typeof(backpack[index]) != TYPE_DICTIONARY:
		return _fail(state, "No item selected.")
	var item: Dictionary = ItemizationScript.normalize_item(Dictionary(backpack[index]))
	if item.is_empty() or not ItemizationScript.is_equipment(item):
		return _fail(state, "Select equipment first.")
	if action != "oracle_lens" and not bool(item.get("identified", true)):
		return _fail(state, "Appraise the item before endgame crafting.")
	var cost: String = _cost_id(action)
	if cost != "" and not _pay(state, cost, 1):
		return _fail(state, "Missing " + material_label(cost) + ".")
	var rng: RandomNumberGenerator = _rng(state)
	match action:
		"greater_transmute":
			item = _transmute(item, rng, 2)
		"perfect_transmute":
			item = _transmute(item, rng, 4)
		"greater_augment":
			item = _augment(item, rng, 2)
		"perfect_augment":
			item = _augment(item, rng, 4)
		"greater_regal":
			item = _regal(item, rng, 2)
		"perfect_regal":
			item = _regal(item, rng, 4)
		"greater_exalt":
			item = _exalt(item, rng, 2)
		"perfect_exalt":
			item = _exalt(item, rng, 4)
		"greater_chaos":
			item = _chaos(item, rng, 2)
		"perfect_chaos":
			item = _chaos(item, rng, 4)
		"oracle_lens":
			state.set("item_oracle_preview", oracle_preview(item, rng))
			_notice(state, str(state.get("item_oracle_preview")))
			return true
		"binding_omen", "ash_omen", "null_omen", "perfecting_omen":
			item["active_omen"] = action
			item["crafting_history"] = Array(item.get("crafting_history", [])) + ["Omen prepared: " + action.replace("_", " ").capitalize()]
		"vaultbind":
			item = vaultbind_item(item, rng)
		"relic_reforge":
			item = relic_reforge(item, rng)
		"extract_unique_rune":
			return _extract_unique_rune(state, backpack, index, item)
		"rune_ancient_ash":
			item = socket_custom_rune(item, "ancient_ash_rune")
		"rune_ancient_storm":
			item = socket_custom_rune(item, "ancient_storm_rune")
		"rune_mythic_vault":
			item = socket_custom_rune(item, "mythic_vault_rune")
		"rune_ward":
			item = socket_custom_rune(item, "ward_rune")
		"rune_meta_forge":
			item = socket_custom_rune(item, "meta_forge_rune")
		_:
			return _fail(state, "Unknown endgame craft: " + action)
	item = finalize_endgame_item(item)
	backpack[index] = item
	state.set("backpack", backpack)
	if state.has_method("recompute_stats"):
		state.call("recompute_stats")
	_notice(state, "Applied " + action.replace("_", " ").capitalize() + ".")
	return true

static func finalize_endgame_item(item: Dictionary) -> Dictionary:
	item = ItemizationScript.normalize_item(item)
	item["loot_priority"] = endgame_loot_priority(item)
	return item

static func make_endgame_rare(base_id: String, item_level: int, rng: RandomNumberGenerator, tag: String = "") -> Dictionary:
	var item: Dictionary = ItemizationScript.make_item(base_id, item_level, "rare", rng)
	item = add_endgame_affix(item, rng, tag, 2, true)
	item = add_endgame_affix(item, rng, "forge", 1, false)
	item["display_name"] = "Endgame " + str(item.get("display_name", "Item"))
	return finalize_endgame_item(item)

static func make_boss_relic(boss_id: String, item_level: int, rng: RandomNumberGenerator) -> Dictionary:
	var item: Dictionary = ItemizationScript.make_unique_item("penitent_zero_relic", item_level, rng)
	match boss_id:
		"ash_foundry_warden":
			item["display_name"] = "Ash Warden's Sealed Relic"
			item["build_rules"] = Array(item.get("build_rules", [])) + ["Boss Relic: Fire skills gain boss-damage scaling after a map boss kill."]
			item = _append_mod(item, _make_mod("boss_ash_fire", "Boss-Warden's", "Boss Reward Chance", 18.0, 3, "suffix", "boss_hunter", "Boss-exclusive fire reward scaling."))
		"storm_archive_warden":
			item["display_name"] = "Storm Archive Reliquary"
			item["build_rules"] = Array(item.get("build_rules", [])) + ["Boss Relic: Lightning chains have improved reward conversion."]
			item = _append_mod(item, _make_mod("boss_storm_chain", "Archive's", "Chain Bonus", 1.0, 3, "prefix", "chain_mastery", "Boss-exclusive chain modifier."))
		_:
			item["build_rules"] = Array(item.get("build_rules", [])) + ["Boss Relic: rare boss-exclusive itemization prototype."]
	item["boss_exclusive"] = true
	return finalize_endgame_item(item)

static func inject_endgame_drops(state: Object, out: Array, enemy_level: int, elite: bool, boss: bool) -> void:
	var rng: RandomNumberGenerator = _rng(state)
	if boss:
		out.append({"kind":"item", "item":make_boss_relic("ash_foundry_warden", maxi(8, enemy_level), rng), "auto_pickup":false, "rarity":"unique"})
		out.append({"kind":"material", "material_id":"boss_relic_fragment", "amount":rng.randi_range(1, 2), "label":"Boss Relic Fragment", "auto_pickup":true, "rarity":"currency"})
		if rng.randf() < 0.55:
			out.append({"kind":"material", "material_id":"vaultbinding_orb", "amount":1, "label":"Vaultbinding Orb", "auto_pickup":true, "rarity":"currency"})
	elif elite and rng.randf() < 0.18:
		out.append({"kind":"material", "material_id":"oracle_lens", "amount":1, "label":"Vault Oracle Lens", "auto_pickup":true, "rarity":"currency"})
	if rng.randf() < (0.16 if boss else (0.045 if elite else 0.015)):
		var rune_ids: Array = ["ancient_ash_rune", "ancient_storm_rune", "mythic_vault_rune", "ward_rune", "meta_forge_rune"]
		var rune_id: String = str(rune_ids[rng.randi_range(0, rune_ids.size() - 1)])
		out.append({"kind":"material", "material_id":rune_id, "amount":1, "label":material_label(rune_id), "auto_pickup":true, "rarity":"currency"})

static func oracle_preview(item: Dictionary, rng: RandomNumberGenerator) -> String:
	var tag: String = _best_tag(item)
	var affix: Dictionary = _roll_endgame_affix(item, rng, tag, 2, false)
	if affix.is_empty():
		return "Oracle Lens sees no valid modifier."
	return "Oracle Lens foresees: +" + str(snappedf(float(affix.get("value", 0.0)), 0.1)) + " " + str(affix.get("stat", "Modifier")) + " T" + str(int(affix.get("tier", 0))) + "."

static func item_level_report(item: Dictionary) -> String:
	var ilvl: int = int(item.get("item_level", 1))
	if ilvl >= 56:
		return "Endgame tier pool unlocked."
	if ilvl >= 38:
		return "High tier pool unlocked."
	if ilvl >= 20:
		return "Mid tier pool unlocked."
	return "Early tier pool only."

static func endgame_item_text(item: Dictionary) -> String:
	if item.is_empty() or not ItemizationScript.is_equipment(item):
		return ""
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a]Endgame Identity[/color]")
	lines.append("• " + item_level_report(item))
	var state: String = str(item.get("craft_state", "stable"))
	if state != "stable":
		lines.append("• Craft State: " + state.capitalize())
	if bool(item.get("corrupted", false)):
		lines.append("• Vaultbound: item is corrupted/locked from normal crafting.")
	if bool(item.get("boss_exclusive", false)):
		lines.append("• Boss-exclusive drop pool item.")
	var history: Array = Array(item.get("crafting_history", []))
	if not history.is_empty():
		lines.append("[color=#8f8777]Crafting History[/color]")
		for i: int in range(min(5, history.size())):
			lines.append("  • " + str(history[max(0, history.size() - 1 - i)]))
	lines.append("[color=#8f8777]Loot Filter[/color] " + loot_filter_label(item))
	return "\n".join(lines)

static func loot_filter_label(item: Dictionary) -> String:
	var p: int = endgame_loot_priority(item)
	if p >= 115:
		return "CHASE RELIC · large gold beam"
	if p >= 95:
		return "BOSS / UNIQUE · gold beam"
	if p >= 80:
		return "HIGH POTENTIAL · blue-gold beam"
	if p >= 65:
		return "VALUABLE RARE · yellow beam"
	if p >= 45:
		return "USEFUL BASE · soft marker"
	return "low priority"

static func endgame_loot_priority(item: Dictionary) -> int:
	if item.is_empty():
		return 0
	if bool(item.get("boss_exclusive", false)):
		return 115
	if str(item.get("rarity", "normal")) == "unique":
		return 100
	if bool(item.get("corrupted", false)):
		return 90
	if int(item.get("forge_potential", 0)) >= 10:
		return 85
	var mods: Array = Array(item.get("explicit_mods", []))
	for value: Variant in mods:
		if typeof(value) == TYPE_DICTIONARY and int(Dictionary(value).get("tier", 0)) >= 4:
			return 75
	return int(item.get("loot_priority", 0))

static func build_aware_delta(candidate: Dictionary, current: Dictionary) -> String:
	if candidate.is_empty():
		return ""
	candidate = ItemizationScript.normalize_item(candidate)
	current = ItemizationScript.normalize_item(current)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a]Build-Aware Comparison[/color]")
	var candidate_stats: Dictionary = Dictionary(candidate.get("total_stats", {}))
	var current_stats: Dictionary = Dictionary(current.get("total_stats", {}))
	var focus: Array[String] = ["Fire Skill Level", "Fire Damage", "Ignite Chance", "Lightning Damage", "Chain Bonus", "Void Damage", "Area Damage", "Spirit Reservation Efficiency", "Runic Ward", "Forge Potential Bonus", "Boss Reward Chance"]
	var any: bool = false
	for stat: String in focus:
		var delta: float = float(candidate_stats.get(stat, 0.0)) - float(current_stats.get(stat, 0.0))
		if absf(delta) >= 0.01:
			any = true
			var sign: String = "+" if delta > 0.0 else ""
			var color: String = "#69a84f" if delta > 0.0 else "#d65a32"
			lines.append("• [color=" + color + "]" + sign + str(snappedf(delta, 0.1)) + " " + stat + "[/color]")
	if not any:
		lines.append("• No major tag/build delta detected.")
	return "\n".join(lines)

static func _transmute(item: Dictionary, rng: RandomNumberGenerator, tier_floor: int) -> Dictionary:
	if str(item.get("rarity", "normal")) != "normal":
		return item
	item["rarity"] = "magic"
	return add_endgame_affix(item, rng, _best_tag(item), tier_floor, tier_floor >= 4)

static func _augment(item: Dictionary, rng: RandomNumberGenerator, tier_floor: int) -> Dictionary:
	if str(item.get("rarity", "normal")) != "magic":
		return item
	if Array(item.get("explicit_mods", [])).size() >= 2:
		return item
	return add_endgame_affix(item, rng, _best_tag(item), tier_floor, tier_floor >= 4)

static func _regal(item: Dictionary, rng: RandomNumberGenerator, tier_floor: int) -> Dictionary:
	if str(item.get("rarity", "normal")) != "magic":
		return item
	item["rarity"] = "rare"
	return add_endgame_affix(item, rng, _best_tag(item), tier_floor, tier_floor >= 4)

static func _exalt(item: Dictionary, rng: RandomNumberGenerator, tier_floor: int) -> Dictionary:
	if str(item.get("rarity", "normal")) != "rare":
		return item
	if Array(item.get("explicit_mods", [])).size() >= 6:
		return item
	return add_endgame_affix(item, rng, _best_tag(item), tier_floor, tier_floor >= 4)

static func _chaos(item: Dictionary, rng: RandomNumberGenerator, tier_floor: int) -> Dictionary:
	if str(item.get("rarity", "normal")) != "rare":
		return item
	item = ItemizationScript.remove_random_affix(item, rng)
	return add_endgame_affix(item, rng, _omen_tag(item, _best_tag(item)), tier_floor, tier_floor >= 4)

static func add_endgame_affix(item: Dictionary, rng: RandomNumberGenerator, forced_tag: String = "", tier_floor: int = 1, perfect: bool = false) -> Dictionary:
	var affix: Dictionary = _roll_endgame_affix(item, rng, forced_tag, tier_floor, perfect)
	if affix.is_empty():
		return ItemizationScript.add_random_affix(item, rng, forced_tag, perfect)
	item = _append_mod(item, affix)
	return ItemizationScript.rebuild_totals(item)

static func _roll_endgame_affix(item: Dictionary, rng: RandomNumberGenerator, forced_tag: String, tier_floor: int, perfect: bool) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var eligible: Array[Dictionary] = []
	var item_level: int = int(item.get("item_level", 1))
	var domain: String = str(item.get("category", "weapon"))
	var existing_groups: Dictionary = {}
	for value: Variant in Array(item.get("explicit_mods", [])):
		if typeof(value) == TYPE_DICTIONARY:
			existing_groups[str(Dictionary(value).get("group", Dictionary(value).get("id", "")))] = true
	for data: Dictionary in ENDGAME_AFFIXES:
		if existing_groups.has(str(data.get("group", ""))):
			continue
		if not Array(data.get("domains", [])).has(domain):
			continue
		if forced_tag != "" and not Array(data.get("tags", [])).has(forced_tag):
			continue
		if _count_side(item, str(data.get("side", "prefix"))) >= 3:
			continue
		eligible.append(data)
	if eligible.is_empty() and forced_tag != "":
		return _roll_endgame_affix(item, rng, "", tier_floor, perfect)
	if eligible.is_empty():
		return {}
	var picked: Dictionary = Dictionary(eligible[rng.randi_range(0, eligible.size() - 1)])
	var min_levels: Array = Array(picked.get("min_levels", []))
	var tiers: Array = Array(picked.get("tiers", []))
	var valid_indices: Array[int] = []
	for i: int in range(tiers.size()):
		var min_level: int = int(min_levels[i]) if i < min_levels.size() else 1
		if item_level >= min_level and i + 1 >= tier_floor:
			valid_indices.append(i)
	if valid_indices.is_empty():
		for i: int in range(tiers.size()):
			var min_level2: int = int(min_levels[i]) if i < min_levels.size() else 1
			if item_level >= min_level2:
				valid_indices.append(i)
	if valid_indices.is_empty():
		valid_indices.append(0)
	var tier_index: int = valid_indices[valid_indices.size() - 1] if perfect else valid_indices[rng.randi_range(0, valid_indices.size() - 1)]
	var value_range: Array = Array(tiers[tier_index])
	var value: float = float(value_range[0])
	if value_range.size() > 1:
		value = rng.randf_range(float(value_range[0]), float(value_range[1]))
	return _make_mod(str(picked.get("id", "endgame")), str(picked.get("id", "endgame")).replace("_", " ").capitalize(), str(picked.get("stat", "Modifier")), value, tier_index + 1, str(picked.get("side", "prefix")), str(picked.get("group", "")), str(picked.get("rule", "")))

static func vaultbind_item(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var roll: float = rng.randf()
	item["corrupted"] = true
	item["craft_state"] = "vaultbound"
	item["crafting_history"] = Array(item.get("crafting_history", [])) + ["Vaultbound corruption applied."]
	if roll < 0.35:
		item = add_endgame_affix(item, rng, _best_tag(item), 3, true)
	elif roll < 0.60:
		item = _add_implicit(item, _make_mod("vaultbound_implicit", "Vaultbound", "Item Rarity", 22.0, 0, "implicit", "vaultbound", "Corrupted implicit from Vaultbinding."))
	elif roll < 0.80:
		item = _append_mod(item, _make_mod("vaultbound_ward", "Vaultbound", "Runic Ward", 45.0, 0, "suffix", "vaultbound_ward", "Emergency ward from corruption."))
	else:
		item["forge_potential"] = 0
		item["craft_state"] = "bricked"
	return item

static func relic_reforge(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if str(item.get("rarity", "normal")) != "unique":
		item["crafting_history"] = Array(item.get("crafting_history", [])) + ["Relic Reforge failed: item is not unique."]
		return item
	item["item_level"] = maxi(int(item.get("item_level", 1)) + rng.randi_range(4, 8), 20)
	item["required_level"] = maxi(int(item.get("required_level", 1)), int(item.get("item_level", 1)) - 2)
	item["forge_potential_max"] = maxi(int(item.get("forge_potential_max", 3)), 5)
	item["forge_potential"] = maxi(int(item.get("forge_potential", 0)), 2)
	item["display_name"] = "Reforged " + str(item.get("display_name", "Relic"))
	item["build_rules"] = Array(item.get("build_rules", [])) + ["Relic Reforged: unique scales into later maps."]
	item["crafting_history"] = Array(item.get("crafting_history", [])) + ["Relic Reforge upgraded item level and future potential."]
	return item

static func socket_custom_rune(item: Dictionary, rune_id: String) -> Dictionary:
	var data: Dictionary = Dictionary(CUSTOM_RUNES.get(rune_id, {}))
	if data.is_empty():
		return item
	var sockets: Array = Array(item.get("sockets", []))
	var filled: bool = false
	for i: int in range(sockets.size()):
		if typeof(sockets[i]) == TYPE_DICTIONARY:
			var socket: Dictionary = Dictionary(sockets[i])
			if str(socket.get("rune_id", "")) == "":
				socket["rune_id"] = rune_id
				sockets[i] = socket
				filled = true
				break
	if not filled:
		var limit: int = _socket_limit(item)
		if sockets.size() < limit:
			sockets.append({"socket_id": sockets.size(), "socket_type":"rune", "rune_id":rune_id})
			filled = true
	if not filled:
		return item
	item["sockets"] = sockets
	item = _append_mod(item, _make_mod(rune_id, str(data.get("name", rune_id)), _first_stat_name(Dictionary(data.get("stats", {}))), _first_stat_value(Dictionary(data.get("stats", {}))), 0, "suffix", rune_id, str(data.get("rule", ""))))
	item["crafting_history"] = Array(item.get("crafting_history", [])) + ["Socketed " + str(data.get("name", rune_id)) + "."]
	return item

static func _extract_unique_rune(state: Object, backpack: Array, index: int, item: Dictionary) -> bool:
	if str(item.get("rarity", "normal")) != "unique":
		return _fail(state, "Only unique/relic items can be destroyed into unique runes.")
	var materials: Dictionary = Dictionary(state.get("materials"))
	materials["boss_relic_fragment"] = int(materials.get("boss_relic_fragment", 0)) + 3
	materials["relic_core"] = int(materials.get("relic_core", 0)) + 1
	state.set("materials", materials)
	backpack.remove_at(index)
	state.set("backpack", backpack)
	_notice(state, "Destroyed unique relic into Boss Relic Fragments and a Relic Core.")
	return true

static func _append_mod(item: Dictionary, mod: Dictionary) -> Dictionary:
	var mods: Array = Array(item.get("explicit_mods", []))
	mods.append(mod)
	item["explicit_mods"] = mods
	return item

static func _add_implicit(item: Dictionary, mod: Dictionary) -> Dictionary:
	var mods: Array = Array(item.get("implicit_mods", []))
	mods.append(mod)
	item["implicit_mods"] = mods
	return item

static func _make_mod(id: String, name: String, stat: String, value: float, tier: int, side: String, group: String, rule: String = "") -> Dictionary:
	return {"id": id, "name": name, "stat": stat, "value": value, "stats": {stat: value}, "tier": tier, "side": side, "group": group, "rule": rule}

static func _count_side(item: Dictionary, side: String) -> int:
	var count: int = 0
	for value: Variant in Array(item.get("explicit_mods", [])):
		if typeof(value) == TYPE_DICTIONARY and str(Dictionary(value).get("side", "")) == side:
			count += 1
	return count

static func _best_tag(item: Dictionary) -> String:
	var tags: Array = Array(item.get("tags", []))
	for tag: String in ["fire", "lightning", "void", "spirit", "forge", "projectile"]:
		if tags.has(tag):
			return tag
	return ""

static func _omen_tag(item: Dictionary, fallback: String) -> String:
	var omen: String = str(item.get("active_omen", ""))
	match omen:
		"ash_omen": return "fire"
		"perfecting_omen": return fallback
		_: return fallback

static func _socket_limit(item: Dictionary) -> int:
	var current: int = Array(item.get("sockets", [])).size()
	return maxi(current + 1, int(item.get("socket_limit", 2)))

static func _selected_item(state: Object) -> Dictionary:
	var backpack: Array = Array(state.get("backpack"))
	if backpack.is_empty():
		return {}
	var index: int = clampi(int(state.get("inventory_cursor")), 0, backpack.size() - 1)
	if typeof(backpack[index]) == TYPE_DICTIONARY:
		return ItemizationScript.normalize_item(Dictionary(backpack[index]))
	return {}

static func _cost_id(action: String) -> String:
	match action:
		"greater_transmute": return "greater_transmutation_orb"
		"perfect_transmute": return "perfect_transmutation_orb"
		"greater_augment": return "greater_augmentation_orb"
		"perfect_augment": return "perfect_augmentation_orb"
		"greater_regal": return "greater_regal_orb"
		"perfect_regal": return "perfect_regal_orb"
		"greater_exalt": return "greater_exalted_orb"
		"perfect_exalt": return "perfect_exalted_orb"
		"greater_chaos": return "greater_chaos_orb"
		"perfect_chaos": return "perfect_chaos_orb"
		"oracle_lens": return "oracle_lens"
		"binding_omen": return "binding_omen"
		"ash_omen": return "ash_omen"
		"null_omen": return "null_omen"
		"perfecting_omen": return "perfecting_omen"
		"vaultbind": return "vaultbinding_orb"
		"relic_reforge": return "relic_reforge_core"
		"rune_ancient_ash": return "ancient_ash_rune"
		"rune_ancient_storm": return "ancient_storm_rune"
		"rune_mythic_vault": return "mythic_vault_rune"
		"rune_ward": return "ward_rune"
		"rune_meta_forge": return "meta_forge_rune"
		_: return ""

static func _explain(action: String) -> String:
	match action:
		"greater_transmute": return "Normal → Magic with a stronger minimum-tier modifier."
		"perfect_transmute": return "Normal → Magic with the best available tier for this item level."
		"greater_augment": return "Add a stronger modifier to a Magic item with an open slot."
		"perfect_augment": return "Add the best available modifier tier to a Magic item."
		"greater_regal": return "Magic → Rare with a stronger modifier."
		"perfect_regal": return "Magic → Rare with the best available tier."
		"greater_exalt": return "Add a stronger modifier to a Rare item."
		"perfect_exalt": return "Add the best available modifier tier to a Rare item."
		"greater_chaos": return "Rare only. Replace one modifier with a better minimum-tier result."
		"perfect_chaos": return "Rare only. Replace one modifier with the best available tier."
		"oracle_lens": return "Preview a likely next high-value craft without changing the item."
		"binding_omen": return "Prepare an omen. Future craft systems can protect a key modifier."
		"ash_omen": return "Prepare an omen that biases the next random craft toward Fire."
		"null_omen": return "Prepare an omen that represents controlled removal."
		"perfecting_omen": return "Prepare an omen that prefers the highest available tier."
		"vaultbind": return "Corrupt/Vaultbind the item. Irreversible. Can add power, lock the item, or brick potential."
		"relic_reforge": return "Upgrade a Unique/Relic so it scales into later maps."
		"extract_unique_rune": return "Destroy a unique/relic item into Relic Core and Boss Relic Fragments."
		"rune_ancient_ash": return "Socket an advanced Fire rune into the selected item."
		"rune_ancient_storm": return "Socket an advanced Lightning rune into the selected item."
		"rune_mythic_vault": return "Socket an advanced Spirit/loot rune into the selected item."
		"rune_ward": return "Socket a Runic Ward defensive rune."
		"rune_meta_forge": return "Socket a crafting-focused rune."
		_: return "No preview available."

static func _pay(state: Object, id: String, amount: int) -> bool:
	if id == "" or amount <= 0:
		return true
	var materials: Dictionary = Dictionary(state.get("materials"))
	if int(materials.get(id, 0)) < amount:
		return false
	materials[id] = int(materials.get(id, 0)) - amount
	state.set("materials", materials)
	return true

static func _rng(state: Object) -> RandomNumberGenerator:
	if state != null:
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

static func _first_stat_name(stats: Dictionary) -> String:
	for key: Variant in stats.keys():
		return str(key)
	return "Modifier"

static func _first_stat_value(stats: Dictionary) -> float:
	for key: Variant in stats.keys():
		return float(stats[key])
	return 0.0
