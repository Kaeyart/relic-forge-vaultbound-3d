class_name RVSkillGemSystem3D
extends RefCounted

# Patch 03: Skill Gem + Support Gem overhaul.
# This is intentionally data-driven and compatible with the existing GameRoot calls.
# It borrows the ARPG structure of active gems + support sockets + reservation gems,
# but uses original IDs/names/effects for Relic Forge: Vaultbound.

const GEM_ACTIVE := "active"
const GEM_SUPPORT := "support"
const GEM_SPIRIT := "spirit"

const MAX_ACTIVE_SLOTS := 4
const STARTING_SUPPORT_SOCKETS := 2
const MAX_SUPPORT_SOCKETS := 5
const SOCKET_INTERVAL := 4

const DEFAULT_ACTIVE_IDS := ["fireball", "storm_lance", "arc_slash", "void_rift"]
const ACTIVE_ORDER := [
	"fireball",
	"storm_lance",
	"chain_spark",
	"arc_slash",
	"blood_cleave",
	"void_rift",
	"ember_mine",
	"bone_spear",
	"ash_nova",
	"shield_burst",
	"infernal_step",
	"furnace_totem"
]
const SUPPORT_ORDER := [
	"controlled_power",
	"efficient_casting",
	"swift_casting",
	"rapid_strikes",
	"greater_area",
	"focused_area",
	"split_projectile",
	"volley_matrix",
	"piercing_force",
	"chain_current",
	"returning_orbit",
	"ignition",
	"searing_burst",
	"shock_charge",
	"bleed_edge",
	"executioner",
	"echoing_ritual",
	"blood_price",
	"minefield",
	"remote_detonator",
	"totem_fortify",
	"cooldown_focus",
	"mana_leech",
	"life_leech"
]
const SPIRIT_ORDER := [
	"clarity",
	"vitality",
	"iron_skin",
	"ember_pact",
	"storm_rhythm",
	"void_tithe",
	"revenant_guard",
	"execution_focus"
]

const ACTIVE_DATA := {
	"fireball": {
		"name": "Fireball", "color": "red", "tags": ["skill", "spell", "projectile", "fire"],
		"description": "Launch a fire projectile that can ignite and explode through supports.",
		"damage": 32.0, "mana": 10.0, "cooldown": 0.18, "range": 11.0, "radius": 0.42, "projectile_speed": 14.0
	},
	"storm_lance": {
		"name": "Storm Lance", "color": "blue", "tags": ["skill", "spell", "projectile", "lightning", "beam"],
		"description": "Fire a straight lightning lance with high range and strong chain scaling.",
		"damage": 28.0, "mana": 12.0, "cooldown": 0.22, "range": 10.5, "radius": 0.34, "projectile_speed": 19.0
	},
	"chain_spark": {
		"name": "Chain Spark", "color": "blue", "tags": ["skill", "spell", "projectile", "lightning", "chain"],
		"description": "Release an unstable spark that jumps between nearby enemies.",
		"damage": 20.0, "mana": 11.0, "cooldown": 0.24, "range": 8.0, "radius": 0.36, "projectile_speed": 12.0, "chain": 2
	},
	"arc_slash": {
		"name": "Arc Slash", "color": "red", "tags": ["skill", "attack", "melee", "physical"],
		"description": "A quick frontal weapon arc. Strong with bleed, execution, and attack supports.",
		"damage": 38.0, "mana": 8.0, "cooldown": 0.20, "range": 2.8, "area": 1.0
	},
	"blood_cleave": {
		"name": "Blood Cleave", "color": "red", "tags": ["skill", "attack", "melee", "physical", "blood", "area"],
		"description": "A heavy sweeping attack that wants bleed and life-cost supports.",
		"damage": 52.0, "mana": 13.0, "cooldown": 0.36, "range": 3.2, "area": 1.15
	},
	"void_rift": {
		"name": "Void Rift", "color": "blue", "tags": ["skill", "spell", "area", "void", "duration"],
		"description": "Open a void rupture at the cursor. Excellent with area, echo, and control supports.",
		"damage": 44.0, "mana": 16.0, "cooldown": 0.42, "range": 8.0, "area": 2.15
	},
	"ember_mine": {
		"name": "Ember Mine", "color": "red", "tags": ["skill", "spell", "mine", "fire", "area"],
		"description": "Throw a mine that detonates in a fiery burst. Mine supports change its rhythm.",
		"damage": 58.0, "mana": 15.0, "cooldown": 0.50, "range": 6.5, "area": 1.8
	},
	"bone_spear": {
		"name": "Bone Spear", "color": "green", "tags": ["skill", "spell", "projectile", "physical", "pierce"],
		"description": "Fire a piercing physical spear. Scales well with pierce, volley, and bleed.",
		"damage": 34.0, "mana": 10.0, "cooldown": 0.22, "range": 12.0, "radius": 0.32, "projectile_speed": 17.0, "pierce": 1
	},
	"ash_nova": {
		"name": "Ash Nova", "color": "red", "tags": ["skill", "spell", "area", "fire", "nova"],
		"description": "A close-range fire nova. Safe only if you build around area and recovery.",
		"damage": 46.0, "mana": 14.0, "cooldown": 0.34, "range": 0.0, "area": 2.7
	},
	"shield_burst": {
		"name": "Shield Burst", "color": "green", "tags": ["skill", "attack", "melee", "area", "guard"],
		"description": "Explode defensive force in a short cone. Works with guard and execution supports.",
		"damage": 42.0, "mana": 12.0, "cooldown": 0.38, "range": 2.6, "area": 1.2
	},
	"infernal_step": {
		"name": "Infernal Step", "color": "red", "tags": ["skill", "attack", "movement", "fire", "area"],
		"description": "Dash pressure fantasy: burns a path and strikes at the endpoint.",
		"damage": 40.0, "mana": 13.0, "cooldown": 0.65, "range": 4.5, "area": 1.55
	},
	"furnace_totem": {
		"name": "Furnace Totem", "color": "red", "tags": ["skill", "spell", "totem", "fire", "area", "duration"],
		"description": "Place a furnace focus that pulses fire damage. Prototype uses instant pulses for now.",
		"damage": 25.0, "mana": 18.0, "cooldown": 0.85, "range": 6.0, "area": 1.75, "pulses": 3
	}
}

