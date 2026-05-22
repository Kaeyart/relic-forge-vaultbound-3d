class_name RVItemizationSystem3D
extends RefCounted

const STARTER_COUNTS: Dictionary = {
	"transmutation_orb": 5,
	"augmentation_orb": 5,
	"regal_orb": 2,
	"exalted_orb": 2,
	"chaos_orb": 1,
	"annulment_orb": 1,
	"alchemy_orb": 1,
	"whetstone": 2,
	"armour_scrap": 2,
	"artificer_orb": 1,
	"ember_seal_lesser": 1,
	"iron_seal_lesser": 1,
	"arcanist_seal_lesser": 1,
	"ash_rune": 1,
	"iron_rune": 1,
	"vault_rune": 1,
	"shards": 8,
	"embers": 25,
}

const BASES: Dictionary = {
	"ash_wand": {"name":"Ash Wand", "slot":"weapon", "category":"weapon", "weapon_type":"wand", "stats":{"Spell Damage":8.0}, "implicit":{"Spell Damage":8.0}, "tags":["weapon","spell","caster","fire"], "socket_limit":2, "grid_w":1, "grid_h":3},
	"storm_wand": {"name":"Storm Wand", "slot":"weapon", "category":"weapon", "weapon_type":"wand", "stats":{"Lightning Damage":8.0}, "implicit":{"Lightning Damage":8.0}, "tags":["weapon","spell","caster","lightning"], "socket_limit":2, "grid_w":1, "grid_h":3},
	"iron_sword": {"name":"Iron Sword", "slot":"weapon", "category":"weapon", "weapon_type":"sword", "stats":{"Attack Damage":9.0}, "implicit":{"Attack Damage":8.0}, "tags":["weapon","attack","melee","physical"], "socket_limit":2, "grid_w":1, "grid_h":3},
	"guard_shield": {"name":"Guard Shield", "slot":"offhand", "category":"offhand", "weapon_type":"shield", "stats":{"Armor":28.0}, "implicit":{"Block Chance":5.0}, "tags":["offhand","shield","defence"], "socket_limit":2, "grid_w":2, "grid_h":3},
	"storm_focus": {"name":"Storm Focus", "slot":"offhand", "category":"offhand", "weapon_type":"focus", "stats":{"Maximum Mana":10.0}, "implicit":{"Lightning Damage":6.0}, "tags":["offhand","focus","caster","spell"], "socket_limit":1, "grid_w":2, "grid_h":2},
	"seer_cowl": {"name":"Seer Cowl", "slot":"head", "category":"armor", "stats":{"Maximum Mana":10.0}, "implicit":{"Cast Speed":2.0}, "tags":["armor","head","caster"], "socket_limit":1, "grid_w":2, "grid_h":2},
	"ashwoven_robe": {"name":"Ashwoven Robe", "slot":"chest", "category":"armor", "stats":{"Maximum Mana":18.0}, "implicit":{"Fire Resistance":8.0}, "tags":["armor","chest","fire","caster"], "socket_limit":2, "grid_w":2, "grid_h":3},
	"traveler_boots": {"name":"Traveler Boots", "slot":"boots", "category":"armor", "stats":{"Movement Speed":4.0}, "implicit":{"Movement Speed":4.0}, "tags":["armor","boots","movement"], "socket_limit":1, "grid_w":2, "grid_h":2},
	"ember_ring": {"name":"Ember Ring", "slot":"ring1", "category":"jewelry", "stats":{}, "implicit":{"Fire Damage":4.0,"Fire Resistance":5.0}, "tags":["jewelry","ring","fire"], "socket_limit":1, "grid_w":1, "grid_h":1},
	"storm_ring": {"name":"Storm Ring", "slot":"ring2", "category":"jewelry", "stats":{}, "implicit":{"Lightning Damage":4.0,"Shock Chance":4.0}, "tags":["jewelry","ring","lightning"], "socket_limit":1, "grid_w":1, "grid_h":1},
	"vault_amulet": {"name":"Vault Amulet", "slot":"amulet", "category":"jewelry", "stats":{}, "implicit":{"Maximum Spirit":3.0,"Spell Damage":3.0}, "tags":["jewelry","amulet","spirit","caster"], "socket_limit":1, "grid_w":1, "grid_h":1},
	"penitent_relic": {"name":"Penitent Relic", "slot":"relic", "category":"relic", "stats":{}, "implicit":{"Maximum Life":12.0,"Maximum Spirit":2.0}, "tags":["relic","life","spirit"], "socket_limit":1, "grid_w":1, "grid_h":2},
}

