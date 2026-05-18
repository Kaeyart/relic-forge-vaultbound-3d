class_name RVGemDB3D
extends RefCounted

static func active_gems() -> Dictionary:
	return {
		"fireball":{"name":"Fireball", "tags":["active","spell","fire","projectile"], "mana_cost":14.0, "damage":28.0, "description":"Launches a fire projectile."},
		"storm_lance":{"name":"Storm Lance", "tags":["active","spell","lightning","line"], "mana_cost":18.0, "damage":25.0, "description":"Strikes enemies in a lightning line."},
		"arc_slash":{"name":"Arc Slash", "tags":["active","attack","melee","physical"], "mana_cost":10.0, "damage":31.0, "description":"Sweeps enemies in front of you."},
		"void_rift":{"name":"Void Rift", "tags":["active","spell","void","area"], "mana_cost":24.0, "damage":34.0, "description":"Opens a damaging void rift."},
		"ember_mine":{"name":"Ember Mine", "tags":["active","trap","fire","area"], "mana_cost":20.0, "damage":38.0, "description":"Places an explosive ember charge."}
	}

static func support_gems() -> Dictionary:
	return {
		"controlled_power":{"name":"Controlled Power", "tags":["support","spell","attack","trap"], "damage_mult":1.24, "cost_mult":1.18, "description":"More damage, higher cost."},
		"efficient_casting":{"name":"Efficient Casting", "tags":["support","spell","trap"], "damage_mult":0.92, "cost_mult":0.72, "description":"Lower cost, slightly less damage."},
		"greater_area":{"name":"Greater Area", "tags":["support","area","melee","trap"], "area_mult":1.35, "damage_mult":0.90, "description":"Larger area, less damage."},
		"split_projectile":{"name":"Split Projectile", "tags":["support","projectile"], "extra_projectiles":2, "damage_mult":0.82, "description":"Adds extra projectiles."},
		"chain_current":{"name":"Chain Current", "tags":["support","lightning","projectile","line"], "chain":1, "damage_mult":0.92, "description":"Lightning/projectile effects chain."},
		"ignition":{"name":"Ignition", "tags":["support","fire"], "rules":["ignite"], "damage_mult":1.05, "description":"Fire skills ignite."},
		"bleed_edge":{"name":"Bleed Edge", "tags":["support","melee","attack"], "rules":["bleed"], "damage_mult":1.10, "description":"Melee attacks bleed."},
		"echoing_void":{"name":"Echoing Void", "tags":["support","void"], "echo_count":1, "cost_mult":1.16, "description":"Void skills echo."}
	}

static func spirit_gems() -> Dictionary:
	return {
		"clarity":{"name":"Clarity", "reservation":10, "stats":{"Mana Regen":0.30,"Maximum Mana":16.0}, "rules":[], "description":"Reserves Spirit. Improves mana sustain."},
		"vitality":{"name":"Vitality", "reservation":12, "stats":{"Life Regen":0.35,"Maximum Life":18.0}, "rules":[], "description":"Reserves Spirit. Improves life sustain."},
		"ember_pact":{"name":"Ember Pact", "reservation":18, "stats":{"Fire Damage":0.12}, "rules":["spirit_fire_ignite"], "description":"Fire skills gain ignite pressure."},
		"storm_rhythm":{"name":"Storm Rhythm", "reservation":18, "stats":{"Lightning Damage":0.12,"Cast Speed":0.04}, "rules":["spirit_shock"], "description":"Lightning skills become faster and sharper."},
		"void_tithe":{"name":"Void Tithe", "reservation":22, "stats":{"Void Damage":0.16}, "rules":["void_tithe"], "description":"Void skills hit harder."},
		"iron_skin":{"name":"Iron Skin", "reservation":15, "stats":{"Armor":36.0}, "rules":[], "description":"Reserves Spirit. Adds armor."}
	}

static func active(id: String) -> Dictionary:
	return Dictionary(active_gems().get(id, {})).duplicate(true)

static func support(id: String) -> Dictionary:
	return Dictionary(support_gems().get(id, {})).duplicate(true)

static func spirit(id: String) -> Dictionary:
	return Dictionary(spirit_gems().get(id, {})).duplicate(true)

static func support_compatible(active_id: String, support_id: String) -> bool:
	var active_tags: Array = Array(active(active_id).get("tags", []))
	var support_tags: Array = Array(support(support_id).get("tags", []))
	for tag_value: Variant in support_tags:
		var tag: String = str(tag_value)
		if tag == "support": continue
		if active_tags.has(tag): return true
	return false