const SUPPORT_DATA := {
	"controlled_power": {"name": "Controlled Power", "color": "red", "requires_any": ["skill"], "description": "More damage, higher cost.", "damage_more": 0.30, "mana_more": 0.22},
	"efficient_casting": {"name": "Efficient Casting", "color": "blue", "requires_any": ["spell", "skill"], "description": "Lower cost, slightly lower damage.", "damage_more": -0.06, "mana_more": -0.28},
	"swift_casting": {"name": "Swift Casting", "color": "blue", "requires_any": ["spell"], "description": "Faster spell rhythm.", "cooldown_more": -0.18, "mana_more": 0.10},
	"rapid_strikes": {"name": "Rapid Strikes", "color": "green", "requires_any": ["attack"], "description": "Faster attacks with slightly less damage.", "damage_more": -0.08, "cooldown_more": -0.22},
	"greater_area": {"name": "Greater Area", "color": "red", "requires_any": ["area", "nova"], "description": "Larger area, lower direct damage.", "area_more": 0.45, "damage_more": -0.12, "mana_more": 0.15},
	"focused_area": {"name": "Focused Area", "color": "blue", "requires_any": ["area", "nova"], "description": "Smaller area, much harder hits.", "area_more": -0.28, "damage_more": 0.42},
	"split_projectile": {"name": "Split Projectile", "color": "green", "requires_any": ["projectile"], "description": "Adds two extra projectiles with spread.", "extra_projectiles": 2, "spread": 0.24, "damage_more": -0.12, "mana_more": 0.18},
	"volley_matrix": {"name": "Volley Matrix", "color": "green", "requires_any": ["projectile"], "description": "Adds four projectiles, but each hit is weaker.", "extra_projectiles": 4, "spread": 0.34, "damage_more": -0.30, "mana_more": 0.32},
	"piercing_force": {"name": "Piercing Force", "color": "green", "requires_any": ["projectile"], "description": "Projectiles pierce additional enemies.", "pierce": 2, "damage_more": 0.04},
	"chain_current": {"name": "Chain Current", "color": "blue", "requires_any": ["projectile", "lightning"], "description": "Hits jump to nearby enemies.", "chain": 2, "damage_more": -0.08, "mana_more": 0.24},
	"returning_orbit": {"name": "Returning Orbit", "color": "green", "requires_any": ["projectile"], "description": "Projectile skills get a second delayed hit in this prototype.", "echo_count": 1, "damage_more": -0.16, "mana_more": 0.18},
	"ignition": {"name": "Ignition", "color": "red", "requires_any": ["fire"], "description": "Fire hits can ignite.", "ignite_chance": 0.55, "damage_more": 0.08},
	"searing_burst": {"name": "Searing Burst", "color": "red", "requires_any": ["fire"], "description": "Fire kills and heavy hits reward area burst damage.", "on_hit_burst": 1, "area_more": 0.15, "damage_more": 0.12, "mana_more": 0.14},
	"shock_charge": {"name": "Shock Charge", "color": "blue", "requires_any": ["lightning"], "description": "Lightning hits can shock and deal more chain damage.", "shock_chance": 0.50, "chain": 1, "damage_more": 0.06},
	"bleed_edge": {"name": "Bleed Edge", "color": "red", "requires_any": ["attack", "physical"], "description": "Physical and attack hits can bleed.", "bleed_chance": 0.45, "damage_more": 0.10},
	"executioner": {"name": "Executioner", "color": "green", "requires_any": ["skill"], "description": "Much stronger against low-health enemies.", "execute_more": 0.55},
	"echoing_ritual": {"name": "Echoing Ritual", "color": "blue", "requires_any": ["spell"], "description": "Spell repeats once after the first hit in this prototype.", "echo_count": 1, "damage_more": -0.08, "mana_more": 0.22},
	"blood_price": {"name": "Blood Price", "color": "red", "requires_any": ["skill"], "description": "Part of the cost is paid with life instead of mana. More damage.", "blood_price": 0.55, "damage_more": 0.22, "mana_more": -0.45},
	"minefield": {"name": "Minefield", "color": "green", "requires_any": ["mine"], "description": "Throws extra mines with less damage each.", "extra_mines": 2, "damage_more": -0.22, "mana_more": 0.35},
	"remote_detonator": {"name": "Remote Detonator", "color": "blue", "requires_any": ["mine"], "description": "Mine skills repeat their burst in this prototype.", "echo_count": 1, "damage_more": 0.08},
	"totem_fortify": {"name": "Totem Fortify", "color": "green", "requires_any": ["totem"], "description": "Totem skills pulse longer and grant defensive flavor.", "extra_pulses": 2, "area_more": 0.12},
	"cooldown_focus": {"name": "Cooldown Focus", "color": "blue", "requires_any": ["skill"], "description": "Reduces cooldown but raises cost.", "cooldown_more": -0.20, "mana_more": 0.18},
	"mana_leech": {"name": "Mana Leech", "color": "blue", "requires_any": ["skill"], "description": "Hits recover some mana.", "mana_leech": 0.04, "damage_more": -0.04},
	"life_leech": {"name": "Life Leech", "color": "red", "requires_any": ["attack", "physical"], "description": "Hits recover some life.", "life_leech": 0.035, "damage_more": -0.04}
}

const SPIRIT_DATA := {
	"clarity": {"name": "Clarity", "color": "blue", "reservation": 20, "description": "Reserves spirit for mana sustain.", "stats": {"mana_regen": 3, "max_mana": 10}},
	"vitality": {"name": "Vitality", "color": "red", "reservation": 25, "description": "Reserves spirit for life sustain.", "stats": {"health_regen": 2, "max_health": 18}},
	"iron_skin": {"name": "Iron Skin", "color": "green", "reservation": 25, "description": "Reserves spirit for armor.", "stats": {"armor": 18}},
	"ember_pact": {"name": "Ember Pact", "color": "red", "reservation": 30, "description": "Fire skills hit harder and ignite more often.", "stats": {"fire_damage": 18, "ignite_chance": 10}},
	"storm_rhythm": {"name": "Storm Rhythm", "color": "blue", "reservation": 30, "description": "Lightning skills gain chain pressure.", "stats": {"lightning_damage": 15, "chain_bonus": 1}},
	"void_tithe": {"name": "Void Tithe", "color": "blue", "reservation": 35, "description": "Void skills gain damage at a resource cost.", "stats": {"void_damage": 22, "mana_cost": 8}},
	"revenant_guard": {"name": "Revenant Guard", "color": "green", "reservation": 35, "description": "Defensive spirit for rough maps.", "stats": {"block_chance": 8, "armor": 14}},
	"execution_focus": {"name": "Execution Focus", "color": "green", "reservation": 25, "description": "More damage against injured enemies.", "stats": {"execute_more": 18}}
}

