class_name RVGemDB3D
extends RefCounted

static func active_gems() -> Dictionary:
	return {
		"fireball": {
			"name":"Fireball", "tags":["spell","fire","projectile"], "base_damage":28.0, "mana_cost":12.0, "cooldown":0.22,
			"description":"Launches a fire projectile that can be supported by spell, fire, and projectile supports."
		},
		"storm_lance": {
			"name":"Storm Lance", "tags":["spell","lightning","projectile","line"], "base_damage":22.0, "mana_cost":14.0, "cooldown":0.18,
			"description":"Fires a fast lightning lance. Supports can add chain, pierce, or shock behavior."
		},
		"arc_slash": {
			"name":"Arc Slash", "tags":["attack","melee","physical","area"], "base_damage":34.0, "mana_cost":8.0, "cooldown":0.28,
			"description":"A short-range cleaving attack. Supports can add bleed, area, or tempo."
		},
		"void_rift": {
			"name":"Void Rift", "tags":["spell","void","area"], "base_damage":38.0, "mana_cost":18.0, "cooldown":0.75,
			"description":"Opens a rift at target point, damaging enemies in an area."
		},
		"ember_mine": {
			"name":"Ember Mine", "tags":["trap","fire","area"], "base_damage":42.0, "mana_cost":16.0, "cooldown":0.85,
			"description":"Drops a delayed ember mine that explodes near enemies."
		},
	}

static func support_gems() -> Dictionary:
	return {
		"controlled_power": {"name":"Controlled Power", "tags":["spell","attack","projectile","area","melee","fire","lightning","void"], "damage_more":0.22, "cost_more":0.18, "description":"More damage, higher mana cost."},
		"efficient_casting": {"name":"Efficient Casting", "tags":["spell","trap"], "damage_more":-0.08, "cost_more":-0.25, "description":"Lower mana cost, slightly less damage."},
		"greater_area": {"name":"Greater Area", "tags":["area","melee","trap"], "area_more":0.35, "damage_more":-0.10, "description":"Bigger area, slightly less damage."},
		"split_projectile": {"name":"Split Projectile", "tags":["projectile"], "extra_projectiles":2, "damage_more":-0.18, "description":"Projectile skills fire extra split shots."},
		"chain_current": {"name":"Chain Current", "tags":["lightning","projectile"], "chain_count":1, "shock_chance":0.18, "cost_more":0.12, "description":"Lightning/projectile skills can chain and shock."},
		"ignition": {"name":"Ignition", "tags":["fire"], "ignite_chance":0.45, "description":"Fire skills have a strong ignite chance."},
		"bleed_edge": {"name":"Bleed Edge", "tags":["melee","attack","physical"], "bleed_chance":0.55, "description":"Melee/attack skills can bleed."},
		"echoing_void": {"name":"Echoing Void", "tags":["void"], "echo_count":1, "cost_more":0.20, "description":"Void skills echo once at reduced damage."},
	}

static func spirit_gems() -> Dictionary:
	return {
		"clarity": {"name":"Clarity", "reservation":10, "stats":{"mana_regeneration":0.35}, "rules":[], "description":"Reserves Spirit. Improves mana regeneration."},
		"vitality": {"name":"Vitality", "reservation":15, "stats":{"maximum_life":22.0}, "rules":["life_regen_minor"], "description":"Reserves Spirit. Grants life and minor recovery."},
		"ember_pact": {"name":"Ember Pact", "reservation":20, "stats":{"fire_damage":0.10}, "rules":["spirit_fire_ignite"], "description":"Fire skills gain ignite pressure."},
		"storm_rhythm": {"name":"Storm Rhythm", "reservation":20, "stats":{"lightning_damage":0.10}, "rules":["spirit_lightning_shock"], "description":"Lightning skills gain shock pressure."},
		"void_tithe": {"name":"Void Tithe", "reservation":25, "stats":{"void_damage":0.16}, "rules":["spirit_void_cost_pressure"], "description":"Void skills hit harder but pressure resources."},
		"iron_skin": {"name":"Iron Skin", "reservation":15, "stats":{"armor":28.0}, "rules":[], "description":"Reserves Spirit. Grants armor."},
	}

static func active_data(id: String) -> Dictionary:
	return Dictionary(active_gems().get(id, {})).duplicate(true)

static func support_data(id: String) -> Dictionary:
	return Dictionary(support_gems().get(id, {})).duplicate(true)

static func spirit_data(id: String) -> Dictionary:
	return Dictionary(spirit_gems().get(id, {})).duplicate(true)

static func make_active_gem(uid: String, gem_id: String, level: int = 1) -> Dictionary:
	var data: Dictionary = active_data(gem_id)
	return {"uid":uid, "kind":"active", "gem_id":gem_id, "name":str(data.get("name", gem_id)), "level":level, "xp":0.0, "tags":Array(data.get("tags", [])).duplicate(true)}

static func make_support_gem(uid: String, gem_id: String, level: int = 1) -> Dictionary:
	var data: Dictionary = support_data(gem_id)
	return {"uid":uid, "kind":"support", "gem_id":gem_id, "name":str(data.get("name", gem_id)), "level":level, "xp":0.0, "tags":Array(data.get("tags", [])).duplicate(true)}

static func make_spirit_gem(uid: String, gem_id: String, level: int = 1) -> Dictionary:
	var data: Dictionary = spirit_data(gem_id)
	return {"uid":uid, "kind":"spirit", "gem_id":gem_id, "name":str(data.get("name", gem_id)), "level":level, "xp":0.0, "enabled":false, "reservation":int(data.get("reservation", 0))}

static func can_support(active_gem_id: String, support_gem_id: String) -> bool:
	var active: Dictionary = active_data(active_gem_id)
	var support: Dictionary = support_data(support_gem_id)
	if active.is_empty() or support.is_empty():
		return false
	var active_tags: Array = Array(active.get("tags", []))
	for tag_value: Variant in Array(support.get("tags", [])):
		if active_tags.has(str(tag_value)):
			return true
	return false

static func gem_detail(kind: String, gem_id: String) -> String:
	var data: Dictionary = {}
	match kind:
		"active": data = active_data(gem_id)
		"support": data = support_data(gem_id)
		"spirit": data = spirit_data(gem_id)
	if data.is_empty():
		return "Unknown gem."
	var text: String = str(data.get("name", gem_id)) + "\n"
	text += str(kind).capitalize() + " Gem\n"
	text += str(data.get("description", "")) + "\n"
	if data.has("tags"):
		text += "Tags: " + ", ".join(PackedStringArray(_string_array(Array(data.get("tags", []))))) + "\n"
	if data.has("reservation"):
		text += "Reservation: " + str(int(data.get("reservation", 0))) + " Spirit\n"
	return text

static func _string_array(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value: Variant in values:
		out.append(str(value))
	return out
