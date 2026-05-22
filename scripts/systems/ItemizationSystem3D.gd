class_name RVItemizationSystem3D
extends RefCounted

const STARTER_COUNTS: Dictionary = {
	"transmutation_orb": 6,
	"augmentation_orb": 6,
	"regal_orb": 3,
	"exalted_orb": 3,
	"chaos_orb": 2,
	"annulment_orb": 1,
	"alchemy_orb": 2,
	"whetstone": 3,
	"armour_scrap": 3,
	"artificer_orb": 2,
	"ember_seal_lesser": 2,
	"storm_seal_lesser": 2,
	"blood_seal_lesser": 1,
	"iron_seal_lesser": 2,
	"fleet_seal_lesser": 1,
	"arcanist_seal_lesser": 2,
	"ash_rune": 2,
	"storm_rune": 2,
	"blood_rune": 1,
	"iron_rune": 2,
	"vault_rune": 2,
	"seeker_rune": 1,
	"artificer_shard": 0,
	"essence_dust": 0,
	"relic_core": 1,
	"echo_glass": 1,
	"shards": 12,
	"embers": 35,
}

const BASES: Dictionary = {
	"ash_wand": {"name":"Ash Wand", "slot":"weapon", "category":"weapon", "weapon_type":"wand", "stats":{"Spell Damage":8.0}, "implicit":{"Spell Damage":8.0}, "tags":["weapon","spell","caster","fire","projectile"], "socket_limit":2, "grid_w":1, "grid_h":3, "req":{"intelligence":12}},
	"storm_focus": {"name":"Storm Focus", "slot":"offhand", "category":"offhand", "weapon_type":"focus", "stats":{"Maximum Mana":10.0}, "implicit":{"Lightning Damage":6.0}, "tags":["offhand","focus","caster","spell","lightning","chain"], "socket_limit":2, "grid_w":2, "grid_h":2, "req":{"intelligence":14}},
	"bone_sceptre": {"name":"Bone Sceptre", "slot":"weapon", "category":"weapon", "weapon_type":"sceptre", "stats":{"Spell Damage":6.0,"Maximum Spirit":2.0}, "implicit":{"Minion Damage":8.0}, "tags":["weapon","spell","minion","spirit","physical"], "socket_limit":2, "grid_w":1, "grid_h":3, "req":{"intelligence":10}},
	"void_staff": {"name":"Void Staff", "slot":"weapon", "category":"weapon", "weapon_type":"staff", "stats":{"Spell Damage":12.0,"Maximum Mana":12.0}, "implicit":{"Void Damage":8.0}, "tags":["weapon","staff","spell","area","void","caster"], "socket_limit":3, "grid_w":2, "grid_h":4, "req":{"intelligence":20}},
	"iron_mace": {"name":"Iron Mace", "slot":"weapon", "category":"weapon", "weapon_type":"mace", "stats":{"Attack Damage":12.0}, "implicit":{"Stun Power":8.0}, "tags":["weapon","attack","melee","physical","stun"], "socket_limit":2, "grid_w":2, "grid_h":3, "req":{"strength":16}},
	"splitter_axe": {"name":"Splitter Axe", "slot":"weapon", "category":"weapon", "weapon_type":"axe", "stats":{"Attack Damage":14.0}, "implicit":{"Bleed Chance":8.0}, "tags":["weapon","attack","melee","physical","bleed","execute"], "socket_limit":2, "grid_w":2, "grid_h":3, "req":{"strength":14}},
	"guard_shield": {"name":"Guard Shield", "slot":"offhand", "category":"offhand", "weapon_type":"shield", "stats":{"Armor":28.0}, "implicit":{"Block Chance":5.0}, "tags":["offhand","shield","defence","armor"], "socket_limit":2, "grid_w":2, "grid_h":3, "req":{"strength":10}},
	"seer_cowl": {"name":"Seer Cowl", "slot":"head", "category":"armor", "stats":{"Maximum Mana":10.0}, "implicit":{"Cast Speed":2.0}, "tags":["armor","head","caster"], "socket_limit":1, "grid_w":2, "grid_h":2, "req":{"intelligence":10}},
	"ashwoven_robe": {"name":"Ashwoven Robe", "slot":"chest", "category":"armor", "stats":{"Maximum Mana":18.0}, "implicit":{"Fire Resistance":8.0}, "tags":["armor","chest","fire","caster"], "socket_limit":2, "grid_w":2, "grid_h":3, "req":{"intelligence":12}},
	"iron_plate": {"name":"Iron Plate", "slot":"chest", "category":"armor", "stats":{"Armor":42.0}, "implicit":{"Physical Reduction":4.0}, "tags":["armor","chest","defence","physical"], "socket_limit":2, "grid_w":2, "grid_h":3, "req":{"strength":16}},
	"traveler_boots": {"name":"Traveler Boots", "slot":"boots", "category":"armor", "stats":{"Movement Speed":4.0}, "implicit":{"Movement Speed":4.0}, "tags":["armor","boots","movement"], "socket_limit":1, "grid_w":2, "grid_h":2, "req":{}},
	"ember_ring": {"name":"Ember Ring", "slot":"ring1", "category":"jewelry", "stats":{}, "implicit":{"Fire Damage":4.0,"Fire Resistance":5.0}, "tags":["jewelry","ring","fire"], "socket_limit":1, "grid_w":1, "grid_h":1, "req":{}},
	"storm_ring": {"name":"Storm Ring", "slot":"ring2", "category":"jewelry", "stats":{}, "implicit":{"Lightning Damage":4.0,"Shock Chance":4.0}, "tags":["jewelry","ring","lightning"], "socket_limit":1, "grid_w":1, "grid_h":1, "req":{}},
	"vault_amulet": {"name":"Vault Amulet", "slot":"amulet", "category":"jewelry", "stats":{}, "implicit":{"Maximum Spirit":3.0,"Spell Damage":3.0}, "tags":["jewelry","amulet","spirit","caster"], "socket_limit":1, "grid_w":1, "grid_h":1, "req":{}},
	"penitent_relic": {"name":"Penitent Relic", "slot":"relic", "category":"relic", "stats":{}, "implicit":{"Maximum Life":12.0,"Maximum Spirit":2.0}, "tags":["relic","life","spirit"], "socket_limit":1, "grid_w":1, "grid_h":2, "req":{}},
}