static func ensure_defaults(state: Object) -> void:
	if state == null:
		return
	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	while slots.size() < MAX_ACTIVE_SLOTS:
		var default_id: String = str(DEFAULT_ACTIVE_IDS[slots.size() % DEFAULT_ACTIVE_IDS.size()])
		slots.append(active_instance(default_id))
	for i in range(slots.size()):
		if typeof(slots[i]) == TYPE_DICTIONARY:
			slots[i] = normalize_active(Dictionary(slots[i]))
		else:
			slots[i] = active_instance(str(DEFAULT_ACTIVE_IDS[i % DEFAULT_ACTIVE_IDS.size()]))
	state.set("active_skill_slots", slots)
	state.set("selected_skill_slot", clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, max(0, slots.size() - 1)))
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for j in range(spirits.size()):
		if typeof(spirits[j]) == TYPE_DICTIONARY:
			spirits[j] = normalize_spirit(Dictionary(spirits[j]))
	state.set("spirit_gem_slots", spirits)
	if _state_get(state, "spirit_max", null) == null:
		state.set("spirit_max", 100)
	recompute_spirit_reservation(state)

static func ensure_starter_gem_items(state: Object) -> void:
	if state == null:
		return
	if bool(_state_get(state, "gem_progression_seeded", false)):
		return
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	var starter := [
		[GEM_ACTIVE, "chain_spark"],
		[GEM_ACTIVE, "blood_cleave"],
		[GEM_ACTIVE, "ember_mine"],
		[GEM_ACTIVE, "bone_spear"],
		[GEM_SUPPORT, "controlled_power"],
		[GEM_SUPPORT, "split_projectile"],
		[GEM_SUPPORT, "chain_current"],
		[GEM_SUPPORT, "ignition"],
		[GEM_SUPPORT, "bleed_edge"],
		[GEM_SUPPORT, "echoing_ritual"],
		[GEM_SUPPORT, "blood_price"],
		[GEM_SPIRIT, "clarity"],
		[GEM_SPIRIT, "ember_pact"],
		[GEM_SPIRIT, "storm_rhythm"]
	]
	for spec in starter:
		backpack.append(make_gem_item(str(spec[0]), str(spec[1])))
	state.set("backpack", backpack)
	state.set("gem_progression_seeded", true)

static func active_instance(id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	return normalize_active({"kind": GEM_ACTIVE, "gem_id": id, "active": id, "active_id": id, "level": level, "xp": xp, "quality": quality, "supports": supports})

static func normalize_active(slot: Dictionary) -> Dictionary:
	var id: String = str(slot.get("gem_id", slot.get("active", slot.get("active_id", "fireball"))))
	if not ACTIVE_DATA.has(id):
		id = "fireball"

	var level: int = maxi(1, _to_int(slot.get("level", slot.get("gem_level", 1))))
	var xp: int = maxi(0, _to_int(slot.get("xp", slot.get("gem_xp", 0))))
	var quality: int = clampi(_to_int(slot.get("quality", slot.get("gem_quality", 0))), 0, 100)

	var supports: Array = []
	for support_value: Variant in _as_array(slot.get("supports", [])):
		supports.append(normalize_support_value(support_value))

	return {
		"kind": GEM_ACTIVE,
		"gem_id": id,
		"active": id,
		"active_id": id,
		"level": level,
		"xp": xp,
		"quality": quality,
		"supports": supports,
		"unlocked_support_sockets": unlocked_support_sockets(level)
	}

static func normalize_support_value(value: Variant) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return normalize_support(Dictionary(value))
	return normalize_support({"gem_id": str(value), "support_id": str(value), "level": 1, "xp": 0, "quality": 0})

static func normalize_support(support: Dictionary) -> Dictionary:
	var id := gem_id(support)
	if not SUPPORT_DATA.has(id):
		id = "controlled_power"
	return {
		"kind": GEM_SUPPORT,
		"gem_id": id,
		"support_id": id,
		"level": max(1, _to_int(support.get("level", support.get("gem_level", 1)))),
		"xp": max(0, _to_int(support.get("xp", support.get("gem_xp", 0)))),
		"quality": clampi(_to_int(support.get("quality", support.get("gem_quality", 0))), 0, 100)
	}

static func normalize_spirit(spirit: Dictionary) -> Dictionary:
	var id: String = str(spirit.get("gem_id", spirit.get("spirit_id", "clarity")))
	if not SPIRIT_DATA.has(id):
		id = "clarity"

	var supports: Array = []
	for support_value: Variant in _as_array(spirit.get("supports", [])):
		supports.append(normalize_support_value(support_value))

	var level: int = maxi(1, _to_int(spirit.get("level", spirit.get("gem_level", 1))))
	var xp: int = maxi(0, _to_int(spirit.get("xp", spirit.get("gem_xp", 0))))
	var quality: int = clampi(_to_int(spirit.get("quality", spirit.get("gem_quality", 0))), 0, 100)

	return {
		"kind": GEM_SPIRIT,
		"gem_id": id,
		"spirit_id": id,
		"enabled": bool(spirit.get("enabled", false)),
		"level": level,
		"xp": xp,
		"quality": quality,
		"supports": supports,
		"unlocked_support_sockets": unlocked_support_sockets(level)
	}

static func selected_cast_data(state: Object) -> Dictionary:
	if state == null:
		return {}
	ensure_defaults(state)
	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	if slots.is_empty():
		return {}
	var index := clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, slots.size() - 1)
	var active := normalize_active(Dictionary(slots[index]))
	return build_cast_data(state, active, index)