const RUNE_DATA: Dictionary = {
	"ash_rune": {"name":"Ash Rune", "stats":{"Fire Damage":10.0}, "text":"+10% Fire Damage"},
	"iron_rune": {"name":"Iron Rune", "stats":{"Armor":18.0}, "text":"+18 Armor"},
	"vault_rune": {"name":"Vault Rune", "stats":{"Maximum Spirit":3.0}, "text":"+3 Maximum Spirit"},
}

const AFFIXES: Array[Dictionary] = [
	{"id":"life", "name":"Vigorous", "group":"life", "side":"prefix", "domains":["armor","jewelry","relic"], "tags":["life"], "stat":"Maximum Life", "tiers":[[12,20],[21,34],[35,52]]},
	{"id":"mana", "name":"Lucid", "group":"mana", "side":"prefix", "domains":["weapon","offhand","armor","jewelry","relic"], "tags":["mana","caster"], "stat":"Maximum Mana", "tiers":[[8,16],[17,28],[29,44]]},
	{"id":"armor", "name":"Ironclad", "group":"armor", "side":"prefix", "domains":["armor","offhand"], "tags":["defence"], "stat":"Armor", "tiers":[[12,24],[25,42],[43,70]]},
	{"id":"spell_damage", "name":"Arcanist's", "group":"spell_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["spell","caster"], "stat":"Spell Damage", "tiers":[[6,10],[11,18],[19,30]]},
	{"id":"attack_damage", "name":"Warlord's", "group":"attack_damage", "side":"prefix", "domains":["weapon","jewelry","relic"], "tags":["attack","physical"], "stat":"Attack Damage", "tiers":[[6,10],[11,18],[19,32]]},
	{"id":"fire_damage", "name":"Ember", "group":"fire_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["fire"], "stat":"Fire Damage", "tiers":[[7,12],[13,22],[23,38]]},
	{"id":"lightning_damage", "name":"Storm", "group":"lightning_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["lightning"], "stat":"Lightning Damage", "tiers":[[7,12],[13,22],[23,38]]},
	{"id":"cast_speed", "name":"Quickened", "group":"cast_speed", "side":"suffix", "domains":["weapon","offhand","jewelry","armor"], "tags":["caster","speed"], "stat":"Cast Speed", "tiers":[[3,5],[6,9],[10,14]]},
	{"id":"movement_speed", "name":"Fleet", "group":"movement_speed", "side":"suffix", "domains":["armor"], "tags":["movement"], "stat":"Movement Speed", "tiers":[[3,5],[6,9],[10,14]]},
	{"id":"fire_resistance", "name":"of Ash", "group":"fire_resistance", "side":"suffix", "domains":["armor","jewelry","relic"], "tags":["fire","resistance"], "stat":"Fire Resistance", "tiers":[[6,12],[13,22],[23,35]]},
	{"id":"spirit", "name":"Vaultbound", "group":"spirit", "side":"suffix", "domains":["jewelry","relic","offhand"], "tags":["spirit"], "stat":"Maximum Spirit", "tiers":[[2,3],[4,6],[7,10]]},
	{"id":"item_rarity", "name":"Seeker's", "group":"item_rarity", "side":"suffix", "domains":["jewelry","relic"], "tags":["loot"], "stat":"Item Rarity", "tiers":[[6,12],[13,24],[25,40]]},
]

static func ensure_itemization_defaults(state: Object) -> void:
	if state == null:
		return
	var materials: Dictionary = Dictionary(state.get("materials"))
	if not bool(materials.get("_itemization_seeded_029", false)):
		for key: Variant in STARTER_COUNTS.keys():
			materials[str(key)] = int(materials.get(str(key), 0)) + int(STARTER_COUNTS[key])
		materials["_itemization_seeded_029"] = true
		state.set("materials", materials)
		var rng: RandomNumberGenerator = _rng(state)
		var backpack: Array = Array(state.get("backpack"))
		backpack.append(make_item("ash_wand", 3, "normal", rng))
		backpack.append(make_item("ashwoven_robe", 3, "magic", rng))
		backpack.append(make_item("traveler_boots", 4, "rare", rng))
		var shield: Dictionary = add_socket(make_item("guard_shield", 4, "magic", rng))
		backpack.append(shield)
		state.set("backpack", backpack)
	_normalize_backpack(state)
	_normalize_equipped(state)

static func _normalize_backpack(state: Object) -> void:
	var rng: RandomNumberGenerator = _rng(state)
	var backpack: Array = Array(state.get("backpack"))
	for i: int in range(backpack.size()):
		if typeof(backpack[i]) == TYPE_DICTIONARY:
			backpack[i] = normalize_item(Dictionary(backpack[i]), rng)
	state.set("backpack", backpack)

static func _normalize_equipped(state: Object) -> void:
	var rng: RandomNumberGenerator = _rng(state)
	var equipped: Dictionary = Dictionary(state.get("equipped"))
	for key: Variant in equipped.keys():
		if typeof(equipped[key]) == TYPE_DICTIONARY:
			equipped[key] = normalize_item(Dictionary(equipped[key]), rng)
	state.set("equipped", equipped)

static func _rng(state: Object) -> RandomNumberGenerator:
	var value: Variant = state.get("rng") if state != null else null
	if value is RandomNumberGenerator:
		return value as RandomNumberGenerator
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return rng

static func material_label(id: String) -> String:
	var labels: Dictionary = {"transmutation_orb":"Orb of Transmutation","augmentation_orb":"Orb of Augmentation","regal_orb":"Regal Orb","exalted_orb":"Exalted Orb","chaos_orb":"Chaos Orb","annulment_orb":"Orb of Annulment","alchemy_orb":"Orb of Alchemy","whetstone":"Blacksmith's Whetstone","armour_scrap":"Armourer's Scrap","artificer_orb":"Artificer's Orb","ember_seal_lesser":"Lesser Ember Seal","iron_seal_lesser":"Lesser Iron Seal","arcanist_seal_lesser":"Lesser Arcanist Seal","ash_rune":"Ash Rune","iron_rune":"Iron Rune","vault_rune":"Vault Rune","artificer_shard":"Artificer's Shard","essence_dust":"Essence Dust","shards":"Shards","embers":"Embers"}
	return str(labels.get(id, id.replace("_", " ").capitalize()))

static func is_equipment(item: Dictionary) -> bool:
	var kind: String = str(item.get("kind", item.get("item_kind", "")))
	if kind in ["map", "uncut_skill_gem", "uncut_support_gem", "uncut_spirit_gem", "active_gem", "support_gem", "spirit_gem", "currency", "material"]:
		return false
	return str(item.get("slot", "")) != "" or str(item.get("base_id", "")) != ""

static func normalize_item(item: Dictionary, rng: RandomNumberGenerator = null) -> Dictionary:
	if item.is_empty():
		return {}
	var kind: String = str(item.get("kind", item.get("item_kind", "")))
	if kind in ["map", "uncut_skill_gem", "uncut_support_gem", "uncut_spirit_gem", "active_gem", "support_gem", "spirit_gem"]:
		if not item.has("uid"):
			item["uid"] = _new_uid("item")
		return item
	if not is_equipment(item):
		return item
	if rng == null:
		rng = RandomNumberGenerator.new(); rng.randomize()
	var base_id: String = str(item.get("base_id", ""))
	if base_id == "":
		base_id = _guess_base_from_slot(str(item.get("slot", "weapon")))
	var base: Dictionary = Dictionary(BASES.get(base_id, BASES["ash_wand"]))
	item["base_id"] = base_id
	item["kind"] = "item"
	item["item_kind"] = "equipment"
	item["category"] = str(base.get("category", "weapon"))
	item["slot"] = str(base.get("slot", "weapon"))
	item["weapon_type"] = str(base.get("weapon_type", ""))
	item["item_level"] = maxi(1, int(item.get("item_level", item.get("level", 1))))
	item["rarity"] = str(item.get("rarity", "normal")).to_lower()
	item["quality"] = clampi(int(item.get("quality", 0)), 0, 20)
	item["max_quality"] = 20
	item["base_stats"] = Dictionary(item.get("base_stats", base.get("stats", {}))).duplicate(true)
	item["tags"] = Array(item.get("tags", base.get("tags", []))).duplicate(true)
	item["socket_limit"] = int(item.get("socket_limit", base.get("socket_limit", 1)))
	item["grid_w"] = int(item.get("grid_w", base.get("grid_w", 1)))
	item["grid_h"] = int(item.get("grid_h", base.get("grid_h", 1)))
	item["forge_potential"] = int(item.get("forge_potential", 6))
	item["crafting_history"] = Array(item.get("crafting_history", [])).duplicate(true)
	item["identified"] = bool(item.get("identified", true))
	item["favorite"] = bool(item.get("favorite", false))
	item["locked"] = bool(item.get("locked", false))
	if not item.has("uid"):
		item["uid"] = _new_uid("item")
	if not item.has("implicit_mods"):
		item["implicit_mods"] = _mods_from_stats("implicit", Dictionary(base.get("implicit", {})))
	if not item.has("explicit_mods"):
		item["explicit_mods"] = []
	if not item.has("sockets"):
		item["sockets"] = []
	return rebuild_totals(item)

static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var item: Dictionary = {"uid":_new_uid("item"), "base_id":base_id, "kind":"item", "item_kind":"equipment", "rarity":rarity.to_lower(), "item_level":maxi(1,item_level), "quality":0, "forge_potential":6}
	item = normalize_item(item, rng)
	var count: int = 0
	match str(item.get("rarity", "normal")):
		"magic": count = rng.randi_range(1, 2)
		"rare": count = rng.randi_range(3, 5)
	for i: int in range(count):
		item = add_random_affix(item, rng)
	return rebuild_totals(item)

static func random_equipment_drop(item_level: int, rng: RandomNumberGenerator, boss: bool = false) -> Dictionary:
	var ids: Array = BASES.keys()
	var base_id: String = str(ids[rng.randi_range(0, ids.size() - 1)])
	var roll: float = rng.randf()
	var rarity: String = "normal"
	if boss or roll < 0.12: rarity = "rare"
	elif roll < 0.48: rarity = "magic"
	var item: Dictionary = make_item(base_id, item_level, rarity, rng)
	if rng.randf() < (0.42 if boss else 0.16): item["quality"] = rng.randi_range(3, 18 if boss else 12)
	if rng.randf() < (0.25 if boss else 0.08): item = add_socket(item)
	return rebuild_totals(item)

static func add_random_affix(item: Dictionary, rng: RandomNumberGenerator, forced_tag: String = "") -> Dictionary:
	item = normalize_item(item, rng)
	if Array(item.get("explicit_mods", [])).size() >= 6: return item
	var pool: Array[Dictionary] = _eligible_affixes(item, forced_tag)
	if pool.is_empty(): return item
	var def: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var tiers: Array = Array(def.get("tiers", []))
	var tier_index: int = clampi(int(float(item.get("item_level", 1)) / 12.0), 0, tiers.size() - 1)
	var range_v: Array = Array(tiers[tier_index])
	var amount: float = float(rng.randi_range(int(range_v[0]), int(range_v[1])))
	var stat: String = str(def.get("stat", "Power"))
	var mod: Dictionary = {"id":str(def.get("id", "mod")) + "_t" + str(tier_index + 1), "base_id":str(def.get("id", "mod")), "name":str(def.get("name", "Modifier")), "group":str(def.get("group", "")), "tier":tier_index + 1, "prefix_suffix":str(def.get("side", "prefix")), "tags":Array(def.get("tags", [])).duplicate(true), "stats":{stat:amount}, "text":_format_stat(stat, amount)}
	var mods: Array = Array(item.get("explicit_mods", [])); mods.append(mod); item["explicit_mods"] = mods
	return rebuild_totals(item)

static func _eligible_affixes(item: Dictionary, forced_tag: String = "") -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var category: String = str(item.get("category", ""))
	var used: Array[String] = []
	for v: Variant in Array(item.get("explicit_mods", [])):
		if typeof(v) == TYPE_DICTIONARY: used.append(str(Dictionary(v).get("group", "")))
	for def: Dictionary in AFFIXES:
		if used.has(str(def.get("group", ""))): continue
		if not Array(def.get("domains", [])).has(category): continue
		if forced_tag != "" and not Array(def.get("tags", [])).has(forced_tag) and not Array(item.get("tags", [])).has(forced_tag): continue
		var side: String = str(def.get("side", "prefix"))
		if _count_side(item, side) >= 3: continue
		out.append(def.duplicate(true))
	return out

static func _count_side(item: Dictionary, side: String) -> int:
	var count: int = 0
	for v: Variant in Array(item.get("explicit_mods", [])):
		if typeof(v) == TYPE_DICTIONARY and str(Dictionary(v).get("prefix_suffix", "")) == side: count += 1
	return count

static func remove_random_affix(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var mods: Array = Array(item.get("explicit_mods", []))
	if mods.is_empty(): return item
	mods.remove_at(rng.randi_range(0, mods.size() - 1)); item["explicit_mods"] = mods
	return rebuild_totals(item)

static func add_socket(item: Dictionary) -> Dictionary:
	item = normalize_item(item)
	var sockets: Array = Array(item.get("sockets", []))
	if sockets.size() >= int(item.get("socket_limit", 1)): return item
	sockets.append({"socket_id":sockets.size(), "socket_type":"rune", "rune_id":""})
	item["sockets"] = sockets
	return rebuild_totals(item)

static func socket_rune(item: Dictionary, rune_id: String) -> Dictionary:
	item = normalize_item(item)
	var sockets: Array = Array(item.get("sockets", []))
	for i: int in range(sockets.size()):
		var s: Dictionary = Dictionary(sockets[i])
		if str(s.get("rune_id", "")) == "":
			s["rune_id"] = rune_id; sockets[i] = s; item["sockets"] = sockets; return rebuild_totals(item)
	return item

static func rebuild_totals(item: Dictionary) -> Dictionary:
	if not is_equipment(item): return item
	var total: Dictionary = {}
	_merge(total, Dictionary(item.get("base_stats", {})))
	for v: Variant in Array(item.get("implicit_mods", [])):
		if typeof(v) == TYPE_DICTIONARY: _merge(total, Dictionary(Dictionary(v).get("stats", {})))
	for v: Variant in Array(item.get("explicit_mods", [])):
		if typeof(v) == TYPE_DICTIONARY: _merge(total, Dictionary(Dictionary(v).get("stats", {})))
	for v: Variant in Array(item.get("sockets", [])):
		if typeof(v) == TYPE_DICTIONARY:
			var rune_id: String = str(Dictionary(v).get("rune_id", ""))
			_merge(total, Dictionary(Dictionary(RUNE_DATA.get(rune_id, {})).get("stats", {})))
	item["total_stats"] = total
	item["affixes"] = Array(item.get("explicit_mods", []))
	item["item_power"] = int(float(item.get("item_level", 1)) * 4.0 + Array(item.get("explicit_mods", [])).size() * 7 + int(item.get("quality", 0)))
	item["display_name"] = _build_name(item)
	return item

static func item_detail_text(item: Dictionary) -> String:
	if item.is_empty(): return "No item selected."
	if not is_equipment(item): return str(item.get("display_name", item.get("label", "Item")))
	item = normalize_item(item)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[font_size=18][color=#c59b4a][b]" + str(item.get("display_name", "Item")) + "[/b][/color][/font_size]")
	lines.append(str(item.get("rarity", "normal")).capitalize() + " · " + str(item.get("slot", "")) + " · ilvl " + str(item.get("item_level", 1)) + " · Power " + str(item.get("item_power", 0)))
	lines.append("Quality +" + str(item.get("quality", 0)) + "% · Forge Potential " + str(item.get("forge_potential", 0)))
	for section: String in ["implicit_mods", "explicit_mods"]:
		var mods: Array = Array(item.get(section, []))
		if not mods.is_empty(): lines.append("\n[color=#8f8777]" + ("Implicit" if section == "implicit_mods" else "Explicit") + "[/color]")
		for v: Variant in mods:
			if typeof(v) == TYPE_DICTIONARY: lines.append("• " + str(Dictionary(v).get("text", "Modifier")))
	var sockets: Array = Array(item.get("sockets", []))
	if not sockets.is_empty(): lines.append("\n[color=#8f8777]Rune Sockets[/color]")
	for v: Variant in sockets:
		if typeof(v) == TYPE_DICTIONARY:
			var rune_id: String = str(Dictionary(v).get("rune_id", ""))
			if rune_id == "": lines.append("[ ] Empty Rune Socket")
			else: lines.append("[x] " + str(Dictionary(RUNE_DATA.get(rune_id, {})).get("name", rune_id)) + " · " + str(Dictionary(RUNE_DATA.get(rune_id, {})).get("text", "")))
	lines.append("\n[color=#8f8777]Totals[/color]")
	for key: Variant in Dictionary(item.get("total_stats", {})).keys(): lines.append("• " + str(key) + ": " + str(Dictionary(item.get("total_stats", {}))[key]))
	return "\n".join(lines)

static func compare_items_text(candidate: Dictionary, equipped: Dictionary) -> String:
	if candidate.is_empty(): return "No item selected."
	if equipped.is_empty(): return "No equipped item in this slot."
	candidate = normalize_item(candidate); equipped = normalize_item(equipped)
	var lines: PackedStringArray = PackedStringArray(["[color=#c59b4a][b]Comparison[/b][/color]"])
	var keys: Array[String] = []
	for k: Variant in Dictionary(candidate.get("total_stats", {})).keys():
		if not keys.has(str(k)):
			keys.append(str(k))
	for k: Variant in Dictionary(equipped.get("total_stats", {})).keys():
		if not keys.has(str(k)):
			keys.append(str(k))
	for k: String in keys:
		var d: float = float(Dictionary(candidate.get("total_stats", {})).get(k, 0.0)) - float(Dictionary(equipped.get("total_stats", {})).get(k, 0.0))
		if absf(d) > 0.001: lines.append(("+" if d > 0.0 else "") + str(snappedf(d, 0.1)) + " " + k)
	return "\n".join(lines)

static func _guess_base_from_slot(slot: String) -> String:
	match slot:
		"weapon": return "ash_wand"
		"offhand": return "storm_focus"
		"head": return "seer_cowl"
		"chest": return "ashwoven_robe"
		"boots": return "traveler_boots"
		"ring1": return "ember_ring"
		"ring2": return "storm_ring"
		"amulet": return "vault_amulet"
		"relic": return "penitent_relic"
		_: return "ash_wand"

static func _mods_from_stats(prefix: String, stats: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for key: Variant in stats.keys(): out.append({"id":prefix+str(key), "text":_format_stat(str(key), float(stats[key])), "stats":{str(key):float(stats[key])}, "prefix_suffix":"implicit", "group":prefix+str(key)})
	return out

static func _merge(target: Dictionary, stats: Dictionary) -> void:
	for key: Variant in stats.keys(): target[str(key)] = float(target.get(str(key), 0.0)) + float(stats[key])

static func _build_name(item: Dictionary) -> String:
	var base_name: String = str(Dictionary(BASES.get(str(item.get("base_id", "ash_wand")), {})).get("name", "Item"))
	var rarity: String = str(item.get("rarity", "normal"))
	if rarity == "magic" and not Array(item.get("explicit_mods", [])).is_empty(): return str(Dictionary(Array(item.get("explicit_mods", []))[0]).get("name", "Magic")) + " " + base_name
	if rarity == "rare": return "Relic " + base_name
	return base_name

static func _format_stat(stat_name: String, value: float) -> String:
	var n: String = str(int(round(value)))
	if stat_name.find("Damage") >= 0 or stat_name.find("Speed") >= 0 or stat_name.find("Resistance") >= 0 or stat_name.find("Chance") >= 0: return "+" + n + "% " + stat_name
	return "+" + n + " " + stat_name

static func _new_uid(prefix: String) -> String:
	return prefix + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 1000000)