const RUNE_DATA: Dictionary = {
	"ash_rune": {"name":"Ash Rune", "stats":{"Fire Damage":10.0}, "text":"+10% Fire Damage", "tags":["fire","damage"]},
	"storm_rune": {"name":"Storm Rune", "stats":{"Lightning Damage":10.0}, "text":"+10% Lightning Damage", "tags":["lightning","damage"]},
	"blood_rune": {"name":"Blood Rune", "stats":{"Maximum Life":22.0}, "text":"+22 Maximum Life", "tags":["life"]},
	"iron_rune": {"name":"Iron Rune", "stats":{"Armor":18.0}, "text":"+18 Armor", "tags":["armor"]},
	"vault_rune": {"name":"Vault Rune", "stats":{"Maximum Spirit":3.0}, "text":"+3 Maximum Spirit", "tags":["spirit"]},
	"seeker_rune": {"name":"Seeker Rune", "stats":{"Item Rarity":16.0}, "text":"+16% Item Rarity", "tags":["loot"]},
}

const UNIQUE_DATA: Dictionary = {
	"cinderspite_lantern": {"name":"Cinderspite Lantern", "base":"ash_wand", "slot":"weapon", "stats":{"Fire Damage":18.0,"Ignite Chance":18.0}, "rules":["Fireball leaves burning ground for 2 seconds.","Fire skills gain +1 projectile after you ignite a rare enemy."], "tags":["unique","fire","spell","projectile"], "flavor":"A prayer bowl, inverted into a weapon."},
	"choir_of_storms": {"name":"Choir of Storms", "base":"storm_focus", "slot":"offhand", "stats":{"Lightning Damage":16.0,"Chain Bonus":1.0,"Maximum Mana":18.0}, "rules":["Storm Lance chains one additional time.","Chained hits deal 15% less damage but shock more reliably."], "tags":["unique","lightning","chain","spell"], "flavor":"Every vault has an echo. This one learned to sing."},
	"bone_tithe_sceptre": {"name":"Bone Tithe Sceptre", "base":"bone_sceptre", "slot":"weapon", "stats":{"Minion Damage":20.0,"Maximum Spirit":5.0}, "rules":["Spirit gems reserve 10% less Spirit.","Minions inherit 12% of your Armor."], "tags":["unique","minion","spirit"], "flavor":"The dead pay in obedience."},
	"rift_eater_staff": {"name":"Rift-Eater Staff", "base":"void_staff", "slot":"weapon", "stats":{"Void Damage":22.0,"Area Damage":14.0,"Maximum Mana":25.0}, "rules":["Void Rift repeats at 60% area after 0.8 seconds.","Void skills cost 12% more Mana."], "tags":["unique","void","area","spell"], "flavor":"It does not open the door. It eats the hinges."},
	"warden_heart_plate": {"name":"Warden-Heart Plate", "base":"iron_plate", "slot":"chest", "stats":{"Armor":70.0,"Maximum Life":38.0}, "rules":["Gain Ward after spending 50 Mana.","You cannot evade while Ward is active."], "tags":["unique","defence","ward","armor"], "flavor":"A prison built around a pulse."},
	"pilgrims_last_boots": {"name":"Pilgrim's Last Boots", "base":"traveler_boots", "slot":"boots", "stats":{"Movement Speed":18.0,"Maximum Spirit":2.0}, "rules":["After using a flask, your next movement skill costs no Mana.","Movement skills have 15% increased cooldown recovery."], "tags":["unique","movement","flask"], "flavor":"The last step is always lighter."},
	"red_vow_ring": {"name":"Red Vow", "base":"ember_ring", "slot":"ring1", "stats":{"Fire Damage":12.0,"Maximum Life":20.0}, "rules":["Ignites on enemies below 35% Life deal damage faster.","Bleeding you inflict counts as Burning for item bonuses."], "tags":["unique","fire","bleed","execute"], "flavor":"A wedding band for a condemned pyre."},
	"unbroken_chain_ring": {"name":"The Unbroken Chain", "base":"storm_ring", "slot":"ring2", "stats":{"Lightning Damage":11.0,"Chain Bonus":1.0}, "rules":["Every third Lightning hit creates a secondary chain.","Your Lightning hits cannot chain to the original target."], "tags":["unique","lightning","chain"], "flavor":"A circle that refuses to close."},
	"vault_mothers_locket": {"name":"Vault-Mother's Locket", "base":"vault_amulet", "slot":"amulet", "stats":{"Maximum Spirit":8.0,"Item Rarity":18.0}, "rules":["Your enabled Spirit gems each grant 3% Item Rarity.","You lose 5% Maximum Mana per enabled Spirit gem."], "tags":["unique","spirit","loot"], "flavor":"The vault remembers what you loved enough to lock away."},
	"hammer_of_the_last_bell": {"name":"Hammer of the Last Bell", "base":"iron_mace", "slot":"weapon", "stats":{"Attack Damage":26.0,"Stun Power":20.0}, "rules":["Every fifth melee hit triggers Bone Spear.","Triggered Bone Spear deals 40% less damage."], "tags":["unique","melee","physical","trigger"], "flavor":"It rings once. Then the room answers."},
	"splitter_of_oaths": {"name":"Splitter of Oaths", "base":"splitter_axe", "slot":"weapon", "stats":{"Attack Damage":24.0,"Bleed Chance":18.0}, "rules":["Bleeding enemies explode on death for small physical damage.","You cannot inflict Ignite."], "tags":["unique","melee","bleed","physical"], "flavor":"A promise is only useful once broken."},
	"penitent_zero_relic": {"name":"Penitent Zero Relic", "base":"penitent_relic", "slot":"relic", "stats":{"Maximum Life":20.0,"Maximum Spirit":6.0}, "rules":["If a skill has 4+ supports, it costs 8% less Mana.","Your first craft on each Rare item costs no Forge Potential."], "tags":["unique","relic","support","forge"], "flavor":"A relic from a future attempt."},
}