static func build_cast_data(state: Object, active: Dictionary, selected_slot: int = 0) -> Dictionary:
	var id := str(active.get("gem_id", "fireball"))
	var data := active_data(id)
	var tags: Array = _as_array(data.get("tags", [])).duplicate(true)
	var level: int = maxi(1, _to_int(active.get("level", 1)))
	var quality: int = clampi(_to_int(active.get("quality", 0)), 0, 100)
	var damage := float(data.get("damage", 10.0)) * (1.0 + float(level - 1) * 0.13) * (1.0 + float(quality) * 0.01)
	var mana_cost := float(data.get("mana", 8.0)) * (1.0 + float(level - 1) * 0.035)
	var cooldown := float(data.get("cooldown", 0.25))
	var area_mult := 1.0
	var extra_projectiles := 0
	var spread := 0.0
	var pierce := _to_int(data.get("pierce", 0))
	var chain := _to_int(data.get("chain", 0))
	var echo_count := 0
	var extra_mines := 0
	var extra_pulses := _to_int(data.get("pulses", 1)) - 1
	var ignite_chance := 0.0
	var shock_chance := 0.0
	var bleed_chance := 0.0
	var execute_more := 0.0
	var life_leech := 0.0
	var mana_leech := 0.0
	var blood_price := 0.0
	var on_hit_burst := false
	var support_names: Array = []
	var applied_supports: Array = []
	for support in _as_array(active.get("supports", [])):
		var s := normalize_support_value(support)
		if not is_support_compatible(active, s):
			continue
		var sid := str(s.get("gem_id", ""))
		var sdata := support_data(sid)
		var slevel: int = maxi(1, _to_int(s.get("level", 1)))
		var squality: int = clampi(_to_int(s.get("quality", 0)), 0, 100)
		var support_scale: float = 1.0 + float(slevel - 1) * 0.035 + float(squality) * 0.006
		damage *= max(0.05, 1.0 + float(sdata.get("damage_more", 0.0)) * support_scale)
		mana_cost *= max(0.05, 1.0 + float(sdata.get("mana_more", 0.0)) * support_scale)
		cooldown *= max(0.05, 1.0 + float(sdata.get("cooldown_more", 0.0)) * support_scale)
		area_mult *= max(0.20, 1.0 + float(sdata.get("area_more", 0.0)) * support_scale)
		extra_projectiles += _to_int(sdata.get("extra_projectiles", 0))
		spread = max(spread, float(sdata.get("spread", 0.0)))
		pierce += _to_int(sdata.get("pierce", 0))
		chain += _to_int(sdata.get("chain", 0))
		echo_count += _to_int(sdata.get("echo_count", 0))
		extra_mines += _to_int(sdata.get("extra_mines", 0))
		extra_pulses += _to_int(sdata.get("extra_pulses", 0))
		ignite_chance += float(sdata.get("ignite_chance", 0.0)) * support_scale
		shock_chance += float(sdata.get("shock_chance", 0.0)) * support_scale
		bleed_chance += float(sdata.get("bleed_chance", 0.0)) * support_scale
		execute_more += float(sdata.get("execute_more", 0.0)) * support_scale
		life_leech += float(sdata.get("life_leech", 0.0)) * support_scale
		mana_leech += float(sdata.get("mana_leech", 0.0)) * support_scale
		blood_price = max(blood_price, float(sdata.get("blood_price", 0.0)))
		on_hit_burst = on_hit_burst or _to_int(sdata.get("on_hit_burst", 0)) > 0
		support_names.append(str(sdata.get("name", sid.capitalize())))
		applied_supports.append(sid)
	var stat_mult := _build_stat_damage_multiplier(state, tags)
	damage *= stat_mult
	var spirit_stats := spirit_total_stats(state)
	if tags.has("fire"):
		damage *= 1.0 + float(spirit_stats.get("fire_damage", 0)) * 0.01
		ignite_chance += float(spirit_stats.get("ignite_chance", 0)) * 0.01
	if tags.has("lightning"):
		damage *= 1.0 + float(spirit_stats.get("lightning_damage", 0)) * 0.01
		chain += _to_int(spirit_stats.get("chain_bonus", 0))
	if tags.has("void"):
		damage *= 1.0 + float(spirit_stats.get("void_damage", 0)) * 0.01
		mana_cost *= 1.0 + float(spirit_stats.get("mana_cost", 0)) * 0.01
	if tags.has("attack"):
		damage *= 1.0 + _stat_percent(state, "attack_damage")
	if tags.has("spell"):
		damage *= 1.0 + _stat_percent(state, "spell_damage")
	if tags.has("projectile"):
		damage *= 1.0 + _stat_percent(state, "projectile_damage")
	mana_cost = max(0.0, mana_cost)
	var life_cost := 0.0
	if blood_price > 0.0:
		life_cost = mana_cost * blood_price
		mana_cost = mana_cost * (1.0 - blood_price)
	return {
		"name": str(data.get("name", id.capitalize())),
		"active_id": id,
		"selected_slot": selected_slot,
		"level": level,
		"quality": quality,
		"tags": tags,
		"damage": damage,
		"mana_cost": mana_cost,
		"life_cost": life_cost,
		"cooldown": cooldown,
		"range": float(data.get("range", 8.0)),
		"radius": float(data.get("radius", 0.4)),
		"base_area": float(data.get("area", 1.0)),
		"area_mult": area_mult,
		"projectile_speed": float(data.get("projectile_speed", 13.0)),
		"extra_projectiles": extra_projectiles,
		"projectile_count": 1 + extra_projectiles,
		"spread": spread,
		"pierce": pierce,
		"chain": chain,
		"echo_count": echo_count,
		"extra_mines": extra_mines,
		"extra_pulses": extra_pulses,
		"rules": {
			"ignite_chance": clampf(ignite_chance, 0.0, 1.0),
			"shock_chance": clampf(shock_chance, 0.0, 1.0),
			"bleed_chance": clampf(bleed_chance, 0.0, 1.0),
			"execute_more": max(0.0, execute_more),
			"life_leech": max(0.0, life_leech),
			"mana_leech": max(0.0, mana_leech),
			"on_hit_burst": on_hit_burst,
			"applied_supports": applied_supports
		},
		"support_names": support_names
	}

static func cycle_active_slot_gem(state: Object, dir: int) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	var index := clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, max(0, slots.size() - 1))
	var current := normalize_active(Dictionary(slots[index]))
	var id := str(current.get("gem_id", "fireball"))
	var order_index := ACTIVE_ORDER.find(id)
	if order_index < 0:
		order_index = 0
	var next_id := str(ACTIVE_ORDER[wrapi(order_index + dir, 0, ACTIVE_ORDER.size())])
	current["gem_id"] = next_id
	current["active"] = next_id
	current["active_id"] = next_id
	current["supports"] = _filter_compatible_supports(current, _as_array(current.get("supports", [])))
	slots[index] = normalize_active(current)
	state.set("active_skill_slots", slots)
	_add_notice(state, "Active slot " + str(index + 1) + ": " + str(active_data(next_id).get("name", next_id)))

static func add_next_valid_support(state: Object) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	if slots.is_empty():
		return
	var index := clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, slots.size() - 1)
	var active := normalize_active(Dictionary(slots[index]))
	var supports: Array = _as_array(active.get("supports", []))
	var limit := unlocked_support_sockets(_to_int(active.get("level", 1)))
	if supports.size() >= limit:
		_add_notice(state, "No unlocked support socket. Level the gem for more sockets.")
		return
	for support_id in SUPPORT_ORDER:
		var candidate := normalize_support({"gem_id": str(support_id)})
		if _support_list_has(supports, str(support_id)):
			continue
		if is_support_compatible(active, candidate):
			supports.append(candidate)
			active["supports"] = supports
			slots[index] = active
			state.set("active_skill_slots", slots)
			_add_notice(state, "Socketed " + str(support_data(str(support_id)).get("name", support_id)) + " into " + active_display_name(active) + ".")
			return
	_add_notice(state, "No compatible support found for " + active_display_name(active) + ".")

static func remove_last_support(state: Object) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	var index := clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, max(0, slots.size() - 1))
	var active := normalize_active(Dictionary(slots[index]))
	var supports: Array = _as_array(active.get("supports", []))
	if supports.is_empty():
		_add_notice(state, "No support to remove.")
		return
	var removed := normalize_support_value(supports.pop_back())
	active["supports"] = supports
	slots[index] = active
	state.set("active_skill_slots", slots)
	_add_notice(state, "Removed " + support_display_name(removed) + ".")

static func toggle_next_spirit(state: Object) -> void:
	if state == null:
		return
	ensure_defaults(state)
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if spirits.is_empty():
		for id in ["clarity", "vitality", "ember_pact"]:
			spirits.append(normalize_spirit({"gem_id": str(id), "enabled": false}))
	var cursor := _to_int(_state_get(state, "spirit_cursor", 0))
	cursor = wrapi(cursor, 0, spirits.size())
	var spirit := normalize_spirit(Dictionary(spirits[cursor]))
	spirit["enabled"] = not bool(spirit.get("enabled", false))
	spirits[cursor] = spirit
	state.set("spirit_gem_slots", spirits)
	state.set("spirit_cursor", wrapi(cursor + 1, 0, spirits.size()))
	recompute_spirit_reservation(state)
	_add_notice(state, ("Enabled " if bool(spirit.get("enabled", false)) else "Disabled ") + spirit_display_name(spirit) + ".")

static func panel_text(state: Object) -> String:
	ensure_defaults(state)
	var lines := PackedStringArray()
	lines.append("SKILL GEMS")
	lines.append("1-4 select slot · A/D change active · S add compatible support · W remove support · G toggle spirit")
	lines.append("Support sockets unlock at gem levels 1, 5, 9, 13, 17. Current rule: supports must match skill tags.")
	lines.append("")
	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	var selected := clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, max(0, slots.size() - 1))
	for i in range(slots.size()):
		var active := normalize_active(Dictionary(slots[i]))
		var cast := build_cast_data(state, active, i)
		var marker := "> " if i == selected else "  "
		var supports := _as_array(active.get("supports", []))
		var socket_text := str(supports.size()) + "/" + str(unlocked_support_sockets(_to_int(active.get("level", 1))))
		lines.append(marker + str(i + 1) + ". " + active_display_name(active) + " Lv" + str(active.get("level", 1)) + "  Sockets " + socket_text + "  Cost " + str(int(round(float(cast.get("mana_cost", 0.0))))) + "  Damage " + str(int(round(float(cast.get("damage", 0.0))))))
		if supports.is_empty():
			lines.append("     Supports: —")
		else:
			var support_labels := PackedStringArray()
			for s in supports:
				var ns := normalize_support_value(s)
				var compatible := is_support_compatible(active, ns)
				support_labels.append(support_display_name(ns) + ("" if compatible else " [inactive]"))
			lines.append("     Supports: " + ", ".join(support_labels))
	lines.append("")
	lines.append("SPIRIT GEMS  Reserved: " + str(_to_int(_state_get(state, "spirit_reserved", 0))) + "/" + str(_to_int(_state_get(state, "spirit_max", 100))))
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if spirits.is_empty():
		lines.append("  No spirit gems installed. Press G to seed/toggle starter spirits.")
	else:
		for spirit_value in spirits:
			var spirit := normalize_spirit(Dictionary(spirit_value))
			var status := "ON" if bool(spirit.get("enabled", false)) else "off"
			var sdata := spirit_data(str(spirit.get("gem_id", "clarity")))
			lines.append("  " + status + " · " + spirit_display_name(spirit) + " · reserves " + str(_reservation_for_spirit(spirit)) + " · " + str(sdata.get("description", "")))
	var selected_cast := selected_cast_data(state)
	lines.append("")
	lines.append("SELECTED BREAKDOWN")
	lines.append(str(selected_cast.get("name", "Skill")) + " · Tags: " + ", ".join(_as_string_array(selected_cast.get("tags", []))))
	lines.append("Damage " + str(int(round(float(selected_cast.get("damage", 0.0))))) + " · Mana " + str(int(round(float(selected_cast.get("mana_cost", 0.0))))) + " · Life " + str(int(round(float(selected_cast.get("life_cost", 0.0))))) + " · Cooldown " + str(snappedf(float(selected_cast.get("cooldown", 0.0)), 0.01)))
	var rules: Dictionary = Dictionary(selected_cast.get("rules", {}))
	lines.append("Rules: ignite " + str(int(round(float(rules.get("ignite_chance", 0.0)) * 100.0))) + "% · shock " + str(int(round(float(rules.get("shock_chance", 0.0)) * 100.0))) + "% · bleed " + str(int(round(float(rules.get("bleed_chance", 0.0)) * 100.0))) + "% · chain " + str(selected_cast.get("chain", 0)) + " · pierce " + str(selected_cast.get("pierce", 0)))
	return "\n".join(lines)

static func is_support_compatible(active: Dictionary, support: Dictionary) -> bool:
	var active_id := str(active.get("gem_id", active.get("active_id", "")))
	var adata := active_data(active_id)
	var active_tags := _as_array(adata.get("tags", []))
	var sid := str(support.get("gem_id", support.get("support_id", "")))
	if not SUPPORT_DATA.has(sid):
		return false
	var sdata := support_data(sid)
	var requires_any := _as_array(sdata.get("requires_any", []))
	if requires_any.is_empty():
		return true
	for tag in requires_any:
		if active_tags.has(str(tag)):
			return true
	return false

static func award_selected_active_xp(state: Object, amount: int) -> void:
	if state == null:
		return

	ensure_defaults(state)

	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	if slots.is_empty():
		return

	var index: int = clampi(_to_int(_state_get(state, "selected_skill_slot", 0)), 0, slots.size() - 1)
	var active: Dictionary = normalize_active(Dictionary(slots[index]))

	var level: int = _to_int(active.get("level", 1))
	var gained_xp: int = maxi(0, amount)
	var xp: int = _to_int(active.get("xp", 0)) + gained_xp

	var old_sockets: int = unlocked_support_sockets(level)
	var leveled: bool = false

	while xp >= xp_to_next(level):
		var required_xp: int = xp_to_next(level)
		xp -= required_xp
		level += 1
		leveled = true

	active["level"] = level
	active["xp"] = xp
	active["unlocked_support_sockets"] = unlocked_support_sockets(level)

	slots[index] = active
	state.set("active_skill_slots", slots)

	if leveled:
		var msg: String = active_display_name(active) + " reached level " + str(level) + "."
		if unlocked_support_sockets(level) > old_sockets:
			msg += " New support socket unlocked."
		_add_notice(state, msg)