const AFFIXES: Array[Dictionary] = [
	{"id":"life", "name":"Vigorous", "group":"life", "side":"prefix", "domains":["armor","jewelry","relic"], "tags":["life"], "stat":"Maximum Life", "tiers":[[12,20],[21,34],[35,52],[53,76]]},
	{"id":"mana", "name":"Lucid", "group":"mana", "side":"prefix", "domains":["weapon","offhand","armor","jewelry","relic"], "tags":["mana","caster"], "stat":"Maximum Mana", "tiers":[[8,16],[17,28],[29,44],[45,64]]},
	{"id":"armor", "name":"Ironclad", "group":"armor", "side":"prefix", "domains":["armor","offhand"], "tags":["defence","armor"], "stat":"Armor", "tiers":[[12,24],[25,42],[43,70],[71,110]]},
	{"id":"spell_damage", "name":"Arcanist's", "group":"spell_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["spell","caster"], "stat":"Spell Damage", "tiers":[[6,10],[11,18],[19,30],[31,46]]},
	{"id":"attack_damage", "name":"Warlord's", "group":"attack_damage", "side":"prefix", "domains":["weapon","jewelry","relic"], "tags":["attack","physical"], "stat":"Attack Damage", "tiers":[[6,10],[11,18],[19,32],[33,50]]},
	{"id":"fire_damage", "name":"Ember", "group":"fire_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["fire","damage"], "stat":"Fire Damage", "tiers":[[7,12],[13,22],[23,38],[39,58]]},
	{"id":"lightning_damage", "name":"Storm", "group":"lightning_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["lightning","damage"], "stat":"Lightning Damage", "tiers":[[7,12],[13,22],[23,38],[39,58]]},
	{"id":"void_damage", "name":"Void-Touched", "group":"void_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["void","damage"], "stat":"Void Damage", "tiers":[[7,12],[13,22],[23,38],[39,58]]},
	{"id":"projectile_damage", "name":"Splintering", "group":"projectile_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["projectile","skill_tag"], "stat":"Projectile Damage", "tiers":[[6,10],[11,18],[19,30],[31,46]], "rule":"Projectile skills deal increased damage."},
	{"id":"area_damage", "name":"Echoing", "group":"area_damage", "side":"prefix", "domains":["weapon","offhand","jewelry","relic"], "tags":["area","skill_tag"], "stat":"Area Damage", "tiers":[[6,10],[11,18],[19,30],[31,46]], "rule":"Area skills have improved impact."},
	{"id":"gem_fire_level", "name":"Pyromancer's", "group":"fire_skill_level", "side":"prefix", "domains":["weapon","amulet","relic"], "tags":["fire","gem_level"], "stat":"Fire Skill Level", "tiers":[[1,1],[1,1],[2,2],[2,2]], "rule":"+Level to Fire skill gems."},
	{"id":"gem_lightning_level", "name":"Galvanic", "group":"lightning_skill_level", "side":"prefix", "domains":["weapon","amulet","relic"], "tags":["lightning","gem_level"], "stat":"Lightning Skill Level", "tiers":[[1,1],[1,1],[2,2],[2,2]], "rule":"+Level to Lightning skill gems."},
	{"id":"cast_speed", "name":"Quickened", "group":"cast_speed", "side":"suffix", "domains":["weapon","offhand","jewelry","armor"], "tags":["caster","speed"], "stat":"Cast Speed", "tiers":[[3,5],[6,9],[10,14],[15,20]]},
	{"id":"attack_speed", "name":"Merciless", "group":"attack_speed", "side":"suffix", "domains":["weapon","jewelry","armor"], "tags":["attack","speed"], "stat":"Attack Speed", "tiers":[[3,5],[6,9],[10,14],[15,20]]},
	{"id":"movement_speed", "name":"Fleet", "group":"movement_speed", "side":"suffix", "domains":["armor"], "tags":["movement"], "stat":"Movement Speed", "tiers":[[3,5],[6,9],[10,14],[15,20]]},
	{"id":"fire_resistance", "name":"of Ash", "group":"fire_resistance", "side":"suffix", "domains":["armor","jewelry","relic"], "tags":["fire","resistance"], "stat":"Fire Resistance", "tiers":[[6,12],[13,22],[23,35],[36,52]]},
	{"id":"spirit", "name":"Vaultbound", "group":"spirit", "side":"suffix", "domains":["jewelry","relic","offhand"], "tags":["spirit"], "stat":"Maximum Spirit", "tiers":[[2,3],[4,6],[7,10],[11,15]]},
	{"id":"ignite_chance", "name":"of Kindling", "group":"ignite_chance", "side":"suffix", "domains":["weapon","offhand","jewelry","relic"], "tags":["fire","ailment"], "stat":"Ignite Chance", "tiers":[[5,8],[9,14],[15,22],[23,32]]},
	{"id":"shock_chance", "name":"of Conductors", "group":"shock_chance", "side":"suffix", "domains":["weapon","offhand","jewelry","relic"], "tags":["lightning","ailment"], "stat":"Shock Chance", "tiers":[[5,8],[9,14],[15,22],[23,32]]},
	{"id":"chain_bonus", "name":"of Recursion", "group":"chain_bonus", "side":"suffix", "domains":["weapon","offhand","jewelry","relic"], "tags":["lightning","chain"], "stat":"Chain Bonus", "tiers":[[1,1],[1,1],[1,2],[2,2]], "rule":"Lightning skills can gain additional chaining."},
	{"id":"mana_on_ignite", "name":"of Smouldering Thought", "group":"mana_on_ignite", "side":"suffix", "domains":["weapon","jewelry","relic"], "tags":["fire","resource"], "stat":"Mana On Ignite", "tiers":[[1,2],[3,4],[5,7],[8,10]], "rule":"Recover Mana when you ignite enemies."},
	{"id":"support_cost", "name":"Linked", "group":"support_cost", "side":"suffix", "domains":["jewelry","relic","offhand"], "tags":["support","mana"], "stat":"Supported Skill Mana Efficiency", "tiers":[[3,5],[6,9],[10,14],[15,20]], "rule":"Skills with 3+ supports cost less Mana."},
	{"id":"forge_potential", "name":"Unspent", "group":"forge_potential", "side":"suffix", "domains":["weapon","offhand","armor","jewelry","relic"], "tags":["forge"], "stat":"Forge Potential Bonus", "tiers":[[1,1],[1,2],[2,3],[3,4]], "rule":"Drops with more long-term crafting space."},
	{"id":"item_rarity", "name":"Seeker's", "group":"item_rarity", "side":"suffix", "domains":["jewelry","relic"], "tags":["loot"], "stat":"Item Rarity", "tiers":[[6,12],[13,24],[25,40],[41,60]]},
]

static func ensure_itemization_defaults(state: Object) -> void:
	if state == null:
		return
	var materials: Dictionary = Dictionary(state.get("materials"))
	if not bool(materials.get("_item_identity_seeded_030", false)):
		for key: Variant in STARTER_COUNTS.keys():
			materials[str(key)] = int(materials.get(str(key), 0)) + int(STARTER_COUNTS[key])
		materials["_item_identity_seeded_030"] = true
		state.set("materials", materials)
		var rng: RandomNumberGenerator = _rng(state)
		var backpack: Array = Array(state.get("backpack"))
		backpack.append(make_item("ash_wand", 6, "normal", rng))
		backpack.append(make_item("ashwoven_robe", 6, "magic", rng))
		backpack.append(make_item("traveler_boots", 8, "rare", rng))
		backpack.append(add_socket(make_item("guard_shield", 7, "magic", rng)))
		backpack.append(make_unique_item("cinderspite_lantern", 8, rng))
		backpack.append(make_unique_item("vault_mothers_locket", 8, rng))
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
	var labels: Dictionary = {
		"transmutation_orb":"Orb of Transmutation", "augmentation_orb":"Orb of Augmentation", "regal_orb":"Regal Orb", "exalted_orb":"Exalted Orb", "chaos_orb":"Chaos Orb", "annulment_orb":"Orb of Annulment", "alchemy_orb":"Orb of Alchemy",
		"whetstone":"Blacksmith's Whetstone", "armour_scrap":"Armourer's Scrap", "artificer_orb":"Artificer's Orb", "ember_seal_lesser":"Lesser Ember Seal", "storm_seal_lesser":"Lesser Storm Seal", "blood_seal_lesser":"Lesser Blood Seal", "iron_seal_lesser":"Lesser Iron Seal", "fleet_seal_lesser":"Lesser Fleet Seal", "arcanist_seal_lesser":"Lesser Arcanist Seal",
		"ash_rune":"Ash Rune", "storm_rune":"Storm Rune", "blood_rune":"Blood Rune", "iron_rune":"Iron Rune", "vault_rune":"Vault Rune", "seeker_rune":"Seeker Rune", "artificer_shard":"Artificer's Shard", "essence_dust":"Essence Dust", "relic_core":"Relic Core", "echo_glass":"Echo Glass", "shards":"Shards", "embers":"Embers"
	}
	return str(labels.get(id, id.replace("_", " ").capitalize()))

static func is_equipment(item: Dictionary) -> bool:
	var kind: String = str(item.get("kind", item.get("item_kind", "")))
	if kind in ["map", "uncut_skill_gem", "uncut_support_gem", "uncut_spirit_gem", "active_gem", "support_gem", "spirit_gem", "currency", "material"]:
		return false
	return str(item.get("slot", "")) != "" or str(item.get("base_id", "")) != "" or str(item.get("unique_id", "")) != ""

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
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var unique_id: String = str(item.get("unique_id", ""))
	if unique_id != "" and UNIQUE_DATA.has(unique_id):
		return _normalize_unique(item, rng)
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
	item["tags"] = Array(item.get("tags", base.get("tags", [])))
	item["requirements"] = Dictionary(item.get("requirements", base.get("req", {})))
	item["grid_w"] = int(item.get("grid_w", base.get("grid_w", 1)))
	item["grid_h"] = int(item.get("grid_h", base.get("grid_h", 2)))
	item["item_level"] = int(item.get("item_level", item.get("level", 1)))
	item["required_level"] = int(item.get("required_level", maxi(1, int(item.get("item_level", 1)) - 2)))
	item["rarity"] = str(item.get("rarity", "normal"))
	item["identified"] = bool(item.get("identified", true))
	item["quality"] = clampi(int(item.get("quality", 0)), 0, int(item.get("max_quality", 20)))
	item["max_quality"] = int(item.get("max_quality", 20))
	item["forge_potential_max"] = int(item.get("forge_potential_max", 6 + int(item.get("item_level", 1)) / 4))
	item["forge_potential"] = clampi(int(item.get("forge_potential", item.get("forge_potential_max", 6))), 0, int(item.get("forge_potential_max", 6)))
	item["craft_state"] = str(item.get("craft_state", "stable"))
	item["implicit_mods"] = Array(item.get("implicit_mods", _mods_from_stats("Implicit", Dictionary(base.get("implicit", {})))))
	item["explicit_mods"] = Array(item.get("explicit_mods", item.get("affixes", [])))
	item["sockets"] = Array(item.get("sockets", []))
	item["build_rules"] = Array(item.get("build_rules", []))
	if not item.has("uid"):
		item["uid"] = _new_uid("item")
	item = rebuild_totals(item)
	item["display_name"] = str(item.get("display_name", _build_name(item)))
	item["loot_priority"] = loot_priority(item)
	return item

static func _normalize_unique(item: Dictionary, rng: RandomNumberGenerator = null) -> Dictionary:
	var unique_id: String = str(item.get("unique_id", ""))
	var unique_data: Dictionary = Dictionary(UNIQUE_DATA.get(unique_id, {}))
	var base_id: String = str(unique_data.get("base", item.get("base_id", "ash_wand")))
	var base: Dictionary = Dictionary(BASES.get(base_id, BASES["ash_wand"]))
	item["base_id"] = base_id
	item["kind"] = "item"
	item["item_kind"] = "equipment"
	item["category"] = str(base.get("category", "weapon"))
	item["slot"] = str(unique_data.get("slot", base.get("slot", "weapon")))
	item["rarity"] = "unique"
	item["identified"] = true
	item["weapon_type"] = str(base.get("weapon_type", ""))
	item["tags"] = Array(unique_data.get("tags", base.get("tags", [])))
	item["requirements"] = Dictionary(item.get("requirements", base.get("req", {})))
	item["item_level"] = int(item.get("item_level", 8))
	item["required_level"] = int(item.get("required_level", maxi(1, int(item.get("item_level", 1)) - 1)))
	item["quality"] = clampi(int(item.get("quality", 0)), 0, 20)
	item["max_quality"] = 20
	item["forge_potential_max"] = int(item.get("forge_potential_max", 3))
	item["forge_potential"] = clampi(int(item.get("forge_potential", item.get("forge_potential_max", 3))), 0, int(item.get("forge_potential_max", 3)))
	item["craft_state"] = str(item.get("craft_state", "sealed"))
	item["implicit_mods"] = Array(item.get("implicit_mods", _mods_from_stats("Implicit", Dictionary(base.get("implicit", {})))))
	item["explicit_mods"] = Array(item.get("explicit_mods", _mods_from_stats("Unique", Dictionary(unique_data.get("stats", {})))))
	item["sockets"] = Array(item.get("sockets", []))
	item["build_rules"] = Array(unique_data.get("rules", []))
	item["flavor"] = str(unique_data.get("flavor", ""))
	item["display_name"] = str(unique_data.get("name", "Unique Relic"))
	item["grid_w"] = int(item.get("grid_w", base.get("grid_w", 1)))
	item["grid_h"] = int(item.get("grid_h", base.get("grid_h", 2)))
	if not item.has("uid"):
		item["uid"] = _new_uid("unique")
	item = rebuild_totals(item)
	item["loot_priority"] = loot_priority(item)
	return item

static func make_item(base_id: String, item_level: int, rarity: String, rng: RandomNumberGenerator) -> Dictionary:
	var item: Dictionary = {"base_id": base_id, "item_level": item_level, "rarity": rarity, "uid": _new_uid("item"), "identified": true, "explicit_mods": []}
	if rarity == "magic":
		item = add_random_affix(item, rng)
	elif rarity == "rare":
		for i: int in range(rng.randi_range(3, 5)):
			item = add_random_affix(item, rng)
	return normalize_item(item, rng)

static func make_unique_item(unique_id: String, item_level: int, rng: RandomNumberGenerator = null) -> Dictionary:
	return normalize_item({"unique_id": unique_id, "item_level": item_level, "uid": _new_uid("unique")}, rng)

static func random_equipment_drop(item_level: int, rng: RandomNumberGenerator, boss: bool = false) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var unique_chance: float = 0.035 if not boss else 0.18
	if rng.randf() < unique_chance:
		var unique_keys: Array = UNIQUE_DATA.keys()
		return make_unique_item(str(unique_keys[rng.randi_range(0, unique_keys.size() - 1)]), item_level, rng)
	var base_keys: Array = BASES.keys()
	var base_id: String = str(base_keys[rng.randi_range(0, base_keys.size() - 1)])
	var roll: float = rng.randf()
	var rarity: String = "normal"
	if boss or roll > 0.78:
		rarity = "rare"
	elif roll > 0.42:
		rarity = "magic"
	var item: Dictionary = make_item(base_id, item_level, rarity, rng)
	if rarity in ["magic", "rare"] and rng.randf() < 0.55:
		item["identified"] = false
	if boss:
		item["forge_potential"] = int(item.get("forge_potential", 4)) + 2
		item["forge_potential_max"] = int(item.get("forge_potential_max", 6)) + 2
	return normalize_item(item, rng)

static func add_random_affix(item: Dictionary, rng: RandomNumberGenerator, forced_tag: String = "", high_tier: bool = false) -> Dictionary:
	item = normalize_item(item, rng)
	var candidates: Array[Dictionary] = _eligible_affixes(item, forced_tag)
	if candidates.is_empty():
		return item
	var affix: Dictionary = Dictionary(candidates[rng.randi_range(0, candidates.size() - 1)])
	var tiers: Array = Array(affix.get("tiers", []))
	if tiers.is_empty():
		return item
	var tier_index: int = rng.randi_range(0, tiers.size() - 1)
	if high_tier:
		tier_index = rng.randi_range(maxi(0, tiers.size() - 2), tiers.size() - 1)
	var range_values: Array = Array(tiers[tier_index])
	var value: float = float(rng.randi_range(int(range_values[0]), int(range_values[1])))
	var explicit_mods: Array = Array(item.get("explicit_mods", []))
	explicit_mods.append({"id": str(affix.get("id", "affix")), "name": str(affix.get("name", "Modifier")), "group": str(affix.get("group", "")), "side": str(affix.get("side", "prefix")), "tier": tier_index + 1, "stat": str(affix.get("stat", "Power")), "value": value, "stats": {str(affix.get("stat", "Power")): value}, "tags": Array(affix.get("tags", [])), "rule": str(affix.get("rule", ""))})
	item["explicit_mods"] = explicit_mods
	if str(affix.get("group", "")) == "forge_potential":
		item["forge_potential_max"] = int(item.get("forge_potential_max", 6)) + int(value)
		item["forge_potential"] = int(item.get("forge_potential", 0)) + int(value)
	return rebuild_totals(item)

static func _eligible_affixes(item: Dictionary, forced_tag: String = "") -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var category: String = str(item.get("category", "weapon"))
	var used_groups: Array[String] = []
	for mod_value: Variant in Array(item.get("explicit_mods", [])):
		if typeof(mod_value) == TYPE_DICTIONARY:
			used_groups.append(str(Dictionary(mod_value).get("group", "")))
	for affix_value: Dictionary in AFFIXES:
		if used_groups.has(str(affix_value.get("group", ""))):
			continue
		var domains: Array = Array(affix_value.get("domains", []))
		if not domains.has(category) and not domains.has(str(item.get("slot", ""))) and not domains.has(str(item.get("weapon_type", ""))):
			continue
		if forced_tag != "" and not Array(affix_value.get("tags", [])).has(forced_tag):
			continue
		var side: String = str(affix_value.get("side", "prefix"))
		if _count_side(item, side) >= 3:
			continue
		out.append(affix_value)
	return out

static func _count_side(item: Dictionary, side: String) -> int:
	var count: int = 0
	for mod_value: Variant in Array(item.get("explicit_mods", [])):
		if typeof(mod_value) == TYPE_DICTIONARY and str(Dictionary(mod_value).get("side", "prefix")) == side:
			count += 1
	return count

static func remove_random_affix(item: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var explicit_mods: Array = Array(item.get("explicit_mods", []))
	if explicit_mods.is_empty():
		return item
	explicit_mods.remove_at(rng.randi_range(0, explicit_mods.size() - 1))
	item["explicit_mods"] = explicit_mods
	return rebuild_totals(item)

static func add_socket(item: Dictionary) -> Dictionary:
	item = normalize_item(item)
	var sockets: Array = Array(item.get("sockets", []))
	var base: Dictionary = Dictionary(BASES.get(str(item.get("base_id", "ash_wand")), BASES["ash_wand"]))
	var limit: int = int(base.get("socket_limit", 1))
	if sockets.size() < limit:
		sockets.append({"socket_id": sockets.size(), "socket_type":"rune", "socketed_uid":"", "rune_id":""})
	item["sockets"] = sockets
	return rebuild_totals(item)

static func socket_rune(item: Dictionary, rune_id: String) -> Dictionary:
	item = normalize_item(item)
	if not RUNE_DATA.has(rune_id):
		return item
	var sockets: Array = Array(item.get("sockets", []))
	for i: int in range(sockets.size()):
		if typeof(sockets[i]) == TYPE_DICTIONARY:
			var socket: Dictionary = Dictionary(sockets[i])
			if str(socket.get("rune_id", "")) == "":
				socket["rune_id"] = rune_id
				socket["socketed_uid"] = rune_id
				socket["display_name"] = str(Dictionary(RUNE_DATA[rune_id]).get("name", rune_id))
				sockets[i] = socket
				item["sockets"] = sockets
				return rebuild_totals(item)
	return item

static func rebuild_totals(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return item
	var totals: Dictionary = {}
	var base: Dictionary = Dictionary(BASES.get(str(item.get("base_id", "ash_wand")), BASES["ash_wand"]))
	_merge(totals, Dictionary(base.get("stats", {})))
	_merge(totals, Dictionary(base.get("implicit", {})))
	var quality: int = int(item.get("quality", 0))
	if quality > 0:
		if str(item.get("category", "")) == "weapon":
			totals["Attack Damage"] = float(totals.get("Attack Damage", 0.0)) * (1.0 + float(quality) / 100.0)
			totals["Spell Damage"] = float(totals.get("Spell Damage", 0.0)) * (1.0 + float(quality) / 100.0)
		elif str(item.get("category", "")) == "armor" or str(item.get("slot", "")) in ["head","chest","gloves","boots","offhand"]:
			totals["Armor"] = float(totals.get("Armor", 0.0)) * (1.0 + float(quality) / 100.0)
	for mod_value: Variant in Array(item.get("explicit_mods", [])):
		if typeof(mod_value) == TYPE_DICTIONARY:
			_merge(totals, Dictionary(Dictionary(mod_value).get("stats", {})))
	for socket_value: Variant in Array(item.get("sockets", [])):
		if typeof(socket_value) == TYPE_DICTIONARY:
			var rune_id: String = str(Dictionary(socket_value).get("rune_id", ""))
			if RUNE_DATA.has(rune_id):
				_merge(totals, Dictionary(Dictionary(RUNE_DATA[rune_id]).get("stats", {})))
	item["total_stats"] = totals
	item["item_power"] = _power_from_stats(totals) + int(item.get("item_level", 1))
	item["build_rules"] = _collect_rules(item)
	item["loot_priority"] = loot_priority(item)
	return item

static func _collect_rules(item: Dictionary) -> Array:
	var out: Array = Array(item.get("build_rules", []))
	for mod_value: Variant in Array(item.get("explicit_mods", [])):
		if typeof(mod_value) == TYPE_DICTIONARY:
			var rule: String = str(Dictionary(mod_value).get("rule", ""))
			if rule != "" and not out.has(rule):
				out.append(rule)
	return out

static func appraise_item(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return item
	item["identified"] = true
	item["new_item"] = false
	return normalize_item(item)

static func item_detail_text(item: Dictionary) -> String:
	if item.is_empty():
		return "No item selected."
	item = normalize_item(item)
	var lines: PackedStringArray = PackedStringArray()
	var rarity: String = str(item.get("rarity", "normal"))
	lines.append("[font_size=17][color=" + rarity_color(rarity) + "][b]" + str(item.get("display_name", "Item")) + "[/b][/color][/font_size]")
	lines.append(rarity.capitalize() + " · " + str(item.get("slot", "")) + " · Item Level " + str(int(item.get("item_level", 1))) + " · Power " + str(int(item.get("item_power", 0))))
	if not bool(item.get("identified", true)):
		lines.append("[color=#d65a32]Unappraised. Affixes hidden. Use Appraise before serious crafting.[/color]")
		lines.append("Forge Potential " + str(int(item.get("forge_potential", 0))) + "/" + str(int(item.get("forge_potential_max", 0))))
		return "\n".join(lines)
	lines.append("Quality +" + str(int(item.get("quality", 0))) + "% · Forge Potential " + str(int(item.get("forge_potential", 0))) + "/" + str(int(item.get("forge_potential_max", 0))) + " · " + str(item.get("craft_state", "stable")).capitalize())
	lines.append("[color=#8f8777]Requirements[/color] " + _requirements_text(Dictionary(item.get("requirements", {})), int(item.get("required_level", 1))))
	_append_mod_lines(lines, "Implicit", Array(item.get("implicit_mods", [])), "#8f8777")
	_append_mod_lines(lines, "Prefixes / Suffixes", Array(item.get("explicit_mods", [])), "#d8d0be")
	_append_socket_lines(lines, Array(item.get("sockets", [])))
	_append_rule_lines(lines, Array(item.get("build_rules", [])))
	if str(item.get("flavor", "")) != "":
		lines.append("[color=#8f8777][i]" + str(item.get("flavor", "")) + "[/i][/color]")
	lines.append("[color=#8f8777]Loot Filter[/color] " + loot_label(item))
	return "\n".join(lines)

static func compare_items_text(candidate: Dictionary, equipped: Dictionary) -> String:
	if candidate.is_empty():
		return ""
	candidate = normalize_item(candidate)
	equipped = normalize_item(equipped)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("\n[color=#c59b4a][b]COMPARISON[/b][/color]")
	if equipped.is_empty():
		lines.append("No equipped item in this slot.")
		return "\n".join(lines)
	var groups: Dictionary = {"Offense":["Fire Damage","Lightning Damage","Void Damage","Spell Damage","Attack Damage","Projectile Damage","Area Damage","Cast Speed","Attack Speed","Ignite Chance","Shock Chance","Chain Bonus"], "Defense":["Maximum Life","Armor","Block Chance","Fire Resistance"], "Resources":["Maximum Mana","Maximum Spirit","Mana Regeneration","Supported Skill Mana Efficiency"], "Loot / Forge":["Item Rarity","Forge Potential Bonus"]}
	var candidate_stats: Dictionary = Dictionary(candidate.get("total_stats", {}))
	var equipped_stats: Dictionary = Dictionary(equipped.get("total_stats", {}))
	for group_name: Variant in groups.keys():
		var group_lines: PackedStringArray = PackedStringArray()
		for stat_value: Variant in Array(groups[group_name]):
			var stat: String = str(stat_value)
			var delta: float = float(candidate_stats.get(stat, 0.0)) - float(equipped_stats.get(stat, 0.0))
			if absf(delta) >= 0.01:
				var sign: String = "+" if delta > 0.0 else ""
				var color: String = "#69a84f" if delta > 0.0 else "#d65a32"
				group_lines.append("  [color=" + color + "]" + sign + str(snappedf(delta, 0.1)) + " " + stat + "[/color]")
		if not group_lines.is_empty():
			lines.append("[color=#8f8777]" + str(group_name) + "[/color]")
			for line: String in group_lines:
				lines.append(line)
	lines.append("[color=#8f8777]Forge Potential[/color] " + str(int(equipped.get("forge_potential", 0))) + " → " + str(int(candidate.get("forge_potential", 0))))
	lines.append(build_relevance_text(candidate))
	return "\n".join(lines)

static func build_relevance_text(item: Dictionary) -> String:
	if item.is_empty():
		return ""
	item = normalize_item(item)
	var tags: Array = Array(item.get("tags", []))
	var stats: Dictionary = Dictionary(item.get("total_stats", {}))
	var lines: PackedStringArray = PackedStringArray()
	lines.append("[color=#c59b4a]Build Relevance[/color]")
	if tags.has("fire") or stats.has("Fire Damage") or stats.has("Ignite Chance"):
		lines.append("• Fireball / Ember builds: relevant")
	if tags.has("lightning") or stats.has("Lightning Damage") or stats.has("Chain Bonus") or stats.has("Shock Chance"):
		lines.append("• Storm Lance / chain builds: relevant")
	if tags.has("void") or stats.has("Void Damage") or stats.has("Area Damage"):
		lines.append("• Void Rift / area builds: relevant")
	if tags.has("melee") or stats.has("Attack Damage") or stats.has("Bleed Chance"):
		lines.append("• Melee / bleed builds: relevant")
	if stats.has("Maximum Spirit") or tags.has("spirit"):
		lines.append("• Spirit reservation builds: relevant")
	if lines.size() <= 1:
		lines.append("• Generic value only. No strong build hook.")
	return "\n".join(lines)

static func loot_priority(item: Dictionary) -> int:
	if item.is_empty():
		return 0
	var rarity: String = str(item.get("rarity", "normal"))
	if rarity == "unique":
		return 100
	if int(item.get("forge_potential", 0)) >= 9:
		return 75
	if rarity == "rare":
		return 60
	if Array(item.get("sockets", [])).size() > 0:
		return 45
	if rarity == "magic":
		return 30
	return 10

static func loot_label(item: Dictionary) -> String:
	var priority: int = loot_priority(item)
	if priority >= 100:
		return "UNIQUE RELIC · gold beam"
	if priority >= 75:
		return "HIGH POTENTIAL · blue-gold beam"
	if priority >= 60:
		return "RARE · yellow label"
	if priority >= 45:
		return "SOCKETED · cyan marker"
	if priority >= 30:
		return "MAGIC · blue label"
	return "normal"

static func rarity_color(rarity: String) -> String:
	match rarity:
		"unique": return "#d89032"
		"rare": return "#d6b44c"
		"magic": return "#5e8cff"
		_: return "#d8d0be"

static func _append_mod_lines(lines: PackedStringArray, title: String, mods: Array, color: String) -> void:
	if mods.is_empty():
		return
	lines.append("[color=#8f8777]" + title + "[/color]")
	for mod_value: Variant in mods:
		if typeof(mod_value) != TYPE_DICTIONARY:
			continue
		var mod: Dictionary = Dictionary(mod_value)
		var stat: String = str(mod.get("stat", mod.get("name", "Modifier")))
		var value: float = float(mod.get("value", 0.0))
		var tier: String = " T" + str(int(mod.get("tier", 0))) if int(mod.get("tier", 0)) > 0 else ""
		var side: String = str(mod.get("side", ""))
		var prefix: String = (side.capitalize() + " · ") if side != "" else ""
		lines.append("• [color=" + color + "]" + prefix + "+" + str(snappedf(value, 0.1)) + " " + stat + tier + "[/color]")
		var rule: String = str(mod.get("rule", ""))
		if rule != "":
			lines.append("  [color=#8f8777]" + rule + "[/color]")

static func _append_socket_lines(lines: PackedStringArray, sockets: Array) -> void:
	if sockets.is_empty():
		lines.append("[color=#8f8777]Sockets[/color] none")
		return
	lines.append("[color=#8f8777]Sockets[/color]")
	for socket_value: Variant in sockets:
		if typeof(socket_value) != TYPE_DICTIONARY:
			continue
		var socket: Dictionary = Dictionary(socket_value)
		var rune_id: String = str(socket.get("rune_id", ""))
		if rune_id != "" and RUNE_DATA.has(rune_id):
			lines.append("• " + str(Dictionary(RUNE_DATA[rune_id]).get("name", rune_id)) + " — " + str(Dictionary(RUNE_DATA[rune_id]).get("text", "")))
		else:
			lines.append("• Empty Rune Socket")

static func _append_rule_lines(lines: PackedStringArray, rules: Array) -> void:
	if rules.is_empty():
		return
	lines.append("[color=#c59b4a]Build Rules[/color]")
	for rule_value: Variant in rules:
		lines.append("• " + str(rule_value))

static func _requirements_text(req: Dictionary, required_level: int) -> String:
	var parts: PackedStringArray = PackedStringArray()
	parts.append("Level " + str(required_level))
	for key: Variant in req.keys():
		var amount: int = int(req[key])
		if amount > 0:
			parts.append(str(key).capitalize() + " " + str(amount))
	return ", ".join(parts)

static func _guess_base_from_slot(slot: String) -> String:
	match slot:
		"weapon": return "ash_wand"
		"offhand": return "guard_shield"
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
	for key: Variant in stats.keys():
		out.append({"id": prefix.to_lower() + "_" + str(key).to_snake_case(), "name": prefix, "stat": str(key), "value": float(stats[key]), "stats": {str(key): float(stats[key])}, "side":"implicit"})
	return out

static func _merge(target: Dictionary, stats: Dictionary) -> void:
	for key: Variant in stats.keys():
		target[str(key)] = float(target.get(str(key), 0.0)) + float(stats[key])

static func _power_from_stats(stats: Dictionary) -> int:
	var total: float = 0.0
	for key: Variant in stats.keys():
		total += absf(float(stats[key]))
	return int(round(total))

static func _build_name(item: Dictionary) -> String:
	var base: Dictionary = Dictionary(BASES.get(str(item.get("base_id", "ash_wand")), BASES["ash_wand"]))
	var rarity: String = str(item.get("rarity", "normal"))
	if rarity == "rare":
		return "Vaultforged " + str(base.get("name", "Item"))
	if rarity == "magic":
		return "Altered " + str(base.get("name", "Item"))
	return str(base.get("name", "Item"))

static func _new_uid(prefix: String) -> String:
	return prefix + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 100000)