static func roll_gem_drop_to_backpack(state: Object, force: bool = false) -> bool:
	if state == null:
		return false
	var rng: RandomNumberGenerator = _rng(state)
	if not force and rng.randf() > 0.18:
		return false
	var roll := rng.randf()
	var type := GEM_SUPPORT
	var id := "controlled_power"
	if roll < 0.25:
		type = GEM_ACTIVE
		id = str(ACTIVE_ORDER[rng.randi_range(0, ACTIVE_ORDER.size() - 1)])
	elif roll < 0.84:
		type = GEM_SUPPORT
		id = str(SUPPORT_ORDER[rng.randi_range(0, SUPPORT_ORDER.size() - 1)])
	else:
		type = GEM_SPIRIT
		id = str(SPIRIT_ORDER[rng.randi_range(0, SPIRIT_ORDER.size() - 1)])
	var quality := 0
	if rng.randf() < 0.22:
		quality = rng.randi_range(5, 18)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	backpack.append(make_gem_item(type, id, 1, 0, quality))
	state.set("backpack", backpack)
	_add_notice(state, "Gem found: " + str(gem_data(type, id).get("name", id)))
	return true

static func make_gem_item(type: String, id: String, level: int = 1, xp: int = 0, quality: int = 0, supports: Array = []) -> Dictionary:
	var data := gem_data(type, id)
	var kind := type + "_gem"
	return {
		"id": "gem_" + id + "_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 99999),
		"base_id": id,
		"gem_id": id,
		"name": str(data.get("name", id.capitalize())),
		"display_name": str(data.get("name", id.capitalize())),
		"kind": kind,
		"item_kind": kind,
		"category": "skill_gem",
		"slot": kind,
		"rarity": "magic",
		"gem_type": type,
		"skill_gem_type": type,
		"base_color": str(data.get("color", "blue")),
		"gem_color": str(data.get("color", "blue")),
		"carved": true,
		"level": max(1, level),
		"gem_level": max(1, level),
		"xp": max(0, xp),
		"gem_xp": max(0, xp),
		"quality": clampi(quality, 0, 100),
		"gem_quality": clampi(quality, 0, 100),
		"supports": supports.duplicate(true),
		"tags": ["gem", kind, type],
		"grid_w": 1,
		"grid_h": 1,
		"detail_text": gem_detail_text({"gem_type": type, "gem_id": id, "level": level, "xp": xp, "quality": quality, "supports": supports})
	}

static func make_gem_item_from_drop(drop_kind: String, gem_id_value: String) -> Dictionary:
	var type := GEM_SUPPORT
	match drop_kind:
		"active_gem": type = GEM_ACTIVE
		"support_gem": type = GEM_SUPPORT
		"spirit_gem": type = GEM_SPIRIT
		_:
			type = str(drop_kind).replace("_gem", "")
	return make_gem_item(type, gem_id_value)


static func install_active_from_inventory(state: Object, backpack_index: int, slot_index: int) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No active gem selected."
	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_ACTIVE:
		return "That is not an active gem."
	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	slot_index = clampi(slot_index, 0, max(0, slots.size() - 1))
	var previous: Dictionary = {}
	if typeof(slots[slot_index]) == TYPE_DICTIONARY:
		previous = normalize_active(Dictionary(slots[slot_index]))
	var incoming := active_instance(gem_id(item), _to_int(item.get("level", item.get("gem_level", 1))), _to_int(item.get("xp", item.get("gem_xp", 0))), _to_int(item.get("quality", item.get("gem_quality", 0))), _as_array(item.get("supports", [])))
	backpack.remove_at(backpack_index)
	if not previous.is_empty():
		backpack.append(make_gem_item(GEM_ACTIVE, str(previous.get("gem_id", "fireball")), _to_int(previous.get("level", 1)), _to_int(previous.get("xp", 0)), _to_int(previous.get("quality", 0)), _as_array(previous.get("supports", []))))
	slots[slot_index] = incoming
	state.set("active_skill_slots", slots)
	state.set("backpack", backpack)
	state.set("selected_skill_slot", slot_index)
	return "Installed active gem into slot " + str(slot_index + 1) + "."

static func install_support_from_inventory_to_active(state: Object, backpack_index: int, active_index: int) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No support gem selected."
	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_SUPPORT:
		return "That is not a support gem."
	var slots: Array = _as_array(_state_get(state, "active_skill_slots", []))
	if active_index < 0 or active_index >= slots.size() or typeof(slots[active_index]) != TYPE_DICTIONARY:
		return "No active target."
	var active := normalize_active(Dictionary(slots[active_index]))
	var support := normalize_support({"gem_id": gem_id(item), "level": _to_int(item.get("level", item.get("gem_level", 1))), "xp": _to_int(item.get("xp", item.get("gem_xp", 0))), "quality": _to_int(item.get("quality", item.get("gem_quality", 0)))})
	if not is_support_compatible(active, support):
		return "Support tags do not match " + active_display_name(active) + "."
	var supports: Array = _as_array(active.get("supports", []))
	if supports.size() >= unlocked_support_sockets(_to_int(active.get("level", 1))):
		return "No unlocked support socket."
	if _support_list_has(supports, str(support.get("gem_id", ""))):
		return "That support is already socketed."
	supports.append(support)
	active["supports"] = supports
	slots[active_index] = active
	backpack.remove_at(backpack_index)
	state.set("active_skill_slots", slots)
	state.set("backpack", backpack)
	state.set("selected_skill_slot", active_index)
	return "Socketed " + support_display_name(support) + " into " + active_display_name(active) + "."

static func install_spirit_from_inventory(state: Object, backpack_index: int) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No spirit gem selected."
	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_SPIRIT:
		return "That is not a spirit gem."
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	var spirit := normalize_spirit({"gem_id": gem_id(item), "enabled": false, "level": _to_int(item.get("level", item.get("gem_level", 1))), "xp": _to_int(item.get("xp", item.get("gem_xp", 0))), "quality": _to_int(item.get("quality", item.get("gem_quality", 0))), "supports": _as_array(item.get("supports", []))})
	spirits.append(spirit)
	backpack.remove_at(backpack_index)
	state.set("spirit_gem_slots", spirits)
	state.set("backpack", backpack)
	recompute_spirit_reservation(state)
	return "Installed spirit gem disabled."

static func install_support_from_inventory_to_spirit(state: Object, backpack_index: int, spirit_index: int) -> String:
	if state == null:
		return "No state."
	ensure_defaults(state)
	var backpack: Array = _as_array(_state_get(state, "backpack", []))
	if backpack_index < 0 or backpack_index >= backpack.size() or typeof(backpack[backpack_index]) != TYPE_DICTIONARY:
		return "No support gem selected."
	var item: Dictionary = Dictionary(backpack[backpack_index])
	if gem_type(item) != GEM_SUPPORT:
		return "That is not a support gem."
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	if spirit_index < 0 or spirit_index >= spirits.size() or typeof(spirits[spirit_index]) != TYPE_DICTIONARY:
		return "No spirit target."
	var spirit := normalize_spirit(Dictionary(spirits[spirit_index]))
	var supports: Array = _as_array(spirit.get("supports", []))
	if supports.size() >= unlocked_support_sockets(_to_int(spirit.get("level", 1))):
		return "No unlocked support socket."
	var support := normalize_support({"gem_id": gem_id(item), "level": _to_int(item.get("level", item.get("gem_level", 1))), "xp": _to_int(item.get("xp", item.get("gem_xp", 0))), "quality": _to_int(item.get("quality", item.get("gem_quality", 0)))})
	if _support_list_has(supports, str(support.get("gem_id", ""))):
		return "That support is already socketed."
	supports.append(support)
	spirit["supports"] = supports
	spirits[spirit_index] = spirit
	backpack.remove_at(backpack_index)
	state.set("spirit_gem_slots", spirits)
	state.set("backpack", backpack)
	recompute_spirit_reservation(state)
	return "Socketed " + support_display_name(support) + " into " + spirit_display_name(spirit) + "."

static func gem_type(item: Dictionary) -> String:
	var explicit := str(item.get("gem_type", item.get("skill_gem_type", ""))).to_lower()
	if explicit in [GEM_ACTIVE, GEM_SUPPORT, GEM_SPIRIT]:
		return explicit
	var kind := str(item.get("kind", item.get("item_kind", item.get("category", "")))).to_lower()
	if kind == "active_gem" or kind == "active_skill_gem":
		return GEM_ACTIVE
	if kind == "support_gem":
		return GEM_SUPPORT
	if kind == "spirit_gem":
		return GEM_SPIRIT
	return ""

static func gem_id(d: Dictionary) -> String:
	for key in ["gem_id", "active_id", "support_id", "spirit_id", "base_id", "id"]:
		var value := str(d.get(str(key), ""))
		if value != "":
			if value.begins_with("gem_") and d.has("base_id"):
				return str(d.get("base_id", value))
			return value
	return str(d.get("name", "unknown_gem")).to_lower().replace(" ", "_")

static func gem_data(type: String, id: String) -> Dictionary:
	match type:
		GEM_ACTIVE:
			return active_data(id)
		GEM_SUPPORT:
			return support_data(id)
		GEM_SPIRIT:
			return spirit_data(id)
		_:
			return {"name": id.capitalize(), "color": "blue", "tags": []}

static func active_data(id: String) -> Dictionary:
	return Dictionary(ACTIVE_DATA.get(id, {"name": id.capitalize(), "color": "red", "tags": ["skill"], "damage": 10.0, "mana": 5.0, "cooldown": 0.25}))

static func support_data(id: String) -> Dictionary:
	return Dictionary(SUPPORT_DATA.get(id, {"name": id.capitalize() + " Support", "color": "green", "requires_any": ["skill"], "description": "Generic support."}))

static func spirit_data(id: String) -> Dictionary:
	return Dictionary(SPIRIT_DATA.get(id, {"name": id.capitalize(), "color": "blue", "reservation": 25, "description": "Spirit reservation.", "stats": {}}))

static func gem_detail_text(d: Dictionary, assumed_type: String = "") -> String:
	var type: String = assumed_type if assumed_type != "" else gem_type(d)
	if type == "":
		type = str(d.get("gem_type", GEM_SUPPORT))

	var id: String = gem_id(d)
	var data: Dictionary = gem_data(type, id)

	var level: int = maxi(1, _to_int(d.get("level", d.get("gem_level", 1))))
	var xp: int = maxi(0, _to_int(d.get("xp", d.get("gem_xp", 0))))
	var quality: int = clampi(_to_int(d.get("quality", d.get("gem_quality", 0))), 0, 100)

	var lines: PackedStringArray = PackedStringArray()

	lines.append(str(data.get("name", id.capitalize())) + " [" + type.capitalize() + " Gem]")
	lines.append("Level " + str(level) + " · XP " + str(xp) + "/" + str(xp_to_next(level)) + " · Quality +" + str(quality) + "%")

	if type == GEM_ACTIVE:
		lines.append("Tags: " + ", ".join(_as_string_array(data.get("tags", []))))
		lines.append(str(data.get("description", "")))
		lines.append("Support sockets: " + str(unlocked_support_sockets(level)) + "/" + str(MAX_SUPPORT_SOCKETS))
	elif type == GEM_SUPPORT:
		lines.append("Requires: " + ", ".join(_as_string_array(data.get("requires_any", []))))
		lines.append(str(data.get("description", "")))
	else:
		lines.append("Reserves " + str(_to_int(data.get("reservation", 25))) + " Spirit")
		lines.append(str(data.get("description", "")))

	return "\n".join(lines)


static func collect_spirit_bundle(state: Object) -> Dictionary:
	if state == null:
		return {"stats": {}, "rules": [], "reserved": 0}
	ensure_defaults(state)
	var raw_stats := spirit_total_stats(state)
	var stats := {}
	var rules: Array = []
	for key in raw_stats.keys():
		var k := str(key)
		var v := float(raw_stats[key])
		stats[k] = v
		match k:
			"max_health":
				stats["Maximum Life"] = float(stats.get("Maximum Life", 0.0)) + v
			"max_mana":
				stats["Maximum Mana"] = float(stats.get("Maximum Mana", 0.0)) + v
			"spirit", "spirit_max":
				stats["Maximum Spirit"] = float(stats.get("Maximum Spirit", 0.0)) + v
			"armor":
				stats["Armor"] = float(stats.get("Armor", 0.0)) + v
			"movement_speed":
				stats["Movement Speed"] = float(stats.get("Movement Speed", 0.0)) + v * 0.01
			"fire_damage":
				stats["Fire Damage"] = float(stats.get("Fire Damage", 0.0)) + v
			"lightning_damage":
				stats["Lightning Damage"] = float(stats.get("Lightning Damage", 0.0)) + v
			"void_damage":
				stats["Void Damage"] = float(stats.get("Void Damage", 0.0)) + v
			"spell_damage":
				stats["Spell Damage"] = float(stats.get("Spell Damage", 0.0)) + v
			"attack_damage":
				stats["Attack Damage"] = float(stats.get("Attack Damage", 0.0)) + v
			_:
				pass
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for value in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit := normalize_spirit(Dictionary(value))
		if bool(spirit.get("enabled", false)):
			rules.append("spirit:" + str(spirit.get("gem_id", "")))
	return {"stats": stats, "rules": rules, "reserved": _to_int(_state_get(state, "spirit_reserved", 0))}

static func spirit_total_stats(state: Object) -> Dictionary:
	var out := {}
	if state == null:
		return out
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for value in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit := normalize_spirit(Dictionary(value))
		if not bool(spirit.get("enabled", false)):
			continue
		var stats := Dictionary(spirit_data(str(spirit.get("gem_id", ""))).get("stats", {}))
		var level_scale := 1.0 + float(_to_int(spirit.get("level", 1)) - 1) * 0.05 + float(_to_int(spirit.get("quality", 0))) * 0.006
		for key in stats.keys():
			out[key] = float(out.get(key, 0.0)) + float(stats[key]) * level_scale
	return out

static func recompute_spirit_reservation(state: Object) -> void:
	if state == null:
		return
	var total := 0
	var spirits: Array = _as_array(_state_get(state, "spirit_gem_slots", []))
	for value in spirits:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var spirit := normalize_spirit(Dictionary(value))
		if bool(spirit.get("enabled", false)):
			total += _reservation_for_spirit(spirit)
	state.set("spirit_reserved", total)

static func _reservation_for_spirit(spirit: Dictionary) -> int:
	var data: Dictionary = spirit_data(str(spirit.get("gem_id", "clarity")))
	var base: int = _to_int(data.get("reservation", 25))
	var quality: int = clampi(_to_int(spirit.get("quality", 0)), 0, 100)
	var support_count: int = _as_array(spirit.get("supports", [])).size()

	var quality_multiplier: float = maxf(0.70, 1.0 - float(quality) * 0.004)
	var reservation_value: float = float(base) * (1.0 + float(support_count) * 0.15) * quality_multiplier

	return int(ceil(reservation_value))

static func xp_to_next(level: int) -> int:
	return max(80, 85 + level * 95 + int(pow(float(level), 1.35) * 18.0))

static func unlocked_support_sockets(level: int) -> int:
	return clampi(STARTING_SUPPORT_SOCKETS + int(floor(float(max(1, level) - 1) / float(SOCKET_INTERVAL))), STARTING_SUPPORT_SOCKETS, MAX_SUPPORT_SOCKETS)

static func active_display_name(active: Dictionary) -> String:
	var id := str(active.get("gem_id", active.get("active_id", "fireball")))
	return str(active_data(id).get("name", id.capitalize()))

static func support_display_name(support: Dictionary) -> String:
	var id := str(support.get("gem_id", support.get("support_id", "controlled_power")))
	return str(support_data(id).get("name", id.capitalize()))

static func spirit_display_name(spirit: Dictionary) -> String:
	var id := str(spirit.get("gem_id", spirit.get("spirit_id", "clarity")))
	return str(spirit_data(id).get("name", id.capitalize()))

static func _filter_compatible_supports(active: Dictionary, supports: Array) -> Array:
	var out: Array = []
	for support in supports:
		var s := normalize_support_value(support)
		if is_support_compatible(active, s) and not _support_list_has(out, str(s.get("gem_id", ""))):
			out.append(s)
	return out

static func _support_list_has(supports: Array, id: String) -> bool:
	for support in supports:
		if str(normalize_support_value(support).get("gem_id", "")) == id:
			return true
	return false

static func _build_stat_damage_multiplier(state: Object, tags: Array) -> float:
	var mult := 1.0
	if tags.has("fire"):
		mult *= 1.0 + _stat_percent(state, "fire_damage")
	if tags.has("lightning"):
		mult *= 1.0 + _stat_percent(state, "lightning_damage")
	if tags.has("void"):
		mult *= 1.0 + _stat_percent(state, "void_damage")
	if tags.has("physical"):
		mult *= 1.0 + _stat_percent(state, "physical_damage")
	return mult

static func _stat_percent(state: Object, key: String) -> float:
	if state == null:
		return 0.0
	var build_stats := Dictionary(_state_get(state, "build_stats", {}))
	var combined := _to_float(_state_get(state, key, 0.0))
	combined += _to_float(build_stats.get(key, 0.0))
	combined += _to_float(build_stats.get(_title_stat_key(key), 0.0))
	return combined * 0.01

static func _title_stat_key(key: String) -> String:
	var words := str(key).replace("-", "_").split("_")
	var out := PackedStringArray()
	for word in words:
		if str(word) == "":
			continue
		out.append(str(word).substr(0, 1).to_upper() + str(word).substr(1).to_lower())
	return " ".join(out)

static func _add_notice(state: Object, text: String) -> void:
	if state != null and state.has_method("add_notice"):
		state.call("add_notice", text)

static func _rng(state: Object) -> RandomNumberGenerator:
	if state != null:
		var value: Variant = state.get("rng")
		if value is RandomNumberGenerator:
			return value as RandomNumberGenerator
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng

static func _state_get(state: Object, key: String, fallback: Variant = null) -> Variant:
	if state == null:
		return fallback
	var value: Variant = state.get(key)
	return fallback if value == null else value

static func _as_array(value: Variant) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return Array(value)
	return []

static func _as_string_array(value: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	for v in _as_array(value):
		out.append(str(v))
	return out

static func _to_int(value: Variant, fallback: int = 0) -> int:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_INT:
			return int(value)
		TYPE_FLOAT:
			return int(round(float(value)))
		TYPE_BOOL:
			return 1 if bool(value) else 0
		TYPE_STRING:
			var s := str(value)
			if s.is_valid_int():
				return s.to_int()
			if s.is_valid_float():
				return int(round(s.to_float()))
			return fallback
		_:
			return fallback

static func _to_float(value: Variant, fallback: float = 0.0) -> float:
	if value == null:
		return fallback
	match typeof(value):
		TYPE_FLOAT:
			return float(value)
		TYPE_INT:
			return float(value)
		TYPE_BOOL:
			return 1.0 if bool(value) else 0.0
		TYPE_STRING:
			var s := str(value)
			return s.to_float() if s.is_valid_float() else fallback
		_:
			return fallback
